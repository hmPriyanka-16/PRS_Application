using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.Services;
using System.Web.UI;

namespace PRSwebapp
{
    public partial class PRS_Request : Page
    {
        private readonly string connectionString =
            ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

        public static List<string> supplierItems = new List<string>();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadSuppliers();

            }
        }

        private void LoadSuppliers()
        {
            supplierItems.Clear();
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                string sql = "SELECT SupplierName FROM Suppliers ORDER BY SupplierName";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                        supplierItems.Add(dr["SupplierName"].ToString());
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {


                // 0️⃣ Validate User
                if (Session["UserID"] == null || Session["Role"] == null)
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "invalidUser",
                        "alert('Invalid user. Please login again.');", true);
                    return; // stop execution
                }

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();

                    // 1️⃣ Get SupplierID
                    int supplierId;
                    using (SqlCommand cmd = new SqlCommand("SELECT SupplierID FROM Suppliers WHERE SupplierName=@name", con))
                    {
                        cmd.Parameters.AddWithValue("@name", txtSupplierCombo.Text.Trim());
                        object result = cmd.ExecuteScalar();
                        if (result == null) throw new Exception("Supplier not found.");
                        supplierId = Convert.ToInt32(result);
                    }

                    // 2️⃣ Check if PONumber + Period exists
                    bool exists = false;
                    using (SqlCommand cmd = new SqlCommand(@"
                SELECT COUNT(*) 
                FROM PrsMaster
                WHERE PONumber = @PONumber AND Period = @Period", con))
                    {
                        cmd.Parameters.AddWithValue("@PONumber", txtPONumber.Text.Trim());
                        cmd.Parameters.AddWithValue("@Period", txtPeriodMonth.Text.Trim());
                        exists = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                    }

                    string generatedPRSNo = "";

                    // 3️⃣ Call stored procedure to insert
                    // Stored procedure call
                    using (SqlCommand cmd = new SqlCommand("Pr_PRS", con))
                    {
                        cmd.CommandType = System.Data.CommandType.StoredProcedure;

                        // Output parameter
                        var prsNoParam = new SqlParameter("@PRSNo", System.Data.SqlDbType.VarChar, 50)
                        {
                            Direction = System.Data.ParameterDirection.Output
                        };
                        cmd.Parameters.Add(prsNoParam);

                        // Required input parameters

                        cmd.Parameters.AddWithValue("@PRSType", ddlPRSType.SelectedValue);
                        cmd.Parameters.AddWithValue("@PONumber", txtPONumber.Text.Trim());
                        cmd.Parameters.AddWithValue("@billno", txtBillNumber.Text.Trim());
                        cmd.Parameters.AddWithValue("@billdate", string.IsNullOrWhiteSpace(txtBillDate.Text) ? (object)DBNull.Value : DateTime.Parse(txtBillDate.Text));
                        cmd.Parameters.AddWithValue("@Inoviceamount", string.IsNullOrWhiteSpace(txtAmount.Text) ? (object)DBNull.Value : Convert.ToDecimal(txtAmount.Text));
                        cmd.Parameters.AddWithValue("@duedate", string.IsNullOrWhiteSpace(txtDueDate.Text) ? (object)DBNull.Value : DateTime.Parse(txtDueDate.Text));
                        cmd.Parameters.AddWithValue("@Natureofexpenses", string.IsNullOrWhiteSpace(txtNatureOfExp.Text) ? (object)DBNull.Value : txtNatureOfExp.Text.Trim());
                        cmd.Parameters.AddWithValue("@PRSStatus", "New");
                        cmd.Parameters.AddWithValue("@Period", string.IsNullOrWhiteSpace(txtPeriodMonth.Text) ? (object)DBNull.Value : txtPeriodMonth.Text.Trim());
                        cmd.Parameters.AddWithValue("@Comments", string.IsNullOrWhiteSpace(txtComments.Text) ? (object)DBNull.Value : txtComments.Text.Trim());

                        // User info
                        cmd.Parameters.AddWithValue("@user_ID", Session["UserID"]);
                        cmd.Parameters.AddWithValue("@user_role", Session["Role"]);
                        cmd.Parameters.AddWithValue("@TRANType", 0);

                        // Employee info
                        cmd.Parameters.AddWithValue("@Emp_Code", Session["Emp_Code"] ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@Emp_Name", Session["Emp_Name"] ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@Emp_Designation", Session["Emp_Designation"] ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@Emp_Department", Session["Emp_Department"] ?? (object)DBNull.Value);

                        cmd.ExecuteNonQuery();


                        // ✅ Assign output value to the variable declared outside
                        generatedPRSNo = prsNoParam.Value.ToString();
                    }
                    ClearForm();
                    Response.Redirect($"RingiPopupp.aspx?ringi={generatedPRSNo}");



                    // 4️⃣ Upload files
                    if (fuDocument.HasFiles)
                    {
                        string poNumber = txtPONumber.Text.Trim();
                        string baseFolder = Server.MapPath("~/UploadedFiles/");
                        if (!Directory.Exists(baseFolder)) Directory.CreateDirectory(baseFolder);

                        string poFolder = Path.Combine(baseFolder, poNumber);
                        if (!Directory.Exists(poFolder)) Directory.CreateDirectory(poFolder);

                        foreach (var file in fuDocument.PostedFiles)
                        {
                            string fileName = Path.GetFileName(file.FileName);
                            string savePath = Path.Combine(poFolder, fileName);
                            file.SaveAs(savePath);

                            using (SqlCommand cmdFile = new SqlCommand(
                                "INSERT INTO SupplierDocuments (SupplierName, PONumber, FileName, FilePath) VALUES (@SupplierName, @PONumber, @FileName, @FilePath)", con))
                            {
                                cmdFile.Parameters.AddWithValue("@SupplierName", txtSupplierCombo.Text.Trim());
                                cmdFile.Parameters.AddWithValue("@PONumber", poNumber);
                                cmdFile.Parameters.AddWithValue("@FileName", fileName);
                                cmdFile.Parameters.AddWithValue("@FilePath", $"~/UploadedFiles/{poNumber}/{fileName}");
                                cmdFile.ExecuteNonQuery();
                            }
                        }
                    }

                    // 5️⃣ Update status if same PONumber exists
                    if (exists)
                    {
                        using (SqlCommand cmd = new SqlCommand(@"
                    UPDATE SupplierPOEntry 
                    SET ProcessStatus = 'Completed' 
                    WHERE PONumber = @PONumber", con))
                        {
                            cmd.Parameters.AddWithValue("@PONumber", txtPONumber.Text.Trim());
                            cmd.ExecuteNonQuery();
                        }
                    }
                }

                ClearForm();
                ClientScript.RegisterStartupScript(this.GetType(), "success", "alert('Saved successfully!');", true);
            }
            catch (SqlException sqlEx)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "error", $"alert('SQL Error: {sqlEx.Message}');", true);
                throw;
            }
            catch (Exception ex)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "error", $"alert('Error: {ex.Message}');", true);
                throw;
            }
        }


        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        private void ClearForm()
        {
            txtSupplierCombo.Text = "";
            txtPONumber.Text = "";
            txtNatureOfExp.Text = "";
            txtPeriodMonth.Text = "";
            txtBillNumber.Text = "";
            txtAmount.Text = "";
            txtComments.Text = "";
            txtBillDate.Text = "";
            txtDueDate.Text = "";
            txtPODate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        }

        private static string NormalizeMonthName(string input)
        {
            if (string.IsNullOrWhiteSpace(input)) return null;
            input = input.Trim().ToLower();

            switch (input)
            {
                case "jan":
                case "january": return "January";
                case "feb":
                case "february": return "February";
                case "mar":
                case "march": return "March";
                case "apr":
                case "april": return "April";
                case "may": return "May";
                case "jun":
                case "june": return "June";
                case "jul":
                case "july": return "July";
                case "aug":
                case "august": return "August";
                case "sep":
                case "sept":
                case "september": return "September";
                case "oct":
                case "october": return "October";
                case "nov":
                case "november": return "November";
                case "dec":
                case "december": return "December";
                default: return null;
            }
        }
        [WebMethod]
        public static List<Dictionary<string, string>> GetFilteredPOHistory(string supplierName, string agreementStart, string agreementEnd)
        {
            var results = new List<Dictionary<string, string>>();
            string connStr = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                string sql = @"
            SELECT s.SupplierName, d.Name AS Department, e.prstype, e.PONumber, e.PODate,
                   e.POPaymentType, e.PaymentsApplicable, e.POAmount, e.InvoiceAmount,
                   e.natureofexp, e.AgreementStart, e.AgreementEnd, e.RingNumber, e.ProcessStatus
            FROM SupplierPOEntry e
            INNER JOIN Suppliers s ON e.SupplierName = CAST(s.SupplierID AS VARCHAR(10))
            LEFT JOIN Department d ON e.Department = d.ID
            WHERE 1=1";

                if (!string.IsNullOrEmpty(supplierName))
                    sql += " AND s.SupplierName LIKE @s";

                if (!string.IsNullOrEmpty(agreementStart))
                    sql += " AND e.AgreementStart >= @start";

                if (!string.IsNullOrEmpty(agreementEnd))
                    sql += " AND e.AgreementEnd <= @end";

                sql += " ORDER BY e.AgreementStart DESC";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    if (!string.IsNullOrEmpty(supplierName))
                        cmd.Parameters.AddWithValue("@s", "%" + supplierName + "%");

                    if (!string.IsNullOrEmpty(agreementStart))
                        cmd.Parameters.AddWithValue("@start", DateTime.Parse(agreementStart));

                    if (!string.IsNullOrEmpty(agreementEnd))
                        cmd.Parameters.AddWithValue("@end", DateTime.Parse(agreementEnd));

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string poNumber = dr["PONumber"].ToString();
                            string paymentsApplicable = dr["PaymentsApplicable"]?.ToString() ?? "";

                            // Clean & split months robustly
                            paymentsApplicable = Regex.Replace(paymentsApplicable, "(processed|process)", "", RegexOptions.IgnoreCase);
                            var months = Regex.Split(paymentsApplicable, @"[,\-/;\s]+")
                                              .Select(NormalizeMonthName)
                                              .Where(m => !string.IsNullOrEmpty(m))
                                              .Distinct(StringComparer.OrdinalIgnoreCase)
                                              .ToList();

                            // Get processed months from PrePaymentSlips
                            HashSet<string> processedMonths = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                            using (SqlConnection con2 = new SqlConnection(connStr))
                            {
                                con2.Open();
                                using (SqlCommand cmdCheck = new SqlCommand("SELECT Period FROM PrsMaster WHERE PONumber=@po", con2))
                                {
                                    cmdCheck.Parameters.AddWithValue("@po", poNumber);
                                    using (SqlDataReader drCheck = cmdCheck.ExecuteReader())
                                    {
                                        while (drCheck.Read())
                                        {
                                            string dbMonths = drCheck["Period"].ToString();
                                            if (!string.IsNullOrWhiteSpace(dbMonths))
                                            {
                                                foreach (var m in Regex.Split(dbMonths, @"[,\s;]+")
                                                                       .Select(NormalizeMonthName)
                                                                       .Where(x => !string.IsNullOrEmpty(x)))
                                                {
                                                    processedMonths.Add(m);
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Add one row per month (Processed or Pending)
                            foreach (string month in months)
                            {
                                string status = processedMonths.Contains(month) ? "Processed" : "Pending";

                                results.Add(new Dictionary<string, string>
                                {
                                    ["SupplierName"] = dr["SupplierName"].ToString(),
                                    ["Department"] = dr["Department"].ToString(),
                                    ["prstype"] = dr["prstype"].ToString(),
                                    ["PONumber"] = poNumber,
                                    ["PODate"] = dr["PODate"] == DBNull.Value ? "" : Convert.ToDateTime(dr["PODate"]).ToString("yyyy-MM-dd"),
                                    ["POPaymentType"] = dr["POPaymentType"].ToString(),
                                    ["PaymentsApplicable"] = month,
                                    ["Status"] = status,
                                    ["POAmount"] = dr["POAmount"].ToString(),
                                    ["InvoiceAmount"] = dr["InvoiceAmount"].ToString(),
                                    ["natureofexp"] = dr["natureofexp"].ToString(),
                                    ["AgreementStart"] = dr["AgreementStart"] == DBNull.Value ? "" : Convert.ToDateTime(dr["AgreementStart"]).ToString("yyyy-MM-dd"),
                                    ["AgreementEnd"] = dr["AgreementEnd"] == DBNull.Value ? "" : Convert.ToDateTime(dr["AgreementEnd"]).ToString("yyyy-MM-dd"),
                                    ["RingNumber"] = dr["RingNumber"].ToString(),
                                    ["ProcessStatus"] = dr["ProcessStatus"].ToString()
                                });
                            }
                        }
                    }
                }
            }

            return results;
        }



    }

}