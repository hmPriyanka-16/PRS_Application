using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ClosedXML.Excel;
using System.IO;

namespace PRSwebapp
{
    public partial class CompletedTask : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"].ToString() == null || Session["UserID"].ToString() == "")
            {
                Response.Redirect("Login.aspx");
            }

            if (!IsPostBack)
            {
                txtFromDate.Text = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1)
                                    .AddMonths(-1).ToString("yyyy-MM-dd");

                txtToDate.Text = DateTime.Today.ToString("yyyy-MM-dd");

                ViewState["SelectedPRS"] = "Capex Advance PRS";

                int role = Convert.ToInt32(Session["Role"]);

                // Department filter only for Role > 2
                // Department filter only for Role > 2 but NOT for 51 and 52
                if (role > 2 && role != 51 && role != 52)
                {
                    divDepartment.Visible = true;
                    BindDepartments();
                }
                else
                {
                    divDepartment.Visible = false;
                }

                BindCompletedTasks();
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
            ddlDepartment.Items.Insert(0, new ListItem("All Departments", "ALL"));
        }
        protected void ddlDepartment_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindCompletedTasks();
        }
        protected void ddlPRSType_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindCompletedTasks();
        }
        protected void PRS_Click(object sender, EventArgs e)
        {
            LinkButton clicked = (LinkButton)sender;
            ViewState["SelectedPRS"] = clicked.Text;
         
            BindCompletedTasks();
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
            DateTime? prevDate = null;

            foreach (DataRow row in dtTrail.Rows)
            {
                DateTime currentDate = Convert.ToDateTime(row["Date"]);

                string tat = "";

                if (prevDate != null)
                {
                    TimeSpan diff = currentDate - prevDate.Value;

                    int totalDays = (int)diff.TotalDays;
                    int totalHours = (int)diff.TotalHours;
                    int remainingHours = diff.Hours;
                    int minutes = diff.Minutes;

                    if (totalDays >= 1)
                        tat = $"{totalDays}d {remainingHours}h {minutes}m";
                    else if (totalHours >= 1)
                        tat = $"{totalHours}h {minutes}m";
                    else
                        tat = $"{minutes}m";
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

        protected void btnShow_Click(object sender, EventArgs e)
        {
            BindCompletedTasks();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtFromDate.Text = "";
            txtToDate.Text = "";

            // Rebind using default dates
            BindCompletedTasks();
        }

        // ============================================================
        // MAIN FUNCTION TO LOAD COMPLETED TASKS WITH CORRECT PRS TYPE
        // ============================================================
        private void BindCompletedTasks()
        {
            if (ViewState["SelectedPRS"] == null) return;

            string prsType = ddlPRSType.SelectedValue;
            string query = "";

            using (SqlConnection con = new SqlConnection(connString))
            {
                switch (Session["Role"].ToString())
                {
                    case "1":
                    case "51":
                    case "52":
                    case "53":
                    case "54":
                        query = @"
                SELECT 
                    V.*, 
                    T.TransactionDate AS CompletedDate
                FROM vw_PRSlist V
                LEFT JOIN (
                    SELECT PRSNo, MAX(TransactionDate) AS TransactionDate
                    FROM PRS_Payment_Transactions
                    GROUP BY PRSNo
                ) T ON V.PRSNo = T.PRSNo
                WHERE V.PRSStatus = 'Completed'
                AND CAST(V.PRSdate AS DATE) BETWEEN @FromDate AND @ToDate
                AND (V.Emp_code = @UserID OR V.Emp_code IS NULL) ";
                        break;

                    default:
                        query = @"
                SELECT 
                    V.*, 
                    T.TransactionDate AS CompletedDate
                FROM vw_PRSlist V
                LEFT JOIN (
                    SELECT PRSNo, MAX(TransactionDate) AS TransactionDate
                    FROM PRS_Payment_Transactions
                    GROUP BY PRSNo
                ) T ON V.PRSNo = T.PRSNo
                WHERE V.PRSStatus = 'Completed'
                AND CAST(V.PRSdate AS DATE) BETWEEN @FromDate AND @ToDate ";
                        break;
                }

                // ✅ Department filter
                if (Session["Role"].ToString() == "1" ||
                    Session["Role"].ToString() == "2" ||
                    Session["Role"].ToString() == "51" ||
                    Session["Role"].ToString() == "52")
                {
                    query += " AND V.Deptid = " + Session["DeptID"].ToString();
                }
                else
                {
                    if (ddlDepartment.SelectedValue != "ALL")
                    {
                        query += " AND V.Deptid = @DeptID";
                    }
                }

                // ✅ PRS Type filter (FIXED SQL INJECTION RISK)
                if (prsType != "ALL PRS")
                {
                    query += " AND V.PRSType = @PRSType";
                }

                query += " ORDER BY V.PRSdate DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    // ✅ Dates
                    DateTime fromDate = string.IsNullOrEmpty(txtFromDate.Text)
                        ? new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1).AddMonths(-1)
                        : Convert.ToDateTime(txtFromDate.Text);

                    DateTime toDate = string.IsNullOrEmpty(txtToDate.Text)
                        ? DateTime.Today
                        : Convert.ToDateTime(txtToDate.Text);

                    cmd.Parameters.AddWithValue("@FromDate", fromDate);
                    cmd.Parameters.AddWithValue("@ToDate", toDate);
                    cmd.Parameters.AddWithValue("@UserID", Session["UserID"].ToString());

                    // ✅ PRS Type
                    if (prsType != "ALL PRS")
                    {
                        cmd.Parameters.AddWithValue("@PRSType", prsType);
                    }

                    // ✅ Department
                    if (Session["Role"].ToString() != "1" && Session["Role"].ToString() != "2")
                    {
                        if (ddlDepartment.SelectedValue != "ALL")
                        {
                            cmd.Parameters.AddWithValue("@DeptID", ddlDepartment.SelectedValue);
                        }
                    }

                    DataTable dt = new DataTable();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);

                    gvCompleted.DataSource = dt;
                    gvCompleted.DataBind();
                }
            }
        }


        // ==========================
        // LOAD TRANSACTION DETAILS
        // ==========================
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
            FROM PRS_Payment_Transactions T
            LEFT JOIN vw_PRSlist P ON P.PRSNo = T.PRSNo
            LEFT JOIN Login L ON L.Employeeno = T.CreatedBy   
            WHERE T.PRSNo = @PRSNo
            ORDER BY T.TransactionDate DESC;";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@PRSNo", prsNo);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    lblTransID.Text = dr["TransactionID"].ToString();
                    lblPRSNo.Text = dr["PRSNo"].ToString();

                    lblPRSDate.Text = dr["PRSdate"] != DBNull.Value
                        ? Convert.ToDateTime(dr["PRSdate"]).ToString("dd-MMM-yyyy")
                        : "-";

                    lblInvAmt.Text = Convert.ToDecimal(dr["InvoiceAmount"]).ToString("N2");
                    lblTransDate.Text = Convert.ToDateTime(dr["TransactionDate"]).ToString("dd-MMM-yyyy");
                    lblCreatedBy.Text = dr["CreatedBy"].ToString();

                    if (dr["DocumentPath"] != DBNull.Value && !string.IsNullOrEmpty(dr["DocumentPath"].ToString()))
                    {
                        // File exists → link normally
                        lnkDocument.NavigateUrl = dr["DocumentPath"].ToString();
                        lnkDocument.Attributes["onclick"] = "";
                    }
                    else
                    {
                        // File missing → show alert
                        lnkDocument.NavigateUrl = "#";
                        lnkDocument.Attributes["onclick"] = "alert('There is no document for this transaction'); return false;";
                    }
                }

                dr.Close();
            }
        }

        // ==========================
        // LOAD DOCUMENTS
        // ==========================
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
        // ==========================
        // SHOW PRS DETAILS
        // ==========================
        private void ShowPRSModal(string prsNo)
        {
            if (string.IsNullOrEmpty(prsNo)) return;

            DataTable dt = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("SELECT * FROM vw_PRSlist WHERE PRSNo=@PRSNo", con))
            {
                cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                new SqlDataAdapter(cmd).Fill(dt);
            }

            if (dt.Rows.Count == 0) return;

            var row = dt.Rows[0];
            string info = "<table class='table table-borderless table-sm'><tbody>";

           
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
                    info += $"<th>{col.ColumnName}</th>";
                }

                info += "</tr></thead><tbody>";

                foreach (DataRow claim in dtClaims.Rows)
                {
                    info += "<tr>";

                    foreach (DataColumn col in dtClaims.Columns)
                    {
                        var val = claim[col];
                        info += $"<td>{(val != DBNull.Value ? HttpUtility.HtmlEncode(val.ToString()) : "-")}</td>";
                    }

                    info += "</tr>";
                }

                info += "</tbody></table>";
            }

            string script = $@"
              document.getElementById('prsDetail').innerHTML = `{info}`;
              var myModal = new bootstrap.Modal(document.getElementById('prsModal'));
              myModal.show();";

            ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowPRSModal", script, true);
        }

        // ==========================
        // ADD ROW HELPER
        // ==========================
      

        protected void btnExportCompleted_Click(object sender, EventArgs e)
        {
            if (ViewState["SelectedPRS"] == null) return;

            string prsType = ddlPRSType.SelectedValue;

            // Build query
            string query = @"
        SELECT 
            PRSNo AS [PRS No],
            PRSdate AS [PRS Date],
            PRSType AS [PRS Type],
            Department,
            SupplierCode AS [Supplier Code],
            SupplierName AS [Supplier Name],
            billno AS [Bill No],
            billdate AS [Bill Date],
            duedate AS [Due Date],
            Inoviceamount AS [Invoice Amount],
            Natureofexpenses AS [Nature Of Expenses]
        FROM vw_PRSlist
        WHERE PRSStatus = 'Completed'
          AND (@PRS_Type = 'ALL PRS' OR PRSType = @PRS_Type)
          AND CAST(PRSdate AS DATE) BETWEEN @FromDate AND @ToDate
    ";

            // Role-based department filter
            if (Session["Role"].ToString() == "1" || Session["Role"].ToString() == "2")
            {
                query += " AND Deptid = @DeptID";
            }
            else
            {
                if (ddlDepartment.SelectedValue != "ALL")
                {
                    query += " AND Deptid = @DeptID";
                }
            }

            query += " ORDER BY PRSdate DESC";

            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@PRS_Type", prsType);

                DateTime fromDate = string.IsNullOrEmpty(txtFromDate.Text)
                    ? new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1).AddMonths(-1)
                    : Convert.ToDateTime(txtFromDate.Text);

                DateTime toDate = string.IsNullOrEmpty(txtToDate.Text)
                    ? DateTime.Today
                    : Convert.ToDateTime(txtToDate.Text);

                cmd.Parameters.AddWithValue("@FromDate", fromDate);
                cmd.Parameters.AddWithValue("@ToDate", toDate);

                // Department parameter
                if ((Session["Role"].ToString() == "1" || Session["Role"].ToString() == "2")
                    || (ddlDepartment.SelectedValue != "ALL" && Session["Role"].ToString() != "1" && Session["Role"].ToString() != "2"))
                {
                    cmd.Parameters.AddWithValue("@DeptID", Session["DeptID"] != null ? Session["DeptID"].ToString() : ddlDepartment.SelectedValue);
                }

                new SqlDataAdapter(cmd).Fill(dt);
            }

            if (dt.Rows.Count == 0)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "NoDataAlert",
                    "alert('No data available to export');", true);
                return;
            }

            using (XLWorkbook wb = new XLWorkbook())
            {
                var ws = wb.Worksheets.Add("Completed PRS");
                ws.Cell(1, 1).InsertTable(dt);

                // Header style
                var header = ws.Range(1, 1, 1, dt.Columns.Count);
                header.Style.Font.Bold = true;
                header.Style.Fill.BackgroundColor = XLColor.LightGray;

                // Format Date Columns
                ws.Column(2).Style.DateFormat.Format = "dd-MMM-yyyy";
                ws.Column(8).Style.DateFormat.Format = "dd-MMM-yyyy";
                ws.Column(9).Style.DateFormat.Format = "dd-MMM-yyyy";

                // Format Amount Column
                ws.Column(10).Style.NumberFormat.Format = "#,##0.00";

                ws.Columns().AdjustToContents();
                ws.SheetView.FreezeRows(1);

                // Send Excel to browser
                Response.Clear();
                Response.Buffer = true;
                Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                Response.AddHeader("content-disposition", "attachment;filename=CompletedPRS.xlsx");

                using (MemoryStream stream = new MemoryStream())
                {
                    wb.SaveAs(stream);
                    stream.WriteTo(Response.OutputStream);
                }

                Response.Flush();
                Response.End(); // Properly ends the response
            }
        }
        // MAIN METHOD (kept for future use with completed date)
        protected string GetTATDays(object prsDateObj, object completedDateObj)
        {
            if (prsDateObj == null || prsDateObj == DBNull.Value ||
                completedDateObj == null || completedDateObj == DBNull.Value)
                return "-";

            DateTime prsDate, completedDate;

            if (!DateTime.TryParse(prsDateObj.ToString(), out prsDate) ||
                !DateTime.TryParse(completedDateObj.ToString(), out completedDate))
                return "-";

            TimeSpan diff = completedDate - prsDate;

            if (diff.TotalDays >= 1)
                return $"{(int)diff.TotalDays}d";
            else if (diff.TotalHours >= 1)
                return $"{(int)diff.TotalHours}h";
            else
                return $"{(int)diff.TotalMinutes}m";
        }


        // OVERLOAD METHOD (this fixes your ASPX error)
        protected string GetTATDays(object prsDateObj)
        {
            return GetTATDays(prsDateObj, null);
        }
        // ==========================
        // GRID ROW COMMAND
        // ==========================
        protected void gvCompleted_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ShowTransaction")
            {
                string prsNo = e.CommandArgument.ToString();
                LoadTransactionDetails(prsNo);

                ScriptManager.RegisterStartupScript(this, GetType(),
                    "ShowTransModal", "openTransactionModal();", true);
            }

            if (e.CommandName == "ShowPRS")
            {
                string prsNo = e.CommandArgument.ToString();
                ShowPRSModal(prsNo);
            }

            if (e.CommandName == "ViewDocs")
            {
                string poNumber = e.CommandArgument.ToString();
                LoadDocuments(poNumber);
            }
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

        
        }
    }
}


