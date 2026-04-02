<%@ Page Title="" Language="C#" MasterPageFile="~/SiteMaster.Master" AutoEventWireup="true" CodeBehind="query.aspx.cs" Inherits="PRSwebapp.query" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        .gridview-header th {
            background-color: #5a3fb5;
            color: white;
            padding: 10px;
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
            max-width: 700px !important;
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
        .btn-docs-sm { font-size: 10px !important; padding: 2px 5px !important; height: 25px !important; line-height: 1 !important; }
   .compact-header {
    padding: 6px 10px !important;
    min-height: 38px;
}

.compact-header h5 {
    font-size: 14px;
    margin: 0;
}

.compact-header .form-select {
    padding: 2px 6px;
    font-size: 12px;
    height: 28px;
}

.compact-header .btn {
    padding: 3px 8px;
    font-size: 12px;
}
        </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

<div class="container-fluid mt-4">
<div class="card shadow-sm mb-5 w-100">
     <div class="card-header compact-header text-white d-flex align-items-center justify-content-between"
     style="background-color:#5a3fb5;">

   <!-- LEFT : Department Filter -->
<div style="width:270px; display:flex; align-items:center; gap:5px;">
    <span style="color:white; font-weight:bold; font-size:12px;">Department:</span>
    <asp:DropDownList ID="ddlDepartment"
        runat="server"
        CssClass="form-select form-select-sm"
        AutoPostBack="true"
        OnSelectedIndexChanged="ddlDepartment_SelectedIndexChanged">
    </asp:DropDownList>
</div>

    <!-- CENTER : Title -->
    <div class="text-center flex-grow-1">
        <h5 class="mb-0 fw-bold">Query PRS</h5>
    </div>
     <div class="d-flex align-items-center gap-3">

    <div class="btn btn-warning btn-sm fw-bold">
        Tasks: <asp:Label ID="lblTotalTasks" runat="server" Text="0"></asp:Label>
    </div>

    <div class="btn btn-warning btn-sm fw-bold">
        ₹ <asp:Label ID="lblTotalAmount" runat="server" Text="0.00"></asp:Label>
    </div>


    <!-- RIGHT : Export Button -->
    <div>
        <asp:Button ID="btnExport" runat="server"
            Text="Export to Excel"
            CssClass="btn btn-warning btn-sm fw-bold text-dark"
            OnClick="btnExport_Click" />
    </div>
</div>

</div>

            <div class="card-body">
               
                <asp:GridView ID="gvMainPending" runat="server" AutoGenerateColumns="False"
                    CssClass="table table-striped table-bordered"
                    HeaderStyle-CssClass="gridview-header"
                    OnRowCommand="gvMainPending_RowCommand"
                    OnRowDataBound="gvMainPending_RowDataBound"
                    OnDataBound="gvMainPending_DataBound">

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
                        <asp:TemplateField HeaderText="Query Raised By">
                            <EditItemTemplate>
                                <asp:TextBox ID="TextBox1" runat="server" Text='<%# Bind("LastAction") %>'></asp:TextBox>
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:Label ID="Label1" runat="server" Text='<%# Bind("LastAction") %>'></asp:Label>
                                <asp:Label ID="Lbl_l_roleID" runat="server" Text='<%# Bind("Next_Sequence")  %>'  Visible="False"></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Action">
    <ItemTemplate>
        <asp:LinkButton ID="btnAction" runat="server"
            Text="Action"
            CssClass="btn btn-success btn-sm"
            CommandName="OpenPRS"
            CommandArgument='<%# Eval("PRSNo")
                        
    %>' Visible="False"></asp:LinkButton>
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

<HeaderStyle CssClass="gridview-header"></HeaderStyle>

                </asp:GridView>

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


    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script> function showDocsModal() {
          var modal = new bootstrap.Modal(document.getElementById('docsModal'));
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
</asp:Content>