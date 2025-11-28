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

                    // PRS No
                    if (row["PRSNo"] != DBNull.Value && !string.IsNullOrEmpty(row["PRSNo"].ToString()))
                        info += $"<tr><th style='width:150px;'>PRS No:</th><td>{row["PRSNo"]}</td></tr>";

                    // PRS Type
                    if (!string.IsNullOrEmpty(prsType))
                        info += $"<tr><th>PRS Type:</th><td>{prsType}</td></tr>";

                    // Employee info
                    if (prsType == "Expense" || prsType == "Advance" || prsType == "Conveyance")
                    {
                        if (row["Emp_Name"] != DBNull.Value && !string.IsNullOrEmpty(row["Emp_Name"].ToString()))
                            info += $"<tr><th>Employee Name:</th><td>{row["Emp_Name"]}</td></tr>";

                        if (row["Emp_code"] != DBNull.Value && !string.IsNullOrEmpty(row["Emp_code"].ToString()))
                            info += $"<tr><th>Employee ID:</th><td>{row["Emp_code"]}</td></tr>";
                    }
                    else
                    {
                        if (row["SupplierName"] != DBNull.Value && !string.IsNullOrEmpty(row["SupplierName"].ToString()))
                            info += $"<tr><th>Supplier:</th><td>{row["SupplierName"]}</td></tr>";
                    }

                    // Department
                    if (row["Department"] != DBNull.Value && !string.IsNullOrEmpty(row["Department"].ToString()))
                        info += $"<tr><th>Department:</th><td>{row["Department"]}</td></tr>";

                    // Amount
                    if (row["Inoviceamount"] != DBNull.Value)
                        info += $"<tr><th>Amount:</th><td>{Convert.ToDecimal(row["Inoviceamount"]):N2}</td></tr>";

                    // Bill No
                    if (row["billno"] != DBNull.Value && !string.IsNullOrEmpty(row["billno"].ToString()))
                        info += $"<tr><th>Bill No:</th><td>{row["billno"]}</td></tr>";

                    // Bill Date
                    if (row["billdate"] != DBNull.Value)
                        info += $"<tr><th>Bill Date:</th><td>{Convert.ToDateTime(row["billdate"]).ToString("dd-MMM-yyyy")}</td></tr>";

                    // Due Date
                    if (row["duedate"] != DBNull.Value)
                        info += $"<tr><th>Due Date:</th><td>{Convert.ToDateTime(row["duedate"]).ToString("dd-MMM-yyyy")}</td></tr>";

                    // Nature of Expenses
                    if (row["Natureofexpenses"] != DBNull.Value && !string.IsNullOrEmpty(row["Natureofexpenses"].ToString()))
                        info += $"<tr><th>Nature of Expenses:</th><td>{row["Natureofexpenses"]}</td></tr>";

                    info += "</tbody></table>";

                    // PRS Claims
                    if (prsType == "Expense" || prsType == "Advance" || prsType == "Conveyance")
                    {
                        DataTable dtClaims = new DataTable();
                        using (SqlConnection con = new SqlConnection(connString))
                        using (SqlCommand cmd = new SqlCommand("SELECT * FROM PRS_Claims WHERE PRSNO=@PRSNo ORDER BY SLno ASC", con))
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

                            // Determine columns to display dynamically
                            string[] allColumns = { "SLno", "PARTICULARS", "PARTICULARS2", "PURPOSE", "BillNo_Mode", "BillDate_Distance", "Comments","Amount" };
                            List<string> displayColumns = new List<string>();

                            foreach (string col in allColumns)
                            {
                                foreach (DataRow r in dtClaims.Rows)
                                {
                                    if (r[col] != DBNull.Value && !string.IsNullOrEmpty(r[col].ToString()))
                                    {
                                        displayColumns.Add(col);
                                        break;
                                    }
                                }
                            }

                            // Generate headers
                            foreach (string col in displayColumns)
                                info += $"<th>{col}</th>";

                            info += "</tr></thead><tbody>";

                            // Generate rows
                            foreach (DataRow claim in dtClaims.Rows)
                            {
                                info += "<tr>";
                                foreach (string col in displayColumns)
                                {
                                    string val = claim[col] != DBNull.Value ? claim[col].ToString() : "";
                                    info += $"<td>{val}</td>";
                                }
                                info += "</tr>";
                            }

                            info += "</tbody></table>";
                        }
                    }

                    // Clear trail repeater
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
                string[] args = e.CommandArgument.ToString().Split('|');
                string prsNo = args[0];

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
    }
}
