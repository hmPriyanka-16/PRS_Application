<%@ Page Title="Supplier Registration" Language="C#" MasterPageFile="~/SiteMaster.Master"
    AutoEventWireup="true" CodeBehind="Supplier.aspx.cs" Inherits="PRSwebapp.Supplier" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        /* ✅ Scoped styling */
        .supplier-page {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f4f4f9;
            padding: 20px 0;
        }

        .supplier-page .content-container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 0 15px;
        }

        .supplier-page .supplier-card {
            background: linear-gradient(180deg, #ffffff, #e6e0ff);
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.12);
            border: 1px solid rgba(108, 92, 231, 0.3);
        }

        .supplier-page .page-title {
            text-align: center;
            font-size: 28px;
            font-weight: bold;
            color: #6c5ce7;
            margin-bottom: 25px;
        }

        .supplier-page .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
        }

        .supplier-page .form-group {
            display: flex;
            flex-direction: column;
            position: relative;
        }

        .supplier-page .form-group label {
            font-weight: 500;
            color: #5a3fb5;
            margin-bottom: 6px;
            font-size: 14px;
        }

        .supplier-page .form-control,
        .supplier-page .status-dropdown {
            padding: 10px 12px;
            border-radius: 6px;
            border: 1px solid #6c5ce7;
            font-size: 14px;
            width: 100%;
            box-sizing: border-box;
        }

        .supplier-page .form-group.address {
            grid-column: 1 / -1;
        }

        .supplier-page .btn-group {
            grid-column: 1 / -1;
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 25px;
        }

        .supplier-page .btn {
            padding: 10px 28px;
            border-radius: 6px;
            border: none;
            font-weight: 500;
            cursor: pointer;
            background: linear-gradient(90deg, #4e3ec7, #8c61ff);
            color: #fff;
            transition: all 0.3s ease;
        }

        .supplier-page .btn:hover {
            background: linear-gradient(90deg, #3b2fc1, #6f49e6);
            transform: translateY(-2px);
        }

        .supplier-page .message {
            grid-column: 1 / -1;
            text-align: center;
            font-weight: 600;
            margin-bottom: 10px;
            color: green;
            font-size: 14px;
        }

        /* Dropdown */
        .supplier-page #supplierDropdown {
            display: none;
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            max-height: 200px;
            overflow-y: auto;
            border: 1px solid #ccc;
            border-radius: 8px;
            background: #fff;
            z-index: 999;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .supplier-page #supplierDropdown table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        .supplier-page #supplierDropdown th,
        .supplier-page #supplierDropdown td {
            padding: 6px 8px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }

        .supplier-page #supplierDropdown th {
            background: #f0f0f5;
            font-weight: 700;
            color: #4e3ec7;
        }

        .supplier-page #supplierDropdown tr:hover,
        .supplier-page #supplierDropdown tr.selected {
            background: #cce4ff;
            cursor: pointer;
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
                var html = '<table><tr><th>Name</th><th>Code</th><th>Email</th><th>Mobile</th><th>GSTIN</th><th>Address</th><th>Status</th></tr>';
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

                if (["ArrowDown", "ArrowUp", "Enter", "Escape"].includes(e.key)) {
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
                    $dropdown.find("tr").removeClass("selected").eq(selectedIndex + 1).addClass("selected");
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

            $dropdown.on("click", "tr[data-index]", function () {
                var idx = $(this).data("index");
                selectSupplier(idx);
            });

            $(document).click(function (e) {
                if (!$(e.target).closest("#<%= txtSupplierName.ClientID %>, #supplierDropdown").length) {
                    $dropdown.hide();
                }
            });
        });

        // ✅ Mobile number validation
        function isNumberKey(evt) {
            var charCode = (evt.which) ? evt.which : evt.keyCode;
            // Allow only numbers (0-9)
            if (charCode > 31 && (charCode < 48 || charCode > 57))
                return false;
            return true;
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="supplier-page">
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
                        <asp:TextBox ID="txtMobile" runat="server" CssClass="form-control" placeholder="Mobile Number"
                            onkeypress="return isNumberKey(event);"></asp:TextBox>
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
    </div>
</asp:Content>
