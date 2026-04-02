using System;
using System.Configuration;
using System.Data.SqlClient;

namespace PRSwebapp
{
    public partial class dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // ✅ Proper login check (FIXED)
            if (Session["UserID"] == null || Session["UserID"].ToString() == "")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadPendingSummary(); // ✅ Load dashboard data
                LoadInProgressSummary();
                LoadRejectedSummary();
                LoadHoldSummary();
                LoadQuerySummary();
            }

            // ✅ Show Supplier PO / Supplier Registration only for Employee 01686
            string allowedEmployee = "01686";

            if (Session["UserID"].ToString() == allowedEmployee)
            {
                divSupplierPO.Visible = true;
                divSupplierreg.Visible = true;
            }
            else
            {
                divSupplierPO.Visible = false;
                divSupplierreg.Visible = false;
            }
        }

        // ✅ LOAD PENDING COUNT + AMOUNT
        private void LoadPendingSummary()
        {
            string connString = ConfigurationManager
                .ConnectionStrings["PRSConnectionString"].ConnectionString;

            string role = Session["Role"]?.ToString() ?? "0";
            string hospitalId = Session["HospitalID"]?.ToString() ?? "0";
            string userId = Session["UserID"]?.ToString() ?? "0";

            string query = "";

            switch (role)
            {
                // SAME as Pending Page
                case "1":
                case "2":
                case "51":
                case "52":
                case "53":
                case "54":

                    query = @"
            SELECT 
                COUNT(*) AS TotalCount,
                ISNULL(SUM(Inoviceamount),0) AS TotalAmount
            FROM vw_PRSlist 
WHERE PRSStatus IN ('New', 'Approved')
AND Next_Sequence = @Role
              AND HospitalID = @HospitalID 
              AND DeptID IN (
                    SELECT DeptID 
                    FROM login_role 
                    WHERE userid = @UserID
              )";
                    break;

                default:

                    query = @"
            SELECT 
                COUNT(*) AS TotalCount,
                ISNULL(SUM(Inoviceamount),0) AS TotalAmount
            FROM vw_PRSlist 
WHERE PRSStatus IN ('New', 'Approved')
AND Next_Sequence = @Role
              AND HospitalID = @HospitalID";
                    break;
            }

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@Role", role);
                cmd.Parameters.AddWithValue("@HospitalID", hospitalId);
                cmd.Parameters.AddWithValue("@UserID", userId);

                con.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        lblPendingCount.Text = reader["TotalCount"].ToString();

                        decimal amount = reader["TotalAmount"] != DBNull.Value
                            ? Convert.ToDecimal(reader["TotalAmount"])
                            : 0;

                        lblPendingAmount.Text = FormatAmountShort(amount);
                    }
                }
            }
        }

        private void LoadRejectedSummary()
        {
            string connString = ConfigurationManager
                .ConnectionStrings["PRSConnectionString"].ConnectionString;

            int hospitalId = 0;
            int.TryParse(Session["HospitalID"]?.ToString(), out hospitalId);

            string role = Session["Role"]?.ToString() ?? "0";
            string userId = Session["UserID"]?.ToString();

            string query = "";

            // 🔴 SAME LOGIC AS YOUR OTHER METHODS
            if (role == "1" || role == "51" || role == "52" || role == "53" || role == "54")
            {
                query = @"
        SELECT 
            COUNT(*) AS TotalCount,
            ISNULL(SUM(Inoviceamount),0) AS TotalAmount
        FROM vw_PRSlist 
        WHERE PRSStatus = 'Rejected'
          AND (Emp_code = @UserID OR Emp_code IS NULL)
          AND (Deptid IN (SELECT DeptID FROM Login_role WHERE UserID = @UserID))
          AND HospitalID = @HospitalID";
            }
            else if (role == "2")
            {
                query = @"
        SELECT 
            COUNT(*) AS TotalCount,
            ISNULL(SUM(Inoviceamount),0) AS TotalAmount
        FROM vw_PRSlist 
        WHERE PRSStatus = 'Rejected'
          AND (Deptid IN (SELECT DeptID FROM Login_role WHERE UserID = @UserID))
          AND HospitalID = @HospitalID";
            }
            else
            {
                query = @"
        SELECT 
            COUNT(*) AS TotalCount,
            ISNULL(SUM(Inoviceamount),0) AS TotalAmount
        FROM vw_PRSlist 
        WHERE PRSStatus = 'Rejected'
          AND HospitalID = @HospitalID";
            }

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@HospitalID", hospitalId);

                con.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        lblRejectedCount.Text = reader["TotalCount"].ToString();

                        decimal amount = reader["TotalAmount"] != DBNull.Value
                            ? Convert.ToDecimal(reader["TotalAmount"])
                            : 0;

                        lblRejectedAmount.Text = FormatAmountShort(amount);
                    }
                }
            }
        }

        private void LoadHoldSummary()
        {
            string connString = ConfigurationManager
                .ConnectionStrings["PRSConnectionString"].ConnectionString;

            int hospitalId = 0;
            int.TryParse(Session["HospitalID"]?.ToString(), out hospitalId);

            string role = Session["Role"]?.ToString() ?? "0";
            string userId = Session["UserID"]?.ToString();

            string query = "";

            if (role == "1" || role == "51" || role == "52" || role == "53" || role == "54")
            {
                query = @"
        SELECT 
            COUNT(*) AS TotalCount,
            ISNULL(SUM(Inoviceamount),0) AS TotalAmount
        FROM vw_PRSlist 
        WHERE PRSStatus = 'Hold'
          AND (Emp_code = @UserID OR Emp_code IS NULL)
          AND (Deptid IN (SELECT DeptID FROM Login_role WHERE UserID = @UserID))
          AND HospitalID = @HospitalID";
            }
            else if (role == "2")
            {
                query = @"
        SELECT 
            COUNT(*) AS TotalCount,
            ISNULL(SUM(Inoviceamount),0) AS TotalAmount
        FROM vw_PRSlist 
        WHERE PRSStatus = 'Hold'
          AND (Deptid IN (SELECT DeptID FROM Login_role WHERE UserID = @UserID))
          AND HospitalID = @HospitalID";
            }
            else
            {
                query = @"
        SELECT 
            COUNT(*) AS TotalCount,
            ISNULL(SUM(Inoviceamount),0) AS TotalAmount
        FROM vw_PRSlist 
        WHERE PRSStatus = 'Hold'
          AND HospitalID = @HospitalID";
            }

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@HospitalID", hospitalId);

                con.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        lblHoldCount.Text = reader["TotalCount"].ToString();

                        decimal amount = reader["TotalAmount"] != DBNull.Value
                            ? Convert.ToDecimal(reader["TotalAmount"])
                            : 0;

                        lblHoldAmount.Text = FormatAmountShort(amount);
                    }
                }
            }
        }
        private void LoadQuerySummary()
        {
            string connString = ConfigurationManager
                .ConnectionStrings["PRSConnectionString"].ConnectionString;

            int hospitalId = 0;
            int.TryParse(Session["HospitalID"]?.ToString(), out hospitalId);

            string role = Session["Role"]?.ToString() ?? "0";
            string userId = Session["UserID"]?.ToString();

            string query = "";

            // ✅ SAME PATTERN AS HOLD / REJECTED
            if (role == "1" || role == "51" || role == "52" || role == "53" || role == "54")
            {
                query = @"
        SELECT 
            COUNT(*) AS TotalCount,
            ISNULL(SUM(Inoviceamount),0) AS TotalAmount
        FROM vw_PRSlist 
        WHERE PRSStatus = 'Query'
          AND (Emp_code = @UserID OR Emp_code IS NULL)
          AND (Deptid IN (SELECT DeptID FROM Login_role WHERE UserID = @UserID))
          AND HospitalID = @HospitalID";
            }
            else if (role == "2")
            {
                query = @"
        SELECT 
            COUNT(*) AS TotalCount,
            ISNULL(SUM(Inoviceamount),0) AS TotalAmount
        FROM vw_PRSlist 
        WHERE PRSStatus = 'Query'
          AND (Deptid IN (SELECT DeptID FROM Login_role WHERE UserID = @UserID))
          AND HospitalID = @HospitalID";
            }
            else
            {
                query = @"
        SELECT 
            COUNT(*) AS TotalCount,
            ISNULL(SUM(Inoviceamount),0) AS TotalAmount
        FROM vw_PRSlist 
        WHERE PRSStatus = 'Query'
          AND HospitalID = @HospitalID";
            }

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@HospitalID", hospitalId);

                con.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        lblQueryCount.Text = reader["TotalCount"].ToString();

                        decimal amount = reader["TotalAmount"] != DBNull.Value
                            ? Convert.ToDecimal(reader["TotalAmount"])
                            : 0;

                        lblQueryAmount.Text = FormatAmountShort(amount);
                    }
                }
            }
        }
        private void LoadInProgressSummary()
        {
            string connString = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

            int hospitalId = 0;
            int.TryParse(Session["HospitalID"]?.ToString(), out hospitalId);

            string role = Session["Role"]?.ToString() ?? "0";
            string userId = Session["UserID"]?.ToString();

            string query = "";

            // ✅ SAME LOGIC AS InProgress PAGE
            if (role == "1" || role == "51" || role == "52" || role == "53" || role == "54")
            {
                query = @"
        SELECT 
            COUNT(*) AS TotalCount,
            ISNULL(SUM(Inoviceamount),0) AS TotalAmount
        FROM vw_PRSlist 
        WHERE PRSStatus <> 'Completed'
          AND (Emp_code = @UserID OR Emp_code IS NULL)
          AND (Deptid IN (SELECT DeptID FROM Login_role WHERE UserID = @UserID))
          AND HospitalID = @HospitalID";
            }
            else if (role == "2")
            {
                query = @"
        SELECT 
            COUNT(*) AS TotalCount,
            ISNULL(SUM(Inoviceamount),0) AS TotalAmount
        FROM vw_PRSlist 
        WHERE PRSStatus <> 'Completed'
          AND (Deptid IN (SELECT DeptID FROM Login_role WHERE UserID = @UserID))
          AND HospitalID = @HospitalID";
            }
            else
            {
                query = @"
        SELECT 
            COUNT(*) AS TotalCount,
            ISNULL(SUM(Inoviceamount),0) AS TotalAmount
        FROM vw_PRSlist 
        WHERE PRSStatus <> 'Completed'
          AND HospitalID = @HospitalID";
            }

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@HospitalID", hospitalId);

                con.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        lblInProgressCount.Text = reader["TotalCount"].ToString();

                        decimal amount = reader["TotalAmount"] != DBNull.Value
                            ? Convert.ToDecimal(reader["TotalAmount"])
                            : 0;

                        lblInProgressAmount.Text = FormatAmountShort(amount);
                    }
                }
            }
        }
        // ✅ SHORT FORMAT (₹ 3.4 L / ₹ 1.2 Cr)
        private string FormatAmountShort(decimal amount)
        {
            if (amount >= 100000) // Lakhs (MAX)
                return "₹ " + (amount / 100000).ToString("0.#") + " L";

            if (amount >= 1000) // Thousands
                return "₹ " + (amount / 1000).ToString("0.#") + " K";

            return "₹ " + amount.ToString("0.##");
        }
    }
}