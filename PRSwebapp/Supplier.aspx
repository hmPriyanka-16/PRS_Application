<%@ Page Title="Supplier Registration" Language="C#" MasterPageFile="~/SiteMaster.Master"
    AutoEventWireup="true" CodeBehind="Supplier.aspx.cs" Inherits="PRSwebapp.Supplier" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background:#f4f4f9; margin:0; padding:0; }
        .content-container { max-width:1100px; margin:40px auto; padding:0 15px; }
        .supplier-card { background:#fff; border-radius:16px; box-shadow:0 8px 30px rgba(0,0,0,0.08); padding:40px; transition: all 0.3s ease; position:relative; }
        .supplier-card:hover { box-shadow:0 12px 40px rgba(0,0,0,0.12); }
        .page-title { text-align:center; font-size:32px; font-weight:700; color:#4e3ec7; margin-bottom:30px; }
        .form-grid { display:grid; grid-template-columns:repeat(auto-fit, minmax(250px,1fr)); gap:20px; position:relative; }
        .form-group { display:flex; flex-direction:column; position:relative; }
        .form-group label { font-weight:600; color:#4e3ec7; margin-bottom:6px; font-size:14px; }
        .form-control, .status-dropdown { padding:10px 14px; border-radius:8px; border:1px solid #ccc; font-size:14px; transition:border 0.3s; }
        .form-control:focus, .status-dropdown:focus { border-color:#4e3ec7; outline:none; }
        .form-group.address { grid-column:1 / -1; }
        .btn-group { grid-column:1 / -1; display:flex; justify-content:center; gap:20px; margin-top:25px; }
        .btn { padding:12px 36px; border-radius:10px; border:none; font-weight:600; cursor:pointer; background:linear-gradient(90deg,#4e3ec7,#8c61ff); color:#fff; transition: all 0.3s ease; }
        .btn:hover { background:linear-gradient(90deg,#3b2fc1,#6f49e6); transform:translateY(-2px); }
        .message { grid-column:1 / -1; text-align:center; font-weight:600; margin-bottom:10px; color:green; font-size:14px; }

        /* Dropdown-style grid */
        #supplierDropdown {
            display:none;
            position:absolute;
            top:100%;
            left:0;
            right:0;
            max-height:200px;
            overflow-y:auto;
            border:1px solid #ccc;
            border-radius:8px;
            background:#fff;
            z-index:999;
            box-shadow:0 4px 12px rgba(0,0,0,0.1);
        }

        #supplierDropdown table { width:100%; border-collapse: collapse; font-size:13px; }
        #supplierDropdown th, #supplierDropdown td { padding:6px 8px; text-align:left; border-bottom:1px solid #eee; }
        #supplierDropdown th { background:#f0f0f5; font-weight:700; }
        #supplierDropdown tr:hover, #supplierDropdown tr.selected { background:#cce4ff; cursor:pointer; }

        @media(max-width:768px) {
            .form-grid { grid-template-columns: 1fr; }
            #supplierDropdown th, #supplierDropdown td { font-size:12px; padding:4px 6px; }
        }
    </style>

    <script type="text/javascript">
        $(document).ready(function () {
            var $dropdown = $("#supplierDropdown");
            var suppliers = [];
            var selectedIndex = -1;

            function renderDropdown() {
                if (suppliers.length === 0) {
                    $dropdown.html("<div style='padding:10px;'>No records found</div>").show();
                    return;
                }

                var html = '<table>';
                html += '<tr><th>Name</th><th>Code</th><th>Email</th><th>Mobile</th><th>GSTIN</th><th>Address</th><th>Status</th></tr>';
                for (var i = 0; i < suppliers.length; i++) {
                    html += '<tr data-index="' + i + '">';
                    html += '<td>' + suppliers[i].SupplierName + '</td>';
                    html += '<td>' + suppliers[i].SupplierCode + '</td>';
                    html += '<td>' + suppliers[i].Email + '</td>';
                    html += '<td>' + suppliers[i].Mobile + '</td>';
                    html += '<td>' + suppliers[i].GSTIN + '</td>';
                    html += '<td>' + suppliers[i].Address + '</td>';
                    html += '<td>' + suppliers[i].Status + '</td>';
                    html += '</tr>';
                }
                html += '</table>';
                $dropdown.html(html).show();
            }

            function selectSupplier(idx) {
                var item = suppliers[idx];
                $("#<%= txtSupplierName.ClientID %>").val(item.SupplierName);
                $("#<%= txtSupplierCode.ClientID %>").val(item.SupplierCode);
                $("#<%= txtEmail.ClientID %>").val(item.Email);
                $("#<%= txtMobile.ClientID %>").val(item.Mobile);
                $("#<%= txtGSTIN.ClientID %>").val(item.GSTIN);
                $("#<%= txtAddress.ClientID %>").val(item.Address);
                $("#<%= ddlStatus.ClientID %>").val(item.Status);
                $dropdown.hide();
            }

            $("#<%= txtSupplierName.ClientID %>").on("keyup", function (e) {
                var prefix = $(this).val();
                if (prefix.length < 1) {
                    $dropdown.hide();
                    return;
                }

                if (e.key === "ArrowDown" || e.key === "ArrowUp" || e.key === "Enter" || e.key === "Escape") {
                    // handle in keydown below
                    return;
                }

                $.ajax({
                    type: "POST",
                    url: "Supplier.aspx/GetSupplierNamesTable",
                    contentType: "application/json; charset=utf-8",
                    data: JSON.stringify({ prefix: prefix }),
                    dataType: "json",
                    success: function (data) {
                        suppliers = data.d;
                        selectedIndex = -1;
                        renderDropdown();
                    }
                });
            });

            $("#<%= txtSupplierName.ClientID %>").on("keydown", function (e) {
                if ($dropdown.is(":hidden")) return;

                if (e.key === "ArrowDown") {
                    selectedIndex++;
                    if (selectedIndex >= suppliers.length) selectedIndex = 0;
                    $dropdown.find("tr").removeClass("selected").eq(selectedIndex + 1).addClass("selected"); // +1 for header row
                    e.preventDefault();
                } else if (e.key === "ArrowUp") {
                    selectedIndex--;
                    if (selectedIndex < 0) selectedIndex = suppliers.length - 1;
                    $dropdown.find("tr").removeClass("selected").eq(selectedIndex + 1).addClass("selected");
                    e.preventDefault();
                } else if (e.key === "Enter") {
                    if (selectedIndex >= 0 && selectedIndex < suppliers.length) {
                        selectSupplier(selectedIndex);
                        e.preventDefault();
                    }
                } else if (e.key === "Escape") {
                    $dropdown.hide();
                }
            });

            // Click row to select
            $dropdown.on("click", "tr[data-index]", function () {
                var idx = $(this).data("index");
                selectSupplier(idx);
            });

            // Hide dropdown on outside click
            $(document).click(function (e) {
                if (!$(e.target).closest("#<%= txtSupplierName.ClientID %>, #supplierDropdown").length) {
                    $dropdown.hide();
                }
            });
        });
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />

    <div class="content-container">
        <div class="supplier-card">
            <h2 class="page-title">Supplier Registration</h2>
            <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>

            <div class="form-grid">
                <div class="form-group">
                    <label>Supplier Name</label>
                    <asp:TextBox ID="txtSupplierName" runat="server" CssClass="form-control" placeholder="Supplier Name"></asp:TextBox>
                    <div id="supplierDropdown"></div>
                </div>

                <div class="form-group">
                    <label>Supplier Code</label>
                    <asp:TextBox ID="txtSupplierCode" runat="server" CssClass="form-control" placeholder="Supplier Code"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Email"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>Mobile</label>
                    <asp:TextBox ID="txtMobile" runat="server" CssClass="form-control" placeholder="Mobile Number"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>GSTIN</label>
                    <asp:TextBox ID="txtGSTIN" runat="server" CssClass="form-control" placeholder="GSTIN"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>Status</label>
                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="status-dropdown">
                        <asp:ListItem Text="-- Select --" Value=""></asp:ListItem>
                        <asp:ListItem Text="Active" Value="Active"></asp:ListItem>
                        <asp:ListItem Text="Inactive" Value="Inactive"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="form-group address">
                    <label>Address</label>
                    <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="Address"></asp:TextBox>
                </div>

                <div class="btn-group">
                    <asp:Button ID="btnSave" runat="server" CssClass="btn" Text="Save" OnClick="btnSave_Click" />
                    <asp:Button ID="btnClear" runat="server" CssClass="btn" Text="Clear" OnClick="btnClear_Click" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>


