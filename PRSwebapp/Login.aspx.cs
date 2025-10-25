using System;
using System.Web.UI;

namespace PRSwebapp
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            lblError.Text = ""; // clear error
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            // Hard-coded login (can replace with DB check)
            if (username == "admin" && password == "admin123")
            {
                Session["username"] = username; // store session
                Response.Redirect("dashboard.aspx"); // open dashboard
            }
            else
            {
                lblError.Text = "Invalid username or password!";
            }
        }
    }
}
