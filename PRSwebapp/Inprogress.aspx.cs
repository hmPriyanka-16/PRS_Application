using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Collections.Generic;

namespace PRSwebapp
{
    public partial class InProgressTasks : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindInProgressTasks();
            }
        }

        private void BindInProgressTasks()
        {
            string deptId = Session["deptid"] as string;
            string connString = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

            string query = @"
                SELECT * FROM vw_PRSlist 
                WHERE PRSStatus <> 'Completed' 
                AND (Emp_code = @UserID OR Emp_code IS NULL)
                AND Deptid = @DeptId 
                ORDER BY duedate";

            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@UserID", Session["UserID"].ToString());
                cmd.Parameters.AddWithValue("@DeptId", deptId);

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            gvMainPending.DataSource = dt;
            gvMainPending.DataBind();
        }

        protected void gvMainPending_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            string connString = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

            if (e.CommandName == "ShowPRS")
            {
                string prsNo = e.CommandArgument.ToString();

                // Fetch PRS Main Details
                DataTable dt = new DataTable();
                using (SqlConnection con = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand("SELECT * FROM vw_PRSlist WHERE PRSNo=@PRSNo", con))
                {
                    cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }

                if (dt.Rows.Count > 0)
                {
                    var row = dt.Rows[0];
                    string prsType = row["PRSType"].ToString();
                    string info = "<table class='table table-borderless table-sm'><tbody>";

                    // PRS Info
                    info += AddRow("PRS No", row["PRSNo"]);
                    info += AddRow("PRS Type", prsType);
                    info += AddRow("Employee Name", row["Emp_Name"]);
                    info += AddRow("Employee ID", row["Emp_code"]);
                    info += AddRow("Department", row["Department"]);
                    info += AddRow("Amount", ConvertDecimal(row["Inoviceamount"]));
                    info += AddRow("Bill No", row["billno"]);
                    info += AddRow("Bill Date", ConvertDate(row["billdate"]));
                    info += AddRow("Due Date", ConvertDate(row["duedate"]));
                    info += AddRow("Nature of Expenses", row["Natureofexpenses"]);

                    info += "</tbody></table>";

                    // ★★★★★ CLAIM DETAILS FROM SP ★★★★★
                    DataTable dtClaims = new DataTable();
                    using (SqlConnection con = new SqlConnection(connString))
                    using (SqlCommand cmd = new SqlCommand("EXEC PR_PRCclaims @PRSNo", con))
                    {
                        cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dtClaims);
                        }
                    }

                    if (dtClaims.Rows.Count > 0)
                    {
                        info += "<hr/><b>Claim Details:</b><br/>";
                        info += "<table class='table table-sm table-bordered'><thead><tr>";

                        // Auto headers
                        foreach (DataColumn col in dtClaims.Columns)
                        {
                            info += $"<th>{col.ColumnName}</th>";
                        }

                        info += "</tr></thead><tbody>";

                        // Auto rows
                        foreach (DataRow claim in dtClaims.Rows)
                        {
                            info += "<tr>";
                            foreach (DataColumn col in dtClaims.Columns)
                            {
                                info += $"<td>{claim[col]?.ToString()}</td>";
                            }
                            info += "</tr>";
                        }

                        info += "</tbody></table>";
                    }

                    // Clear and bind trail
                    rpTrailHistory.DataSource = null;
                    rpTrailHistory.DataBind();

                    // Show Modal
                    string script = $@"
                        document.getElementById('prsDetail').innerHTML = `{info}`;
                        var myModal = new bootstrap.Modal(document.getElementById('prsModal'));
                        myModal.show();
                    ";

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowPRSModal", script, true);
                }
            }

            else if (e.CommandName == "ShowTrail")
            {
                string prsNo = e.CommandArgument.ToString();

                DataTable dtTrail = new DataTable();
                using (SqlConnection con = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT 
                        PT.prsno,
                        PT.prsstatus,
                        L.EmpName AS EmpName,
                        PT.Createdate AS [Date],
                        PP.Display,
                        PT.remark
                    FROM PRS_Transcation_Status PT
                    INNER JOIN PRS_Process_Approval_flow PP 
                        ON PT.userrole = PP.SeqID
                    LEFT JOIN login L
                        ON PT.userid = L.Employeeno
                    WHERE PT.prsno = @prsno
                    ORDER BY PT.id ASC", con))
                {
                    cmd.Parameters.AddWithValue("@prsno", prsNo);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dtTrail);
                    }
                }

                rpTrailHistory.DataSource = dtTrail;
                rpTrailHistory.DataBind();

                string script = $@"
                    document.getElementById('prsDetail').innerHTML = '<b>PRS No:</b> {prsNo}';
                    var myModal = new bootstrap.Modal(document.getElementById('prsModal'));
                    myModal.show();
                ";

                ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowTrailModal", script, true);
            }
        }

        // **************** HELPER FUNCTIONS ****************

        private string AddRow(string label, object value)
        {
            if (value == null || value == DBNull.Value || string.IsNullOrEmpty(value.ToString()))
                return "";

            return $"<tr><th style='width:150px'>{label}:</th><td>{value}</td></tr>";
        }

        private string ConvertDate(object value)
        {
            if (value == DBNull.Value) return "";
            return Convert.ToDateTime(value).ToString("dd-MMM-yyyy");
        }

        private string ConvertDecimal(object value)
        {
            if (value == DBNull.Value) return "";
            return Convert.ToDecimal(value).ToString("N2");
        }
    }
}
