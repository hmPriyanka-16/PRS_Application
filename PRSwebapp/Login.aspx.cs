using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Net;
using System.Net.Mail;
using System.Web.UI.WebControls;

namespace PRSwebapp
{
    public partial class Login : Page
    {
        string connectionString = System.Configuration.ConfigurationManager
            .ConnectionStrings["PRSConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtUsername.Text = "";
                txtPassword.Text = "";
                lblError.Text = "";
                lblForgotMsg.Text = "";
                lblRecoverMsg.Text = "";

                if (Request.QueryString["logout"] == "true")
                {
                    lblError.Text = "You have been logged out successfully.";
                    lblError.CssClass = "text-success d-block mb-2";
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            string DfRole = "";
            string DfRolename = "";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                string query = @"
SELECT Top 1 
    L.Empname,
    L.Employeeno AS UserID,
    LR.Deptid,
    D.Name AS Department,
    L.PRS_Role,
    L.HospitalID,
    L.PRS_DeptID
FROM login L
Inner Join Login_Role LR on LR.UserID=L.Employeeno
LEFT JOIN Department D ON L.Deptid = D.ID
WHERE L.Active = 0 
  AND L.Employeeno = @u 
  AND L.Password = @p";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@u", username);
                cmd.Parameters.AddWithValue("@p", password);

                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    Session["UserID"] = dr["UserID"].ToString();
                    Session["username"] = dr["Empname"].ToString();
                    Session["department"] = dr["Department"].ToString();
                    Session["deptid"] = dr["Deptid"].ToString();
                    Session["Role"] = dr["PRS_Role"].ToString();
                    Session["HospitalID"] = dr["HospitalID"].ToString();
                    Session["PRS_DeptID"] = dr["PRS_DeptID"].ToString();
                    dr.Close();

                    Response.Redirect("dashboard.aspx");
                }
                else
                {
                    lblError.Text = "Invalid username or password!";
                    lblError.CssClass = "text-danger d-block mb-2";
                }
            }
        }


        // Query Login_role joined with Hospitals and PRS_Process_Approval_Flow for a user
        private DataTable GetUserRoleHospitalMappings(string userId)
        {
            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                // LR.PRS_Role maps to PRS_Process_Approval_Flow.ID (Role ID)
                // LR.HospitalID maps to Hospitals.HospitalID
                string sql = @"
                    SELECT DISTINCT
                        LR.HospitalID,
                        H.HospitalName,
                        LR.PRS_Role,
                        PF.Name AS RoleName,
                        LR.Deptid
                    FROM Login_role LR
                    LEFT JOIN Hospitals H ON LR.HospitalID = H.HospitalID
                    LEFT JOIN PRS_Process_Approval_Flow PF ON LR.PRS_Role = PF.ID
                    WHERE LR.UserID = @uid
                    ORDER BY H.HospitalName, PF.Name";

                SqlCommand cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@uid", userId);

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            return dt;
        }

        protected void btnResetPassword_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();
            string newPassword = txtNewPassword.Text.Trim();
            string confirmPassword = txtConfirmPassword.Text.Trim();

            if (string.IsNullOrEmpty(email))
            {
                lblForgotMsg.Text = "Please enter your registered email.";
                lblForgotMsg.CssClass = "text-danger d-block mb-2";
            }
            else if (newPassword != confirmPassword)
            {
                lblForgotMsg.Text = "Passwords do not match.";
                lblForgotMsg.CssClass = "text-danger d-block mb-2";
            }
            else
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand(
                        "UPDATE login SET Password=@pass WHERE emailid=@em", con);

                    cmd.Parameters.AddWithValue("@pass", newPassword);
                    cmd.Parameters.AddWithValue("@em", email);

                    int rows = cmd.ExecuteNonQuery();

                    if (rows > 0)
                    {
                        lblForgotMsg.Text = "Password successfully reset!";
                        lblForgotMsg.CssClass = "text-success d-block mb-2";
                        txtEmail.Text = "";
                        txtNewPassword.Text = "";
                        txtConfirmPassword.Text = "";
                    }
                    else
                    {
                        lblForgotMsg.Text = "No user found with this email.";
                        lblForgotMsg.CssClass = "text-danger d-block mb-2";
                    }
                }
            }

            hdnModalToOpen.Value = "forgotPasswordModal";
        }

        protected void btnRecoverEmail_Click(object sender, EventArgs e)
        {
            string empId = txtEmpId.Text.Trim();

            if (string.IsNullOrEmpty(empId))
            {
                lblRecoverMsg.Text = "Please enter your Employee ID.";
                lblRecoverMsg.CssClass = "text-danger d-block mb-2";
                hdnModalToOpen.Value = "forgotEmailModal";
                return;
            }

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                SqlCommand cmd = new SqlCommand(
                    "SELECT emailid FROM login WHERE Active=0 And Employeeno = @id", con);

                cmd.Parameters.AddWithValue("@id", empId);

                object result = cmd.ExecuteScalar();

                if (result != null)
                {
                    lblRecoverMsg.Text = "Your registered email: " + result.ToString();
                    lblRecoverMsg.CssClass = "text-success d-block mb-2";
                }
                else
                {
                    lblRecoverMsg.Text = "No record found for Employee ID: " + empId;
                    lblRecoverMsg.CssClass = "text-danger d-block mb-2";
                }
            }

            hdnModalToOpen.Value = "forgotEmailModal";
        }


        protected void btnGetPasswordEmail_Click(object sender, EventArgs e)
        {
            string empId = txtGetPasswordEmailEmpId.Text.Trim();

            if (string.IsNullOrEmpty(empId))
            {
                lblGetPasswordEmailMsg.Text = "Please enter your Employee ID.";
                lblGetPasswordEmailMsg.CssClass = "text-danger d-block mb-2";
                hdnModalToOpen.Value = "getPasswordEmailModal";
                return;
            }

            string empName = "";
            string email = "";
            string password = "";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                SqlCommand cmd = new SqlCommand(
                    "SELECT EmpName, emailid, Password FROM login WHERE Active=0 AND Employeeno=@id",
                    con);

                cmd.Parameters.AddWithValue("@id", empId);

                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    empName = dr["EmpName"].ToString();
                    email = dr["emailid"].ToString();
                    password = dr["Password"].ToString();
                }
                dr.Close();
            }

            if (string.IsNullOrEmpty(email))
            {
                lblGetPasswordEmailMsg.Text = "No record found for Employee ID: " + empId;
                lblGetPasswordEmailMsg.CssClass = "text-danger d-block mb-2";
                hdnModalToOpen.Value = "getPasswordEmailModal";
                return;
            }

            // Email body
            string body = "<html><body>" +
                          "<p>Dear " + empName + ",</p>" +
                          "<p>Your login password is: <b>" + password + "</b></p>" +
                          "<p>Please keep it confidential.</p>" +
                          "<br/>Regards,<br/>IT Team</body></html>";

            // Send email in background
            System.Threading.Tasks.Task.Run(() =>
            {
                try
                {
                    using (MailMessage mail = new MailMessage())
                    {
                        mail.From = new MailAddress("sahaj@sakraworldhospital.com");
                        mail.To.Add(email);
                        mail.Subject = "Your Sakra Login Password";
                        mail.Body = body;
                        mail.IsBodyHtml = true;

                        using (SmtpClient smtp = new SmtpClient("mail.sakraworldhospital.com", 25))
                        {
                            smtp.Credentials = new NetworkCredential(
                                "umesh.gowda@sakraworldhospital.com",
                                "abcd123$");

                            smtp.EnableSsl = false;
                            smtp.Send(mail);
                        }
                    }
                }
                catch
                {
                    // Optional: log error
                }
            });

            lblGetPasswordEmailMsg.Text = "Password has been sent to your registered email.";
            lblGetPasswordEmailMsg.CssClass = "text-success d-block mb-2";
            txtGetPasswordEmailEmpId.Text = "";

            // Reopen modal to show message
            hdnModalToOpen.Value = "getPasswordEmailModal";

            // Close modal automatically after 2 seconds
            ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal",
            "setTimeout(function(){ var modal = bootstrap.Modal.getInstance(document.getElementById('getPasswordEmailModal')); if(modal){ modal.hide(); } },2000);", true);
        }
    }
}
