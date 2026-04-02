using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using ClosedXML.Excel;
using System.IO;
using System.Web.UI.WebControls;

namespace PRSwebapp
{
    public partial class InProgressTasks : System.Web.UI.Page
    {
        // ================================
        // Class-level connection string
        // ================================
        string connString = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["UserID"].ToString() == "")
            {
                Response.Redirect("Login.aspx");
              
            }

            if (!IsPostBack)
            {
                // Show department dropdown only for role > 2
                int role = Convert.ToInt32(Session["Role"]);

                // Show department dropdown only for role >2 BUT NOT 51 & 52
                if (role > 2 && role != 51 && role != 52)
                {
                    ddlDepartment.Visible = true;
                    BindDepartments();
                }
                else
                {
                    ddlDepartment.Visible = false;
                }

                BindInProgressTasks();
            }
        }
        private void BindDepartments()
        {
            DataTable dt = new DataTable();

            string query = @"SELECT DISTINCT D.ID, D.Name
                     FROM Login_role LR
                     INNER JOIN Department D ON LR.DeptID = D.ID
                     ORDER BY D.Name";

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            ddlDepartment.DataSource = dt;
            ddlDepartment.DataTextField = "Name";   // department name
            ddlDepartment.DataValueField = "ID";    // department id
            ddlDepartment.DataBind();

            ddlDepartment.Items.Insert(0, new ListItem("All Departments", ""));
        }
        protected void ddlDepartment_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindInProgressTasks();
        }
        // ================================
        // Bind In Progress Tasks
        // ================================
        protected string GetTATDays(object prsDateObj)
        {
            if (prsDateObj == null || prsDateObj == DBNull.Value)
                return "-";

            DateTime prsDate;
            if (!DateTime.TryParse(prsDateObj.ToString(), out prsDate))
                return "-";

            TimeSpan diff = DateTime.Now - prsDate;

            if (diff.TotalDays >= 1)
                return $"{(int)diff.TotalDays}d";
            else if (diff.TotalHours >= 1)
                return $"{(int)diff.TotalHours}h";
            else
                return $"{(int)diff.TotalMinutes}m";
        }
        private void BindInProgressTasks()
        {
            int hospitalId = 0;

            if (Session["HospitalID"] != null)
                int.TryParse(Session["HospitalID"].ToString(), out hospitalId);

            string query = "";

            switch (Session["Role"].ToString())
            {
                case "1":
                case "51":
                case "52":
                case "53":
                case "54":
                    query = @"
            SELECT * FROM vw_PRSlist 
            WHERE PRSStatus IN ('New', 'Approved')
              AND (Emp_code = @UserID OR Emp_code IS NULL)
              AND (Deptid IN (SELECT DeptID FROM Login_role WHERE UserID = @UserID))
              AND HospitalID = @HospitalID
            ORDER BY PRSdate";
                    break;

                case "2":
                    query = @"
            SELECT * FROM vw_PRSlist 
            WHERE PRSStatus IN ('New', 'Approved')
              AND (Deptid IN (SELECT DeptID FROM Login_role WHERE UserID = @UserID))
              AND HospitalID = @HospitalID
            ORDER BY PRSdate";
                    break;

                default:
                    string deptFilter = "";

                    if (ddlDepartment != null && !string.IsNullOrEmpty(ddlDepartment.SelectedValue))
                    {
                        deptFilter = " AND Deptid = @DeptID ";
                    }

                    query = @"
            SELECT * FROM vw_PRSlist 
            WHERE PRSStatus IN ('New', 'Approved')
            " + deptFilter + @"
            ORDER BY PRSdate";
                    break;
            }

            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@UserID", Session["UserID"].ToString());
                cmd.Parameters.AddWithValue("@HospitalID", hospitalId);

                if (Session["Role"].ToString() != "1" &&
                    Session["Role"].ToString() != "2" &&
                    Session["Role"].ToString() != "51" &&
                    Session["Role"].ToString() != "52" &&
                    Session["Role"].ToString() != "53" &&
                    Session["Role"].ToString() != "54")
                {
                    if (ddlDepartment != null && !string.IsNullOrEmpty(ddlDepartment.SelectedValue))
                    {
                        cmd.Parameters.AddWithValue("@DeptID", ddlDepartment.SelectedValue);
                    }
                }

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            // ✅ Bind Grid
            gvMainPending.DataSource = dt;
            gvMainPending.DataBind();

            // ✅ NEW: Calculate Summary
            lblTotalTasks.Text = dt.Rows.Count.ToString();

            decimal totalAmount = 0;
            foreach (DataRow row in dt.Rows)
            {
                if (row["Inoviceamount"] != DBNull.Value)
                {
                    totalAmount += Convert.ToDecimal(row["Inoviceamount"]);
                }
            }

            decimal displayAmount = totalAmount;
            string formattedAmount = "";

            if (displayAmount >= 100000) // Lakhs
            {
                formattedAmount = (displayAmount / 100000).ToString("N2") + " L";
            }
            else // Thousands
            {
                formattedAmount = (displayAmount / 1000).ToString("N2") + " K";
            }

            lblTotalAmount.Text = formattedAmount;
        } // ================================
          // GridView RowCommand
          // ================================
        [System.Web.Services.WebMethod]
        public static object GetPRSTAT(string prsNo, string supplier, string dept, string amount)
        {
            string connString = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

            string info = "<table class='table table-sm table-borderless'>";

            info += $"<tr><th>PRS No:</th><td>{prsNo}</td></tr>";
            info += $"<tr><th>Supplier:</th><td>{supplier}</td></tr>";
            info += $"<tr><th>Department:</th><td>{dept}</td></tr>";
            info += $"<tr><th>Amount:</th><td>{amount}</td></tr>";

            // ============================
            // PRS Details
            // ============================
            DataTable dtPRS = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT PRSType, RingNumber, billno, billdate, duedate, Natureofexpenses FROM vw_PRSlist WHERE PRSNo = @PRSNo", con))
            {
                cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                new SqlDataAdapter(cmd).Fill(dtPRS);
            }

            if (dtPRS.Rows.Count > 0)
            {
                var r = dtPRS.Rows[0];
                if (!string.IsNullOrWhiteSpace(r["PRSType"].ToString()))
                    info += $"<tr><th>PRS Type:</th><td>{r["PRSType"]}</td></tr>";
                if (!string.IsNullOrWhiteSpace(r["RingNumber"].ToString()))
                    info += $"<tr><th>Ringi Number:</th><td>{r["RingNumber"]}</td></tr>";
                if (!string.IsNullOrWhiteSpace(r["billno"].ToString()))
                    info += $"<tr><th>Bill No:</th><td>{r["billno"]}</td></tr>";
                if (DateTime.TryParse(r["billdate"].ToString(), out DateTime bd))
                    info += $"<tr><th>Bill Date:</th><td>{bd:dd-MMM-yyyy}</td></tr>";
                if (DateTime.TryParse(r["duedate"].ToString(), out DateTime dd))
                    info += $"<tr><th>Due Date:</th><td>{dd:dd-MMM-yyyy}</td></tr>";
                if (!string.IsNullOrWhiteSpace(r["Natureofexpenses"].ToString()))
                    info += $"<tr><th>Nature of Expenses:</th><td>{r["Natureofexpenses"]}</td></tr>";
            }

            info += "</table>";

            // ============================
            // Claim Details
            // ============================
            DataTable dtClaims = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("EXEC PR_PRCclaims @PRSNo", con))
            {
                cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                new SqlDataAdapter(cmd).Fill(dtClaims);
            }

            if (dtClaims.Rows.Count > 0)
            {
                info += "<hr/><b>Claim Details:</b><br/>";
                info += "<table class='table table-sm table-bordered'><thead><tr>";
                foreach (DataColumn col in dtClaims.Columns)
                {
                    info += $"<th>{HttpUtility.HtmlEncode(col.ColumnName)}</th>";
                }
                info += "</tr></thead><tbody>";
                foreach (DataRow claim in dtClaims.Rows)
                {
                    info += "<tr>";
                    foreach (DataColumn col in dtClaims.Columns)
                    {
                        var val = claim[col];
                        info += $"<td>{(val != DBNull.Value && !string.IsNullOrWhiteSpace(val.ToString()) ? HttpUtility.HtmlEncode(val.ToString()) : "")}</td>";
                    }
                    info += "</tr>";
                }
                info += "</tbody></table>";
            }

            // ============================
            // Timeline
            // ============================
            DataTable dtTrail = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT prsstatus, Date, EmpName, userid, Display, remark FROM vw_PRS_Transcation_Status WHERE prsno = @PRSNo ORDER BY id ASC", con))
            {
                cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                new SqlDataAdapter(cmd).Fill(dtTrail);
            }

            string timelineHtml = "";
            DateTime? prevDate = null;

            foreach (DataRow row in dtTrail.Rows)
            {
                DateTime currentDate = Convert.ToDateTime(row["Date"]);

                string tat = "";
                if (prevDate != null)
                {
                    TimeSpan diff = currentDate - prevDate.Value;

                    if (diff.TotalDays >= 1)
                        tat = $"{(int)diff.TotalDays}d {diff.Hours}h {diff.Minutes}m";
                    else if (diff.TotalHours >= 1)
                        tat = $"{diff.Hours}h {diff.Minutes}m";
                    else
                        tat = $"{diff.Minutes}m";
                }

                timelineHtml += "<div class='timeline-item mb-3'>";
                timelineHtml += "<div class='timeline-content'>";

                timelineHtml += $"<div class='fw-bold'>{row["prsstatus"]}</div>";

                timelineHtml += $"<div style='font-size:12px;'>" +
                                $"{currentDate:dd-MMM-yyyy hh:mm tt} | {row["EmpName"]} ({row["userid"]}) | {row["Display"]}" +
                                $"</div>";

                if (!string.IsNullOrEmpty(tat))
                {
                    timelineHtml += $"<div style='font-size:11px; color:#0d6efd; font-weight:600;'>⏱ TAT: {tat}</div>";
                }

                timelineHtml += $"<div style='font-size:12px; font-weight:bold; color:#d63384;'>{row["remark"]}</div>";

                timelineHtml += "</div></div>";

                prevDate = currentDate;
            }

            return new { header = info, timeline = timelineHtml };
        }
        [System.Web.Services.WebMethod]
        public static object GetDocuments(string poNumber)
        {
            string connString = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

            DataTable dt = new DataTable();
            string query = @"
    SELECT 0 AS TypeID, PONumber, FileName, FilePath, UploadDate
    FROM SupplierDocuments
    WHERE PONumber = @PONumber AND status = 0
    UNION ALL
    SELECT 1 AS TypeID, SP.PONumber, RF.FileName,
           'https://ringi.sakraworldhospital.com:8095/RINGI/' + R.ReqNo + '/' + RF.FileName AS FilePath,
           R.TranDate AS UploadDate
    FROM Request_Master R
    INNER JOIN Req_File RF ON R.ReqNo = RF.ReqNo
    INNER JOIN SupplierPOEntry SP ON R.RINGINO = SP.RingNumber
    WHERE SP.PONumber = @PONumber
    ORDER BY UploadDate DESC";

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@PONumber", poNumber);
                new SqlDataAdapter(cmd).Fill(dt);
            }

            var list = dt.AsEnumerable().Select(r => new
            {
                TypeID = r["TypeID"],
                PONumber = r["PONumber"],
                FileName = r["FileName"],
                FilePath = r["FilePath"],
                UploadDate = r["UploadDate"] != DBNull.Value ? Convert.ToDateTime(r["UploadDate"]).ToString("dd-MMM-yyyy") : ""
            }).ToList();

            return list;
        }
        [System.Web.Services.WebMethod]
        public static string GetPRSDetails(string prsNo)
        {
            if (string.IsNullOrEmpty(prsNo))
                return ""; // Return empty if no PRS No

            string connString = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

            DataTable dt = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("SELECT * FROM vw_PRSlist WHERE PRSNo=@PRSNo", con))
            {
                cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                new SqlDataAdapter(cmd).Fill(dt);
            }

            if (dt.Rows.Count == 0)
                return ""; // No data found

            var row = dt.Rows[0];
            string info = "<table class='table table-borderless table-sm'><tbody>";

            info += AddRow("PRS No", row["PRSNo"]);
            info += AddRow("PRS Type", row["PRSType"]);
            info += AddRow("Employee Name", row["Emp_Name"]);
            info += AddRow("Employee ID", row["Emp_code"]);
            info += AddRow("RingNumber", row["RingNumber"]);
            info += AddRow("SupplierName", row["SupplierName"]);
            info += AddRow("Department", row["Department"]);
            info += AddRow("Amount", row["Inoviceamount"]);
            info += AddRow("Bill No", row["billno"]);
            info += AddRow("Bill Date", row["billdate"]);
            info += AddRow("Due Date", row["duedate"]);
            info += AddRow("Nature of Expenses", row["Natureofexpenses"]);
            info += "</tbody></table>";

            // Claim Details
            DataTable dtClaims = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("EXEC PR_PRCclaims @PRSNo", con))
            {
                cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                new SqlDataAdapter(cmd).Fill(dtClaims);
            }

            if (dtClaims.Rows.Count > 0)
            {
                info += "<hr/><b>Claim Details:</b><br/>";
                info += "<table class='table table-sm table-bordered'><thead><tr>";
                foreach (DataColumn col in dtClaims.Columns)
                {
                    info += $"<th>{HttpUtility.HtmlEncode(col.ColumnName)}</th>";
                }
                info += "</tr></thead><tbody>";

                foreach (DataRow claim in dtClaims.Rows)
                {
                    info += "<tr>";
                    foreach (DataColumn col in dtClaims.Columns)
                    {
                        var val = claim[col];
                        info += $"<td>{(val != DBNull.Value && !string.IsNullOrWhiteSpace(val.ToString()) ? HttpUtility.HtmlEncode(val.ToString()) : "-")}</td>";
                    }
                    info += "</tr>";
                }
                info += "</tbody></table>";
            }

            return info; // Return HTML string
        }

        private static string AddRow(string label, object value)
        {
            if (value == null || value == DBNull.Value || string.IsNullOrWhiteSpace(value.ToString()))
                return "";

            string displayValue = value.ToString();

            if (label != "Employee ID")
            {
                if (decimal.TryParse(displayValue, out decimal dec))
                    displayValue = dec.ToString("N2");
            }

            if (DateTime.TryParse(displayValue, out DateTime dt))
                displayValue = dt.ToString("dd-MMM-yyyy");

            return $"<tr><th style='width:150px'>{HttpUtility.HtmlEncode(label)}</th><td>{HttpUtility.HtmlEncode(displayValue)}</td></tr>";
        }

        protected void gvMainPending_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            // -------------------------
            // SHOW PRS (Main Details)
            // -------------------------
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

                    
                    info += "</tbody></table>";

                    // -------------------------
                    // CLAIM DETAILS FROM SP
                    // -------------------------
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

                        foreach (DataColumn col in dtClaims.Columns)
                        {
                            info += $"<th>{col.ColumnName}</th>";
                        }

                        info += "</tr></thead><tbody>";

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

                    

                    string script = $@"
                        document.getElementById('prsDetail').innerHTML = `{info}`;
                        var myModal = new bootstrap.Modal(document.getElementById('prsModal'));
                        myModal.show();
                    ";
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowPRSModal", script, true);
                }
            }

            // -------------------------
            // SHOW TRAIL (Status History)
            // -------------------------
            else if (e.CommandName == "ViewTAT")
            {
                string[] data = e.CommandArgument.ToString().Split('|');

                string prsNo = data.Length > 0 ? data[0] : "";
                string supplier = data.Length > 1 ? data[1] : "";
                string dept = data.Length > 2 ? data[2] : "";
                string amount = data.Length > 3 ? Convert.ToDecimal(data[3]).ToString("N2") : "";

                // ============================
                // 1️⃣ Trail History
                // ============================
                DataTable dtTrail = new DataTable();
                using (SqlConnection con = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT * FROM vw_PRS_Transcation_Status WHERE prsno = @prsno ORDER BY id ASC", con))
                {
                    cmd.Parameters.AddWithValue("@prsno", prsNo);
                    new SqlDataAdapter(cmd).Fill(dtTrail);
                }

               


                // ============================
                // 2️⃣ PRS Details
                // ============================
                DataTable dtPRS = new DataTable();
                using (SqlConnection con = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT PRSType, RingNumber, billno, billdate, duedate, Natureofexpenses FROM vw_PRSlist WHERE PRSNo = @PRSNo", con))
                {
                    cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                    new SqlDataAdapter(cmd).Fill(dtPRS);
                }

                string prsType = "";
                string ringNo = "";
                string billNo = "";
                string billDate = "";
                string dueDate = "";
                string nature = "";

                if (dtPRS.Rows.Count > 0)
                {
                    var r = dtPRS.Rows[0];

                    prsType = r["PRSType"]?.ToString();
                    ringNo = r["RingNumber"]?.ToString();
                    billNo = r["billno"]?.ToString();
                    nature = r["Natureofexpenses"]?.ToString();

                    DateTime tempDate;

                    if (DateTime.TryParse(r["billdate"]?.ToString(), out tempDate))
                        billDate = tempDate.ToString("dd-MMM-yyyy");

                    if (DateTime.TryParse(r["duedate"]?.ToString(), out tempDate))
                        dueDate = tempDate.ToString("dd-MMM-yyyy");
                }


                // ============================
                // 3️⃣ Build Header (Only If Data Exists)
                // ============================
                string info = "<table class='table table-sm table-borderless'>";

                info += $"<tr><th>PRS No:</th><td>{prsNo}</td></tr>";
                info += $"<tr><th>Supplier:</th><td>{supplier}</td></tr>";
                info += $"<tr><th>Department:</th><td>{dept}</td></tr>";
                info += $"<tr><th>Amount:</th><td>{amount}</td></tr>";

                if (!string.IsNullOrWhiteSpace(prsType))
                    info += $"<tr><th>PRS Type:</th><td>{prsType}</td></tr>";

                if (!string.IsNullOrWhiteSpace(ringNo))
                    info += $"<tr><th>Ringi Number:</th><td>{ringNo}</td></tr>";

                if (!string.IsNullOrWhiteSpace(billNo))
                    info += $"<tr><th>Bill No:</th><td>{billNo}</td></tr>";

                if (!string.IsNullOrWhiteSpace(billDate))
                    info += $"<tr><th>Bill Date:</th><td>{billDate}</td></tr>";

                if (!string.IsNullOrWhiteSpace(dueDate))
                    info += $"<tr><th>Due Date:</th><td>{dueDate}</td></tr>";

                if (!string.IsNullOrWhiteSpace(nature))
                    info += $"<tr><th>Nature of Expenses:</th><td>{nature}</td></tr>";

                info += "</table>";


                // ============================
                // 4️⃣ Claim Details
                // ============================
                DataTable dtClaims = new DataTable();
                using (SqlConnection con = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand("EXEC PR_PRCclaims @PRSNo", con))
                {
                    cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                    new SqlDataAdapter(cmd).Fill(dtClaims);
                }

                if (dtClaims.Rows.Count > 0)
                {
                    info += "<hr/><b>Claim Details:</b><br/>";
                    info += "<table class='table table-sm table-bordered'><thead><tr>";

                    foreach (DataColumn col in dtClaims.Columns)
                    {
                        info += $"<th>{HttpUtility.HtmlEncode(col.ColumnName)}</th>";
                    }

                    info += "</tr></thead><tbody>";

                    foreach (DataRow claim in dtClaims.Rows)
                    {
                        info += "<tr>";

                        foreach (DataColumn col in dtClaims.Columns)
                        {
                            var val = claim[col];

                            if (val != DBNull.Value && !string.IsNullOrWhiteSpace(val.ToString()))
                                info += $"<td>{HttpUtility.HtmlEncode(val.ToString())}</td>";
                            else
                                info += "<td></td>";   // Empty instead of "-"
                        }

                        info += "</tr>";
                    }

                    info += "</tbody></table>";
                }


                // ============================
                // 5️⃣ Show Modal
                // ============================
                string script = $@"
        document.getElementById('trailHeader').innerHTML = `{info}`;
        var myModal = new bootstrap.Modal(document.getElementById('trailModal'));
        myModal.show();";

                ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowTrailModal", script, true);
            }

            // -------------------------
            // VIEW DOCUMENTS
            // -------------------------
            else if (e.CommandName == "ViewDocs")
            {
                string poNumber = e.CommandArgument.ToString();
                LoadDocuments(poNumber);
            }
        }

        protected void btnExport_Click(object sender, EventArgs e)
        {
            int hospitalId = 0;

            if (Session["HospitalID"] != null)
                int.TryParse(Session["HospitalID"].ToString(), out hospitalId);

            string query = "";

            switch (Session["Role"].ToString())
            {
                case "1":
                case "2":
                case "11":
                case "12":
                case "13":
                case "14":
                    query = @"
                SELECT PRSNo AS [PRS No],
                       PRSdate AS [PRS Date],
                       PRSType AS [PRS Type],
                       Department,
                       SupplierCode AS [Supplier/Emp Code],
                       SupplierName AS [Supplier/Emp Name],
                       billno AS [Bill No],
                       billdate AS [Bill Date],
                       duedate AS [Due Date],
                       Inoviceamount AS [Amount],
                       Natureofexpenses AS [Nature Of Expenses],
                       LastAction AS [Last Approver],
                       Next_Action AS [Next Approver]
                FROM vw_PRSlist
                WHERE PRSStatus IN ('New', 'Approved')
                  AND (Emp_code = @UserID OR Emp_code IS NULL)
                  AND (Deptid IN (SELECT DeptID FROM Login_role WHERE UserID = @UserID))
                  AND HospitalID = @HospitalID
                ORDER BY duedate";
                    break;

                default:
                    query = @"
                SELECT PRSNo AS [PRS No],
                       PRSdate AS [PRS Date],
                       PRSType AS [PRS Type],
                       Department,
                       SupplierCode AS [Supplier/Emp Code],
                       SupplierName AS [Supplier/Emp Name],
                       billno AS [Bill No],
                       billdate AS [Bill Date],
                       duedate AS [Due Date],
                       Inoviceamount AS [Amount],
                       Natureofexpenses AS [Nature Of Expenses],
                       LastAction AS [Last Approver],
                       Next_Action AS [Next Approver]
                FROM vw_PRSlist
                WHERE IN ('New', 'Approved')
                ORDER BY duedate";
                    break;
            }

            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@UserID", Session["UserID"].ToString());
                cmd.Parameters.AddWithValue("@HospitalID", hospitalId);

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            using (XLWorkbook wb = new XLWorkbook())
            {
                var ws = wb.Worksheets.Add("InProgressPRS");

                ws.Cell(1, 1).InsertTable(dt);

                // Style header
                var headerRange = ws.Range(1, 1, 1, dt.Columns.Count);
                headerRange.Style.Font.Bold = true;
                headerRange.Style.Fill.BackgroundColor = XLColor.LightGray;

                ws.Columns().AdjustToContents();

                Response.Clear();
                Response.ContentType =
                    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                Response.AddHeader("content-disposition",
                    "attachment;filename=InProgressPRS.xlsx");

                using (MemoryStream stream = new MemoryStream())
                {
                    wb.SaveAs(stream);
                    stream.WriteTo(Response.OutputStream);
                    Response.Flush();
                    HttpContext.Current.ApplicationInstance.CompleteRequest();
                }
            }
        }
        // ================================
        // Load Documents for PO
        // ================================
        private void LoadDocuments(string poNumber)
        {
            DataTable dt = new DataTable();
            string query = @"
                Select * from (
                SELECT 0 TypeID,PONumber, FileName, FilePath, UploadDate
                FROM SupplierDocuments
                WHERE PONumber = @PONumber
Union All
    Select 1 TypeID,SP.PONumber,RF.FileName,
                'https://ringi.sakraworldhospital.com:8095/RINGI/' + R.ReqNo + '/' + RF.FileName 'FilePath',
                R.TranDate UploadDate
                from Request_Master R
                Inner Join Req_File RF on R.ReqNo=RF.ReqNo 
                Inner Join SupplierPOEntry SP on R.RINGINO=SP.RingNumber
                WHERE SP.PONumber = @PONumber) M 
                ORDER BY UploadDate DESC";

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@PONumber", poNumber);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            foreach (DataRow row in dt.Rows)
            {
                if (row["FilePath"] != DBNull.Value)
                {
                    string filePath = row["FilePath"].ToString();
                    
                    if (row["TypeID"].ToString() == "0")
                    {
                        string folder = VirtualPathUtility.GetDirectory(filePath);
                        string fileName = System.IO.Path.GetFileName(filePath);

                        string safeFileName = string.Concat(
                            fileName.Select(c =>
                                char.IsLetterOrDigit(c) || c == '.' || c == '_' || c == '-' || c == ' '
                                    ? c.ToString()
                                    : Uri.HexEscape(c)
                            )
                        );
                        row["FilePath"] = ResolveUrl(folder + safeFileName);
                    }                
                    else
                    {
                        row["FilePath"] = ResolveUrl(filePath);
                    }
                }
            }

           
            ScriptManager.RegisterStartupScript(this, GetType(), "ShowDocsModal", "showDocsModal();", true);
        }

        // ================================
        // Helper Functions
        // ================================
       

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
