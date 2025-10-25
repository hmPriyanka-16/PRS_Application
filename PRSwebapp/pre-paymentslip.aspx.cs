using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.UI;

namespace PRSwebapp
{
    public partial class pre_payment_slip : Page
    {
        private string connectionString = @"Server=SAK-TEST-DBS\SQLDBUAT01;Database=PRS;User ID=sa;Password=SakraDB@123;";

        public static List<string> supplierItems = new List<string>();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadSuppliers();
                txtPODate.Text = DateTime.Now.ToString("yyyy-MM-dd"); // Auto-set PO Date
            }
        }

        private void LoadSuppliers()
        {
            supplierItems.Clear();
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand("SELECT SupplierName FROM Suppliers ORDER BY SupplierName", con))
                {
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            supplierItems.Add(dr["SupplierName"].ToString());
                        }
                    }
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();
                    string query = @"INSERT INTO PrePaymentSlips 
                                    (SupplierName, PODate, PONumber, NatureOfExpense, PeriodMonth, BillNumber, BillDate, DueDate, Amount, Comments)
                                    VALUES
                                    (@SupplierName, @PODate, @PONumber, @NatureOfExpense, @PeriodMonth, @BillNumber, @BillDate, @DueDate, @Amount, @Comments)";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@SupplierName", txtSupplierCombo.Text.Trim());
                        cmd.Parameters.AddWithValue("@PODate", string.IsNullOrEmpty(txtPODate.Text) ? (object)DBNull.Value : DateTime.Parse(txtPODate.Text));
                        cmd.Parameters.AddWithValue("@PONumber", txtPONumber.Text.Trim());
                        cmd.Parameters.AddWithValue("@NatureOfExpense", txtNatureOfExp.Text.Trim());
                        cmd.Parameters.AddWithValue("@PeriodMonth", txtPeriodMonth.Text.Trim());
                        cmd.Parameters.AddWithValue("@BillNumber", txtBillNumber.Text.Trim());
                        cmd.Parameters.AddWithValue("@BillDate", string.IsNullOrEmpty(txtBillDate.Text) ? (object)DBNull.Value : DateTime.Parse(txtBillDate.Text));
                        cmd.Parameters.AddWithValue("@DueDate", string.IsNullOrEmpty(txtDueDate.Text) ? (object)DBNull.Value : DateTime.Parse(txtDueDate.Text));
                        cmd.Parameters.AddWithValue("@Amount", string.IsNullOrEmpty(txtAmount.Text) ? (object)DBNull.Value : decimal.Parse(txtAmount.Text));
                        cmd.Parameters.AddWithValue("@Comments", txtComments.Text.Trim());
                        cmd.ExecuteNonQuery();
                    }
                }

                ClearForm();
                ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Pre-payment slip saved successfully!');", true);
            }
            catch (Exception ex)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert", $"alert('Error: {ex.Message}');", true);
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

            txtPODate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            txtBillDate.Text = "";
            txtDueDate.Text = "";
        }

        [WebMethod]
        public static List<Dictionary<string, string>> GetFilteredPOHistory(string supplierName, string poDate, string validity)
        {
            var results = new List<Dictionary<string, string>>();
            using (SqlConnection con = new SqlConnection(@"Server=SAK-TEST-DBS\SQLDBUAT01;Database=PRS;User ID=sa;Password=SakraDB@123;"))
            {
                con.Open();
                string sql = "SELECT TOP 50 ID, SupplierName, PONumber, PODate, POAmountType, PaymentsApplicable, POAmount, InvoiceAmount, AgreementValidity FROM SupplierPOEntry WHERE 1=1";
                if (!string.IsNullOrEmpty(supplierName)) sql += " AND SupplierName LIKE @s";
                if (!string.IsNullOrEmpty(poDate)) sql += " AND PODate=@d";
                if (!string.IsNullOrEmpty(validity)) sql += " AND AgreementValidity=@v";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    if (!string.IsNullOrEmpty(supplierName)) cmd.Parameters.AddWithValue("@s", "%" + supplierName + "%");
                    if (!string.IsNullOrEmpty(poDate)) cmd.Parameters.AddWithValue("@d", DateTime.Parse(poDate));
                    if (!string.IsNullOrEmpty(validity)) cmd.Parameters.AddWithValue("@v", DateTime.Parse(validity));

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            var row = new Dictionary<string, string>();
                            for (int i = 0; i < dr.FieldCount; i++)
                            {
                                string colName = dr.GetName(i);
                                if (dr[i] is DateTime dt) row[colName] = dt.ToString("yyyy-MM-dd");
                                else row[colName] = dr[i]?.ToString();
                            }
                            results.Add(row);
                        }
                    }
                }
            }
            return results;
        }
    }
}
