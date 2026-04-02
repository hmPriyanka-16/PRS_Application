using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PRSwebapp
{
    public partial class PRS_Request : Page
    {
        private readonly string connectionString =
            ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

        public static List<string> supplierItems = new List<string>();

        string UdeptID = "";
        string prsRole = "";
        string hospitalId = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"].ToString() == null || Session["UserID"].ToString() == "")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "SELECT Deptid, PRS_Role, HospitalID FROM Login_role WHERE UserID = @UserID And HospitalID=@HospitalID";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@UserID", Session["UserID"].ToString());
                    cmd.Parameters.AddWithValue("@HospitalID", Session["HospitalID"] ?? "");

                    con.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader.Read())
                    {
                        UdeptID = reader["Deptid"].ToString();
                        prsRole = reader["PRS_Role"].ToString();
                        hospitalId = reader["HospitalID"].ToString();

                        Session["Deptid"] = UdeptID;
                        Session["PRS_Role"] = prsRole;
                        Session["HospitalID"] = hospitalId;
                    }
                    con.Close();
                }
            }

            if (Session["Role"].ToString() == "1" || Session["Role"].ToString() == "2" || Session["Role"].ToString() == "51" || Session["Role"].ToString() == "52")
                btnSave.Visible = true;
            else
            {
                btnSave.Visible = false;
                string alertscript = "alert('You are not authorized to create PRS, please change the role');" +
                                     "window.location='dashboard.aspx';";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alertRedirect", alertscript, true);
            }

            if (!IsPostBack)
            {
                LoadSuppliers();
                LoadPRSTypes();
            }
        }

        private void RebindInvoiceRows()
        {
            var billNos = Request.Form.GetValues("billNo");
            var billDates = Request.Form.GetValues("billDate");
            var dueDates = Request.Form.GetValues("dueDate");
            var billFroms = Request.Form.GetValues("billPeriodFrom");
            var billTos = Request.Form.GetValues("billPeriodTo");
            var natures = Request.Form.GetValues("natureOfExp");
            var amounts = Request.Form.GetValues("amount");

            if (billNos == null) return;

            string script = "window.invoiceData = [];";

            for (int i = 0; i < billNos.Length; i++)
            {
                script += $@"
        window.invoiceData.push({{
            billNo: '{billNos[i]}',
            billDate: '{billDates?[i]}',
            dueDate: '{dueDates?[i]}',
            from: '{billFroms?[i]}',
            to: '{billTos?[i]}',
            nature: '{natures?[i]}',
            amount: '{amounts?[i]}'
        }});";
            }

            ScriptManager.RegisterStartupScript(this, GetType(), "restoreRows", script, true);
        }
        private void LoadSuppliers()
        {
            supplierItems.Clear();
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                string sql = "SELECT SupplierName FROM Suppliers ORDER BY SupplierName";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                        supplierItems.Add(dr["SupplierName"].ToString());
                }
            }
        }
       
        private void LoadPRSTypes()
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                string query = "SELECT * FROM PRS_Category WHERE Category=1 ORDER BY ID";
                using (SqlCommand cmd = new SqlCommand(query, con))
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    ddlPRSType.DataSource = dr;
                    ddlPRSType.DataTextField = "PRSName";
                    ddlPRSType.DataValueField = "ID";
                    ddlPRSType.DataBind();
                }
            }
            ddlPRSType.Items.Insert(0, new ListItem("-- Select PRS Type --", "0"));
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
            {
                RebindInvoiceRows();
                ScriptManager.RegisterStartupScript(this, GetType(),
                    "notify",
                    "showNotification('Please fill all required fields correctly!');",
                    true);
                return;
            }

            try
            {
                if (Session["UserID"] == null || Session["Role"] == null)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(),
                        "invalidUser",
                        "alert('Invalid user. Please login again.');",
                        true);
                    return;
                }

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();

                    // ---------- Get SupplierID ----------
                    int supplierId;
                    using (SqlCommand cmd = new SqlCommand("SELECT SupplierID FROM Suppliers WHERE SupplierName=@name", con))
                    {
                        cmd.Parameters.AddWithValue("@name", txtSupplierCombo.Text.Trim());
                        object result = cmd.ExecuteScalar();

                        if (result == null)
                        {
                            RebindInvoiceRows();
                            ScriptManager.RegisterStartupScript(this, GetType(),
                                "noSupplier",
                                "alert('Supplier not found. Please select a valid supplier.');",
                                true);
                            return;
                        }

                        supplierId = Convert.ToInt32(result);
                    }

                    // ---------- Get Invoice Arrays ----------
                    string[] billNos = Request.Form.GetValues("billNo");
                    string[] billDates = Request.Form.GetValues("billDate");
                    string[] dueDates = Request.Form.GetValues("dueDate");
                    string[] billFroms = Request.Form.GetValues("billPeriodFrom");
                    string[] billTos = Request.Form.GetValues("billPeriodTo");
                    string[] natures = Request.Form.GetValues("natureOfExp");
                    string[] invoiceAmounts = Request.Form.GetValues("amount");

                    // ---------- CHECK DUPLICATE BILL NUMBER IN CURRENT GRID ----------
                    if (billNos != null)
                    {
                        HashSet<string> enteredBills = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

                        for (int i = 0; i < billNos.Length; i++)
                        {
                            string billNo = billNos[i]?.Trim();

                            if (string.IsNullOrEmpty(billNo))
                                continue;

                            if (enteredBills.Contains(billNo))
                            {
                                RebindInvoiceRows();
                                ScriptManager.RegisterStartupScript(this, GetType(),
                                    "duplicateLocal",
                                    $"alert('Duplicate Bill Number at Row {i + 1}: {billNo}');",
                                    true);
                                return;
                            }

                            enteredBills.Add(billNo);
                        }

                        // ---------- CHECK DUPLICATE IN DATABASE (OPTIMIZED SINGLE QUERY) ----------
                        List<string> cleanBills = enteredBills.Select(b => b.ToLower()).ToList();

                        if (cleanBills.Count > 0)
                        {
                            string billList = string.Join(",", cleanBills.Select(b => "'" + b.Replace("'", "''") + "'"));

                            string sql = $@"
                    SELECT C.PARTICULARS
                    FROM PRS_Claims C
                    JOIN PrsMaster M ON C.PRSNO = M.PRSNO
                    WHERE M.SupplierID = @SupplierID
                    AND LOWER(LTRIM(RTRIM(C.PARTICULARS))) IN ({billList})";

                            using (SqlCommand cmdCheck = new SqlCommand(sql, con))
                            {
                                cmdCheck.Parameters.AddWithValue("@SupplierID", supplierId);

                                SqlDataReader dr = cmdCheck.ExecuteReader();

                                if (dr.HasRows)
                                {
                                    dr.Read();
                                    string duplicateBill = dr["PARTICULARS"].ToString();

                                    int rowIndex = Array.FindIndex(billNos, b =>
                                        b != null && b.Trim().Equals(duplicateBill, StringComparison.OrdinalIgnoreCase));
                                    RebindInvoiceRows();

                                    ScriptManager.RegisterStartupScript(this, GetType(),
                                        "duplicateBill",
                                        $"alert('Bill Number already exists in database at Row {rowIndex + 1}: {duplicateBill}');",
                                        true);

                                    dr.Close();
                                    return;
                                }

                                dr.Close();
                            }
                        }
                    }

                    // ---------- Calculate Total Amount ----------
                    decimal totalInvoiceAmount = 0;

                    if (invoiceAmounts != null)
                    {
                        foreach (string a in invoiceAmounts)
                        {
                            if (decimal.TryParse(a, out decimal amt))
                                totalInvoiceAmount += amt;
                        }
                    }

                    // ---------- Insert PRS Master ----------
                    string prsDeptId = Session["PRS_DeptID"] != null ? Session["PRS_DeptID"].ToString() : "";

                    string generatedPRSNo = "";

                    using (SqlCommand cmd = new SqlCommand("Pr_PRS", con))
                    {
                        cmd.CommandType = System.Data.CommandType.StoredProcedure;

                        var prsNoParam = new SqlParameter("@PRSNo", System.Data.SqlDbType.VarChar, 50)
                        {
                            Direction = System.Data.ParameterDirection.Output
                        };

                        cmd.Parameters.Add(prsNoParam);

                        cmd.Parameters.AddWithValue("@PRSType", ddlPRSType.SelectedValue);
                        cmd.Parameters.AddWithValue("@PONumber", txtPONumber.Text.Trim());
                        cmd.Parameters.AddWithValue("@billno", DBNull.Value);
                        cmd.Parameters.AddWithValue("@billdate", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Inoviceamount", totalInvoiceAmount);
                        cmd.Parameters.AddWithValue("@duedate", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Natureofexpenses", DBNull.Value);
                        cmd.Parameters.AddWithValue("@PRSStatus", "New");
                        cmd.Parameters.AddWithValue("@Period", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Comments",
                            string.IsNullOrWhiteSpace(txtComments.Text)
                                ? (object)DBNull.Value
                                : txtComments.Text.Trim());

                        cmd.Parameters.AddWithValue("@user_ID", Session["UserID"]);
                        cmd.Parameters.AddWithValue("@user_role", Session["PRS_Role"]);
                        cmd.Parameters.AddWithValue("@TRANType", 0);
                        cmd.Parameters.AddWithValue("@Emp_Code", Session["Emp_Code"] ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@Emp_Name", Session["Emp_Name"] ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@Emp_Designation", Session["Emp_Designation"] ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@Emp_Department", prsDeptId);
                        cmd.Parameters.AddWithValue("@BillFrom", DBNull.Value);
                        cmd.Parameters.AddWithValue("@BillTo", DBNull.Value);
                        cmd.Parameters.AddWithValue("@HospitalID", Session["HospitalID"]);
                        cmd.Parameters.AddWithValue("@supplierID", supplierId);

                        cmd.ExecuteNonQuery();

                        generatedPRSNo = prsNoParam.Value.ToString();
                    }

                    // ---------- Save Invoice Rows ----------
                    if (billNos != null && invoiceAmounts != null)
                    {
                        for (int i = 0; i < billNos.Length; i++)
                        {
                            decimal rowAmount = 0;
                            decimal.TryParse(invoiceAmounts[i], out rowAmount);

                            using (SqlCommand cmd = new SqlCommand("sp_SavePRSClaim", con))
                            {
                                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                                cmd.Parameters.AddWithValue("@PRSNO", generatedPRSNo);
                                cmd.Parameters.AddWithValue("@SLno", i + 1);
                                cmd.Parameters.AddWithValue("@PARTICULARS", billNos[i] ?? "");
                                cmd.Parameters.AddWithValue("@PARTICULARS2", billDates[i] ?? "");
                                cmd.Parameters.AddWithValue("@PURPOSE", dueDates[i] ?? "");
                                cmd.Parameters.AddWithValue("@BillNo_Mode", billFroms[i] ?? "");
                                cmd.Parameters.AddWithValue("@BillDate_Distance", billTos[i] ?? "");
                                cmd.Parameters.AddWithValue("@Comments", natures[i] ?? "");
                                cmd.Parameters.AddWithValue("@Amount", rowAmount);

                                cmd.ExecuteNonQuery();
                            }
                        }
                    }

                    // ---------- Upload Documents ----------
                    // ---------- Upload Documents ----------
                    if (fuDocument.HasFiles)
                    {
                        string baseFolder = Server.MapPath("~/UploadedFiles/");
                        string prsFolder = Path.Combine(baseFolder, generatedPRSNo);

                        if (!Directory.Exists(prsFolder))
                            Directory.CreateDirectory(prsFolder);

                        foreach (HttpPostedFile file in fuDocument.PostedFiles)
                        {
                            string originalFileName = Path.GetFileName(file.FileName);
                            string safeFileName = Regex.Replace(originalFileName, @"[^a-zA-Z0-9_\-\.]", "_");

                            string savePath = Path.Combine(prsFolder, safeFileName);
                            file.SaveAs(savePath);

                            using (SqlCommand cmdFile = new SqlCommand(
                                "INSERT INTO SupplierDocuments (PONumber, FileName, FilePath, Status) " +
                                "VALUES (@PONumber, @FileName, @FilePath, @Status)", con))
                            {
                                cmdFile.Parameters.AddWithValue("@PONumber", generatedPRSNo);
                                cmdFile.Parameters.AddWithValue("@FileName", safeFileName);
                                cmdFile.Parameters.AddWithValue("@FilePath", $"UploadedFiles/{generatedPRSNo}/{safeFileName}");
                                cmdFile.Parameters.AddWithValue("@Status", 0); // <-- Default status = 0
                                cmdFile.ExecuteNonQuery();
                            }
                        }
                    }

                    // ---------- Redirect ----------
                    Response.Redirect($"RingiPopupp.aspx?ringi={generatedPRSNo}", false);
                    Context.ApplicationInstance.CompleteRequest();
                }
            }
            catch (Exception ex)
            {
                RebindInvoiceRows();
                ScriptManager.RegisterStartupScript(this, GetType(),
                    "err",
                    $"alert('Error: {ex.Message.Replace("'", "")}');",
                    true);
            }
        }
        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        private void ClearForm()
        {
            txtSupplierCombo.Text = "";
            txtPONumber.Text = "";
            txtComments.Text = "";
            txtPODate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        }
    }
}