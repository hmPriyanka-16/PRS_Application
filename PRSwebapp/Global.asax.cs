using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.SessionState;

namespace PRSwebapp
{
    public class Global : System.Web.HttpApplication
    {

        protected void Application_Start(object sender, EventArgs e)
        {

        }

        protected void Session_Start(object sender, EventArgs e)
        {
            Session["username"] = "";
            Session["userId"] = "";
            Session["EmpName"] = "";
            Session["depid"] = "";
            Session["department"] = "";
            Session["Role"] = "0";
        }

        protected void Application_BeginRequest(object sender, EventArgs e)
        {

        }

        protected void Application_AuthenticateRequest(object sender, EventArgs e)
        {

        }

        protected void Application_Error(object sender, EventArgs e)
        {

        }

        protected void Session_End(object sender, EventArgs e)
        {

            Session["username"] = "";
            Session["userId"] = "";
            Session["EmpName"] = "";
            Session["depid"] = "";
            Session["department"] = "";
            Session["Role"] = "0";
        }

        protected void Application_End(object sender, EventArgs e)
        {

        }
    }
}