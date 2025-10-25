<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="PRSwebapp.Login" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Login - Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
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
        .login-card img.logo { width: 80px; margin-bottom: 20px; }
        .login-card h3 { font-weight: 700; color: #333; margin-bottom: 30px; }
        .form-control { border-radius: 12px; height: 45px; margin-bottom: 15px; border: 1px solid #ddd; font-size: 15px; padding-left: 15px; }
        .btn-primary { width: 100%; height: 45px; border-radius: 12px; background: linear-gradient(90deg, #6a11cb, #2575fc); border: none; font-weight: 600; }
        .footer-text { margin-top: 15px; font-size: 13px; color: #666; }
        .error-text { color: red; font-size: 14px; margin-bottom: 10px; display: block; }
    </style>
</head>
<body>
    <form runat="server">
        <div class="login-card">
            <img src="images/Sakra-logo.png" alt="Hospital Logo" class="logo" />
            <h3>Hospital Admin Login</h3>

            <asp:Label ID="lblError" runat="server" CssClass="error-text"></asp:Label>

            <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" Placeholder="Username"></asp:TextBox>
            <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" Placeholder="Password"></asp:TextBox>
            <asp:Button ID="btnLogin" runat="server" CssClass="btn btn-primary" Text="Login" OnClick="btnLogin_Click" />

            <div class="footer-text">&copy; 2025 Sakra Hospital. All rights reserved.</div>
        </div>
    </form>
</body>
</html>
