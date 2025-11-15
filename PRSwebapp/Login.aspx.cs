using System;
using System.Data.SqlClient;
using System.Web.UI;

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
                // Clear inputs on page load
                txtUsername.Text = "";
                txtPassword.Text = "";

                lblError.Text = "";
                lblForgotMsg.Text = "";
                lblRecoverMsg.Text = "";

                // Optional: message after logout
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

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                string query = @"
                    SELECT L.Empname,
                           L.Employeeno AS UserID,
                           L.Deptid,            -- Added Deptid
                           D.Name AS Department,
                           L.PRS_Role
                    FROM login L
                    INNER JOIN Department D ON L.Deptid = D.ID
                    WHERE L.Employeeno = @u AND L.Password = @p";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@u", username);
                cmd.Parameters.AddWithValue("@p", password);

                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    Session["UserID"] = dr["UserID"].ToString();
                    Session["username"] = dr["EmpName"].ToString();
                    Session["department"] = dr["Department"].ToString();
                    Session["Role"] = dr["PRS_Role"].ToString();

                    // Deptid session variable
                    Session["deptid"] = dr["Deptid"].ToString();

                    Response.Redirect("dashboard.aspx");
                }
                else
                {
                    lblError.Text = "Invalid username or password!";
                    lblError.CssClass = "text-danger d-block mb-2";
                }
            }
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
                    SqlCommand cmd = new SqlCommand("UPDATE Useers SET Password=@pass WHERE Email=@em", con);
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
                SqlCommand cmd = new SqlCommand("SELECT Email FROM Useers WHERE EmpID=@id", con);
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
    }
}
