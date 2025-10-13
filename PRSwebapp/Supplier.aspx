<%@ Page Title="Supplier Registration" Language="C#" MasterPageFile="~/SiteMaster.Master"
    AutoEventWireup="true" CodeBehind="Supplier.aspx.cs" Inherits="PRSwebapp.Supplier" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        body { background-color:#f4f0fa; font-family:"Segoe UI"; margin:0; padding:0; }
        .content-container { width:100%; padding-top:10px; display:flex; flex-direction:column; align-items:center; }
        .page-title { font-size:32px; font-weight:700; color:#6c5ce7; margin-bottom:20px; text-align:center; }
        .supplier-card { width:100%; max-width:1100px; background:#fff; border-radius:16px; box-shadow:0 8px 30px rgba(108,92,231,0.25); padding:35px 50px; box-sizing:border-box; }
        .form-grid { display:grid; grid-template-columns:repeat(3,1fr); column-gap:30px; row-gap:15px; }
        .form-group label { font-weight:600; color:#5a3fb5; font-size:15px; margin-bottom:5px; }
        .form-control, .status-dropdown { width:100%; padding:10px 12px; border:1px solid #ccc; border-radius:10px; font-size:14px; }
        .form-group.address { grid-column:span 2; }
        .btn-group { grid-column:span 3; display:flex; justify-content:center; gap:20px; margin-top:20px; }
        .btn { background:linear-gradient(90deg,#6c5ce7,#9b59b6); color:white; padding:12px 36px; border-radius:10px; border:none; font-weight:600; cursor:pointer; }
        .btn:hover { background:linear-gradient(90deg,#5a3fb5,#7a4eb8); }
        .message { grid-column:span 3; text-align:center; font-weight:600; margin-bottom:10px; }
    </style>

    <!-- jQuery & Autocomplete -->
    <link href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css" rel="stylesheet" />
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>

    <script type="text/javascript">
        $(function () {
            $("#<%= txtSupplierName.ClientID %>").autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        url: "Supplier.aspx/GetSupplierNames",
                        contentType: "application/json; charset=utf-8",
                        data: JSON.stringify({ prefix: request.term }),
                        dataType: "json",
                        success: function (data) {
                            response(data.d);
                        },
                        error: function (xhr, status, error) {
                            console.log("Error: " + error);
                        }
                    });
                },
                minLength: 2
            });
        });

        function hideMessage() {
            var lbl = document.getElementById('<%= lblMessage.ClientID %>');
            if (lbl) {
                setTimeout(function () {
                    lbl.innerHTML = "";
                }, 3000); // 3 seconds
            }
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- ScriptManager must be inside form -->
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />

    <div class="content-container">
        <h2 class="page-title">Supplier Registration</h2>

        <div class="supplier-card">
            <div class="form-grid">
                <!-- Message Label -->
                <asp:Label ID="lblMessage" runat="server" CssClass="message" ForeColor="Green"></asp:Label>

                <div class="form-group">
                    <label>Supplier Code</label>
                    <asp:TextBox ID="txtSupplierCode" runat="server" CssClass="form-control" placeholder="Enter code"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Supplier Name</label>
                    <asp:TextBox ID="txtSupplierName" runat="server" CssClass="form-control" placeholder="Enter name"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Enter email"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Mobile</label>
                    <asp:TextBox ID="txtMobile" runat="server" CssClass="form-control" placeholder="Enter mobile"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>GSTIN</label>
                    <asp:TextBox ID="txtGSTIN" runat="server" CssClass="form-control" placeholder="Enter GSTIN"></asp:TextBox>
                </div>

                <div class="form-group address">
                    <label>Address</label>
                    <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="Enter address"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Status</label>
                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="status-dropdown">
                        <asp:ListItem Text="-- Select --" Value=""></asp:ListItem>
                        <asp:ListItem Text="Active" Value="Active"></asp:ListItem>
                        <asp:ListItem Text="Inactive" Value="Inactive"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="btn-group">
                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn" OnClick="btnSave_Click" />
                    <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn" OnClick="btnClear_Click" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
