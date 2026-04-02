using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.UI;

namespace PRSwebapp
{
    public partial class Supplier : Page
    {
        protected void Page_Load(object sender, EventArgs e) {
            if (Session["UserID"].ToString() == null || Session["UserID"].ToString() == "")
            {
                Response.Redirect("Login.aspx");
            }
        }

        [WebMethod]
        public static List<object> GetSupplierNamesTable(string prefix)
        {
            List<object> suppliers = new List<object>();
            string connStr = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {

                string query = @"SELECT SupplierName, SupplierCode, Email, Mobile, GSTIN, Address, Status
                                 FROM SUPPLIERS
                                 WHERE SupplierName LIKE @prefix + '%'";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@prefix", prefix);
                    conn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        suppliers.Add(new
                        {
                            SupplierName = dr["SupplierName"].ToString(),
                            SupplierCode = dr["SupplierCode"].ToString(),
                            Email = dr["Email"].ToString(),
                            Mobile = dr["Mobile"].ToString(),
                            GSTIN = dr["GSTIN"].ToString(),
                            Address = dr["Address"].ToString(),
                            Status = dr["Status"].ToString()
                        });
                    }
                }
            }
            return suppliers;
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

                // 🔥 Auto hide message (after 2 seconds)
                ScriptManager.RegisterStartupScript(this, this.GetType(),
                    "hideMessage", "setTimeout(function(){ document.getElementById('" +
                    lblMessage.ClientID + "').innerText=''; }, 1000);", true);

                return;
            }

            string connStr = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

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
                }
            }

            lblMessage.ForeColor = System.Drawing.Color.Green;
            lblMessage.Text = "Supplier saved successfully!";

            // 🔥 Auto hide message after 2 seconds
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                "hideMessageSuccess", "setTimeout(function(){ document.getElementById('" +
                lblMessage.ClientID + "').innerText=''; }, 1000);", true);

            btnClear_Click(sender, e);
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSupplierName.Text = "";
            txtSupplierCode.Text = "";
            txtEmail.Text = "";
            txtMobile.Text = "";
            txtGSTIN.Text = "";
            txtAddress.Text = "";
            ddlStatus.SelectedIndex = 0;
            ScriptManager.RegisterStartupScript(this, this.GetType(), "clearDropdown", "$('#supplierDropdown').hide();", true);
        }
    }
}
