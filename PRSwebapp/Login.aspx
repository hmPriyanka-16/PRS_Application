<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="PRSwebapp.Login" Async="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Login - Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        body {
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background: linear-gradient(135deg, #6a11cb, #2575fc);
            font-family: 'Poppins', sans-serif;
            margin: 0;
        }
        .login-card {
            width: 380px;
            background: #fff;
            border-radius: 20px;
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.25);
            padding: 50px 30px 40px 30px;
            text-align: center;
        }
        .form-control {
            border-radius: 10px;
            height: 34px;          /* smaller height */
            margin-bottom: 10px;
            border: 1px solid #ddd;
            font-size: 13px;       /* smaller text */
            padding: 6px 10px;     /* reduced padding */
         }


        .login-card img.logo { width: 80px; margin-bottom: 20px; }
        .login-card h3 { font-weight: 700; color: #333; margin-bottom: 30px; }
        .btn-primary { width: 100%; height: 45px; border-radius: 12px; background: linear-gradient(90deg, #6a11cb, #2575fc); border: none; font-weight: 600; }
        .footer-text { margin-top: 15px; font-size: 13px; color: #666; }
        .error-text { color: red; font-size: 14px; margin-bottom: 10px; display: block; }
        .forgot-link { display: block; margin-top: 10px; font-size: 14px; color: #2575fc; cursor: pointer; text-decoration: underline; }
    </style>
</head>
<body>
    <form runat="server">
        <div class="login-card">
            <img src="images/Sakra-logo.png" alt="Hospital Logo" class="logo" />
<h3>SAHAJ</h3>
    <h6 style="margin-top: -30px; margin-bottom: 20px; font-weight: 400; color: #555; font-size: 12px;">
        (Sakra Automation Hub For Accelerating Jobs)
    </h6>
            <asp:Label ID="lblError" runat="server" CssClass="error-text"></asp:Label>

            <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" Placeholder="Username"></asp:TextBox>
            <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" Placeholder="Password"></asp:TextBox>

          



            <asp:Button ID="btnLogin" runat="server" CssClass="btn btn-primary" Text="Login" OnClick="btnLogin_Click" />

                     <a class="forgot-link" data-bs-toggle="modal" data-bs-target="#getPasswordEmailModal">Get Password via Email?</a>

            <a class="forgot-link" data-bs-toggle="modal" data-bs-target="#forgotPasswordModal">Reset Password?</a>

            <div class="footer-text">&copy; 2025 Sakra Hospital. All rights reserved.</div>
        </div>
       
        
      
        <!-- Forgot Password Modal -->
        <div class="modal fade" id="forgotPasswordModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content p-3">
                    <div class="modal-header">
                        <h5 class="modal-title">Reset Password</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <asp:Label ID="lblForgotMsg" runat="server" CssClass="text-success d-block mb-2"></asp:Label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" Placeholder="Enter your registered email"></asp:TextBox>
                        <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" TextMode="Password" Placeholder="Enter new password"></asp:TextBox>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" Placeholder="Confirm new password"></asp:TextBox>

                        <a class="forgot-link mt-2" data-bs-toggle="modal" data-bs-target="#forgotEmailModal" data-bs-dismiss="modal">Forgot your email?</a>
                    </div>
                    <div class="modal-footer">
                        <asp:Button ID="btnResetPassword" runat="server" Text="Reset Password" CssClass="btn btn-primary" OnClick="btnResetPassword_Click" />
                    </div>
                </div>
            </div>
        </div>

<!-- Get Password via Email Modal -->
<div class="modal fade" id="getPasswordEmailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content p-3">
            <div class="modal-header">
                <h5 class="modal-title">Get Password via Email</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <asp:Label ID="lblGetPasswordEmailMsg" runat="server" CssClass="text-success d-block mb-2"></asp:Label>
                <asp:TextBox ID="txtGetPasswordEmailEmpId" runat="server" CssClass="form-control" Placeholder="Enter your Employee ID"></asp:TextBox>
            </div>
            <div class="modal-footer">
                <asp:Button ID="btnGetPasswordEmail" runat="server" Text="Send Password" CssClass="btn btn-primary" OnClick="btnGetPasswordEmail_Click" />
            </div>
        </div>
    </div>
</div>

        <!-- Forgot Email Modal -->
        <div class="modal fade" id="forgotEmailModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content p-3">
                    <div class="modal-header">
                        <h5 class="modal-title">Recover Email</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <asp:Label ID="lblRecoverMsg" runat="server" CssClass="text-success d-block mb-2"></asp:Label>
                        <asp:TextBox ID="txtEmpId" runat="server" CssClass="form-control" Placeholder="Enter your Employee ID"></asp:TextBox>
                    </div>
                    <div class="modal-footer">
                        <asp:Button ID="btnRecoverEmail" runat="server" Text="Show Email ID" CssClass="btn btn-primary" OnClick="btnRecoverEmail_Click" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Hidden field to track which modal to reopen -->
        <asp:HiddenField ID="hdnModalToOpen" runat="server" />

        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const modalToOpen = document.getElementById('<%= hdnModalToOpen.ClientID %>').value;
                if (modalToOpen) {
                    const myModal = new bootstrap.Modal(document.getElementById(modalToOpen));
                    myModal.show();
                }
            });
          
                document.addEventListener('DOMContentLoaded', function () {

        const modalToOpen = document.getElementById('<%= hdnModalToOpen.ClientID %>').value;
        if (modalToOpen) {
            const myModal = new bootstrap.Modal(document.getElementById(modalToOpen));
            myModal.show();
        }

        // 🔥 Auto clear message after 2 seconds
        var messageLabel = document.getElementById('<%= lblGetPasswordEmailMsg.ClientID %>');
                if (messageLabel && messageLabel.innerText.trim() !== "") {
                    setTimeout(function () {
                        messageLabel.innerText = "";
                    }, 2000); // 2000 milliseconds = 2 seconds
        }

                });

           
                document.addEventListener("DOMContentLoaded", function () {

    const modalToOpen = document.getElementById('<%= hdnModalToOpen.ClientID %>').value;

    if (modalToOpen) {
        const myModal = new bootstrap.Modal(document.getElementById(modalToOpen));
        myModal.show();
    }

    // Remove leftover bootstrap backdrop (fix black screen)
    document.querySelectorAll('.modal').forEach(function (modalEl) {
        modalEl.addEventListener('hidden.bs.modal', function () {

            document.body.classList.remove('modal-open');

            document.querySelectorAll('.modal-backdrop').forEach(function (backdrop) {
                backdrop.remove();
            });

            document.body.style = "";
        });
    });

    // Auto clear message
    var messageLabel = document.getElementById('<%= lblGetPasswordEmailMsg.ClientID %>');
                if (messageLabel && messageLabel.innerText.trim() !== "") {
                    setTimeout(function () {
                        messageLabel.innerText = "";
                    }, 2000);
    }

});
       

        
        </script>
    </form>
</body>
</html>
