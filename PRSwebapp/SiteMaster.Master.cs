using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace PRSwebapp
{
    public partial class SiteMaster : System.Web.UI.MasterPage
    {
        string conStr = ConfigurationManager.ConnectionStrings["PRSConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect if not logged in
            if (Session["UserID"].ToString() == null || Session["UserID"].ToString() == "")
            {
                Response.Redirect("Login.aspx");
              
            }

            // Set Username
            lblUserName.Text = Session["UserName"] != null
                ? Session["UserName"].ToString()
                : "Guest";

            if (!IsPostBack)
            {
                // Load Hospitals
                LoadHospitalsByUserRole();

                if (Session["HospitalID"] != null &&
                    ddlHospital.Items.FindByValue(Session["HospitalID"].ToString()) != null)
                {
                    ddlHospital.SelectedValue = Session["HospitalID"].ToString();
                }

                // Load Hospital Name & Logo
                LoadHospitalDetails();

                // Load Roles Based on Selected Hospital
                LoadRolesByUserAndHospital();
            }

            // ✅ Set Role Name **after roles are loaded**
            lblUserRole.Text = Session["PRS_RoleName"] != null
     ? "Role: " + Session["PRS_RoleName"].ToString()
     : "Role: No Role";

            // IT Department visibility
            string allowedEmployee = "01686";

            if (Session["UserID"] != null && Session["UserID"].ToString() == allowedEmployee)
            {
                // Show restricted links / page content
                lnkRoleDetailsTop.Visible = true;
                lnkRoleDetailsSide.Visible = true;
                lnkSupplierDetailsTop.Visible = true;
                lnkSupplierDetailsSide.Visible = true;
                lnkSupplierreg.Visible = true;
                lnkSupplierregTop.Visible = true;
            }
            else
            {
                // Hide links for all other users
                lnkRoleDetailsTop.Visible = false;
                lnkRoleDetailsSide.Visible = false;
                lnkSupplierDetailsTop.Visible = false;
                lnkSupplierDetailsSide.Visible = false;
                lnkSupplierreg.Visible = false;
                lnkSupplierregTop.Visible = false;

                // Optional: redirect users who are not allowed
                // Response.Redirect("AccessDenied.aspx");
            }

            // Highlight Active Menu
            HighlightCurrentPage();
        }

        private void LoadRolesByUserAndHospital()
        {
            if (Session["UserID"] == null || Session["HospitalID"] == null)
                return;

            string defaultrole = "";
            string defaultroleID = "";

            ddlRole.Items.Clear();

            using (SqlConnection con = new SqlConnection(conStr))
            {
                string query = @"
        SELECT DISTINCT
            lr.PRS_Role AS RoleID,
            paf.Name AS RoleName,
            (SELECT PF.Name 
             FROM PRS_Process_Approval_flow PF 
             WHERE PF.SeqID = l.PRS_Role) AS DefPrsRole,
            l.PRS_Role AS DefPRSRoleID
        FROM LOGIN l
        INNER JOIN login_role lr ON l.Employeeno = lr.UserID
        INNER JOIN PRS_Process_Approval_flow paf 
            ON lr.PRS_Role = paf.SeqID
        WHERE lr.UserID = @UserID
        AND paf.HospitalID = @HospitalID
        ORDER BY lr.PRS_Role ASC";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@UserID", Session["UserID"]);
                cmd.Parameters.AddWithValue("@HospitalID", Session["HospitalID"]);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                while (dr.Read())
                {
                    ddlRole.Items.Add(new ListItem(
                        dr["RoleName"].ToString(),
                        dr["RoleID"].ToString()));

                    // Store default role from LOGIN table
                    defaultrole = dr["DefPrsRole"].ToString();
                    defaultroleID = dr["DefPRSRoleID"].ToString();
                }
            }

            // ✅ Selection Logic (Correct Way)

            // 1️⃣ If session role exists → select it
            if (Session["PRS_Role"] != null &&
                ddlRole.Items.FindByValue(Session["PRS_Role"].ToString()) != null)
            {
                ddlRole.SelectedValue = Session["PRS_Role"].ToString();
            }

            // 2️⃣ Else select default role from DB
            else if (!string.IsNullOrEmpty(defaultroleID) &&
                     ddlRole.Items.FindByValue(defaultroleID) != null)
            {
                ddlRole.SelectedValue = defaultroleID;

                Session["PRS_Role"] = defaultroleID;
                Session["PRS_RoleName"] = ddlRole.SelectedItem.Text;
            }

            // 3️⃣ Else fallback to first role
            else if (ddlRole.Items.Count > 0)
            {
                ddlRole.SelectedIndex = 0;

                Session["PRS_Role"] = ddlRole.SelectedValue;
                Session["PRS_RoleName"] = ddlRole.SelectedItem.Text;
            }
        }

        protected void btnSwitchRole_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(ddlRole.SelectedValue))
            {
                // Update session values
                Session["PRS_Role"] = ddlRole.SelectedValue;
                Session["PRS_RoleName"] = ddlRole.SelectedItem.Text;
                Session["Role"] = ddlRole.SelectedValue; // old compatibility

                // Refresh page to apply new role
                Response.Redirect(Request.RawUrl);
            }
        }

        // ================= LOAD HOSPITALS BASED ON USER ROLE =================
        private void LoadHospitalsByUserRole()
        {
            if (Session["UserID"] == null)
                return;

            using (SqlConnection con = new SqlConnection(conStr))
            {
                string query = @"
                    SELECT DISTINCT
                        H.HospitalID,
                        H.HospitalName
                    FROM Login_role LR
                    INNER JOIN Hospitals H ON LR.HospitalID = H.HospitalID
                    WHERE LR.UserID = @UserID
                      AND H.Status = 'Active'
                    ORDER BY H.HospitalName";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@UserID", Session["UserID"].ToString());

                con.Open();

                ddlHospital.DataSource = cmd.ExecuteReader();
                ddlHospital.DataTextField = "HospitalName";
                ddlHospital.DataValueField = "HospitalID";
                ddlHospital.DataBind();
            }

            ddlHospital.Items.Insert(0, new ListItem("-- Select Hospital --", ""));
        }


        protected void ddlRole_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(ddlRole.SelectedValue))
            {
                Session["PRS_Role"] = ddlRole.SelectedValue;
                Session["PRS_RoleName"] = ddlRole.SelectedItem.Text;

                // 🔥 Also update old session for compatibility
                Session["Role"] = ddlRole.SelectedValue;

                Response.Redirect("dashboard.aspx");
            }
        }



        // ================= HOSPITAL CHANGE EVENT =================
        protected void ddlHospital_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(ddlHospital.SelectedValue))
            {
                Session["HospitalID"] = ddlHospital.SelectedValue;

                // Clear old role when hospital changes
                Session.Remove("PRS_Role");
                Session.Remove("PRS_RoleName");

                // LoadHospitalDetails();
                // LoadRolesByUserAndHospital();

                Response.Redirect(Request.RawUrl);
            }
        }


        // ================= LOAD HOSPITAL NAME & LOGO =================
        private void LoadHospitalDetails()
        {
            if (Session["HospitalID"] == null)
            {
                lblHospitalName.Text = "SAKRA WORLD HOSPITAL";
                imgHospitalLogo.Src = "~/Images/Sakra-logo.png";
                return;
            }

            int hospitalId = Convert.ToInt32(Session["HospitalID"]);

            using (SqlConnection con = new SqlConnection(conStr))
            {
                string query = @"
                    SELECT HospitalName, LogoPath
                    FROM Hospitals
                    WHERE HospitalID = @HospitalID
                      AND Status = 'Active'";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@HospitalID", hospitalId);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    lblHospitalName.Text = dr["HospitalName"].ToString();
                    imgHospitalLogo.Src = "~/" + dr["LogoPath"].ToString();
                }
                else
                {
                    lblHospitalName.Text = "SAKRA WORLD HOSPITAL";
                    imgHospitalLogo.Src = "~/Images/Sakra-logo.png";
                }
            }
        }

        // ================= LOGOUT =================
        protected void Master_OnCommand(object sender, CommandEventArgs e)
        {
            if (e.CommandName == "Masterlogout")
            {
                Session.Clear();
                Session.Abandon();
                Response.Redirect("Login.aspx", true);
            }
        }

        // ================= MENU HIGHLIGHT =================
        private void HighlightCurrentPage()
        {
            string pageName = System.IO.Path.GetFileName(Request.Path).ToLower();

            foreach (Control ctrl in topNav.Controls)
            {
                if (ctrl is HtmlAnchor anchor)
                {
                    if (anchor.HRef.ToLower().Contains(pageName))
                        anchor.Attributes["class"] = "active";
                    else
                        anchor.Attributes.Remove("class");
                }
            }

            foreach (Control ctrl in sidebar.Controls)
            {
                if (ctrl is HtmlAnchor anchor)
                {
                    if (anchor.HRef.ToLower().Contains(pageName))
                        anchor.Attributes["class"] = "active";
                    else
                        anchor.Attributes.Remove("class");
                }
            }
        }
    }
}
