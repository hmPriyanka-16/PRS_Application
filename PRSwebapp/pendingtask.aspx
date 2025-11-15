<%@ Page Title="Pending Tasks" Language="C#" MasterPageFile="~/SiteMaster.Master"
    AutoEventWireup="true" CodeBehind="PendingTask.aspx.cs" Inherits="PRSwebapp.PendingTask" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />

    <style>
        .card-metric {
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            transition: 0.3s;
            cursor: pointer;
        }
        .card-metric:hover { transform: scale(1.04); }

        /* Smaller centered card */
        .card-small {
            width: 220px;
            margin: auto;
            border-radius: 12px;
            padding: 10px;
        }
        .card-small .card-title { font-size: 14px; }
        .card-small .card-text { font-size: 20px; }

        .gridview-header th {
            background-color: #5a3fb5;
            color: white;
            padding: 5px;
        }

        /* Popup table small text */
        #modalPending .table th,
        #modalPending .table td {
            font-size: 12px !important;
            padding: 4px 6px !important;
        }

        #modalPending .gridview-header th {
            font-size: 12px !important;
            padding: 4px 6px !important;
        }

        /* Smaller popup action buttons */
        #modalPending .btn {
            padding: 2px 6px !important;
            font-size: 11px !important;
            border-radius: 4px !important;
        }
    </style>
</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="container mt-5">

        <h3 class="text-primary mb-4"></h3>

        <!-- SMALL CENTERED CARD -->
        <div class="row mb-5 d-flex justify-content-center">
            <div class="col-md-3 d-flex justify-content-center">

                <div class="card bg-warning text-white text-center card-metric card-small"
                     data-bs-toggle="modal"
                     data-bs-target="#modalPending">

                    <div class="card-body">
                        <h5 class="card-title">Total Pending Tasks</h5>
                        <p runat="server" id="lblTotalPending" class="card-text">0</p>
                    </div>

                </div>

            </div>
        </div>


        <!-- MAIN PAGE GRID -->
       <div class="card shadow-sm mb-5" style="background-color:white;">
    <div class="card-header text-white" style="background-color:#5a3fb5;">
        Pending Tasks List
    </div>

   <div class="card-body"
     style="
        background-color:white;
        border-radius: 0 0 6px 6px;
        color: black;
     ">


                <asp:GridView ID="gvMainPending" runat="server" AutoGenerateColumns="False"
                    CssClass="table table-striped table-bordered"
                    HeaderStyle-CssClass="gridview-header">

                    <Columns>
                        <asp:BoundField DataField="PRSNo" HeaderText="PRS No" />
                        <asp:BoundField DataField="PRSdate" HeaderText="PRS Date" DataFormatString="{0:dd-MMM-yyyy}" />
                        <asp:BoundField DataField="billno" HeaderText="Bill No" />
                        <asp:BoundField DataField="duedate" HeaderText="Due Date" DataFormatString="{0:dd-MMM-yyyy}" />
                        <asp:BoundField DataField="Natureofexpenses" HeaderText="Expenses" />
                        <asp:BoundField DataField="Inoviceamount" HeaderText="Amount" DataFormatString="{0:N2}" />
                        <asp:BoundField DataField="PRSType" HeaderText="Type" />
                        <asp:BoundField DataField="SupplierName" HeaderText="Supplier" />
                        <asp:BoundField DataField="PRSStatus" HeaderText="Status" />
                    </Columns>

                </asp:GridView>

            </div>
        </div>


        <!-- POPUP MODAL -->
        <div class="modal fade" id="modalPending" tabindex="-1">
            <div class="modal-dialog modal-xl modal-dialog-scrollable">
                <div class="modal-content">

                    <div class="modal-header" style="background-color:#5a3fb5; color:white;">
                        <h5 class="modal-title">Pending Task Details (Full Actions)</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>


                    <div class="modal-body">

                        <asp:GridView ID="gvPendingTasks" runat="server" AutoGenerateColumns="False"
                            CssClass="table table-bordered table-striped table-hover"
                            HeaderStyle-CssClass="gridview-header"
                            OnRowCommand="gvPendingTasks_RowCommand">

                            <Columns>
                                <asp:BoundField DataField="PRSNo" HeaderText="PRS No" />
                                <asp:BoundField DataField="PRSdate" HeaderText="PRS Date" DataFormatString="{0:dd-MMM-yyyy}" />
                                <asp:BoundField DataField="billno" HeaderText="Bill Number" />
                                <asp:BoundField DataField="billdate" HeaderText="Bill Date" DataFormatString="{0:dd-MMM-yyyy}" />
                                <asp:BoundField DataField="duedate" HeaderText="Due Date" DataFormatString="{0:dd-MMM-yyyy}" />
                                <asp:BoundField DataField="Natureofexpenses" HeaderText="Nature of Expenses" />
                                <asp:BoundField DataField="Inoviceamount" HeaderText="Invoice Amount" DataFormatString="{0:N2}" />
                                <asp:BoundField DataField="PRSType" HeaderText="PRS Type" />
                                <asp:BoundField DataField="UserID" HeaderText="User ID" />
                                <asp:BoundField DataField="Period" HeaderText="Period" />
                                <asp:BoundField DataField="DeptID" HeaderText="Dept ID" />
                                <asp:BoundField DataField="PRSStatus" HeaderText="Status" />
                                <asp:BoundField DataField="SupplierCode" HeaderText="Supplier Code" />
                                <asp:BoundField DataField="SupplierName" HeaderText="Supplier Name" />
                                <asp:BoundField DataField="LastApproved" HeaderText="Last Approved" DataFormatString="{0:dd-MMM-yyyy}" />

                                <asp:TemplateField HeaderText="Actions">
                                    <ItemTemplate>
                                        <asp:Button ID="btnApprove" runat="server" Text="Approve"
                                            CssClass="btn btn-success btn-sm"
                                            CommandName="Approve" CommandArgument='<%# Eval("PRSNo") %>' />

                                        <asp:Button ID="btnSendBack" runat="server" Text="Send Back"
                                            CssClass="btn btn-danger btn-sm ms-1"
                                            CommandName="SendBack" CommandArgument='<%# Eval("PRSNo") %>' />

                                        <asp:Button ID="btnTrail" runat="server" Text="Trail"
                                            CssClass="btn btn-info btn-sm ms-1"
                                            CommandName="Trail" CommandArgument='<%# Eval("PRSNo") %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>

                    </div>

                </div>
            </div>
        </div>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</asp:Content>
