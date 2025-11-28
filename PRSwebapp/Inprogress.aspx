<%@ Page Title="In Progress Tasks" Language="C#" MasterPageFile="~/SiteMaster.Master"
    AutoEventWireup="true" CodeBehind="InProgressTasks.aspx.cs" Inherits="PRSwebapp.InProgressTasks" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />

    <style>
        .gridview-header th {
            background-color: #5a3fb5;
            color: white;
            padding: 5px;
        }

        #<%= gvMainPending.ClientID %> {
            font-size: 12px !important;
        }
        #<%= gvMainPending.ClientID %> th {
            padding: 4px 6px !important;
            font-size: 12px !important;
        }
        #<%= gvMainPending.ClientID %> td {
            padding: 3px 6px !important;
            font-size: 12px !important;
            line-height: 1.1 !important;
        }

        /* SMALLER MODAL WIDTH */
        .custom-modal-width {
            max-width: 500px !important;
        }

        /* COMPACT TIMELINE */
        .timeline {
            position: relative;
            margin-left: 12px;
            padding-left: 16px;
            border-left: 1px dashed #b9a7ff;
        }

        .timeline-item {
            position: relative;
            margin-bottom: 6px;
        }

        .timeline-dot {
            width: 6px;
            height: 6px;
            background-color: #5a3fb5;
            border-radius: 50%;
            position: absolute;
            left: -17px;
            top: 3px;
        }

        .timeline-content {
            background: #fafaff;
            padding: 3px 6px;
            border: 1px solid #e4e4ff;
            border-radius: 3px;
            font-size: 9.5px;
            line-height: 1.1;
            max-width: 95%;
        }

        .timeline-title {
            font-weight: bold;
            color: #5a3fb5;
            font-size: 10px;
        }

        .timeline-info {
            font-size: 8.5px;
            color: #555;
        }

        .timeline-role {
            font-size: 8.5px;
            color: #7a6f9a;
        }

        .timeline-remark {
            font-size: 9px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

    <div class="container mt-4 d-flex justify-content-center">

        <div class="card shadow-sm mb-5" style="width: 100%; max-width: 1100px;">
            <div class="card-header text-white text-center" style="background-color:#5a3fb5;">
                In Progress PRS
            </div>

            <div class="card-body">

                <asp:GridView ID="gvMainPending" runat="server" AutoGenerateColumns="False"
                    CssClass="table table-striped table-bordered"
                    HeaderStyle-CssClass="gridview-header"
                    OnRowCommand="gvMainPending_RowCommand">

                    <Columns>
                        <asp:TemplateField HeaderText="PRS No">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkPRS" runat="server"
                                    Text='<%# Eval("PRSNo") %>'
                                    CommandName="ShowPRS"
                                    CommandArgument='<%# Eval("PRSNo") %>'
                                    CssClass="text-primary fw-bold">
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>

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

                        <asp:TemplateField HeaderText="Last Approver">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkLastApprover" runat="server"
                                    Text='<%# Eval("LastAction") %>'
                                    CommandName="ShowTrail"
                                    CommandArgument='<%# Eval("PRSNo") + "|" 
                                                    + Eval("SupplierName") + "|" 
                                                    + Eval("Department") + "|" 
                                                    + Eval("Inoviceamount") %>'>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="Next_Action" HeaderText="Next Approver" />
                    </Columns>

                </asp:GridView>

            </div>
        </div>
    </div>

    <!-- PRS Detail & Trail Modal -->
    <div class="modal fade" id="prsModal" tabindex="-1">
        <div class="modal-dialog custom-modal-width modal-dialog-scrollable">
            <div class="modal-content">
               <div class="modal-header" style="background-color:#87CEEB; color:white;">
    <h5 class="modal-title">PRS Info</h5>
    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
</div>

                <div class="modal-body">
                    <div id="prsDetail" style="font-size: 12px; line-height: 1.3;"></div>

                    <div class="timeline mt-3">
                        <asp:Repeater ID="rpTrailHistory" runat="server">
                            <ItemTemplate>
                                <div class="timeline-item">
                                    <div class="timeline-dot"></div>
                                    <div class="timeline-content">
                                        <div class="timeline-title"><%# Eval("prsstatus") %></div>
                                        <div class="timeline-info">
                                            <%# Eval("Date", "{0:dd-MMM-yyyy hh:mm tt}") %> |
                                            <%# Eval("EmpName") %>
                                        </div>
                                        <div class="timeline-role"><%# Eval("Display") %></div>
                                        <div class="timeline-remark"><%# Eval("remark") %></div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</asp:Content>
