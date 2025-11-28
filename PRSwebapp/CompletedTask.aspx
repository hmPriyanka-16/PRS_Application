<%@ Page Title="Completed Tasks" Language="C#" MasterPageFile="~/SiteMaster.Master"
    AutoEventWireup="true" CodeBehind="CompletedTask.aspx.cs" Inherits="PRSwebapp.CompletedTask" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet" />

    <style>
        .navbar .nav-link {
            color: #5a3fb5;
            font-weight: 500;
            padding: 4px 6px !important;
            font-size: 12px !important;
            border-radius: 4px;
            margin-right: 3px;
        }
        .navbar .nav-link:hover {
            background-color: #eee;
            color: #5a3fb5;
        }
        .navbar .nav-link.active {
            background-color: #5a3fb5 !important;
            color: white !important;
        }
        .card-header {
            font-weight: bold;
            text-align: center;
            font-size: 14px;
        }

        fieldset {
            border: 1px solid #ccc;
            padding: 10px;
            border-radius: 6px;
            margin-bottom: 15px;
            background-color: #f9f9f9;
            font-size: 13px;
        }
        legend {
            font-weight: bold;
            color: #5a3fb5;
            padding: 0 5px;
            width: auto;
        }
        .filter-label { font-weight: 500; font-size: 13px; }
        .uniform-control {
            height: 32px !important;
            font-size: 12px !important;
            padding: 2px 6px !important;
        }
        .btn-purple {
            background-color: #5a3fb5 !important;
            color: white !important;
            font-size: 12px !important;
            padding: 3px 8px !important;
        }

        .table-smaller {
            font-size: 12px !important;
            line-height: 1.1;
        }
        .table-smaller th {
            background-color: #5a3fb5 !important;
            color: white !important;
            padding: 4px 6px !important;
            font-weight: 600;
        }
        .table-smaller td { padding: 4px 6px !important; }
         .btn-purple {
        background-color: #6f42c1;
        color: white;
        border: none;
    }
    .btn-purple:hover {
        background-color: #5a32a3;
        color: white;
    }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="container mt-3">

        <div class="card shadow-sm">
            <div class="card-header" style="background-color:#5a3fb5; color:white;">
                Completed PRS
            </div>

            <div class="card-body">

                <!-- FILTER AREA -->
              <fieldset>
    <div class="d-flex align-items-center flex-wrap gap-3">

        <div class="d-flex align-items-center">
            <label class="me-2">Role:</label>
            <asp:DropDownList ID="ddlRole" CssClass="form-select" style="width:180px;" runat="server">
                <asp:ListItem Text="-- Select Role --" Value=""></asp:ListItem>
                <asp:ListItem Text="Processed By" Value="Processed By"></asp:ListItem>
                <asp:ListItem Text="HOD" Value="HOD"></asp:ListItem>
                <asp:ListItem Text="Checked & Verified by" Value="Checked & Verified by"></asp:ListItem>
                <asp:ListItem Text="H-FIN" Value="H-FIN"></asp:ListItem>
                <asp:ListItem Text="CFO" Value="CFO"></asp:ListItem>
                <asp:ListItem Text="Group COO" Value="Group COO"></asp:ListItem>
                <asp:ListItem Text="DMD" Value="DMD"></asp:ListItem>
                <asp:ListItem Text="MD" Value="MD"></asp:ListItem>
                <asp:ListItem Text="BOD" Value="BOD"></asp:ListItem>
                <asp:ListItem Text="Payment Process" Value="Payment Process"></asp:ListItem>
                <asp:ListItem Text="L1" Value="L1"></asp:ListItem>
                <asp:ListItem Text="L3" Value="L3"></asp:ListItem>
                <asp:ListItem Text="L4" Value="L4"></asp:ListItem>
            </asp:DropDownList>
        </div>

        <div class="d-flex align-items-center">
            <label class="me-2">Date From:</label>
            <asp:TextBox ID="txtFromDate" TextMode="Date" CssClass="form-control" style="width:150px;" runat="server"></asp:TextBox>
        </div>

        <div class="d-flex align-items-center">
            <label class="me-2">Date To:</label>
            <asp:TextBox ID="txtToDate" TextMode="Date" CssClass="form-control" style="width:150px;" runat="server"></asp:TextBox>
        </div>

        <div class="d-flex align-items-center">
            <asp:Button ID="btnShow" Text="Show" CssClass="btn btn-purple me-2" runat="server" OnClick="btnShow_Click" />
            <asp:Button ID="btnClear" Text="Clear" CssClass="btn btn-purple" runat="server" OnClick="btnClear_Click" />
        </div>

    </div>
</fieldset>



                <!-- NAV BAR -->
                <nav class="navbar navbar-expand-lg navbar-light bg-light rounded shadow-sm mb-3">
                    <div class="container-fluid p-1">
                        <ul class="navbar-nav me-auto">
                            <li class="nav-item"><asp:LinkButton ID="navPRS1" runat="server" CssClass="nav-link active" OnClick="PRS_Click">Capex Advance PRS</asp:LinkButton></li>
                            <li class="nav-item"><asp:LinkButton ID="navPRS2" runat="server" CssClass="nav-link" OnClick="PRS_Click">Pre-Payment PRS</asp:LinkButton></li>
                            <li class="nav-item"><asp:LinkButton ID="navPRS3" runat="server" CssClass="nav-link" OnClick="PRS_Click">Non Capex PRS</asp:LinkButton></li>
                            <li class="nav-item"><asp:LinkButton ID="navPRS4" runat="server" CssClass="nav-link" OnClick="PRS_Click">Monthly PRS</asp:LinkButton></li>
                            <li class="nav-item"><asp:LinkButton ID="navPRS5" runat="server" CssClass="nav-link" OnClick="PRS_Click">Expense Claim</asp:LinkButton></li>
                            <li class="nav-item"><asp:LinkButton ID="navPRS6" runat="server" CssClass="nav-link" OnClick="PRS_Click">Advance Claim</asp:LinkButton></li>
                            <li class="nav-item"><asp:LinkButton ID="navPRS7" runat="server" CssClass="nav-link" OnClick="PRS_Click">Local Conveyance</asp:LinkButton></li>
                        </ul>
                    </div>
                </nav>

                <!-- GRIDVIEW -->
                <asp:GridView ID="gvCompleted" runat="server"
                    CssClass="table table-bordered table-hover table-smaller"
                    AutoGenerateColumns="False"
                    EmptyDataText="No completed tasks found."
                    OnRowCommand="gvCompleted_RowCommand">

                    <Columns>
                        <asp:BoundField DataField="PRSNo" HeaderText="PRS No" />
                        <asp:BoundField DataField="PRSdate" HeaderText="PRS Date" DataFormatString="{0:dd-MMM-yyyy}" />
                        <asp:BoundField DataField="PRSType" HeaderText="PRSType" />
                        <asp:BoundField DataField="Department" HeaderText="Department" />
                        <asp:BoundField DataField="SupplierCode" HeaderText="S.Code" />
                        <asp:BoundField DataField="SupplierName" HeaderText="Supplier" />
                        <asp:BoundField DataField="billno" HeaderText="Bill No" />
                        <asp:BoundField DataField="billdate" HeaderText="Bill Date" DataFormatString="{0:dd-MMM-yyyy}" />
                        <asp:BoundField DataField="duedate" HeaderText="Due Date" DataFormatString="{0:dd-MMM-yyyy}" />
                        <asp:BoundField DataField="Inoviceamount" HeaderText="Amount" DataFormatString="{0:N2}" />
                        <asp:BoundField DataField="Natureofexpenses" HeaderText="Nature Of Expenses" />

                        <asp:TemplateField HeaderText="Transaction">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkTrans" runat="server"
                                    CommandName="ShowTransaction"
                                    CommandArgument='<%# Eval("PRSNo") %>'
                                    ToolTip="View Transaction">
                                    <i class="bi bi-receipt" style="font-size:18px; color:#5a3fb5;"></i>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>

                    </Columns>
                </asp:GridView>

                <!-- TRANSACTION MODAL -->
                <div class="modal fade" id="transactionModal" tabindex="-1">
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">

                            <div class="modal-header" style="background-color:#5a3fb5; color:white;">
                                <h5 class="modal-title">Transaction Details</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>

                            <div class="modal-body">
    <asp:Panel ID="pnlTransDetails" runat="server">

        <table class="table table-bordered table-sm">
            <tr>
                <th>Transaction ID</th>
                <td><asp:Label ID="lblTransID" runat="server" /></td>
            </tr>

            <tr>
                <th>PRS No</th>
                <td><asp:Label ID="lblPRSNo" runat="server" /></td>
            </tr>

            <tr>
                <th>PRS Date</th>
                <td><asp:Label ID="lblPRSDate" runat="server" /></td>
            </tr>

            <tr>
                <th>Invoice Amount</th>
                <td><asp:Label ID="lblInvAmt" runat="server" /></td>
            </tr>

            <tr>
                <th>Transaction Date</th>
                <td><asp:Label ID="lblTransDate" runat="server" /></td>
            </tr>

            <tr>
                <th>Document</th>
                <td>
                    <asp:HyperLink ID="lnkDocument" runat="server"
                        Text="View Document" Target="_blank" />
                </td>
            </tr>

            <tr>
                <th>Created By</th>
                <td><asp:Label ID="lblCreatedBy" runat="server" /></td>
            </tr>
        </table>

    </asp:Panel>
</div>

                            </div>

                        </div>
                    </div>
                </div>

            </div>
        </div>

    

    <!-- MODAL SCRIPT -->
    <script>
        function openTransactionModal() {
            var modal = new bootstrap.Modal(document.getElementById('transactionModal'));
            modal.show();
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.7/dist/umd/popper.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js"></script>

</asp:Content>
