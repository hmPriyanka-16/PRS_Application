using System;
using System.Web.UI;
using System.Web.UI.HtmlControls;

namespace PRSwebapp
{
    public partial class SiteMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Display logged-in user
            if (Session["UserName"] != null)
            {
                lblUserName.Text = Session["UserName"].ToString();
            }

            // Highlight active page in top nav and sidebar
            if (!IsPostBack)
            {
                HighlightCurrentPage();
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }

        private void HighlightCurrentPage()
        {
            // Get current page name
            string pageName = System.IO.Path.GetFileName(Request.Path).ToLower();

            // Highlight Top Nav links
            foreach (Control ctrl in topNav.Controls)
            {
                if (ctrl is HtmlAnchor anchor)
                {
                    string href = anchor.HRef.ToLower();
                    if (href.Contains(pageName))
                        anchor.Attributes["class"] = "active";
                    else
                        anchor.Attributes.Remove("class");
                }
            }

            // Highlight Sidebar links
            foreach (Control ctrl in sidebar.Controls)
            {
                if (ctrl is HtmlAnchor anchor)
                {
                    string href = anchor.HRef.ToLower();
                    if (href.Contains(pageName))
                        anchor.Attributes["class"] = "active";
                    else
                        anchor.Attributes.Remove("class");
                }
            }
        }
    }
}
