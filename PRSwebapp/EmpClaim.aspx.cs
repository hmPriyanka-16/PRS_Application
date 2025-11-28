using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace PRSwebapp
{
    public partial class EmpClaim : Page
    {
        private readonly string connectionString =
            ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                hfExpenseData.Value = "";
                hfConveyanceData.Value = "";
                Session["CurrentPRSNo"] = null;   // Make sure fresh PRS starts
            }

            btnSaveExpense.Click += BtnSaveAll_Click;
            btnSaveAdvance.Click += BtnSaveAll_Click;
            btnSaveLocal.Click += BtnSaveAll_Click;
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
            string prstype = "";
            if (expenseRows.Count > 0) prstype = "Expense";
            else if (advAmt > 0) prstype = "Advance";
            else if (conveyRows.Count > 0) prstype = "Conveyance";

            // ----------------- CREATE PRS NO ONLY ONCE -----------------
            string prsNo = Session["CurrentPRSNo"] as string;

            if (string.IsNullOrEmpty(prsNo))
            {
                prsNo = CreatePRSMaster(prstype, totalAmount);
                Session["CurrentPRSNo"] = prsNo;      // Save PRS for all rows
            }

            // ----------------- SAVE CLAIMS -----------------
            if (expenseRows.Count > 0) SaveExpenseClaims(prsNo, expenseRows);
            if (advAmt > 0) SaveAdvanceClaim(prsNo);
            if (conveyRows.Count > 0) SaveConveyanceClaims(prsNo, conveyRows);

            // Redirect ONLY after saving all rows
            Response.Redirect("/RINGipopupp.aspx?ringi=" + prsNo, false);

            ClearAllForms();
            Session["CurrentPRSNo"] = null;   // Reset for next PRS
            Context.ApplicationInstance.CompleteRequest();
        }

        private string CreatePRSMaster(string prstype, decimal totalAmount)
        {
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

                cmd.Parameters.AddWithValue("@PRSTYpe", prstype);
                cmd.Parameters.AddWithValue("@PONumber", DBNull.Value);
                cmd.Parameters.AddWithValue("@billno", DBNull.Value);
                cmd.Parameters.AddWithValue("@billdate", DBNull.Value);
                cmd.Parameters.AddWithValue("@Inoviceamount", totalAmount);
                cmd.Parameters.AddWithValue("@duedate", DBNull.Value);
                cmd.Parameters.AddWithValue("@Natureofexpenses", DBNull.Value);
                cmd.Parameters.AddWithValue("@PRSStatus", "New");
                cmd.Parameters.AddWithValue("@Emp_Code", Session["userId"]);
                cmd.Parameters.AddWithValue("@Emp_Name", Session["username"]);
                cmd.Parameters.AddWithValue("@Emp_Designation", DBNull.Value);
                cmd.Parameters.AddWithValue("@Emp_Department", Session["deptid"]);
                cmd.Parameters.AddWithValue("@user_ID", Session["UserID"]);
                cmd.Parameters.AddWithValue("@user_role", Convert.ToInt32(Session["Role"]));
                cmd.Parameters.AddWithValue("@TRANType", 0);
                cmd.Parameters.AddWithValue("@Period", DBNull.Value);
                cmd.Parameters.AddWithValue("@Comments", DBNull.Value);
                cmd.Parameters.AddWithValue("@BillFrom", DBNull.Value);
                cmd.Parameters.AddWithValue("@BillTo", DBNull.Value);

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
                    r["From"],
                    r["To"],
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

        }
    }
}
