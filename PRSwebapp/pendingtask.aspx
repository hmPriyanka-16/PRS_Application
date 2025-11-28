<%@ Page Title="Pending Tasks" Language="C#" MasterPageFile="~/SiteMaster.Master"
    AutoEventWireup="true" CodeBehind="PendingTask.aspx.cs" Inherits="PRSwebapp.PendingTask" %>
<%@ Import Namespace="System.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet" />
    <style>
        .gridview-header th {
            background-color: #5a3fb5;
            color: white;
            padding: 5px;
        }
        #modalPending .table th,
        #modalPending .table td {
            font-size: 13px !important;
            padding: 2px 4px !important;
            line-height: 1.2 !important;
        }
        #modalPending .gridview-header th {
            font-size: 11px !important;
            padding: 2px 4px !important;
        }
        #modalPending .btn {
            font-size: 11px !important;
            padding: 1px 4px !important;
            border-radius: 4px !important;
        }
        .card-header { font-weight: bold; }
        #<%= gvMainPending.ClientID %> { font-size: 12px !important; }
        #<%= gvMainPending.ClientID %> th { padding: 4px 6px !important; font-size: 12px !important; }
        #<%= gvMainPending.ClientID %> td { padding: 3px 6px !important; font-size: 12px !important; line-height: 1.1 !important; }
        #<%= gvMainPending.ClientID %> .table { margin-bottom: 0 !important; }

    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container mt-4">
        <!-- MAIN PENDING GRID -->
        <div class="card shadow-sm mb-5">
            <div class="card-header text-white d-flex justify-content-center position-relative" style="background-color:#5a3fb5;">
                <span class="fw-bold" style="font-size:16px;">Pending PRS List</span>
                <span class="badge bg-warning text-dark px-3 py-2 position-absolute end-0 me-3"
                      style="cursor:pointer;" data-bs-toggle="modal" data-bs-target="#modalPending">
                    Total Pending: <span id="lblTotalPending" runat="server">0</span>
                </span>
            </div>
            <div class="card-body">
                <asp:GridView ID="gvMainPending" runat="server" AutoGenerateColumns="False"
                    CssClass="table table-striped table-bordered" HeaderStyle-CssClass="gridview-header"
                    OnRowDataBound="gvMainPending_RowDataBound">
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
                        <asp:BoundField DataField="LastAction" HeaderText="Last Approver" />
                        <asp:BoundField DataField="Next_Action" HeaderText="Next Approver" />

                        <asp:TemplateField HeaderText="Transaction" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <asp:PlaceHolder ID="phTransaction" runat="server">
                                    <a href="javascript:void(0);" class="text-primary" style="font-size:1.2rem;" title="Add Transaction"
                                       onclick='<%# String.Format("openTransactionModal(\"{0}\", \"{1}\", \"{2}\");",
                                                   HttpUtility.JavaScriptStringEncode(Convert.ToString(Eval("PRSNo"))),
                                                   Eval("PRSdate") == null || Eval("PRSdate") == DBNull.Value ? "" : ((DateTime)Eval("PRSdate")).ToString("yyyy-MM-dd"),
                                                   Eval("Inoviceamount") == null || Eval("Inoviceamount") == DBNull.Value ? "0.00" : String.Format("{0:0.00}", Eval("Inoviceamount"))
                                                  ) %>'>
                                        <i class="bi bi-journal-plus"></i>
                                    </a>
                                </asp:PlaceHolder>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <!-- FULL PENDING MODAL (grid inside modal) -->
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
                            OnRowCommand="gvPendingTasks_RowCommand"
                            OnRowDataBound="gvPendingTasks_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="PRSNo" HeaderText="PRS No" />
                                <asp:BoundField DataField="PRSdate" HeaderText="PRS Date" DataFormatString="{0:dd-MMM-yyyy}" />
                                <asp:BoundField DataField="billno" HeaderText="Bill Number" />
                                <asp:BoundField DataField="billdate" HeaderText="Bill Date" DataFormatString="{0:dd-MMM-yyyy}" />
                                <asp:BoundField DataField="duedate" HeaderText="Due Date" DataFormatString="{0:dd-MMM-yyyy}" />
                                <asp:BoundField DataField="Natureofexpenses" HeaderText="Nature of Expenses" />
                                <asp:BoundField DataField="Inoviceamount" HeaderText="Invoice Amount" DataFormatString="{0:N2}" />
                                <asp:BoundField DataField="PRSType" HeaderText="PRS Type" />
                                <asp:BoundField DataField="Period" HeaderText="Period" />
                                <asp:BoundField DataField="PRSStatus" HeaderText="Status" />
                                <asp:BoundField DataField="SupplierCode" HeaderText="Supplier Code" />
                                <asp:BoundField DataField="SupplierName" HeaderText="Supplier Name" />
                                <asp:BoundField DataField="PONumber" HeaderText="PO Number" />
                                <asp:BoundField DataField="Department" HeaderText="Department" />
                                <asp:TemplateField HeaderText="Documents">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkDocs" runat="server" Text="View Docs"
                                            CssClass="btn btn-info btn-sm"
                                            CommandName="ViewDocs"
                                            CommandArgument='<%# Eval("PONumber") %>'></asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actions">
                                    <ItemTemplate>
                                        <asp:Button ID="btnApprove" runat="server" Text="Approve"
                                            CssClass="btn btn-success btn-sm"
                                            CommandName="Approve" CommandArgument='<%# Eval("PRSNo") %>' />
                                        <asp:Button ID="btnSendBack" runat="server" Text="Send Back"
                                            CssClass="btn btn-danger btn-sm ms-1"
                                            OnClientClick='<%# "openRemarkModal(\"" + Eval("PRSNo") + "\"); return false;" %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Transaction">
                                    <ItemTemplate>
                                        <asp:PlaceHolder ID="phTransactionModal" runat="server">
                                            <a href="javascript:void(0);" class="text-primary" title="Add Transaction"
                                               onclick='<%# String.Format("openTransactionModal(\"{0}\", \"{1}\", \"{2}\");",
                                                           HttpUtility.JavaScriptStringEncode(Convert.ToString(Eval("PRSNo"))),
                                                           Eval("PRSdate") == null || Eval("PRSdate") == DBNull.Value ? "" : ((DateTime)Eval("PRSdate")).ToString("yyyy-MM-dd"),
                                                           Eval("Inoviceamount") == null || Eval("Inoviceamount") == DBNull.Value ? "0.00" : String.Format("{0:0.00}", Eval("Inoviceamount"))
                                                          ) %>'>
                                                <i class="bi bi-journal-plus"></i>
                                            </a>
                                        </asp:PlaceHolder>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>

        <!-- DOCUMENTS MODAL -->
        <div class="modal fade" id="docsModal" tabindex="-1">
            <div class="modal-dialog modal-lg modal-dialog-scrollable">
                <div class="modal-content">
                    <div class="modal-header bg-info text-white">
                        <h5 class="modal-title">PO Documents - <span id="lblModalPONumber" runat="server"></span></h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <asp:GridView ID="gvDocs" runat="server" AutoGenerateColumns="False"
                            CssClass="table table-bordered table-striped table-sm">
                            <Columns>
                                <asp:BoundField DataField="FileName" HeaderText="File Name" />
                                <asp:BoundField DataField="UploadDate" HeaderText="Upload Date" DataFormatString="{0:dd-MMM-yyyy}" />
                                <asp:TemplateField HeaderText="Action">
                                    <ItemTemplate>
                                        <a class="btn btn-primary btn-sm" target="_blank"
                                           href='<%# ResolveUrl(Eval("FilePath").ToString()) %>'>View / Download</a>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <asp:Label ID="lblNoDocs" runat="server" CssClass="text-muted mt-2"></asp:Label>
                    </div>
                </div>
            </div>
        </div>

        <!-- TRANSACTION MODAL -->
        <div class="modal fade" id="transactionModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-info text-white">
                        <h5 class="modal-title">Add Transaction</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <!-- Hidden fields used for reliable server parsing -->
                        <asp:HiddenField ID="hfTransactionPRSNo" runat="server" />
                        <asp:HiddenField ID="hfPRSDate" runat="server" />
                        <asp:HiddenField ID="hfInvoiceAmount" runat="server" />

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label>Transaction ID</label>
                                <asp:TextBox ID="txtTransactionID" runat="server" CssClass="form-control" />
                            </div>
                            <div class="col-md-6">
                                <label>PRS Number</label>
                                <asp:TextBox ID="txtTransactionPRSNo" runat="server" CssClass="form-control" ReadOnly="true" />
                            </div>
                            <div class="col-md-6">
                                <label>PRS Date</label>
                                <asp:TextBox ID="txtPODate" runat="server" CssClass="form-control" ReadOnly="true" />
                            </div>
                            <div class="col-md-6">
                                <label>Invoice Amount</label>
                                <asp:TextBox ID="txtInvoiceAmount" runat="server" CssClass="form-control" ReadOnly="true" />
                            </div>
                            <div class="col-md-6">
                                <label>Transaction Date</label>
                                <asp:TextBox ID="txtTransactionDate" runat="server" CssClass="form-control" />
                            </div>
                            <div class="col-md-6">
                                <label>Upload Document</label>
                                <asp:FileUpload ID="fuTransactionDocs" runat="server" CssClass="form-control" />
                            </div>
                        </div>
                    </div>

                    <div class="modal-footer">
                        <asp:Button ID="btnSubmitTransaction" runat="server" CssClass="btn btn-success" Text="Submit"
                                    OnClick="btnSubmitTransaction_Click" />
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- REMARK MODAL -->
        <div class="modal fade" id="remarkModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header bg-danger text-white">
                        <h5 class="modal-title">Send Back Remark</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <asp:HiddenField ID="hfPRSNoRemark" runat="server" />
                        <label><b>Enter Remark</b></label>
                        <asp:TextBox ID="txtRemark" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" />
                    </div>
                    <div class="modal-footer">
                        <asp:Button ID="btnSubmitRemark" runat="server" Text="Submit" CssClass="btn btn-danger" OnClick="btnSubmitRemark_Click" />
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        function openRemarkModal(prsNo) {
            document.getElementById("<%= hfPRSNoRemark.ClientID %>").value = prsNo;
            var modal = new bootstrap.Modal(document.getElementById('remarkModal'));
            modal.show();
        }

        function showDocsModal() {
            var myModal = new bootstrap.Modal(document.getElementById('docsModal'));
            myModal.show();
        }

        function openTransactionModal(prsNo, prsDate, invoiceAmount) {
            // set visible fields
            document.getElementById('<%= txtTransactionPRSNo.ClientID %>').value = prsNo;
            document.getElementById('<%= txtPODate.ClientID %>').value = prsDate;
            document.getElementById('<%= txtInvoiceAmount.ClientID %>').value = invoiceAmount;

            // set hidden raw values (used by server)
            document.getElementById('<%= hfTransactionPRSNo.ClientID %>').value = prsNo;
            document.getElementById('<%= hfPRSDate.ClientID %>').value = prsDate;
            document.getElementById('<%= hfInvoiceAmount.ClientID %>').value = invoiceAmount;

            // default transaction date (if empty)
            var td = document.getElementById('<%= txtTransactionDate.ClientID %>');
            if (!td.value) td.value = new Date().toISOString().split('T')[0];

            var modal = new bootstrap.Modal(document.getElementById('transactionModal'));
            modal.show();
        }
    </script>
</asp:Content>
