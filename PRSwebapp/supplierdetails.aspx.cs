using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.UI;

namespace PRSwebapp
{
    public partial class supplier_details : Page
    {
        private string connectionString = @"Server=SAK-TEST-DBS\SQLDBUAT01;Database=PRS;User ID=sa;Password=SakraDB@123;";
        public static List<string> supplierItems = new List<string>();
        public static List<string> departmentItems = new List<string>();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                LoadComboData();
        }

        private void LoadComboData()
        {
            supplierItems.Clear();
            departmentItems.Clear();
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                // Load Suppliers
                using (SqlCommand cmd = new SqlCommand("SELECT suppliername FROM Suppliers", con))
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                        supplierItems.Add(dr["suppliername"].ToString());
                }

                // Load Departments
                using (SqlCommand cmd = new SqlCommand("SELECT name FROM Department", con))
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                        departmentItems.Add(dr["name"].ToString());
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string supplier = txtSupplierCombo.Text.Trim();
            string department = txtDepartmentCombo.Text.Trim();
            string poNumber = txtPONumber.Text.Trim();
            string poDate = txtPODate.Text.Trim();
            string poAmountType = rbFixed.Checked ? "Fixed" : rbUsage.Checked ? "On Usage" : "";
            string payments = string.Join(",", GetSelectedMonths());
            string ringNo = txtRingNumber.Text.Trim();
            string invoiceAmount = txtInvoiceAmount.Text.Replace(",", "");
            string poAmount = txtPOAmount.Text.Replace(",", "");
            string validity = txtValidity.Text.Trim();

            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();

                    // Insert Supplier if new
                    if (!string.IsNullOrEmpty(supplier))
                        ExecuteNonQuery(con, "IF NOT EXISTS(SELECT 1 FROM Suppliers WHERE suppliername=@s) INSERT INTO Suppliers(suppliername) VALUES(@s)", ("@s", supplier));

                    // Insert Department if new
                    if (!string.IsNullOrEmpty(department))
                        ExecuteNonQuery(con, "IF NOT EXISTS(SELECT 1 FROM Department WHERE name=@d) INSERT INTO Department(name) VALUES(@d)", ("@d", department));

                    // Insert PO Entry
                    string sql = @"INSERT INTO SupplierPOEntry
                                (SupplierName, Department, PONumber, PODate, POAmountType, PaymentsApplicable, RingNumber, InvoiceAmount, POAmount, AgreementValidity)
                                VALUES (@SupplierName,@Department,@PONumber,@PODate,@POAmountType,@PaymentsApplicable,@RingNumber,@InvoiceAmount,@POAmount,@AgreementValidity)";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@SupplierName", supplier);
                        cmd.Parameters.AddWithValue("@Department", department);
                        cmd.Parameters.AddWithValue("@PONumber", poNumber);
                        cmd.Parameters.AddWithValue("@PODate", string.IsNullOrEmpty(poDate) ? (object)DBNull.Value : DateTime.Parse(poDate));
                        cmd.Parameters.AddWithValue("@POAmountType", poAmountType);
                        cmd.Parameters.AddWithValue("@PaymentsApplicable", payments);
                        cmd.Parameters.AddWithValue("@RingNumber", ringNo);
                        cmd.Parameters.AddWithValue("@InvoiceAmount", string.IsNullOrEmpty(invoiceAmount) ? (object)DBNull.Value : Convert.ToDecimal(invoiceAmount));
                        cmd.Parameters.AddWithValue("@POAmount", string.IsNullOrEmpty(poAmount) ? (object)DBNull.Value : Convert.ToDecimal(poAmount));
                        cmd.Parameters.AddWithValue("@AgreementValidity", string.IsNullOrEmpty(validity) ? (object)DBNull.Value : DateTime.Parse(validity));
                        cmd.ExecuteNonQuery();
                    }
                }

                LoadComboData();
                ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('PO details saved successfully!');", true);
            }
            catch (Exception ex)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert", $"alert('Error: {ex.Message}');", true);
            }
        }

        private void ExecuteNonQuery(SqlConnection con, string sql, params (string, object)[] parameters)
        {
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                foreach (var p in parameters)
                    cmd.Parameters.AddWithValue(p.Item1, p.Item2);
                cmd.ExecuteNonQuery();
            }
        }

        private List<string> GetSelectedMonths()
        {
            var months = new List<string>();
            foreach (System.Web.UI.WebControls.ListItem item in chkListMonths.Items)
                if (item.Selected && item.Value != "All")
                    months.Add(item.Value);
            return months;
        }

        [WebMethod]
        public static List<Dictionary<string, string>> GetFilteredPOHistory(string supplierName, string poDate, string validity)
        {
            var results = new List<Dictionary<string, string>>();
            using (SqlConnection con = new SqlConnection(@"Server=SAK-TEST-DBS\SQLDBUAT01;Database=PRS;User ID=sa;Password=SakraDB@123;"))
            {
                con.Open();

                string sql = @"
                    SELECT TOP 50 
                        e.ID,
                        e.SupplierName,
                        e.PONumber,
                        e.PODate,
                        e.POAmountType,
                        e.PaymentsApplicable,
                        e.POAmount,
                        e.InvoiceAmount,
                        e.AgreementValidity,
                        CASE 
                            WHEN p.ID IS NOT NULL THEN 'Processed'
                            ELSE 'Not Processed'
                        END AS ProcessStatus
                    FROM SupplierPOEntry e
                    LEFT JOIN PrePaymentSlips p ON e.PONumber = p.PONumber
                    WHERE 1=1";

                if (!string.IsNullOrEmpty(supplierName)) sql += " AND e.SupplierName LIKE @s";
                if (!string.IsNullOrEmpty(poDate)) sql += " AND e.PODate=@d";
                if (!string.IsNullOrEmpty(validity)) sql += " AND e.AgreementValidity=@v";
                sql += " ORDER BY e.PODate DESC";

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
                                if (dr[i] is DateTime dt)
                                    row[colName] = dt.ToString("yyyy-MM-dd");
                                else
                                    row[colName] = dr[i]?.ToString();
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
