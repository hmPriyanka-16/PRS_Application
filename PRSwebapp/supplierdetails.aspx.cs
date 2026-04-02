using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PRSwebapp
{
    public partial class supplier_details : Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

        public static List<string> supplierItems = new List<string>();
        public static List<string> departmentItems = new List<string>();

        string UdeptID = "";
        string prsRole = "";
        string hospitalId = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"].ToString() == null || Session["UserID"].ToString() == "")
            {
                Response.Redirect("Login.aspx");
             
            }
            using (SqlConnection con = new SqlConnection(connStr))

            {
                string query = "SELECT Deptid, PRS_Role, HospitalID FROM Login_role WHERE UserID = @UserID And HospitalID=@HospitalID";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@UserID", Session["UserID"].ToString());
                    cmd.Parameters.AddWithValue("@HospitalID", Session["HospitalID"].ToString());

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

            // --- Set button visibility based on PRS role (same as your 1st code) ---
            if (prsRole == "1" || prsRole == "2" || prsRole == "51" || prsRole == "52")
            {
                // Allow creation
                btnSave.Visible = true;
            }
            else
            {
                // Other roles: disable create
                btnSave.Visible = false;

                ScriptManager.RegisterStartupScript(this, this.GetType(),
                    "alert", "alert('You are not authorized to create PO.');", true);
            }

            if (!IsPostBack)
            {
                LoadSupplierItems();

                LoadPRSTypes();


            }
        }
        protected void ValidatePOPaymentType(object source, ServerValidateEventArgs args)
        {
            args.IsValid = rbFixed.Checked || rbOnUsage.Checked;
        }

        private void LoadSupplierItems()
        {
            supplierItems.Clear();
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                string query = "SELECT SupplierName FROM Suppliers ORDER BY SupplierName";
                using (SqlCommand cmd = new SqlCommand(query, con))
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                        supplierItems.Add(dr["SupplierName"].ToString());
                }
            }
        }


        private void LoadPRSTypes()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                string query = "SELECT  * FROM PRS_Category where Category=1 ORDER BY ID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    ddlPRSType.DataSource = dr;
                    ddlPRSType.DataTextField = "PRSName"; // <-- matches your table
                    ddlPRSType.DataValueField = "ID";     // Value stored in DB
                    ddlPRSType.DataBind();
                }
            }

            ddlPRSType.Items.Insert(0, new ListItem("-- Select PRS Type --", "0"));
        }
        protected void btnFetchRing_Click(object sender, EventArgs e)
        {
            FetchRingData();
        }

        protected void txtRingNumber_TextChanged(object sender, EventArgs e)
        {
            btnFetchRing.Click+= new System.EventHandler(this.btnFetchRing_Click);
            //FetchRingData();
        }

        // Reusable method for fetching Ring Number info
     private void FetchRingData()
{
    string ringi = txtRingNumber.Text.Trim();
    if (string.IsNullOrEmpty(ringi))
        return;

    string query = @"SELECT PONO, PODate, SupplierName, RINGIType
                     FROM RINGI_PO
                     WHERE RINGINO = @RingiNumber";

    using (SqlConnection con = new SqlConnection(connStr))
    using (SqlCommand cmd = new SqlCommand(query, con))
    {
        cmd.Parameters.AddWithValue("@RingiNumber", ringi);
        con.Open();

        SqlDataReader dr = cmd.ExecuteReader();
        if (dr.Read())
        {
            txtPONumber.Text = dr["PONO"].ToString();

            txtPODate.Text = dr["PODate"] != DBNull.Value
                ? Convert.ToDateTime(dr["PODate"]).ToString("yyyy-MM-dd")
                : "";

            txtSupplierCombo.Text = dr["SupplierName"].ToString();

            // PRS TYPE AUTO FILL
            if (dr["RINGIType"] != DBNull.Value)
            {
                string ringiType = dr["RINGIType"].ToString().Trim().ToUpper();

                ddlPRSType.ClearSelection();
                foreach (ListItem item in ddlPRSType.Items)
                {
                    if (item.Text.Trim().ToUpper() == ringiType)
                    {
                        item.Selected = true;
                        break;
                    }
                }
            }
            else
            {
                ddlPRSType.SelectedIndex = 0;
            }
        }
        else
        {
            txtPONumber.Text = "";
            txtPODate.Text = "";
            txtSupplierCombo.Text = "";
            ddlPRSType.SelectedIndex = 0;
        }
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
            txtPODate.Text = "";
            rbFixed.Checked = false;
            rbOnUsage.Checked = false;
            txtPOAmount.Text = "";
            txtInvoiceAmount.Text = "";
            txtRingNumber.Text = "";
            txtAgreementStart.Text = "";
            txtAgreementEnd.Text = "";
            txtMonths.Text = "";
            txtMonths.Attributes["value"] = "";
            ddlPRSType.SelectedIndex = 0;
            txtNatureOfExp.Text = "";
            fuDocument.Attributes.Clear();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                string supplierName = txtSupplierCombo.Text.Trim();
             
                string poNumber = txtPONumber.Text.Trim();
                string poDate = txtPODate.Text.Trim();
                string poAmountType = rbFixed.Checked ? "Fixed" : rbOnUsage.Checked ? "On Usage" : "";
                string poAmount = txtPOAmount.Text.Trim();
                string invoiceAmount = txtInvoiceAmount.Text.Trim();
                string ringNumber = txtRingNumber.Text.Trim();
                string agreementStart = txtAgreementStart.Text.Trim();
                string agreementEnd = txtAgreementEnd.Text.Trim();

                string monthsValue = Request.Form[txtMonths.UniqueID];
                if (string.IsNullOrWhiteSpace(monthsValue)) monthsValue = txtMonths.Text;
                string paymentsApplicable = string.IsNullOrWhiteSpace(monthsValue) ? "" : monthsValue;

                object poDateValue = DateTime.TryParse(poDate, out DateTime poDateParsed) ? (object)poDateParsed : DBNull.Value;
                object agreementStartValue = DateTime.TryParse(agreementStart, out DateTime startParsed) ? (object)startParsed : DBNull.Value;
                object agreementEndValue = DateTime.TryParse(agreementEnd, out DateTime endParsed) ? (object)endParsed : DBNull.Value;

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    // Get SupplierID
                    int? supplierID = null;
                    using (SqlCommand cmdSupplier = new SqlCommand("SELECT SupplierID FROM Suppliers WHERE SupplierName = @name", con))
                    {
                        cmdSupplier.Parameters.AddWithValue("@name", supplierName);
                        object val = cmdSupplier.ExecuteScalar();
                        if (val != null) supplierID = Convert.ToInt32(val);
                    }

                    // Get Department ID


                    if (supplierID == null)
                    {
                        ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('⚠ Invalid Supplier ');", true);
                        return;
                    }

                    // INSERT SupplierPOEntry (Updated column SupplierID)
                    string insertSql = @"
                      INSERT INTO SupplierPOEntry 
                      (SupplierID, Department, prstype, PONumber, PODate, POPaymentType, PaymentsApplicable,
                      POAmount, InvoiceAmount, natureofexp, AgreementStart, AgreementEnd, RingNumber, ProcessStatus, HospitalID)
                      VALUES (@SupplierID, @Department, @prstype, @PONumber, @PODate, @POPaymentType, @PaymentsApplicable,
                      @POAmount, @InvoiceAmount, @natureofexp, @AgreementStart, @AgreementEnd, @RingNumber, 'Not Processed', @HospitalID)";


                    using (SqlCommand cmd = new SqlCommand(insertSql, con))
                    {
                        cmd.Parameters.AddWithValue("@SupplierID", supplierID);
                        cmd.Parameters.AddWithValue("@Department", Session["Deptid"]);

                        cmd.Parameters.AddWithValue("@prstype", ddlPRSType.SelectedValue);

                        cmd.Parameters.AddWithValue("@PONumber", string.IsNullOrWhiteSpace(poNumber) ? (object)DBNull.Value : poNumber);
                        cmd.Parameters.AddWithValue("@PODate", poDateValue);
                        cmd.Parameters.AddWithValue("@POPaymentType", string.IsNullOrWhiteSpace(poAmountType) ? (object)DBNull.Value : poAmountType);
                        cmd.Parameters.AddWithValue("@PaymentsApplicable", string.IsNullOrWhiteSpace(paymentsApplicable) ? (object)DBNull.Value : paymentsApplicable);
                        cmd.Parameters.AddWithValue("@POAmount", string.IsNullOrWhiteSpace(poAmount) ? 0 : Convert.ToDecimal(poAmount));
                        cmd.Parameters.AddWithValue("@InvoiceAmount", string.IsNullOrWhiteSpace(invoiceAmount) ? 0 : Convert.ToDecimal(invoiceAmount));
                        cmd.Parameters.AddWithValue("@natureofexp", txtNatureOfExp.Text.Trim());
                        cmd.Parameters.AddWithValue("@AgreementStart", agreementStartValue);
                        cmd.Parameters.AddWithValue("@AgreementEnd", agreementEndValue);
                        cmd.Parameters.AddWithValue("@RingNumber", string.IsNullOrWhiteSpace(ringNumber) ? (object)DBNull.Value : ringNumber);
                        cmd.Parameters.AddWithValue("@HospitalID", Session["HospitalID"]);

                        int rows = cmd.ExecuteNonQuery();

                        // Upload files (SupplierDocuments keeps SupplierName – NOT changed)
                        if (rows > 0 && fuDocument.HasFiles)
                        {
                            string baseFolder = Server.MapPath("~/UploadedFiles/");
                            if (!Directory.Exists(baseFolder)) Directory.CreateDirectory(baseFolder);

                            string poFolder = Path.Combine(baseFolder, poNumber);
                            if (!Directory.Exists(poFolder)) Directory.CreateDirectory(poFolder);

                            foreach (var file in fuDocument.PostedFiles)
                            {
                                string fileName = Path.GetFileName(file.FileName);
                                string savePath = Path.Combine(poFolder, fileName);
                                file.SaveAs(savePath);

                                using (SqlCommand cmdFile = new SqlCommand(
                                    "INSERT INTO SupplierDocuments (PONumber, FileName, FilePath) VALUES (@PONumber, @FileName, @FilePath)", con))
                                {

                                    cmdFile.Parameters.AddWithValue("@PONumber", poNumber);

                                    cmdFile.Parameters.AddWithValue("@FileName", fileName);
                                    cmdFile.Parameters.AddWithValue("@FilePath", $"~/UploadedFiles/{poNumber}/{fileName}");
                                    cmdFile.ExecuteNonQuery();
                                }
                            }
                        }
                        ClearForm();


                        ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('✅ Saved Successfully');", true);
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("<pre style='color:red'>" + ex.ToString() + "</pre>");
            }
            ClientScript.RegisterStartupScript(this.GetType(),
"clearMonths", "document.getElementById('" + txtMonths.ClientID + "').value='';", true);

        }


        // GET PO HISTORY
        [WebMethod]
        public static List<Dictionary<string, string>> GetFilteredPOHistory(string supplierName, string agreementStart, string agreementEnd)
        {
            var results = new List<Dictionary<string, string>>();
            string connStr = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;
            int depID = 0;
            if (HttpContext.Current.Session["deptid"] != null)
                int.TryParse(HttpContext.Current.Session["deptid"].ToString(), out depID);
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();

                string sql = @"
            SELECT 
                e.ID,
                e.SupplierID,
                s.SupplierName,
                d.Name AS Department,
                e.prstype AS PRSTypeID,
                p.PRSName AS PRSTypeName,
                e.PONumber,
                e.PODate,
                e.POPaymentType,
                e.PaymentsApplicable,
                e.POAmount,
                e.InvoiceAmount,
                e.natureofexp,
                e.AgreementStart,
                e.AgreementEnd,
                e.RingNumber
            FROM SupplierPOEntry e
            INNER JOIN Suppliers s ON e.SupplierID = s.SupplierID
            LEFT JOIN Department d ON e.Department = d.ID
          LEFT JOIN prstype p ON e.prstype = p.ID 
            WHERE 1=1
        ";
                if (depID > 0) sql += " AND e.Department = @DepID";
                if (!string.IsNullOrEmpty(supplierName)) sql += " AND s.SupplierName LIKE @s";
                if (!string.IsNullOrEmpty(agreementStart)) sql += " AND e.AgreementStart >= @start";
                if (!string.IsNullOrEmpty(agreementEnd)) sql += " AND e.AgreementEnd <= @end";

                sql += " ORDER BY e.AgreementStart DESC";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    if (depID > 0) cmd.Parameters.AddWithValue("@DepID", depID);
                    if (!string.IsNullOrEmpty(supplierName)) cmd.Parameters.AddWithValue("@s", "%" + supplierName + "%");
                    if (!string.IsNullOrEmpty(agreementStart)) cmd.Parameters.AddWithValue("@start", DateTime.Parse(agreementStart));
                    if (!string.IsNullOrEmpty(agreementEnd)) cmd.Parameters.AddWithValue("@end", DateTime.Parse(agreementEnd));

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            var row = new Dictionary<string, string>
                            {
                                ["ID"] = dr["ID"].ToString(),
                                ["SupplierID"] = dr["SupplierID"].ToString(),
                                ["SupplierName"] = dr["SupplierName"].ToString(),
                                ["Department"] = dr["Department"].ToString(),
                                ["PRSTypeName"] = dr["PRSTypeName"].ToString(),
                                ["PONumber"] = dr["PONumber"].ToString(),
                                ["PODate"] = dr["PODate"] == DBNull.Value ? "" : Convert.ToDateTime(dr["PODate"]).ToString("yyyy-MM-dd"),
                                ["POPaymentType"] = dr["POPaymentType"].ToString(),
                                ["PaymentsApplicable"] = dr["PaymentsApplicable"]?.ToString(),
                                ["POAmount"] = dr["POAmount"].ToString(),
                                ["InvoiceAmount"] = dr["InvoiceAmount"].ToString(),
                                ["natureofexp"] = dr["natureofexp"].ToString(),
                                ["AgreementStart"] = dr["AgreementStart"] == DBNull.Value ? "" : Convert.ToDateTime(dr["AgreementStart"]).ToString("yyyy-MM-dd"),
                                ["AgreementEnd"] = dr["AgreementEnd"] == DBNull.Value ? "" : Convert.ToDateTime(dr["AgreementEnd"]).ToString("yyyy-MM-dd"),
                                ["RingNumber"] = dr["RingNumber"].ToString()
                            };
                            results.Add(row);
                        }
                    }
                }
            }

            return results;
        }



        // UPDATE ANY CELL
        [WebMethod]
        public static string UpdatePOCell(string id, string column, string value)
        {
            string connStr = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    var allowedColumns = new HashSet<string> {
                        "SupplierID","prstype","PONumber","PODate",
                        "POPaymentType","PaymentsApplicable","POAmount","InvoiceAmount",
                        "natureofexp","AgreementStart","AgreementEnd","RingNumber"
                    };

                    if (!allowedColumns.Contains(column))
                        throw new Exception("Invalid column name");

                    string sql = $"UPDATE SupplierPOEntry SET {column} = @value WHERE ID = @id";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        if (column == "PODate" || column == "AgreementStart" || column == "AgreementEnd")
                        {
                            if (DateTime.TryParse(value, out DateTime dt))
                                cmd.Parameters.AddWithValue("@value", dt);
                            else
                                cmd.Parameters.AddWithValue("@value", DBNull.Value);
                        }
                        else if (column == "POAmount" || column == "InvoiceAmount")
                        {
                            if (decimal.TryParse(value.Replace(",", ""), out decimal dec))
                                cmd.Parameters.AddWithValue("@value", dec);
                            else
                                cmd.Parameters.AddWithValue("@value", 0);
                        }
                        else
                        {
                            cmd.Parameters.AddWithValue("@value", string.IsNullOrWhiteSpace(value) ? (object)DBNull.Value : value);
                        }

                        cmd.Parameters.AddWithValue("@id", id);
                        cmd.ExecuteNonQuery();
                    }
                }

                return "Success";
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }
    }
}
