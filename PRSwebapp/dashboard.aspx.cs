using System;
using System.Web.UI;

namespace PRSwebapp
{
    public partial class dashboard : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect to login if not logged in
            if (Session["username"] == null)
            {
                Response.Redirect("Login.aspx");
            }
        }
    }
}
