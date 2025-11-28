using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PRSwebapp
{
    public partial class CompletedTask : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ViewState["SelectedPRS"] = "Capex Advance PRS";
                HighlightNavbar();
                BindCompletedTasks();
            }
        }

        protected void PRS_Click(object sender, EventArgs e)
        {
            LinkButton clicked = (LinkButton)sender;
            ViewState["SelectedPRS"] = clicked.Text;
            HighlightNavbar();
            BindCompletedTasks();
        }

        private void HighlightNavbar()
        {
            if (ViewState["SelectedPRS"] == null) return;

            string active = ViewState["SelectedPRS"].ToString();

            LinkButton[] navLinks =
            {
                navPRS1, navPRS2, navPRS3, navPRS4, navPRS5, navPRS6, navPRS7
            };

            foreach (var nav in navLinks)
            {
                if (nav != null)
                {
                    nav.CssClass = "nav-link me-2 mb-2";
                    if (nav.Text == active)
                        nav.CssClass = "nav-link active me-2 mb-2";
                }
            }
        }

        protected void btnShow_Click(object sender, EventArgs e)
        {
            BindCompletedTasks();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ddlRole.SelectedIndex = 0;
            txtFromDate.Text = "";
            txtToDate.Text = "";
            BindCompletedTasks();
        }

        private void BindCompletedTasks()
        {
            if (ViewState["SelectedPRS"] == null) return;

            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = @"
SELECT *
FROM vw_PRSlist
WHERE PRSStatus = 'Completed'
  AND PRSType = @PRS_Type
  AND CAST(PRSdate AS DATE) BETWEEN 
      ISNULL(@FromDate, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0))
      AND 
      ISNULL(@ToDate, EOMONTH(GETDATE()))
ORDER BY PRSdate DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@PRS_Type", ViewState["SelectedPRS"].ToString());

                    if (string.IsNullOrEmpty(txtFromDate.Text))
                        cmd.Parameters.AddWithValue("@FromDate", DBNull.Value);
                    else
                        cmd.Parameters.AddWithValue("@FromDate", Convert.ToDateTime(txtFromDate.Text));

                    if (string.IsNullOrEmpty(txtToDate.Text))
                        cmd.Parameters.AddWithValue("@ToDate", DBNull.Value);
                    else
                        cmd.Parameters.AddWithValue("@ToDate", Convert.ToDateTime(txtToDate.Text));

                    DataTable dt = new DataTable();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);

                    gvCompleted.DataSource = dt;
                    gvCompleted.DataBind();
                }
            }
        }

        private void LoadTransactionDetails(string prsNo)
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = @"
          SELECT TOP 1 
    T.TransactionID,
    T.PRSNo,
    P.PRSdate,
    T.InvoiceAmount,
    T.TransactionDate,
    L.EmpName AS CreatedBy,  
    T.DocumentPath
FROM Transactions T
LEFT JOIN vw_PRSlist P 
    ON P.PRSNo = T.PRSNo
LEFT JOIN Login L 
    ON L.Employeeno = T.CreatedBy   
WHERE T.PRSNo = @PRSNo
ORDER BY T.TransactionDate DESC;
";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@PRSNo", prsNo);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    lblTransID.Text = dr["TransactionID"].ToString();
                    lblPRSNo.Text = dr["PRSNo"].ToString();
https://localhost:44377/Inprogress.aspx.cs
                    if (dr["PRSdate"] != DBNull.Value)
                        lblPRSDate.Text = Convert.ToDateTime(dr["PRSdate"]).ToString("dd-MMM-yyyy");
                    else
                        lblPRSDate.Text = "-";

                    lblInvAmt.Text = Convert.ToDecimal(dr["InvoiceAmount"]).ToString("N2");

                    lblTransDate.Text = Convert.ToDateTime(dr["TransactionDate"])
                                            .ToString("dd-MMM-yyyy ");

                    lblCreatedBy.Text = dr["CreatedBy"].ToString();

                    if (dr["DocumentPath"] != DBNull.Value)
                        lnkDocument.NavigateUrl = dr["DocumentPath"].ToString();
                    else
                        lnkDocument.NavigateUrl = "#";
                }

                dr.Close();
            }
        }


        protected void gvCompleted_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ShowTransaction")
            {
                string prsNo = e.CommandArgument.ToString();
                LoadTransactionDetails(prsNo);

                ScriptManager.RegisterStartupScript(this, GetType(),
                    "ShowTransModal", "openTransactionModal();", true);
            }
        }
    }
}
