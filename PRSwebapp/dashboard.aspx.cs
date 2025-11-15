using System;

namespace PRSwebapp
{
    public partial class dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect to login page if user session expired or not set
            if (Session["UserName"] == null)
            {
                Response.Redirect("Login.aspx");
            }
        }
    }
}
