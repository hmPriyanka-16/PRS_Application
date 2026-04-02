using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PRSwebapp
{
    public partial class PendingTask : System.Web.UI.Page
    {
        private readonly string connString = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["UserID"].ToString() == "")
            {
                Response.Redirect("Login.aspx");
            }

            if (!IsPostBack)
            {
                // Show Department dropdown only for Role > 2
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

                BindPendingTasks();
                ApplyColumnSecurity();
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
            BindPendingTasks();
        }

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
            DateTime? startDate = null;
            DateTime? prevDate = null;

            foreach (DataRow row in dtTrail.Rows)
            {
                DateTime currentDate = Convert.ToDateTime(row["Date"]);

                if (startDate == null)
                    startDate = currentDate;

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
                    timelineHtml += $"<div style='font-size:11px; color:#0d6efd; font-weight:600;'>⏱ Step TAT: {tat}</div>";
                }

                timelineHtml += $"<div style='font-size:12px; font-weight:bold; color:#d63384;'>{row["remark"]}</div>";

                timelineHtml += "</div></div>";

                prevDate = currentDate;
            }

            // ==========================
            // TOTAL TAT (First → Last)
            // ==========================
            string totalTAT = "";

            if (startDate != null && prevDate != null)
            {
                TimeSpan totalDiff = prevDate.Value - startDate.Value;

                if (totalDiff.TotalDays >= 1)
                    totalTAT = $"{(int)totalDiff.TotalDays}d {totalDiff.Hours}h {totalDiff.Minutes}m";
                else if (totalDiff.TotalHours >= 1)
                    totalTAT = $"{totalDiff.Hours}h {totalDiff.Minutes}m";
                else
                    totalTAT = $"{totalDiff.Minutes}m";
            }

            // ==========================
            // SHOW TOTAL AT TOP ✅
            // ==========================
            if (!string.IsNullOrEmpty(totalTAT))
            {
                string totalBox = $@"
        <div class='timeline-item mb-3'>
            <div class='timeline-content' style='background:#e9f5ff; border:1px solid #0d6efd;'>
                <div style='font-weight:bold; color:#0d6efd; font-size:13px;'>
                    ⏱ Total TAT: {totalTAT}
                </div>
            </div>
        </div>";

                timelineHtml = totalBox + timelineHtml; // 🔥 TOP placement
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

        private void BindPendingTasks()
        {
            string userId = Session["UserID"]?.ToString() ?? "0";
            string deptId = Session["deptid"]?.ToString() ?? "0";
            string role = Session["Role"]?.ToString() ?? "0";
            string hospitalId = Session["HospitalID"]?.ToString() ?? "0";

            // 🔹 Department dropdown value (only for role >2)
            string selectedDept = "";
            if (ddlDepartment != null && ddlDepartment.Visible && !string.IsNullOrEmpty(ddlDepartment.SelectedValue))
            {
                selectedDept = ddlDepartment.SelectedValue;
            }

            string deptFilter = "";
            if (!string.IsNullOrEmpty(selectedDept))
            {
                deptFilter = " AND DeptID = @DeptFilter ";
            }

            string mainQuery = "";

            switch (role.ToString())
            {
                case "1":
                case "2":
                case "51":
                case "52":
                case "53":
                case "54":

                    mainQuery = @"
        SELECT * 
        FROM vw_PRSlist 
        WHERE PRSStatus IN ('New', 'Approved')
          AND Next_Sequence = @Role
          AND HospitalID = @HospitalID 
          AND DeptID in(Select Deptid from login_role where userid in(@DeptID))";

                    deptId = Session["UserID"]?.ToString() ?? "0";
                    break;

                default:

                    mainQuery = @"
        SELECT * 
        FROM vw_PRSlist 
        WHERE PRSStatus IN ('New', 'Approved') 
          AND Next_Sequence = @Role
          AND HospitalID = @HospitalID
        " + deptFilter;

                    break;
            }

            if (string.IsNullOrWhiteSpace(mainQuery))
            {
                gvMainPending.DataSource = null;
                gvMainPending.DataBind();
                lblTotalPending.InnerText = "0";
                lblTotalAmount.InnerText = "0.00"; // ✅ added
                return;
            }

            DataTable dtMain = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(mainQuery, con))
            {
                cmd.Parameters.AddWithValue("@Role", role);
                cmd.Parameters.AddWithValue("@HospitalID", hospitalId);
                cmd.Parameters.AddWithValue("@DeptID", deptId);

                // 🔹 Add Department filter parameter only if used
                if (!string.IsNullOrEmpty(selectedDept))
                {
                    cmd.Parameters.AddWithValue("@DeptFilter", selectedDept);
                }

                new SqlDataAdapter(cmd).Fill(dtMain);
            }

            gvMainPending.DataSource = dtMain;
            gvMainPending.DataBind();

            // ✅ Total Pending Count
            lblTotalPending.InnerText = dtMain.Rows.Count.ToString();

            // ✅ Total Amount Calculation
            decimal totalAmount = 0;

            foreach (DataRow row in dtMain.Rows)
            {
                if (row["Inoviceamount"] != DBNull.Value)
                {
                    decimal amt;
                    if (decimal.TryParse(row["Inoviceamount"].ToString(), out amt))
                    {
                        totalAmount += amt;
                    }
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
                formattedAmount = (displayAmount / 1000).ToString("N2") + " k";
            }

            lblTotalAmount.InnerText = formattedAmount;
        }
        private void ApplyColumnSecurity()
        {
            string role = Session["Role"]?.ToString() ?? "0";

            foreach (DataControlField column in gvMainPending.Columns)
            {
                // Hide Approve column for Role 10
                if (column.HeaderText == "Action")
                {
                    column.Visible = role != "10";
                }

                // Show Transaction only for Role 10
                if (column.HeaderText == "Transaction")
                {
                    column.Visible = role == "10";
                }
            }
        }

        protected string GetTATDays(object prsDateObj)
        {
            if (prsDateObj == null || prsDateObj == DBNull.Value)
                return "-";

            // Parse PRS date including time
            if (!DateTime.TryParse(prsDateObj.ToString(), out DateTime prsDate))
                return "-";

            // Calculate the difference from now (including time)
            TimeSpan diff = DateTime.Now - prsDate;

            // Show only the largest relevant unit
            if (diff.TotalDays >= 1)
                return $"{diff.Days}d";       // full days
            else if (diff.TotalHours >= 1)
                return $"{diff.Hours}h";      // hours part of the day
            else if (diff.TotalMinutes >= 1)
                return $"{diff.Minutes}m";    // minutes part of the hour
            else
                return $"{diff.Seconds}s";    // seconds if less than a minute
        }
        protected void gvMainPending_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                string role = Session["Role"]?.ToString();

                // Change LinkButton to Button
                Button btnApprove = (Button)e.Row.FindControl("btnApprove");
                if (btnApprove != null)
                {
                    btnApprove.Text = role == "3" ? "Verified" : btnApprove.Text;
                }

                PlaceHolder phTransaction = (PlaceHolder)e.Row.FindControl("phTransaction");
                if (phTransaction != null)
                {
                    phTransaction.Visible = role == "10";
                }
            }
        }


        protected void gvMainPending_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string prsNo = e.CommandArgument.ToString();

            if (e.CommandName == "ShowAction")
            {
                // Find the row
                int rowIndex = ((GridViewRow)((Button)e.CommandSource).NamingContainer).RowIndex;
                GridViewRow row = gvMainPending.Rows[rowIndex];

                // Show the panel containing remarks and Approve/Hold/Reject
                Panel pnlAction = (Panel)row.FindControl("pnlAction");
                if (pnlAction != null)
                    pnlAction.Visible = !pnlAction.Visible; // toggle visibility
            }
            else if (e.CommandName == "Approve" || e.CommandName == "Hold" || e.CommandName == "Reject" || e.CommandName == "Query")
            {
                GridViewRow row = ((Button)e.CommandSource).NamingContainer as GridViewRow;

                if (row != null)
                {
                    TextBox txtRemarks = (TextBox)row.FindControl("txtRemarks");
                    string remarks = txtRemarks?.Text.Trim() ?? "";

                    // ✅ Make remarks mandatory for Hold, Reject, Query
                    if ((e.CommandName == "Hold" || e.CommandName == "Reject" || e.CommandName == "Query")
                        && string.IsNullOrWhiteSpace(remarks))
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "AlertMissing",
                            "alert('Remarks are mandatory for Hold, Reject and Query.');", true);
                        return;
                    }

                    string status =
                        e.CommandName == "Approve" ? "Approved" :
                        e.CommandName == "Hold" ? "Hold" :
                        e.CommandName == "Reject" ? "Rejected" :
                        "Query"; // ✅ added

                    UpdatePRSStatus(prsNo, status, remarks);

                    Panel pnlAction = (Panel)row.FindControl("pnlAction");
                    if (pnlAction != null)
                        pnlAction.Visible = false;

                    BindPendingTasks();
                    ApplyColumnSecurity();
                }
            }
            else
            {
                // Existing code (ShowPRS, ViewDocs, ViewTAT etc.)
            }
        }


        private void UpdatePRSStatus(string prsNo, string status, string comments = null)
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand("Pr_PRS", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                    cmd.Parameters.AddWithValue("@PRSStatus", status);
                    cmd.Parameters.AddWithValue("@Comments", string.IsNullOrEmpty(comments) ? DBNull.Value : (object)comments);
                    cmd.Parameters.AddWithValue("@user_ID", Session["UserID"]);
                    cmd.Parameters.AddWithValue("@user_role", Session["Role"]);

                    // Keep only required params for update
                    cmd.Parameters.AddWithValue("@TRANType", 0);
                    cmd.Parameters.AddWithValue("@PRSType", DBNull.Value);
                    cmd.Parameters.AddWithValue("@PONumber", DBNull.Value);
                    cmd.Parameters.AddWithValue("@billno", DBNull.Value);
                    cmd.Parameters.AddWithValue("@billdate", DBNull.Value);
                    cmd.Parameters.AddWithValue("@Inoviceamount", DBNull.Value);
                    cmd.Parameters.AddWithValue("@duedate", DBNull.Value);
                    cmd.Parameters.AddWithValue("@Natureofexpenses", DBNull.Value);
                    cmd.Parameters.AddWithValue("@Period", DBNull.Value);
                    cmd.Parameters.AddWithValue("@BillFrom", DBNull.Value);
                    cmd.Parameters.AddWithValue("@BillTo", DBNull.Value);
                    cmd.Parameters.AddWithValue("@Emp_Code", DBNull.Value);
                    cmd.Parameters.AddWithValue("@Emp_Name", DBNull.Value);
                    cmd.Parameters.AddWithValue("@Emp_Designation", DBNull.Value);
                    cmd.Parameters.AddWithValue("@Emp_Department", DBNull.Value);
                    cmd.Parameters.AddWithValue("@HospitalID", Session["HospitalID"]);
                    cmd.Parameters.AddWithValue("@supplierID", DBNull.Value);

                    cmd.ExecuteNonQuery();
                }
            }
        }
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

        protected void btnSubmitTransaction_Click(object sender, EventArgs e)
        {
            string prsNo = hfTransactionPRSNo.Value?.Trim();
            string transactionID = txtTransactionID.Text.Trim();
            if (string.IsNullOrEmpty(transactionID))
                transactionID = "TR" + DateTime.UtcNow.Ticks.ToString();

            if (string.IsNullOrEmpty(prsNo))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "AlertMissing", "alert('PRS No is required.');", true);
                return;
            }

            DateTime prsDateValue;
            if (!DateTime.TryParseExact(hfPRSDate.Value, "yyyy-MM-dd", CultureInfo.InvariantCulture,
                DateTimeStyles.None, out prsDateValue))
            {
                prsDateValue = DateTime.Now;
            }

            decimal invoiceAmountValue;
            decimal.TryParse(hfInvoiceAmount.Value.Replace(",", ""), NumberStyles.Any, CultureInfo.InvariantCulture, out invoiceAmountValue);

            DateTime transactionDate;
            if (!DateTime.TryParse(txtTransactionDate.Text, out transactionDate))
                transactionDate = DateTime.Now;

            string filePath = null;
            if (fuTransactionDocs.HasFile)
            {
                string folderPath = Server.MapPath($"~/TransactionDocs/{prsNo}/");
                if (!Directory.Exists(folderPath)) Directory.CreateDirectory(folderPath);

                string fileName = Guid.NewGuid().ToString() + "_" + Path.GetFileName(fuTransactionDocs.FileName);
                string savedPath = Path.Combine(folderPath, fileName);
                fuTransactionDocs.SaveAs(savedPath);

                filePath = $"~/TransactionDocs/{prsNo}/{fileName}";
            }

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand("Pr_AddTransaction", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@TransactionID", transactionID);
                    cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                    cmd.Parameters.AddWithValue("@PRSdate", prsDateValue);
                    cmd.Parameters.AddWithValue("@InvoiceAmount", invoiceAmountValue);
                    cmd.Parameters.AddWithValue("@TransactionDate", transactionDate);
                    cmd.Parameters.AddWithValue("@DocumentPath", (object)filePath ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@CreatedBy", Session["UserID"] ?? "System");

                    cmd.ExecuteNonQuery();
                }
            }

            UpdatePRSStatus(prsNo, "Approved");

            txtTransactionID.Text = "";
            txtTransactionPRSNo.Text = "";
            txtPODate.Text = "";
            txtInvoiceAmount.Text = "";
            txtTransactionDate.Text = "";
            hfPRSDate.Value = "";
            hfInvoiceAmount.Value = "";
            hfTransactionPRSNo.Value = "";

            BindPendingTasks();
            ApplyColumnSecurity();

            ScriptManager.RegisterStartupScript(this, GetType(), "CloseTransactionModal",
                "var m = bootstrap.Modal.getInstance(document.getElementById('transactionModal')); if(m) m.hide(); alert('Transaction saved and PRS approved!');", true);
        }

        protected void gvMainPending_SelectedIndexChanged(object sender, EventArgs e)
        {

        }
    }
}
