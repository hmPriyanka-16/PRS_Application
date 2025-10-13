using System;
using System.Web.UI;

namespace PRSwebapp
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            lblError.Text = ""; // clear error on page load
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            // Hard-coded admin login (you can replace with DB validation later)
            if (username == "admin" && password == "admin123")
            {
                // Redirect to Supplier page
                Response.Redirect("Supplier.aspx");
            }
            else
            {
                lblError.Text = "Invalid username or password!";
            }
        }
    }
}
