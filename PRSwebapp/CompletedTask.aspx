<%@ Page Title="Completed Tasks" Language="C#" MasterPageFile="~/SiteMaster.Master"
    AutoEventWireup="true" CodeBehind="CompletedTask.aspx.cs" Inherits="PRSwebapp.CompletedTask" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet" />

    <style>
        .navbar .nav-link { color: #5a3fb5; font-weight: 500; padding: 4px 6px !important; font-size: 12px !important; border-radius: 4px; margin-right: 3px; }
        .navbar .nav-link:hover { background-color: #eee; color: #5a3fb5; }
        .navbar .nav-link.active { background-color: #5a3fb5 !important; color: white !important; }
        .card-header { font-weight: bold; text-align: center; font-size: 14px; }
fieldset {
    border: 1px solid #b9a7ff; /* slightly darker border */
    padding: 12px 14px;
    border-radius: 8px;
    margin-bottom: 15px;
    background: linear-gradient(90deg, #e6e0ff, #f2f0ff);
    box-shadow: 0 2px 6px rgba(0,0,0,0.08);
}

fieldset label {
    font-weight: 600;
    color: #5a3fb5;
    font-size: 13px;
}        legend { font-weight: bold; color: #5a3fb5; padding: 0 5px; width: auto; }
        .filter-label { font-weight: 500; font-size: 13px; }
        .uniform-control { height: 32px !important; font-size: 12px !important; padding: 2px 6px !important; }
        .btn-purple { background-color: #5a3fb5 !important; color: white !important; font-size: 12px !important; padding: 3px 8px !important; }
        .table-smaller { font-size: 12px !important; line-height: 1.1; }
        .table-smaller th { background-color: #5a3fb5 !important; color: white !important; padding: 4px 6px !important; font-weight: 600; }
        .table-smaller td { padding: 4px 6px !important; }
        #prsModal .modal-content { background-color: #87CEEB; }
        #prsModal .modal-body, #prsModal .modal-body * { color: black !important; font-size: 13px !important; }
        .btn-docs-sm { font-size: 10px !important; padding: 2px 5px !important; height: 25px !important; line-height: 1 !important; }
        .gridview-header th {
        background-color: #5a3fb5;
        color: white;
        padding: 5px;
    }

    #<%= gvCompleted.ClientID %> {
        font-size: 12px !important;
    }
    #<%= gvCompleted.ClientID %> th {
        padding: 4px 6px !important;
        font-size: 12px !important;
    }
    #<%= gvCompleted.ClientID %> td {
        padding: 3px 6px !important;
        font-size: 12px !important;
        line-height: 1.1 !important;
    }

    .custom-modal-width {
        max-width: 500px !important;
    }

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

    .btn-docs-sm {
        font-size: 10px !important;
        padding: 2px 5px !important;
        height: 25px !important;
        line-height: 1 !important;
    }
    .navbar .nav-link.active { 
    background-color: #FF6600 !important; /* Sakra logo color */
    color: white !important;              /* text color */
}

.navbar .nav-link:hover { 
    background-color: #FF944D; /* lighter shade for hover */
    color: white; 
}

    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="container-fluid mt-3">
<div class="card shadow-sm w-100">
<div class="card-header text-white d-flex align-items-center justify-content-center position-relative"
     style="background-color:#5a3fb5;">

    <h5 class="mb-0 fw-bold">Completed PRS</h5>

    <div class="position-absolute end-0 me-3">
        <asp:Button ID="btnExportCompleted" runat="server"
            Text="Export to Excel"
            CssClass="btn btn-warning btn-sm fw-bold text-dark"
            OnClick="btnExportCompleted_Click" />
    </div>

</div>        <div class="card-body">
            <!-- FILTER -->
       <fieldset>
    <div class="d-flex align-items-center flex-wrap gap-3">

    <!-- DEPARTMENT FILTER -->
    <div class="d-flex align-items-center" runat="server" id="divDepartment">
        <label class="me-2">Department:</label>
        <asp:DropDownList ID="ddlDepartment"
            runat="server"
            CssClass="form-select"
            style="width:200px;"
            AutoPostBack="true"
            OnSelectedIndexChanged="ddlDepartment_SelectedIndexChanged">
        </asp:DropDownList>
    </div>

    <!-- DATE FROM -->
    <div class="d-flex align-items-center">
        <label class="me-2">Date From:</label>
        <asp:TextBox ID="txtFromDate" TextMode="Date" CssClass="form-control"
            style="width:150px;" runat="server"></asp:TextBox>
    </div>

    <!-- DATE TO -->
    <div class="d-flex align-items-center">
        <label class="me-2">Date To:</label>
        <asp:TextBox ID="txtToDate" TextMode="Date" CssClass="form-control"
            style="width:150px;" runat="server"></asp:TextBox>
    </div>

    <!-- PRS TYPE DROPDOWN -->
    <div class="d-flex align-items-center">
        <label class="me-2">PRS Type:</label>
        <asp:DropDownList ID="ddlPRSType"
            runat="server"
            CssClass="form-select"
            style="width:200px;"
            AutoPostBack="true"
            OnSelectedIndexChanged="ddlPRSType_SelectedIndexChanged">

            <asp:ListItem Text="All PRS" Value="ALL PRS" Selected="True"></asp:ListItem>
            <asp:ListItem Text="Capex Advance PRS" Value="Capex Advance"></asp:ListItem>
            <asp:ListItem Text="Opex Advance" Value="Opex Advance"></asp:ListItem>
            <asp:ListItem Text="Pre-Payment PRS" Value="Pre-Payment"></asp:ListItem>
            <asp:ListItem Text="Regular PRS" Value="Regular PRS"></asp:ListItem>
            <asp:ListItem Text="Expense Claim" Value="Expense Claim"></asp:ListItem>
            <asp:ListItem Text="Advance" Value="Advance"></asp:ListItem>
            <asp:ListItem Text="Local Conveyance" Value="Local Conveyance"></asp:ListItem>
            <asp:ListItem Text="Individual PRS" Value="Individual"></asp:ListItem>
        </asp:DropDownList>
    </div>

    <!-- BUTTONS -->
    <div class="d-flex align-items-center">
        <asp:Button ID="btnShow" Text="Show"
            CssClass="btn btn-purple me-2"
            runat="server"
            OnClick="btnShow_Click" />

        <asp:Button ID="btnClear" Text="Clear"
            CssClass="btn btn-purple"
            runat="server"
            OnClick="btnClear_Click" />
    </div>

</div>


</fieldset>


          

            <!-- GRID -->
            <asp:GridView ID="gvCompleted" runat="server"
                CssClass="table table-bordered table-hover table-smaller"
                AutoGenerateColumns="False"
                EmptyDataText="No completed tasks found."
                OnRowCommand="gvCompleted_RowCommand">
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
<%# GetTATDays(Eval("PRSdate"), Eval("CompletedDate")) %>

            </span>

        </div>

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

            </div>
        </div>

    </div>


    <script>
        function openTransactionModal() {
            var modal = new bootstrap.Modal(document.getElementById('transactionModal'));
            modal.show();
        }
        function showDocsModal() {
            var modal = new bootstrap.Modal(document.getElementById('docsModal'));
            modal.show();
        }
        function openTrailModal() {
            var modal = new bootstrap.Modal(document.getElementById('trailModal'));
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

    </script>

    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.7/dist/umd/popper.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js"></script>

</asp:Content>
