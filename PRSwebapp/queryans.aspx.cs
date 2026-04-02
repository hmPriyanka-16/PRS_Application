using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PRSwebapp
{
    public partial class queryans : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || string.IsNullOrEmpty(Session["UserID"].ToString()))
                Response.Redirect("Login.aspx");

            if (!IsPostBack)
            {
                BindPRSDetails();
                BindDocuments();
            }
        }

        // ================================
        // Bind PRS Details
        // ================================
        private void BindPRSDetails()
        {
            string prsNo = Request.QueryString["prsNo"];
            if (string.IsNullOrEmpty(prsNo)) return;

            string info = "";

            // PRS Details
            DataTable dt = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("SELECT * FROM vw_PRSlist WHERE PRSNo=@PRSNo", con))
            {
                cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            }

            if (dt.Rows.Count > 0)
            {
                var row = dt.Rows[0];
                info += "<table class='table table-borderless table-sm'><tbody>";
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
            }

            // Claim Details
            DataTable dtClaims = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("EXEC PR_PRCclaims @PRSNo", con))
            {
                cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtClaims);
            }

            if (dtClaims.Rows.Count > 0)
            {
                info += "<hr/><b>Claim Details:</b><br/>";
                info += "<table class='table table-sm table-bordered'><thead><tr>";
                foreach (DataColumn col in dtClaims.Columns) info += $"<th>{HttpUtility.HtmlEncode(col.ColumnName)}</th>";
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

            pnlDetails.Controls.Clear();
            pnlDetails.Controls.Add(new LiteralControl(info));
        }

        private static string AddRow(string label, object value)
        {
            if (value == null || value == DBNull.Value || string.IsNullOrWhiteSpace(value.ToString())) return "";

            string displayValue = value.ToString();

            if (label != "Employee ID")
            {
                if (decimal.TryParse(displayValue, out decimal dec)) displayValue = dec.ToString("N2");
            }

            if (DateTime.TryParse(displayValue, out DateTime dt)) displayValue = dt.ToString("dd-MMM-yyyy");

            return $"<tr><th style='width:150px'>{HttpUtility.HtmlEncode(label)}</th><td>{HttpUtility.HtmlEncode(displayValue)}</td></tr>";
        }

        // ================================
        // Bind Documents GridView
        // ================================
        private void BindDocuments()
        {
            string prsNo = Request.QueryString["prsNo"];
            if (string.IsNullOrEmpty(prsNo)) return;

            DataTable dt = new DataTable();
            string query = @"SELECT ID, FileName, FilePath FROM SupplierDocuments WHERE PONumber=@PRSNo AND Status=0 ORDER BY UploadDate DESC";

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            }

            gvDocs.DataSource = dt;
            gvDocs.DataBind();
        }

        // ================================
        // Delete Document
        // ================================
        protected void gvDocs_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteDoc")
            {
                int docId = Convert.ToInt32(e.CommandArgument);
                string filePath = "";

                using (SqlConnection con = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand("SELECT FilePath FROM SupplierDocuments WHERE ID=@ID", con))
                {
                    cmd.Parameters.AddWithValue("@ID", docId);
                    con.Open();
                    filePath = cmd.ExecuteScalar()?.ToString();
                }

                using (SqlConnection con = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand("UPDATE SupplierDocuments SET Status=1 WHERE ID=@ID", con))
                {
                    cmd.Parameters.AddWithValue("@ID", docId);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }

                if (!string.IsNullOrEmpty(filePath))
                {
                    string physicalPath = Server.MapPath(filePath);
                    if (File.Exists(physicalPath)) File.Delete(physicalPath);
                }

                BindDocuments();
            }
        }
        // ================================
        // Reject PRS
        // ================================
        protected void btnReject_Click(object sender, EventArgs e)
        {
            try
            {
                string prsNo = Request.QueryString["PRSNo"];
                if (string.IsNullOrEmpty(prsNo)) return;

                string remarks = txtRemarks.Text.Trim();

                using (SqlConnection con = new SqlConnection(connString))
                {
                    con.Open();

                    // Update PRS Status / Remarks as "rejected"
                    using (SqlCommand cmd = new SqlCommand("Pr_PRS", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                        cmd.Parameters.AddWithValue("@PRSType", DBNull.Value);
                        cmd.Parameters.AddWithValue("@PONumber", DBNull.Value);
                        cmd.Parameters.AddWithValue("@billno", DBNull.Value);
                        cmd.Parameters.AddWithValue("@billdate", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Inoviceamount", 0);
                        cmd.Parameters.AddWithValue("@duedate", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Natureofexpenses", DBNull.Value);
                        cmd.Parameters.AddWithValue("@PRSStatus", "rejected"); // <- Status updated here
                        cmd.Parameters.AddWithValue("@Emp_Code", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Emp_Name", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Emp_Designation", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Emp_Department", DBNull.Value);
                        cmd.Parameters.AddWithValue("@user_ID", Session["UserID"].ToString());
                        cmd.Parameters.AddWithValue("@user_role", Convert.ToInt32(Session["Role"]));
                        cmd.Parameters.AddWithValue("@TRANType", 2);
                        cmd.Parameters.AddWithValue("@Period", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Comments", remarks);
                        cmd.Parameters.AddWithValue("@BillFrom", DBNull.Value);
                        cmd.Parameters.AddWithValue("@BillTo", DBNull.Value);
                        cmd.Parameters.AddWithValue("@HospitalID", Convert.ToInt32(Session["HospitalID"]));
                        cmd.Parameters.AddWithValue("@supplierID", 0);

                        cmd.ExecuteNonQuery();
                    }
                }

                ScriptManager.RegisterStartupScript(this, GetType(), "success",
                    "alert('Query rejected successfully!');window.location='query.aspx';", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "err",
                    "alert('Error: " + ex.Message.Replace("'", "") + "');", true);
            }
        }
        // ================================
        // Submit Remarks & Upload Files
        // ================================
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            try
            {
                string prsNo = Request.QueryString["PRSNo"];
                if (string.IsNullOrEmpty(prsNo)) return;

                string remarks = txtRemarks.Text.Trim();

                using (SqlConnection con = new SqlConnection(connString))
                {
                    con.Open();

                    // Update PRS Status / Remarks
                    using (SqlCommand cmd = new SqlCommand("Pr_PRS", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.AddWithValue("@PRSNo", prsNo);
                        cmd.Parameters.AddWithValue("@PRSType", DBNull.Value);
                        cmd.Parameters.AddWithValue("@PONumber", DBNull.Value);
                        cmd.Parameters.AddWithValue("@billno", DBNull.Value);
                        cmd.Parameters.AddWithValue("@billdate", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Inoviceamount", 0);
                        cmd.Parameters.AddWithValue("@duedate", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Natureofexpenses", DBNull.Value);
                        cmd.Parameters.AddWithValue("@PRSStatus", "Query Answered");
                        cmd.Parameters.AddWithValue("@Emp_Code", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Emp_Name", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Emp_Designation", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Emp_Department", DBNull.Value);
                        cmd.Parameters.AddWithValue("@user_ID", Session["UserID"].ToString());
                        cmd.Parameters.AddWithValue("@user_role", Convert.ToInt32(Session["Role"]));
                        cmd.Parameters.AddWithValue("@TRANType", 2);
                        cmd.Parameters.AddWithValue("@Period", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Comments", remarks);
                        cmd.Parameters.AddWithValue("@BillFrom", DBNull.Value);
                        cmd.Parameters.AddWithValue("@BillTo", DBNull.Value);
                        cmd.Parameters.AddWithValue("@HospitalID", Convert.ToInt32(Session["HospitalID"]));
                        cmd.Parameters.AddWithValue("@supplierID", 0);

                        cmd.ExecuteNonQuery();
                    }

                    // Handle Multiple File Uploads
                    if (Request.Files.Count > 0)
                    {
                        string folderPath = Server.MapPath("~/Uploads/PRSFiles/" + prsNo + "/");
                        if (!Directory.Exists(folderPath)) Directory.CreateDirectory(folderPath);

                        for (int i = 0; i < Request.Files.Count; i++)
                        {
                            HttpPostedFile file = Request.Files[i];
                            if (file != null && file.ContentLength > 0)
                            {
                                string fileName = Path.GetFileName(file.FileName);
                                string fullPath = Path.Combine(folderPath, fileName);
                                file.SaveAs(fullPath);

                                using (SqlCommand cmdFile = new SqlCommand(@"
                                    INSERT INTO SupplierDocuments (PONumber, FileName, FilePath, UploadDate, Status)
                                    VALUES (@PONumber, @FileName, @FilePath, GETDATE(), @Status)", con))
                                {
                                    cmdFile.Parameters.AddWithValue("@PONumber", prsNo);
                                    cmdFile.Parameters.AddWithValue("@FileName", fileName);
                                    cmdFile.Parameters.AddWithValue("@FilePath", "~/Uploads/PRSFiles/" + prsNo + "/" + fileName);
                                    cmdFile.Parameters.AddWithValue("@Status", 0);
                                    cmdFile.ExecuteNonQuery();
                                }
                            }
                        }
                    }
                }

                ScriptManager.RegisterStartupScript(this, GetType(), "success",
                    "alert('Query Answered successfully!');window.location='query.aspx';", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "err",
                    "alert('Error: " + ex.Message.Replace("'", "") + "');", true);
            }
        }
    }
}