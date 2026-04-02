using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web;
using System.Text.RegularExpressions;

namespace PRSwebapp
{
    public partial class EmpClaim : Page
    {
        private readonly string connectionString =
            ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

        string UdeptId = "";
        string prsRole = "";
        string hospitalId = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"].ToString() == null || Session["UserID"].ToString() == "")
            {
                Response.Redirect("Login.aspx");
               
            }

            if (!IsPostBack)
            {
                hfExpenseData.Value = "";
                hfConveyanceData.Value = "";
                Session["CurrentPRSNo"] = null;   // Make sure fresh PRS starts



                // --- Fetch Department & PRS Role from Login_role table ---

                /*
                using (SqlConnection con = new SqlConnection(connectionString))
                {

                    string query = "SELECT Deptid, PRS_Role, HospitalID FROM Login_role WHERE UserID = @UserID And HospitalID=@HospitalID";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@UserID", Session["UserID"].ToString());
                        cmd.Parameters.AddWithValue("@HospitalID", Session["HospitalID"].ToString());

                        con.Open();

                        SqlDataReader reader = cmd.ExecuteReader();
                        if (reader.Read())
                        {
                            UdeptId = reader["Deptid"].ToString();
                            prsRole = reader["PRS_Role"].ToString();
                            hospitalId = reader["HospitalID"].ToString();
                        }
                        con.Close();
                    }
                }
                */
                decimal totalAdvance = 0;

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string query = @"
        SELECT 
        ISNULL(SUM(pm.Inoviceamount),0) 
        - 
        ISNULL((
            SELECT SUM(al.AdjustedAmount) 
            FROM AdvanceLedger al 
            WHERE al.EmpCode = @EmpCode
        ),0) 
        AS RemainingAdvance
        FROM PRSMaster pm
        WHERE pm.Emp_Code = @EmpCode
        AND pm.PRSType = 5";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@EmpCode", Session["UserID"].ToString());
                        con.Open();
                        totalAdvance = Convert.ToDecimal(cmd.ExecuteScalar());
                        con.Close();
                    }
                }

                // Register a startup script to update the span
                string script = $@"
    document.getElementById('totalAdvanceBlink').innerText = '{totalAdvance:F2}';
    document.getElementById('advanceTaken').value = '{totalAdvance:F2}';
    updateExpenseTotal();
";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "SetTotalAdvance", script, true);


                // --- Set button visibility based on PRS role ---
                if (Session["Role"].ToString() == "1" || Session["Role"].ToString() == "2" || Session["Role"].ToString() == "51" || Session["Role"].ToString() == "52")
                {
                    // Allow creation
                    btnSaveExpense.Visible = true;
                    btnSaveAdvance.Visible = true;
                    btnSaveLocal.Visible = true;
                }
                else
                {
                    // Other roles: disable create
                    btnSaveExpense.Visible = false;
                    btnSaveAdvance.Visible = false;
                    btnSaveLocal.Visible = false;

                    string alertscript = "alert('You are not authorized to create PRS, please change the role');" +
                "window.location='dashboard.aspx';";

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alertRedirect", alertscript, true);
                }

            }

        }

        protected void BtnSaveAll_Click(object sender, EventArgs e)
        {
            decimal totalAmount = 0;
            var serializer = new JavaScriptSerializer();

            // ----------------- EXPENSE -----------------
            List<Dictionary<string, string>> expenseRows = new List<Dictionary<string, string>>();
            if (!string.IsNullOrEmpty(hfExpenseData.Value))
            {
                expenseRows = serializer.Deserialize<List<Dictionary<string, string>>>(hfExpenseData.Value);
                expenseRows.RemoveAll(x =>
                    string.IsNullOrWhiteSpace(x["Particulars"]) &&
                    string.IsNullOrWhiteSpace(x["Purpose"]) &&
                    string.IsNullOrWhiteSpace(x["BillNo"]) &&
                    string.IsNullOrWhiteSpace(x["BillDate"]) &&
                    string.IsNullOrWhiteSpace(x["Amount"])
                );

                foreach (var row in expenseRows)
                {
                    decimal.TryParse(row["Amount"], out decimal amt);
                    totalAmount += amt;
                }
            }

            // ----------------- ADVANCE -----------------
            decimal advAmt = 0;
            if (!string.IsNullOrWhiteSpace(txtAdvAmount.Text))
            {
                decimal.TryParse(txtAdvAmount.Text.Trim(), out advAmt);
                totalAmount += advAmt;
            }

            // ----------------- CONVEYANCE -----------------
            List<Dictionary<string, string>> conveyRows = new List<Dictionary<string, string>>();
            if (!string.IsNullOrEmpty(hfConveyanceData.Value))
            {
                conveyRows = serializer.Deserialize<List<Dictionary<string, string>>>(hfConveyanceData.Value);
                conveyRows.RemoveAll(x =>
                    string.IsNullOrWhiteSpace(x["Purpose"]) &&
                    string.IsNullOrWhiteSpace(x["From"]) &&
                    string.IsNullOrWhiteSpace(x["To"]) &&
                    string.IsNullOrWhiteSpace(x["Mode"]) &&
                    string.IsNullOrWhiteSpace(x["Distance"]) &&
                    string.IsNullOrWhiteSpace(x["Amount"])
                );

                foreach (var row in conveyRows)
                {
                    decimal.TryParse(row["Amount"], out decimal amt);
                    totalAmount += amt;
                }
            }

            // Determine PRS Type
            int prsTypeId = 0;
            if (expenseRows.Count > 0) prsTypeId = 7;      // Expense PRS
            else if (advAmt > 0) prsTypeId = 5;            // Advance PRS
            else if (conveyRows.Count > 0) prsTypeId = 6;  // Conveyance PRS

            // ----------------- CREATE PRS NO ONLY ONCE -----------------
            string prsNo = Session["CurrentPRSNo"] as string;
            if (string.IsNullOrEmpty(prsNo))
            {
                prsNo = CreatePRSMaster(prsTypeId, totalAmount);
                Session["CurrentPRSNo"] = prsNo;      // Save PRS for all rows
            }

            // ----------------- SAVE CLAIMS -----------------
            if (expenseRows.Count > 0) SaveExpenseClaims(prsNo, expenseRows);
            SaveAdvanceLedger(prsNo, totalAmount);

            if (advAmt > 0) SaveAdvanceClaim(prsNo);
            if (conveyRows.Count > 0) SaveConveyanceClaims(prsNo, conveyRows);

            // ----------------- SAVE FILES -----------------
            SaveFiles(fuExpenseDocs, prsNo, "Expense Claim");
            SaveFiles(fuAdvanceDocs, prsNo, "Advance");
            SaveFiles(fuLocalDocs, prsNo, "Local Conveyance");

            // Redirect ONLY after saving all rows
            Response.Redirect("/RINGipopupp.aspx?ringi=" + prsNo, false);

            ClearAllForms();
            Session["CurrentPRSNo"] = null;   // Reset for next PRS
            Context.ApplicationInstance.CompleteRequest();
        }
        private void SaveAdvanceLedger(string expensePRSNo, decimal totalExpenseAmount)
        {
            if (string.IsNullOrWhiteSpace(hfSelectedAdvances.Value))
                return;

            var serializer = new JavaScriptSerializer();
            var selectedAdvances = serializer.Deserialize<List<Dictionary<string, object>>>(hfSelectedAdvances.Value);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                decimal remainingExpense = totalExpenseAmount;   // 🔥 Track expense balance

                foreach (var adv in selectedAdvances)
                {
                    if (remainingExpense <= 0)
                        break;   // Expense fully adjusted

                    string advancePRSNo = adv["PRSNo"].ToString();

                    // Get remaining advance for this PRS
                    decimal remainingAdvance = 0;

                    using (SqlCommand cmdRem = new SqlCommand(@"
                SELECT pm.Inoviceamount - ISNULL(SUM(al.AdjustedAmount),0)
                FROM PRSMaster pm
                LEFT JOIN AdvanceLedger al ON pm.PRSNo = al.AdvancePRSNo
                WHERE pm.PRSNo = @PRSNo
                GROUP BY pm.Inoviceamount
            ", con))
                    {
                        cmdRem.Parameters.AddWithValue("@PRSNo", advancePRSNo);
                        object result = cmdRem.ExecuteScalar();
                        remainingAdvance = result != null ? Convert.ToDecimal(result) : 0;
                    }

                    if (remainingAdvance <= 0)
                        continue;

                    // 🔥 THIS IS THE FIX
                    decimal adjustedAmount = Math.Min(remainingAdvance, remainingExpense);

                    using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO AdvanceLedger
                (EmpCode, AdvancePRSNo, ExpensePRSNo, AdjustedAmount, CreatedDate)
                VALUES
                (@EmpCode, @AdvancePRSNo, @ExpensePRSNo, @AdjustedAmount, GETDATE())
            ", con))
                    {
                        cmd.Parameters.AddWithValue("@EmpCode", Session["UserID"].ToString());
                        cmd.Parameters.AddWithValue("@AdvancePRSNo", advancePRSNo);
                        cmd.Parameters.AddWithValue("@ExpensePRSNo", expensePRSNo);
                        cmd.Parameters.AddWithValue("@AdjustedAmount", adjustedAmount);

                        cmd.ExecuteNonQuery();
                    }

                    remainingExpense -= adjustedAmount;  // reduce expense balance
                }
            }
        }



        private string CreatePRSMaster(int prsTypeId, decimal totalAmount)
        {
            /*
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "SELECT Deptid, PRS_Role, HospitalID FROM Login_role WHERE UserID = @UserID And HospitalID=@HospitalID";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@UserID", Session["UserID"].ToString());
                    cmd.Parameters.AddWithValue("@HospitalID", Session["HospitalID"].ToString());

                    con.Open();

                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader.Read())
                    {
                        UdeptId = reader["Deptid"].ToString();
                        prsRole = reader["PRS_Role"].ToString();
                        hospitalId = reader["HospitalID"].ToString();
                    }
                    con.Close();
                }
            }

            */
            string prsDeptId = Session["PRS_DeptID"] != null ? Session["PRS_DeptID"].ToString() : "";
            string prsNo = "";
            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("Pr_PRS", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                SqlParameter prsNoParam = new SqlParameter("@PRSNo", SqlDbType.VarChar, 50)
                {
                    Direction = ParameterDirection.Output
                };
                cmd.Parameters.Add(prsNoParam);

                cmd.Parameters.AddWithValue("@PRSTYpe", prsTypeId);
                cmd.Parameters.AddWithValue("@PONumber", DBNull.Value);
                cmd.Parameters.AddWithValue("@billno", DBNull.Value);
                cmd.Parameters.AddWithValue("@billdate", DBNull.Value);
                cmd.Parameters.AddWithValue("@Inoviceamount", totalAmount);
                cmd.Parameters.AddWithValue("@duedate", DBNull.Value);
                cmd.Parameters.AddWithValue("@Natureofexpenses", DBNull.Value);
                cmd.Parameters.AddWithValue("@PRSStatus", "New");
                if (prsTypeId == 8)
                { cmd.Parameters.AddWithValue("@Emp_Code", DBNull.Value); }
                else
                { cmd.Parameters.AddWithValue("@Emp_Code", Session["userId"].ToString()); }

                cmd.Parameters.AddWithValue("@Emp_Name", Session["username"].ToString());
                cmd.Parameters.AddWithValue("@Emp_Designation", DBNull.Value);

                cmd.Parameters.AddWithValue("@Emp_Department", prsDeptId);
                cmd.Parameters.AddWithValue("@user_ID", Session["UserID"].ToString());
                cmd.Parameters.AddWithValue("@user_role", Session["Role"].ToString());
                cmd.Parameters.AddWithValue("@TRANType", 0);
                cmd.Parameters.AddWithValue("@Period", DBNull.Value);
                cmd.Parameters.AddWithValue("@Comments", DBNull.Value);
                cmd.Parameters.AddWithValue("@BillFrom", DBNull.Value);
                cmd.Parameters.AddWithValue("@BillTo", DBNull.Value);
                cmd.Parameters.AddWithValue("@HospitalID", Session["HospitalID"]);
                cmd.Parameters.AddWithValue("@supplierID", DBNull.Value);

                con.Open();
                cmd.ExecuteNonQuery();

                prsNo = prsNoParam.Value.ToString();
            }

            return prsNo;
        }

        // ----------------- SAVE EXPENSE CLAIMS -----------------
        private void SaveExpenseClaims(string prsNo, List<Dictionary<string, string>> rows)
        {
            int slNo = 1;
            foreach (var r in rows)
            {
                SaveClaim(
                    prsNo,
                    slNo++,
                    r["Particulars"],
                    null,
                    r["Purpose"],
                    r["BillNo"],
                    r["BillDate"],
                    null,
                    r["Amount"]
                );
            }
        }

        // ----------------- SAVE ADVANCE CLAIM -----------------
        private void SaveAdvanceClaim(string prsNo)
        {
            SaveClaim(
                prsNo,
                1,
                null,
                txtAdvNature.Text.Trim(),
                txtAdvPurpose.Text.Trim(),
                null,
                null,
                txtAdvComments.Text.Trim(),
                txtAdvAmount.Text.Trim()
            );
        }

        // ----------------- SAVE CONVEYANCE CLAIMS -----------------
        private void SaveConveyanceClaims(string prsNo, List<Dictionary<string, string>> rows)
        {
            int slNo = 1;

            foreach (var r in rows)
            {
                SaveClaim(
                    prsNo,
                    slNo++,
                    r["FromLocation"],   // FIX
                    r["ToLocation"],     // FIX
                    r["Purpose"],
                    r["Mode"],
                    r["Distance"],
                    null,
                    r["Amount"]
                );
            }
        }

        // ----------------- GENERIC SAVE METHOD -----------------
        private void SaveClaim(string prsNo, int slNo, string particulars, string particulars2,
            string purpose, string billNo_Mode, string billDate_Distance, string comments, string amount)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("sp_SavePRSClaim", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@PRSNO", prsNo);
                cmd.Parameters.AddWithValue("@SLno", slNo);
                cmd.Parameters.AddWithValue("@PARTICULARS", (object)particulars ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@PARTICULARS2", (object)particulars2 ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@PURPOSE", (object)purpose ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@BillNo_Mode", (object)billNo_Mode ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@BillDate_Distance", (object)billDate_Distance ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Comments", (object)comments ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Amount",
                    string.IsNullOrWhiteSpace(amount) ? (object)DBNull.Value : Convert.ToDecimal(amount));

                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // ----------------- SAVE FILES -----------------
        private void SaveFiles(System.Web.UI.WebControls.FileUpload fileUpload, string prsNo, string type)
        {
            if (!fileUpload.HasFiles) return;

            string basePath = Server.MapPath($"~/UploadedFiles/{prsNo}/");
            if (!Directory.Exists(basePath))
                Directory.CreateDirectory(basePath);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                foreach (var file in fileUpload.PostedFiles)
                {
                    string originalFileName = Path.GetFileName(file.FileName);
                    string fileName = Regex.Replace(originalFileName, @"[^a-zA-Z0-9_\-.]", "_");

                    string filePath = Path.Combine(basePath, fileName);

                    // Save the file on the server
                    file.SaveAs(filePath);

                    // Insert record into SupplierDocuments with Status = 0
                    using (SqlCommand cmdFile = new SqlCommand(
                        "INSERT INTO SupplierDocuments (PONumber, FileName, FilePath, Status) " +
                        "VALUES (@PONumber, @FileName, @FilePath, @Status)", con))
                    {
                        cmdFile.Parameters.AddWithValue("@PONumber", prsNo);
                        cmdFile.Parameters.AddWithValue("@FileName", fileName);
                        cmdFile.Parameters.AddWithValue("@FilePath", $"UploadedFiles/{prsNo}/{fileName}");
                        cmdFile.Parameters.AddWithValue("@Status", 0); // <-- Default status = 0
                        cmdFile.ExecuteNonQuery();
                    }
                }
            }
        }

        private void ClearAllForms()
        {
            hfExpenseData.Value = "";
            hfConveyanceData.Value = "";
            txtAdvAmount.Text = "";
            txtAdvNature.Text = "";
            txtAdvPurpose.Text = "";
            txtAdvComments.Text = "";
        }

        protected void btnSaveExpense_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hfExpenseData.Value)) return;

            var serializer = new JavaScriptSerializer();
            var expenseRows = serializer.Deserialize<List<Dictionary<string, string>>>(hfExpenseData.Value);

            expenseRows.RemoveAll(x =>
                string.IsNullOrWhiteSpace(x["Particulars"]) &&
                string.IsNullOrWhiteSpace(x["Purpose"]) &&
                string.IsNullOrWhiteSpace(x["BillNo"]) &&
                string.IsNullOrWhiteSpace(x["BillDate"]) &&
                string.IsNullOrWhiteSpace(x["Amount"])
            );

            if (expenseRows.Count == 0) return;

            decimal totalAmount = 0;
            foreach (var row in expenseRows)
            {
                decimal.TryParse(row["Amount"], out decimal amt);
                totalAmount += amt;
            }

            // ✅ Generate Expense PRS
            string prsNo = CreatePRSMaster(7, totalAmount);

            // ✅ Save Expense rows
            SaveExpenseClaims(prsNo, expenseRows);

            // ✅ IMPORTANT: Save Advance Adjustment
            SaveAdvanceLedger(prsNo, totalAmount);

            // ✅ Save Files
            SaveFiles(fuExpenseDocs, prsNo, "Expense Claim");

            Response.Redirect("/RINGipopupp.aspx?ringi=" + prsNo, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnSaveIndividual_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hfIndividualData.Value))
                return;

            var serializer = new JavaScriptSerializer();
            var individualRows =
                serializer.Deserialize<List<Dictionary<string, string>>>(hfIndividualData.Value);

            // Remove empty rows
            individualRows.RemoveAll(x =>
                string.IsNullOrWhiteSpace(x["Particulars"]) &&
                string.IsNullOrWhiteSpace(x["Purpose"]) &&
                string.IsNullOrWhiteSpace(x["BillNo"]) &&
                string.IsNullOrWhiteSpace(x["BillDate"]) &&
                string.IsNullOrWhiteSpace(x["Comments"]) &&
                string.IsNullOrWhiteSpace(x["Amount"])
            );

            if (individualRows.Count == 0)
                return;

            decimal totalAmount = 0;

            foreach (var row in individualRows)
            {
                decimal.TryParse(row["Amount"], out decimal amt);
                totalAmount += amt;
            }

            // ✅ 8 = Individual PRS Type
            string prsNo = CreatePRSMaster(8, totalAmount);

            int slNo = 1;

            foreach (var r in individualRows)
            {
                SaveClaim(
                    prsNo,
                    slNo++,
                    r["Particulars"],   // Vendor Name
                    null,
                    r["Purpose"],
                    r["BillNo"],
                    r["BillDate"],
                    r["Comments"],
                    r["Amount"]
                );
            }
            // ✅ Save Individual Documents
            SaveFiles(fuIndividualDocs, prsNo, "Individual PRS");
            Response.Redirect("/RINGipopupp.aspx?ringi=" + prsNo, false);
            Context.ApplicationInstance.CompleteRequest();
        }
        protected void btnSaveAdvance_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtAdvAmount.Text))
                return;

            decimal advAmt = 0;
            decimal.TryParse(txtAdvAmount.Text.Trim(), out advAmt);

            if (advAmt <= 0)
                return;

            // Create PRS for Advance (Type 5)
            string prsNo = CreatePRSMaster(5, advAmt);

            // Save Advance Claim
            SaveAdvanceClaim(prsNo);

            // ✅ Save uploaded files for Advance
            SaveFiles(fuAdvanceDocs, prsNo, "Advance");

            Response.Redirect("/RINGipopupp.aspx?ringi=" + prsNo, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        [System.Web.Services.WebMethod]
        public static List<object> GetAdvanceDetails()
        {
            List<object> advanceList = new List<object>();

            string connStr = ConfigurationManager
                .ConnectionStrings["PRSConnectionString"]
                .ConnectionString;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = @"
WITH AdvanceRemaining AS
(
    SELECT
        pm.PRSNo,
        CONVERT(VARCHAR(10), pm.PRSdate, 103) AS PRSdate,
        pm.Inoviceamount,
        pm.Inoviceamount - ISNULL(SUM(al.AdjustedAmount),0) AS RemainingAmount
    FROM PRSMaster pm
    LEFT JOIN AdvanceLedger al ON pm.PRSNo = al.AdvancePRSNo
    WHERE pm.Emp_Code = @EmpCode
      AND pm.PRSType = 5
    GROUP BY pm.PRSNo, pm.PRSdate, pm.Inoviceamount
)
SELECT *
FROM AdvanceRemaining
WHERE RemainingAmount > 0
ORDER BY PRSdate DESC
";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@EmpCode", HttpContext.Current.Session["UserID"].ToString());

                    con.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        decimal remaining = Convert.ToDecimal(reader["RemainingAmount"]);

                        advanceList.Add(new
                        {
                            PRSNo = reader["PRSNo"].ToString(),
                            PRSdate = reader["PRSdate"].ToString(),
                            Inoviceamount = remaining.ToString("F2") // show remaining
                        });
                    }
                }
            }

            return advanceList;
        }





        protected void btnSaveLocal_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hfConveyanceData.Value)) return;

            var serializer = new JavaScriptSerializer();
            var conveyRows = serializer.Deserialize<List<Dictionary<string, string>>>(hfConveyanceData.Value);

            // Remove empty rows
            conveyRows.RemoveAll(x =>
                string.IsNullOrWhiteSpace(x["Purpose"]) &&
                string.IsNullOrWhiteSpace(x["From"]) &&
                string.IsNullOrWhiteSpace(x["To"]) &&
                string.IsNullOrWhiteSpace(x["Mode"]) &&
                string.IsNullOrWhiteSpace(x["Distance"]) &&
                string.IsNullOrWhiteSpace(x["Amount"])
            );

            if (conveyRows.Count == 0) return;

            decimal totalAmount = 0;
            foreach (var row in conveyRows)
            {

                decimal.TryParse(row["Amount"], out decimal amt);
                totalAmount += amt;
            }

            string prsNo = CreatePRSMaster(6, totalAmount); // 6 = Conveyance PRS type
            SaveConveyanceClaims(prsNo, conveyRows);
            SaveFiles(fuLocalDocs, prsNo, "Local Conveyance");

            Response.Redirect("/RINGipopupp.aspx?ringi=" + prsNo, false);
            Context.ApplicationInstance.CompleteRequest();
        }

    }
}