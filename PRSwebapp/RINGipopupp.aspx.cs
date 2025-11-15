using System;
using System.Web.UI;

namespace PRSwebapp
{
    public partial class AcknowledgementPopup : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Get RINGI number from query string
                string ringiNo = Request.QueryString["ringi"];
                lblRingiNumber.Text = ringiNo ?? "N/A";
            }
        }

        protected void btnClose_Click(object sender, EventArgs e)
        {
            // Redirect to Dashboard page
            Response.Redirect("Dashboard.aspx");
        }
    }
}
