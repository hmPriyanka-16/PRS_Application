using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace PRSwebapp
{
    public partial class ROLEDETAILS : System.Web.UI.Page
    {
        string conStr = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

        protected Dictionary<string, int> DepartmentDict = new Dictionary<string, int>();

        protected void Page_Load(object sender, EventArgs e)
        {
            int? hospitalId = null;

            if (Session["HospitalID"] != null && int.TryParse(Session["HospitalID"].ToString(), out int hid))
                hospitalId = hid;

            Session["HospitalID"] = hospitalId;

            if (!IsPostBack)
            {
                LoadHospitals();
                LoadPRSFlowRoles();
                LoadDepartments();
                ClearForm();
            }
        }

        private void LoadHospitals()
        {
            ddlHospital.Items.Clear();
            ddlHospital.Items.Add(new ListItem("-- Select Hospital --", ""));

            string query = "SELECT HospitalID, HospitalName FROM Hospitals WHERE Status='Active' ORDER BY HospitalName";

            using (SqlConnection con = new SqlConnection(conStr))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                while (dr.Read())
                {
                    ddlHospital.Items.Add(new ListItem(dr["HospitalName"].ToString(), dr["HospitalID"].ToString()));
                }
            }

            if (Session["HospitalID"] != null)
                ddlHospital.SelectedValue = Session["HospitalID"].ToString();
        }

        private void LoadPRSFlowRoles()
        {
            ddlRole.Items.Clear();
            ddlRole.Items.Add(new ListItem("-- Select Role --", ""));

            string query = @"
                SELECT SeqID, Name 
                FROM PRS_Process_Approval_flow 
                WHERE EndDate IS NULL 
                ORDER BY SeqID";

            using (SqlConnection con = new SqlConnection(conStr))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                while (dr.Read())
                {
                    ddlRole.Items.Add(new ListItem(dr["Name"].ToString(), dr["SeqID"].ToString()));
                }
            }
        }

        private void LoadDepartments()
        {
            DepartmentDict.Clear();

            string query = "SELECT ID, Name FROM Department ORDER BY Name";

            using (SqlConnection con = new SqlConnection(conStr))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                while (dr.Read())
                {
                    DepartmentDict[dr["Name"].ToString()] = Convert.ToInt32(dr["ID"]);
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string empId = txtEmpCode.Text.Trim();

            try
            {
                using (SqlConnection con = new SqlConnection(conStr))
                {
                    con.Open();

                    // ✅ DUPLICATE CHECK
                    string checkQuery = "SELECT COUNT(*) FROM Login WHERE Employeeno = @EmpID";

                    using (SqlCommand checkCmd = new SqlCommand(checkQuery, con))
                    {
                        checkCmd.Parameters.AddWithValue("@EmpID", empId);

                        int count = Convert.ToInt32(checkCmd.ExecuteScalar());

                        if (count > 0)
                        {
                            lblMessage.ForeColor = System.Drawing.Color.Red;
                            lblMessage.Text = "Employee ID already exists!";
                            return; // ❌ STOP INSERT
                        }
                    }

                    SqlTransaction trans = con.BeginTransaction();

                    try
                    {
                        int? deptId = string.IsNullOrEmpty(hfDepartmentID.Value)
                            ? (int?)null
                            : Convert.ToInt32(hfDepartmentID.Value);

                        int? prsRoleSeqId = string.IsNullOrEmpty(ddlRole.SelectedValue)
                            ? (int?)null
                            : Convert.ToInt32(ddlRole.SelectedValue);

                        // ================= LOGIN INSERT =================
                        string query1 = @"
    INSERT INTO Login
    (Employeeno, EmpName, emailid, DeptID, PRS_DeptID, Password, Active, CreatedDate, Role, HOD, EndDate, PRS_Role, HospitalID)
    VALUES
    (@Employeeno, @EmpName, @EmailID, @DeptID, @PRS_DeptID, @Password, @Active, @CreatedDate, @Role, @HOD, @EndDate, @PRS_Role, @HospitalID)";

                        using (SqlCommand cmd1 = new SqlCommand(query1, con, trans))
                        {
                            cmd1.Parameters.AddWithValue("@Employeeno", empId);
                            cmd1.Parameters.AddWithValue("@EmpName", txtEmpName.Text.Trim());
                            cmd1.Parameters.AddWithValue("@EmailID", txtEmail.Text.Trim());

                            cmd1.Parameters.Add("@DeptID", SqlDbType.Int).Value =
                                deptId.HasValue ? (object)deptId.Value : DBNull.Value;
                            cmd1.Parameters.Add("@PRS_DeptID", SqlDbType.Int).Value =
    deptId.HasValue ? (object)deptId.Value : DBNull.Value;
                            // ✅ Password = Employee ID
                            cmd1.Parameters.AddWithValue("@Password", empId);

                            cmd1.Parameters.AddWithValue("@Active", 0);
                            cmd1.Parameters.AddWithValue("@CreatedDate", DateTime.Now);
                            cmd1.Parameters.AddWithValue("@Role", 0);
                            cmd1.Parameters.AddWithValue("@HOD", 0);
                            cmd1.Parameters.AddWithValue("@EndDate", DBNull.Value);

                            cmd1.Parameters.AddWithValue("@PRS_Role",
                                prsRoleSeqId.HasValue ? (object)prsRoleSeqId.Value : DBNull.Value);

                            cmd1.Parameters.AddWithValue("@HospitalID",
                                string.IsNullOrEmpty(ddlHospital.SelectedValue)
                                ? (object)DBNull.Value
                                : ddlHospital.SelectedValue);

                            cmd1.ExecuteNonQuery();
                        }

                        // ================= SECOND TABLE INSERT =================
                        string query2 = @"
                            INSERT INTO Login_role
                            (UserID, DeptID, PRS_Role, HospitalID)
                            VALUES
                            (@UserID, @DeptID, @PRS_Role, @HospitalID)";

                        using (SqlCommand cmd2 = new SqlCommand(query2, con, trans))
                        {
                            cmd2.Parameters.AddWithValue("@UserID", empId);

                            cmd2.Parameters.Add("@DeptID", SqlDbType.Int).Value =
                                deptId.HasValue ? (object)deptId.Value : DBNull.Value;

                            cmd2.Parameters.AddWithValue("@PRS_Role",
                                prsRoleSeqId.HasValue ? (object)prsRoleSeqId.Value : DBNull.Value);

                            cmd2.Parameters.AddWithValue("@HospitalID",
                                string.IsNullOrEmpty(ddlHospital.SelectedValue)
                                ? (object)DBNull.Value
                                : ddlHospital.SelectedValue);

                            cmd2.ExecuteNonQuery();
                        }

                        trans.Commit();

                        lblMessage.ForeColor = System.Drawing.Color.Green;
                        lblMessage.Text = "Saved successfully";

                        // ✅ Reload dropdown data after save
                        LoadHospitals();
                        LoadPRSFlowRoles();
                        LoadDepartments();

                        ClearForm();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();

                        lblMessage.ForeColor = System.Drawing.Color.Red;
                        lblMessage.Text = ex.Message;
                    }
                }
            }
            catch (Exception ex)
            {
                lblMessage.ForeColor = System.Drawing.Color.Red;
                lblMessage.Text = ex.Message;
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
            lblMessage.Text = "";
        }

        private void ClearForm()
        {
            txtEmpCode.Text = "";
            txtEmpName.Text = "";
            txtEmail.Text = "";
            txtPhone.Text = "";
            txtDepartmentCombo.Text = "";
            hfDepartmentID.Value = "";
            ddlRole.ClearSelection();
            ddlHospital.ClearSelection();
        }
    }
}