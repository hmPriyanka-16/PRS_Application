using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace PRSwebapp
{
    public partial class PendingTask : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindPendingTasks();
            }
        }

        private void BindPendingTasks()
        {
            string deptId = Session["deptid"]?.ToString();

            string connString = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

            string query = @"
                 SELECT 
                    PRSNo,
                    PRSdate,
                  
                    billno,
                    billdate,
                    duedate,
                    Natureofexpenses,
                    Inoviceamount,
                    PRSType,
                    UserID,
                    Period,
                   
                  
                    DeptID,
                    PRSStatus,
                   
                    SupplierCode,
                    SupplierName,
                    LastApproved
                FROM vw_PRSlist
                WHERE PRSStatus <> 'Completed'
                  AND Deptid = @DeptId
                  AND Next_Sequence=2";

            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@DeptId", deptId);
                new SqlDataAdapter(cmd).Fill(dt);
            }

            // Main table on page (NO action buttons)
            gvMainPending.DataSource = dt;
            gvMainPending.DataBind();

            // Popup table (WITH action buttons)
            gvPendingTasks.DataSource = dt;
            gvPendingTasks.DataBind();

            lblTotalPending.InnerText = dt.Rows.Count.ToString();
        }

        protected void gvPendingTasks_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            if (e.CommandArgument == null) return;

            string prsNo = e.CommandArgument.ToString();

            if (e.CommandName == "Approve")
                UpdatePRSStatus(prsNo, "Approved");

            else if (e.CommandName == "SendBack")
                UpdatePRSStatus(prsNo, "Sent Back");

            else if (e.CommandName == "Trail")
                ClientScript.RegisterStartupScript(this.GetType(), "alert",
                    $"alert('Trail clicked for PRSNo: {prsNo}');", true);

            BindPendingTasks();
        }

        private void UpdatePRSStatus(string prsNo, string status)
        {
            string connString = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

            string query = @"UPDATE PrsMaster SET PRSStatus = @Status WHERE PRSNo = @PRSNo";

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@Status", status);
                cmd.Parameters.AddWithValue("@PRSNo", prsNo);

                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }
}
