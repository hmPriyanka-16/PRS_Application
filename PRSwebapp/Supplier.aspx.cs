using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.UI;

namespace PRSwebapp
{
    public partial class Supplier : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static List<string> GetSupplierNames(string prefix)
        {
            List<string> names = new List<string>();
            string connStr = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "SELECT SupplierName FROM SUPPLIERS WHERE SupplierName LIKE @prefix + '%'";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@prefix", prefix);
                    conn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        names.Add(dr["SupplierName"].ToString());
                    }
                }
            }
            return names;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string supplierCode = txtSupplierCode.Text.Trim();
            string supplierName = txtSupplierName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string mobile = txtMobile.Text.Trim();
            string gstin = txtGSTIN.Text.Trim();
            string address = txtAddress.Text.Trim();
            string status = ddlStatus.SelectedValue;

            if (string.IsNullOrEmpty(supplierCode) || string.IsNullOrEmpty(supplierName))
            {
                lblMessage.ForeColor = System.Drawing.Color.Red;
                lblMessage.Text = "Supplier Code and Name are required!";
                return;
            }

            string connStr = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string query = @"INSERT INTO SUPPLIERS
                                    (SupplierCode, SupplierName, Email, Mobile, GSTIN, Address, Status)
                                    VALUES (@SupplierCode, @SupplierName, @Email, @Mobile, @GSTIN, @Address, @Status)";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@SupplierCode", supplierCode);
                        cmd.Parameters.AddWithValue("@SupplierName", supplierName);
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@Mobile", mobile);
                        cmd.Parameters.AddWithValue("@GSTIN", gstin);
                        cmd.Parameters.AddWithValue("@Address", address);
                        cmd.Parameters.AddWithValue("@Status", status);

                        conn.Open();
                        cmd.ExecuteNonQuery();
                        conn.Close();
                    }
                }

                lblMessage.ForeColor = System.Drawing.Color.Green;
                lblMessage.Text = "Supplier saved successfully!";
                btnClear_Click(sender, e); // Clear form

                // Hide message after 3 seconds
                ScriptManager.RegisterStartupScript(this, this.GetType(), "hideMsg", "hideMessage();", true);
            }
            catch (Exception ex)
            {
                lblMessage.ForeColor = System.Drawing.Color.Red;
                lblMessage.Text = "Error: " + ex.Message;
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSupplierCode.Text = "";
            txtSupplierName.Text = "";
            txtEmail.Text = "";
            txtMobile.Text = "";
            txtGSTIN.Text = "";
            txtAddress.Text = "";
            ddlStatus.SelectedIndex = 0;
        }
    }
}
