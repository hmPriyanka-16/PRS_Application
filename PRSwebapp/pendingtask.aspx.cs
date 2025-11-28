using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Web.UI;

namespace PRSwebapp
{
    public partial class PendingTask : System.Web.UI.Page
    {
        private readonly string connString = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindPendingTasks();
                ApplyColumnSecurity();   // 🔥 IMPORTANT
            }
        }

        private void BindPendingTasks()
        {
            string deptId = Session["deptid"]?.ToString() ?? "0";
            string role = Session["Role"]?.ToString() ?? "0";

            string mainQuery = @"SELECT * FROM vw_PRSlist WHERE PRSStatus<>'Completed' AND Next_Sequence = @Role";

            int roleNum;
            if (int.TryParse(role, out roleNum) && roleNum < 3)
            {
                mainQuery += " AND Deptid = @DeptId";
            }

            DataTable dtMain = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(mainQuery, con))
            {
                cmd.Parameters.AddWithValue("@Role", role);
                if (mainQuery.Contains("@DeptId"))
                    cmd.Parameters.AddWithValue("@DeptId", deptId);

                new SqlDataAdapter(cmd).Fill(dtMain);
            }

            gvMainPending.DataSource = dtMain;
            gvMainPending.DataBind();

            gvPendingTasks.DataSource = dtMain;
            gvPendingTasks.DataBind();

            lblTotalPending.InnerText = dtMain.Rows.Count.ToString();
        }

        // 🔥 This function controls column visibility
        private void ApplyColumnSecurity()
        {
            string role = Session["Role"]?.ToString() ?? "0";

            // 💡 Transaction columns index:
            int mainTransCol = 13;
            int pendingTransCol = 16;

            if (role == "10")
            {
                gvMainPending.Columns[mainTransCol].Visible = true;
                gvPendingTasks.Columns[pendingTransCol].Visible = true;
            }
            else
            {
                gvMainPending.Columns[mainTransCol].Visible = false;
                gvPendingTasks.Columns[pendingTransCol].Visible = false;
            }
        }


        protected void gvMainPending_RowDataBound(object sender, System.Web.UI.WebControls.GridViewRowEventArgs e)
        {
            if (e.Row.RowType == System.Web.UI.WebControls.DataControlRowType.DataRow)
            {
                string role = Session["Role"]?.ToString() ?? "";
                var phTransaction = (System.Web.UI.WebControls.PlaceHolder)e.Row.FindControl("phTransaction");

                if (phTransaction != null)
                    phTransaction.Visible = role == "10";
            }
        }

        protected void gvPendingTasks_RowDataBound(object sender, System.Web.UI.WebControls.GridViewRowEventArgs e)
        {
            if (e.Row.RowType == System.Web.UI.WebControls.DataControlRowType.DataRow)
            {
                string role = Session["Role"]?.ToString() ?? "";
                var phTransactionModal = (System.Web.UI.WebControls.PlaceHolder)e.Row.FindControl("phTransactionModal");

                if (phTransactionModal != null)
                    phTransactionModal.Visible = role == "10";
            }
        }


        protected void gvPendingTasks_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            if (e.CommandArgument == null) return;

            string prsNo = e.CommandArgument.ToString();

            switch (e.CommandName)
            {
                case "ViewDocs":
                    LoadDocuments(prsNo);
                    break;

                case "Approve":
                    UpdatePRSStatus(prsNo, "Approved");
                    BindPendingTasks();
                    ApplyColumnSecurity();
                    break;

                case "SendBack":
                    hfPRSNoRemark.Value = prsNo;
                    ScriptManager.RegisterStartupScript(this, GetType(), "ShowRemarkModal",
                        $"openRemarkModal('{prsNo}');", true);
                    break;
            }
        }

        private void UpdatePRSStatus(string prsNo, string status)
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand("Pr_PRS", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                    cmd.Parameters.AddWithValue("@PRSType", DBNull.Value);
                    cmd.Parameters.AddWithValue("@PONumber", DBNull.Value);
                    cmd.Parameters.AddWithValue("@billno", DBNull.Value);
                    cmd.Parameters.AddWithValue("@billdate", DBNull.Value);
                    cmd.Parameters.AddWithValue("@Inoviceamount", DBNull.Value);
                    cmd.Parameters.AddWithValue("@duedate", DBNull.Value);
                    cmd.Parameters.AddWithValue("@Natureofexpenses", DBNull.Value);
                    cmd.Parameters.AddWithValue("@PRSStatus", status);
                    cmd.Parameters.AddWithValue("@Period", DBNull.Value);
                    cmd.Parameters.AddWithValue("@Comments", Session["UserID"]);

                    cmd.Parameters.AddWithValue("@BillFrom", DBNull.Value);
                    cmd.Parameters.AddWithValue("@BillTo", DBNull.Value);
                    cmd.Parameters.AddWithValue("@user_ID", Session["UserID"]);
                    cmd.Parameters.AddWithValue("@user_role", Session["Role"]);
                    cmd.Parameters.AddWithValue("@TRANType", 0);

                    cmd.Parameters.AddWithValue("@Emp_Code", DBNull.Value);
                    cmd.Parameters.AddWithValue("@Emp_Name", DBNull.Value);
                    cmd.Parameters.AddWithValue("@Emp_Designation", DBNull.Value);
                    cmd.Parameters.AddWithValue("@Emp_Department", DBNull.Value);

                    cmd.ExecuteNonQuery();
                }
            }
        }

        protected void btnSubmitRemark_Click(object sender, EventArgs e)
        {
            string prsNo = hfPRSNoRemark.Value;
            string remark = txtRemark.Text.Trim();

            if (string.IsNullOrEmpty(prsNo)) return;

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand(
                    @"UPDATE PRS_Transcation_Status SET PRSStatus='Sent Back', Remark=@Remark WHERE PRSNo=@PRSNo", con))
                {
                    cmd.Parameters.AddWithValue("@Remark", remark);
                    cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                    cmd.ExecuteNonQuery();
                }
            }

            txtRemark.Text = "";
            hfPRSNoRemark.Value = "";

            BindPendingTasks();
            ApplyColumnSecurity();

            ScriptManager.RegisterStartupScript(this, GetType(), "CloseRemarkModal",
                "var m = bootstrap.Modal.getInstance(document.getElementById('remarkModal')); if(m) m.hide();", true);
        }


        private void LoadDocuments(string poNumber)
        {
            if (string.IsNullOrEmpty(poNumber))
            {
                lblNoDocs.Text = "PO Number not provided.";
                gvDocs.DataSource = null;
                gvDocs.DataBind();

                ScriptManager.RegisterStartupScript(this, GetType(), "ShowDocsModal", "showDocsModal();", true);
                return;
            }

            DataTable dt = GetDocumentsByPO(poNumber);

            gvDocs.DataSource = dt.Rows.Count > 0 ? dt : null;
            gvDocs.DataBind();
            lblNoDocs.Text = dt.Rows.Count == 0 ? $"No documents found for PO: {poNumber}" : "";

            lblModalPONumber.InnerText = poNumber;

            ScriptManager.RegisterStartupScript(this, GetType(), "ShowDocsModal", "showDocsModal();", true);
        }

        private DataTable GetDocumentsByPO(string poNumber)
        {
            DataTable dt = new DataTable();
            string query = @"SELECT ID, SupplierName, PONumber, FileName, FilePath, UploadDate
                             FROM SupplierDocuments WHERE PONumber = @PONumber ORDER BY UploadDate DESC";

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@PONumber", poNumber);
                new SqlDataAdapter(cmd).Fill(dt);
            }

            return dt;
        }


        protected void btnSubmitTransaction_Click(object sender, EventArgs e)
        {
            string prsNo = hfTransactionPRSNo.Value?.Trim();
            string transactionID = txtTransactionID.Text.Trim();

            if (string.IsNullOrEmpty(transactionID))
                transactionID = "TR" + DateTime.UtcNow.Ticks.ToString();

            if (string.IsNullOrEmpty(prsNo))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "AlertMissing",
                    "alert('PRS No is required.');", true);
                return;
            }

            DateTime prsDateValue;
            if (!DateTime.TryParseExact(hfPRSDate.Value, "yyyy-MM-dd", CultureInfo.InvariantCulture,
                DateTimeStyles.None, out prsDateValue))
            {
                prsDateValue = DateTime.Now;
            }

            decimal invoiceAmountValue;
            decimal.TryParse(hfInvoiceAmount.Value.Replace(",", ""),
                NumberStyles.Any, CultureInfo.InvariantCulture, out invoiceAmountValue);

            DateTime transactionDate;
            if (!DateTime.TryParse(txtTransactionDate.Text, out transactionDate))
                transactionDate = DateTime.Now;

            string filePath = null;
            if (fuTransactionDocs.HasFile)
            {
                string folderPath = Server.MapPath($"~/TransactionDocs/{prsNo}/");

                if (!Directory.Exists(folderPath))
                    Directory.CreateDirectory(folderPath);

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
                "var m = bootstrap.Modal.getInstance(document.getElementById('transactionModal')); if(m) m.hide(); alert('Transaction saved and PRS approved!');",
                true);
        }

    }
}
