<%@ Page Title="Pending Tasks" Language="C#" MasterPageFile="~/SiteMaster.Master"
    AutoEventWireup="true" CodeBehind="PendingTask.aspx.cs" Inherits="PRSwebapp.PendingTask" %>
<%@ Import Namespace="System.Web" %>
<script runat="server">

    
</script>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet" />
    <style>
        .gridview-header th {
            background-color: #5a3fb5;
            color: white;
            padding: 6px;
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
       
#prsModal .modal-dialog {
    max-width: 500px; 
    margin: 1.75rem auto; 
}

#prsModal .modal-header {
    background-color: #87CEEB !important;
    color: black !important; 
}

#prsModal .modal-body {
    font-size: 12px !important;   
    line-height: 1.2 !important;
}

       .card-header {
    font-weight: bold;
   

}
       .card-expand {
    width: 100% !important;         /* Full width */
    max-width: 1500px !important;   /* Increase horizontal card size */
    margin: 0 auto !important;      /* Center card */
}


        #<%= gvMainPending.ClientID %> { font-size: 10px !important; }
        #<%= gvMainPending.ClientID %> th { padding: 5px 6px !important; font-size: 10px !important; }
        #<%= gvMainPending.ClientID %> td { padding: 3px 6px !important; font-size: 12px !important; line-height: 1.1 !important; }
        #<%= gvMainPending.ClientID %> .table { margin-bottom: 0 !important; }
         .timeline {
     position: relative;
     margin-left: 15px;
     padding-left: 20px;
     border-left: 1px dashed #b9a7ff;
 }

 .timeline-item {
     position: relative;
     margin-bottom: 10px;
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
     font-size: 13px;
     line-height: 1.1;
     max-width: 95%;
 }

 .timeline-title {
     font-weight: bold;
     color: #5a3fb5;
     font-size: 13px;
 }

 .timeline-info {
     font-size: 13px;
     color: #555;
 }

 .timeline-role {
     font-size: 13px;
     color: #7a6f9a;
 }

 .timeline-remark {
     font-size: 13px;
 }
 
    /* Make the card expand full width */
.card-expand {
    width: 100% !important;       /* Take full width of parent container */
    max-width: 100% !important;   /* Remove any max-width restriction */
    margin: 0 auto !important;    /* Center horizontally just in case */
}

/* Optional: if you want it almost full screen width */
.container {
    max-width: 100% !important;   /* Overrides Bootstrap container max-width */
    padding-left: 15px;
    padding-right: 15px;
}
.swal2-popup {
    border-radius: 14px !important;
}

.swal2-icon.swal2-question {
    border-color: #5a3fb5 !important;
    color: #5a3fb5 !important;
}

.swal2-title {
    padding-bottom: 5px !important;
}
.prs-large-modal{
    max-width:1200px !important;   /* increase width */
}
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container mt-4">
        <!-- MAIN PENDING GRID -->
        <div class="card shadow-sm mb-5 card-expand">
            <div class="card-header text-white d-flex justify-content-center position-relative" style="background-color:#5a3fb5;">

    <!-- Department Filter (SMALL LEFT) -->
  <!-- Department Filter (SMALL LEFT) -->
<div style="position:absolute;width:270px; left:10px; display:flex; align-items:center; gap:5px;">
    <span style="color:white; font-weight:bold; font-size:12px;">Department:</span>
    <asp:DropDownList ID="ddlDepartment"
        runat="server"
        CssClass="form-select form-select-sm"
        AutoPostBack="true"
        OnSelectedIndexChanged="ddlDepartment_SelectedIndexChanged"
        style="font-size:11px; height:26px; padding:2px 6px;">
    </asp:DropDownList>
</div>

    <span class="fw-bold" style="font-size:16px;">My Task PRS List</span>

   <span class="badge bg-warning text-dark px-3 py-2 position-absolute end-0 me-3"
      style="cursor:pointer;">
    Pending: 
    <span id="lblTotalPending" runat="server">0</span>
    |
    Amount: ₹ <span id="lblTotalAmount" runat="server">0.00</span>
</span>

</div>
            <div class="card-body">
                <asp:GridView ID="gvMainPending" runat="server" AutoGenerateColumns="False"
                    CssClass="table table-striped table-bordered" HeaderStyle-CssClass="gridview-header"
                    OnRowDataBound="gvMainPending_RowDataBound"
                    OnRowCommand="gvMainPending_RowCommand"  >
                    <Columns>
                        <asp:TemplateField HeaderText="PRS No">
                            <ItemTemplate>
                               <a href="javascript:void(0);" class="text-primary fw-bold"
   onclick='openPRSModal("<%# Eval("PRSNo") %>");'>
   <%# Eval("PRSNo") %>
</a>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="PRSdate" HeaderText="PRS Date" DataFormatString="{0:dd-MMM-yyyy}" />
                        <asp:BoundField DataField="PRSType" HeaderText="PRSType" />
                        <asp:BoundField DataField="Department" HeaderText="Department" />
                       <asp:TemplateField HeaderText="Supplier Name|Supplier Code">
   <ItemTemplate>
        <%# Eval("SupplierName") + " | " + Eval("SupplierCode") %>
    </ItemTemplate>
</asp:TemplateField>
                        <asp:BoundField DataField="Inoviceamount" HeaderText="Amount" DataFormatString="{0:N2}" />
                        <asp:BoundField DataField="LastAction" HeaderText="Last Approver" />
                        <asp:BoundField DataField="Next_Action" HeaderText="Next Approver" />

                   <asp:TemplateField HeaderText="Documents">
    <ItemTemplate>
        <a href="javascript:void(0);"
           class="text-primary"
           style="font-size:18px;"
           title="View Documents"
           onclick='<%# "openDocsModal(\"" + Eval("PONumber") + "\");" %>'>
            <i class="bi bi-file-earmark-text"></i>
        </a>
    </ItemTemplate>
</asp:TemplateField>
   <asp:TemplateField HeaderText="Action">
    <ItemTemplate>
        <button class="btn btn-sm btn-primary py-0 px-1"
                type="button"
                data-bs-toggle="collapse"
                data-bs-target="#<%# "pnlAction_" + Eval("PRSNo") %>"
                aria-expanded="false"
                aria-controls="<%# "pnlAction_" + Eval("PRSNo") %>"
                onclick="closeOtherPanels('<%# "pnlAction_" + Eval("PRSNo") %>')"
                style="font-size:0.75rem;">
            Action
        </button>

        <div class="collapse mt-1" id='<%# "pnlAction_" + Eval("PRSNo") %>'>
            <asp:TextBox ID="txtRemarks" runat="server" 
                         CssClass="form-control form-control-sm mb-1"
                         Placeholder="Enter remarks" 
                         Style="padding:2px 4px; font-size:0.75rem;"></asp:TextBox>

            <div class="d-flex gap-1">
                <asp:Button ID="btnApprove" runat="server" Text="Approve" 
                            CommandName="Approve" CommandArgument='<%# Eval("PRSNo") %>'
                            CssClass="btn btn-success btn-sm flex-fill"
                            Style="padding:2px 4px; font-size:0.75rem; height:28px;" />

                <asp:Button ID="btnHold" runat="server" Text="Hold" 
                            CommandName="Hold" CommandArgument='<%# Eval("PRSNo") %>'
                            CssClass="btn btn-warning btn-sm flex-fill"
                            Style="padding:2px 4px; font-size:0.75rem; height:28px;" />

                <asp:Button ID="btnReject" runat="server" Text="Reject" 
                            CommandName="Reject" CommandArgument='<%# Eval("PRSNo") %>'
                            CssClass="btn btn-danger btn-sm flex-fill"
                            Style="padding:2px 4px; font-size:0.75rem; height:28px;" />
                <!-- ✅ NEW BUTTON -->
<asp:Button ID="btnCustomQuery" runat="server" Text="Query"
    CommandName="Query"
    CommandArgument='<%# Eval("PRSNo") %>'
    CssClass="btn btn-info btn-sm flex-fill"
    Style="padding:2px 4px; font-size:0.75rem; height:28px;" />
            </div>
        </div>
    </ItemTemplate>
</asp:TemplateField>
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
                 <asp:TemplateField HeaderText="TAT">
    <ItemTemplate>

        <div style="display:flex; align-items:center; gap:5px; white-space:nowrap;">

            <!-- TAT Button -->
            <a href="javascript:void(0);" 
               class="btn btn-warning btn-sm" 
               style="padding:2px 6px; font-size:13px; line-height:1;"
               onclick='<%# "openTATModal(\"" + Eval("PRSNo") + "\", \"" + Eval("SupplierName") + "\", \"" + Eval("Department") + "\", \"" + Eval("Inoviceamount") + "\");" %>'>
                TAT
            </a>

            <!-- Days beside -->
            <span style="font-weight:bold; color:#5a3fb5;">
                <%# GetTATDays(Eval("PRSdate")) %>
            </span>

        </div>

    </ItemTemplate>
</asp:TemplateField>
                    </Columns>
                </asp:GridView>

            </div>
        </div>

  

<!-- PRS DETAILS MODAL -->
<div class="modal fade" id="prsModal" tabindex="-1">
    <div class="modal-dialog" style="max-width:700px;">
        <div class="modal-content">
            <div class="modal-header" style="background:#87CEEB; color:black;">
                <h5 class="modal-title">PRS Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="prsDetail" style="background:white; color:black; font-size:13px; max-height:400px; overflow-y:auto;">
                <!-- Content loaded dynamically -->
            </div>
        </div>
    </div>
</div>

        <!-- DOCUMENTS MODAL -->
<div class="modal fade" id="docsModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header bg-info text-white">
                <h5 class="modal-title">PRS Documents - <span id="lblModalPONumber"></span></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div id="docsContainer"></div> <!-- AJAX content will be inserted here -->
            </div>
        </div>
    </div>
</div>
 <!-- TAT / TRAIL MODAL (Smaller Size) -->
<div class="modal fade" id="trailModal" tabindex="-1">
  <div class="modal-dialog" style="max-width:700px;"> <!-- Smaller width -->
    <div class="modal-content" id="printTrailArea">

      <!-- Header -->
      <div class="modal-header" style="background-color:#87CEEB; color:black; display:flex; align-items:center;">

        <!-- Logo -->
        <img src="Images/Sakra-logo.png" alt="Sakra Logo" style="height:40px; margin-right:10px;" />

        <!-- Title -->
        <h5 class="modal-title mb-0">PRS Info</h5>

        <!-- Right Side Buttons -->
        <div class="ms-auto d-flex align-items-center gap-2 no-print">

          <!-- Print Button -->
          <button type="button" class="btn btn-sm btn-light" onclick="printTrailModal()" style="border-radius:50%;">
            <i class="bi bi-printer"></i>
          </button>

          <!-- Close Button -->
          <button type="button" class="btn btn-sm btn-light" data-bs-dismiss="modal" style="border-radius:50%;">
            <i class="bi bi-x-lg"></i>
          </button>

        </div>
      </div>

      <!-- Body -->
      <div class="modal-body" style="font-size:12px; line-height:1.3; max-height:400px; overflow-y:auto;">
        <!-- Header (PRS No, Supplier, Dept, Amount, PRS Details, Claims) -->
        <div id="trailHeader"></div>

        <!-- Timeline -->
        <div class="timeline mt-3" id="trailTimeline"></div>
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
                        <asp:Button ID="btnSubmitTransaction" runat="server" CssClass="btn btn-success" Text="Completed"
                                    OnClick="btnSubmitTransaction_Click" />
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <script>
        function showDocsModal() {
            var myModal = new bootstrap.Modal(document.getElementById('docsModal'));
            myModal.show();
        }
        function openTrailModal() {
            var modal = new bootstrap.Modal(document.getElementById('trailModal'));
            modal.show();
        }
        function openTransactionModal(prsNo, prsDate, invoiceAmount) {
            document.getElementById('<%= txtTransactionPRSNo.ClientID %>').value = prsNo;
            document.getElementById('<%= txtPODate.ClientID %>').value = prsDate;
            document.getElementById('<%= txtInvoiceAmount.ClientID %>').value = invoiceAmount;

            document.getElementById('<%= hfTransactionPRSNo.ClientID %>').value = prsNo;
            document.getElementById('<%= hfPRSDate.ClientID %>').value = prsDate;
            document.getElementById('<%= hfInvoiceAmount.ClientID %>').value = invoiceAmount;

            var td = document.getElementById('<%= txtTransactionDate.ClientID %>');
            if (!td.value) td.value = new Date().toISOString().split('T')[0];

            var modal = new bootstrap.Modal(document.getElementById('transactionModal'));
            modal.show();
        }


        function printModal(modalId) {
            // Get the modal content by ID
            var modal = document.getElementById(modalId);
            if (!modal) return;

            // Clone the modal content so original stays intact
            var clone = modal.cloneNode(true);

            // Remove modal-specific classes and restrictors
            clone.classList.remove("modal", "fade");
            clone.querySelectorAll(".modal-dialog").forEach(dlg => dlg.style.maxWidth = "100%");

            // Remove elements that should not appear in print
            clone.querySelectorAll(".no-print, .btn-close, .btn").forEach(el => el.remove());

            // Expand all scrollable modal bodies
            clone.querySelectorAll(".modal-body").forEach(body => {
                body.style.maxHeight = "none";
                body.style.overflow = "visible";
            });

            // Open print window
            var printWindow = window.open('', '', 'height=900,width=1200');
            printWindow.document.write('<html><head><title>Print Details</title>');
            printWindow.document.write('<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />');
            printWindow.document.write('<style>');
            printWindow.document.write('body {font - size:11px; }'); // smaller font to fit tables
            printWindow.document.write('table {width:100% !important; table-layout: fixed; word-wrap: break-word; }');
            printWindow.document.write('.timeline {border - left: 1px dashed #b9a7ff; padding-left:16px; margin-left:12px; }');
            printWindow.document.write('.timeline-dot {width:6px; height:6px; border-radius:50%; background:#5a3fb5; position:absolute; left:-17px; top:3px; }');
            printWindow.document.write('.timeline-content {background:#fafaff; padding:3px 6px; border:1px solid #e4e4ff; border-radius:3px; font-size:9.5px; line-height:1.1; max-width:95%; }');
            printWindow.document.write('.timeline-title {font - weight:bold; color:#5a3fb5; font-size:10px; }');
            printWindow.document.write('.timeline-info {font - size:8.5px; color:#555; }');
            printWindow.document.write('.timeline-role {font - size:8.5px; color:#7a6f9a; }');
            printWindow.document.write('.timeline-remark {font - size:9px; }');
            printWindow.document.write('</style>');
            printWindow.document.write('</head><body>');
            printWindow.document.write('<div class="container-fluid mt-3">'); // full width container
            printWindow.document.write(clone.innerHTML);
            printWindow.document.write('</div></body></html>');

            printWindow.document.close();
            printWindow.focus();
            printWindow.print();
        }

        // Wrapper functions for convenience
        function printTrailModal() {
            printModal("printTrailArea"); // TAT modal content
        }

        function printPRSModal() {
            printModal("prsModal"); // PRS modal content
        }
        function confirmApproveSweet(btn) {

            event.preventDefault();

            Swal.fire({
                title: '<span style="font-size:14px; font-weight:600; color:#5a3fb5;">Approve PRS</span>',
                html: `
            <textarea id="swalRemarks"
                rows="2"
                style="
                    width:100%;
                    font-size:12px;
                    padding:6px;
                    border-radius:6px;
                    border:1px solid #ddd;
                    resize:none;
                "
                placeholder="Remarks (optional)"></textarea>
        `,
                icon: 'question',
                width: 300,        // 👈 small popup
                padding: '0.8rem', // 👈 compact spacing
                showCancelButton: true,
                confirmButtonText: 'Approve',
                cancelButtonText: 'Cancel',
                buttonsStyling: false,
                customClass: {
                    popup: 'rounded-3 shadow-sm',
                    confirmButton: 'btn btn-success btn-sm px-2 me-2',
                    cancelButton: 'btn btn-outline-secondary btn-sm px-2'
                }
            }).then((result) => {

                if (result.isConfirmed) {

                    const remarks = document.getElementById('swalRemarks').value.trim();

                    var old = document.getElementById("approveRemarks");
                    if (old) old.remove();

                    var hidden = document.createElement("input");
                    hidden.type = "hidden";
                    hidden.id = "approveRemarks";
                    hidden.name = "approveRemarks";
                    hidden.value = remarks;
                    document.forms[0].appendChild(hidden);

                    btn.onclick = null;
                    btn.click();
                }
            });

            return false;
        }
        function openTATModal(prsNo, supplier, dept, amount) {
            fetch('PendingTask.aspx/GetPRSTAT', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify({ prsNo, supplier, dept, amount })
            })
                .then(res => res.json())
                .then(data => {
                    document.getElementById('trailHeader').innerHTML = data.d.header;
                    document.getElementById('trailTimeline').innerHTML = data.d.timeline;

                    var myModal = new bootstrap.Modal(document.getElementById('trailModal'));
                    myModal.show();
                });
        }
        function openDocsModal(poNumber) {
            fetch('PendingTask.aspx/GetDocuments', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify({ poNumber: poNumber })
            })
                .then(res => res.json())
                .then(data => {
                    var docs = data.d;
                    var html = '';

                    if (docs.length === 0) {
                        html = '<p class="text-muted">No documents found for PO: ' + poNumber + '</p>';
                    } else {
                        html = '<table class="table table-bordered table-sm"><thead><tr>' +
                            '<th>File Name</th><th>Upload Date</th><th>Action</th></tr></thead><tbody>';
                        docs.forEach(d => {
                            html += '<tr>';
                            html += '<td>' + d.FileName + '</td>';
                            html += '<td>' + d.UploadDate + '</td>';
                            html += '<td><a href="' + d.FilePath + '" target="_blank" title="View / Download"><i class="bi bi-file-earmark-text text-primary" style="font-size:18px;"></i></a></td>';
                            html += '</tr>';
                        });
                        html += '</tbody></table>';
                    }

                    document.getElementById('lblModalPONumber').innerText = poNumber;
                    document.getElementById('docsContainer').innerHTML = html;

                    var myModal = new bootstrap.Modal(document.getElementById('docsModal'));
                    myModal.show();
                });
        }
        function openPRSModal(prsNo) {
            if (!prsNo) return;

            fetch('PendingTask.aspx/GetPRSDetails', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify({ prsNo: prsNo })
            })
                .then(res => res.json())
                .then(data => {
                    document.getElementById('prsDetail').innerHTML = data.d; // data.d contains HTML string
                    var myModal = new bootstrap.Modal(document.getElementById('prsModal'));
                    myModal.show();
                })
                .catch(err => console.error(err));
        }

       
     
            function closeOtherPanels(currentId) {
    // Close all other panels
    var panels = document.querySelectorAll('.collapse');
            panels.forEach(function(p) {
        if (p.id !== currentId) {
            var bsCollapse = bootstrap.Collapse.getInstance(p);
            if (bsCollapse) {
                bsCollapse.hide();
            }
        }
    });
}

            // Hide/Show button when panel opens/closes
            document.addEventListener('DOMContentLoaded', function () {
    var panels = document.querySelectorAll('.collapse');
            panels.forEach(function(panel) {
                panel.addEventListener('show.bs.collapse', function (event) {
                    // Hide the button that toggled this panel
                    var btn = document.querySelector('[data-bs-target="#' + panel.id + '"]');
                    if (btn) btn.style.display = 'none';
                });
            panel.addEventListener('hide.bs.collapse', function (event) {
            // Show the button again when panel is closed
            var btn = document.querySelector('[data-bs-target="#' + panel.id + '"]');
            if (btn) btn.style.display = 'inline-block';
        });
    });
});
   
    </script>
</asp:Content>
