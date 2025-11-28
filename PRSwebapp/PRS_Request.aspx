<%@ Page Title="" Language="C#" MasterPageFile="~/SiteMaster.Master" AutoEventWireup="true" CodeBehind="PRS_Request.aspx.cs" Inherits="PRSwebapp.PRS_Request" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .form-card { background: linear-gradient(180deg,#fff,#e6e0ff); border-radius:12px; padding:30px; max-width:1000px; margin:30px auto; box-shadow:0 6px 18px rgba(0,0,0,0.12); border:1px solid rgba(108,92,231,0.3);}
        .form-card h2 { text-align:center; color:#6c5ce7; margin-bottom:25px; font-weight:bold; }
        .form-label { font-weight:500; color:#5a3fb5; font-size:14px; }
        .form-control, .form-check-input { border-radius:6px; border:1px solid #6c5ce7; width:100%; }
        .btn-custom { border-radius:6px; padding:8px 18px; font-weight:500; }
        .combo-container { position:relative; width:100%; }
        .combo-toggle { border:1px solid #6c5ce7; background:#fff; cursor:pointer; padding:0 8px; height:36px; display:inline-flex; align-items:center; justify-content:center; margin-left:2px; }
        .dropdown-list { list-style:none; padding:0; margin:2px 0 0 0; border:1px solid #6c5ce7; max-height:150px; overflow-y:auto; display:none; position:absolute; top:100%; left:0; width:100%; background:#fff; z-index:1000; }
        .dropdown-list li { padding:5px 10px; cursor:pointer; }
        .dropdown-list li.highlight,
        .dropdown-list li:hover { background-color:#d9d4ff; color:#3f2fa5; }
        .small-input { font-size:13px; }
        .search-icon-container { position:relative; display:flex; align-items:center; }
        .search-icon-container .search-icon { position:absolute; right:35px; font-size:14px; color:#6c5ce7; cursor:pointer; }
        .btn-clear { background-color:#f8f9fa; border:1px solid #6c5ce7; color:#6c5ce7; }
        .btn-clear:hover { background-color:#6c5ce7; color:#fff; }
        #supplierInfoPopup { position: fixed; top:0; left:0; width:100vw; height:100vh; background: rgba(0,0,0,0.6); z-index:9999; display:none; justify-content:center; align-items:center; }
        #popupContentWrapper { background:#fff; border-radius:12px; width:95%; max-width:1200px; max-height:85vh; overflow:auto; padding:20px; position:relative; box-shadow:0 8px 25px rgba(0,0,0,0.3); animation: popupFadeIn 0.3s ease; }
        #popupClose { position:absolute; top:10px; right:15px; cursor:pointer; font-weight:bold; color:#6c5ce7; font-size:20px; }
        #popupContentWrapper table { width:100%; border-collapse:collapse; font-size:13px; }
        #popupContentWrapper th, #popupContentWrapper td { border:1px solid #6c5ce7; padding:6px 8px; text-align:left; }
        #popupContentWrapper td.numeric { text-align:right; }
        #popupContentWrapper tr:hover { background-color: #f0ecff; cursor: pointer; }
        @keyframes popupFadeIn { from { opacity:0; transform:scale(0.95); } to { opacity:1; transform:scale(1); } }
        #popupContentWrapper tr.highlight { background-color: #d9d4ff !important; text-decoration: underline; font-weight: 600; }
        #popupContentWrapper input.form-control-sm { width:150px; margin-right:10px; }

        #fileListContainer div { display: flex; align-items: center; margin-top: 4px; gap: 6px; }
        #fileListContainer span { font-size: 12px; word-break: break-all; }
        #fileListContainer button { font-size: 10px; width: 18px; height: 18px; padding: 0; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />

    <div class="form-card">
        <h2>Payment Request Slip</h2>
        <div class="row g-3">
            <div class="col-md-4">
                <label class="form-label">Supplier Name</label>
                <div class="combo-container search-icon-container">
                    <asp:TextBox ID="txtSupplierCombo" runat="server" CssClass="form-control combo-input small-input" Placeholder="Supplier Name"></asp:TextBox>
                    <span class="search-icon" id="supplierSearchIcon">&#128269;</span>
                    <button type="button" class="combo-toggle" id="supplierToggle">&#9662;</button>
                    <ul id="supplierDropdown" class="dropdown-list"></ul>
                </div>
            </div>

            <div class="col-md-4">
                <label class="form-label">PRS Type</label>
                <asp:DropDownList ID="ddlPRSType" runat="server" CssClass="form-control small-input">
                    <asp:ListItem Text="-- Select PRS Type --" Value="" Selected="True" />
                    <asp:ListItem Text="Capex advance PRS" Value="Capex advance PRS" />
                    <asp:ListItem Text="Pre-payment PRS" Value="Pre-payment PRS" />
                    <asp:ListItem Text="Non capex PRS" Value="Non capex PRS" />
                    <asp:ListItem Text="Monthly PRS" Value="Monthly PRS" />
                </asp:DropDownList>
            </div>

            <div class="col-md-4">
                <label class="form-label">PO Date</label>
                <asp:TextBox ID="txtPODate" runat="server" TextMode="Date" CssClass="form-control small-input" />
            </div>

            <div class="col-md-4">
                <label class="form-label">PO Number</label>
                <asp:TextBox ID="txtPONumber" runat="server" CssClass="form-control" placeholder="PO Number" />
            </div>

            <div class="col-md-4">
                <label class="form-label">Nature of Exp. / Services</label>
                <asp:TextBox ID="txtNatureOfExp" runat="server" CssClass="form-control small-input" Placeholder="Enter nature of expense or service"></asp:TextBox>
            </div>

            <div class="col-md-4">
                <label class="form-label">Period / Month</label>
                <asp:TextBox ID="txtPeriodMonth" runat="server" CssClass="form-control small-input" Placeholder="Enter period or month"></asp:TextBox>
            </div>

            <div class="col-md-4">
                <label class="form-label">Bill Number</label>
                <asp:TextBox ID="txtBillNumber" runat="server" CssClass="form-control small-input" Placeholder="Enter bill number"></asp:TextBox>
            </div>

            <div class="col-md-4">
                <label class="form-label">Bill Date</label>
                <asp:TextBox ID="txtBillDate" runat="server" TextMode="Date" CssClass="form-control small-input" />
            </div>

            <div class="col-md-4">
                <label class="form-label">Due Date</label>
                <asp:TextBox ID="txtDueDate" runat="server" TextMode="Date" CssClass="form-control small-input" />
            </div>

             <div class="col-md-4">
                 <label class="form-label">Bill Period From</label>
                 <asp:TextBox ID="txtBillPeriodFrom" runat="server" TextMode="Date" CssClass="form-control small-input" />
             </div>

             <div class="col-md-4">
                 <label class="form-label">Bill Period To</label>
                 <asp:TextBox ID="txtBillPeriodTo" runat="server" TextMode="Date" CssClass="form-control small-input" />
             </div>

             <div class="col-md-4">
                 <label class="form-label">Invoice Amount</label>
                 <asp:TextBox ID="txtAmount" runat="server" CssClass="form-control small-input" placeholder="Invoice Amount" onkeyup="formatAmount(this);" />
             </div>

           

            <div class="col-md-4">
                <label class="form-label">Upload Documents</label>
                <asp:FileUpload ID="fuDocument" runat="server" CssClass="form-control" AllowMultiple="true" onchange="handleFileSelection(this);" />
                <div id="fileListContainer"></div>
             </div>

            <div class="col-md-4">
                <label class="form-label">Comments</label>
                <asp:TextBox ID="txtComments" runat="server" TextMode="MultiLine" Rows="2" CssClass="form-control small-input" Placeholder="Enter any remarks"></asp:TextBox>
            </div>

            <div class="col-md-12 text-center mt-3">
                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-primary btn-custom me-2" OnClick="btnSave_Click" />
                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-clear btn-custom" OnClick="btnClear_Click" />
            </div>
        </div>
    </div>

    <!-- Popup -->
    <div id="supplierInfoPopup">
        <div id="popupContentWrapper">
            <span id="popupClose" onclick="closePopup()">×</span>
            <div id="popupContent"></div>
        </div>
    </div>

    <script>
        // ---------- Popup ----------
        document.getElementById('supplierSearchIcon').addEventListener('click', openPopup);
        function closePopup() { document.getElementById('supplierInfoPopup').style.display = 'none'; }

        function openPopup() {
            let html = `
                <div style="margin-bottom:15px; display:flex; gap:15px; flex-wrap:wrap; position:relative;">
                    Supplier: <input type="text" id="popupSupplierName" class="form-control form-control-sm">
                    <ul id="popupSupplierDropdown" class="dropdown-list" style="position:absolute; top:30px; left:0;"></ul>
                    Agreement Start: <input type="date" id="popupPODate" class="form-control form-control-sm">
                    Agreement End: <input type="date" id="popupPOValidity" class="form-control form-control-sm">
                </div>
                <div id="popupTableContainer"><p>Start typing to search...</p></div>`;
            document.getElementById('popupContent').innerHTML = html;
            document.getElementById('supplierInfoPopup').style.display = 'flex';
            document.getElementById('popupSupplierName').focus();

            const supplierInput = document.getElementById('popupSupplierName');
            const poDateInput = document.getElementById('popupPODate');
            const validityInput = document.getElementById('popupPOValidity');
            const dropdown = document.getElementById('popupSupplierDropdown');

            const supplierItems = <%= new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(supplierItems) %>;
            let debounceTimer;

            supplierInput.addEventListener('input', function () {
                clearTimeout(debounceTimer);
                debounceTimer = setTimeout(function () {
                    dropdown.innerHTML = '';
                    let val = supplierInput.value.toLowerCase();
                    supplierItems.forEach(item => {
                        if (!val || item.toLowerCase().includes(val)) {
                            let li = document.createElement('li');
                            li.innerHTML = item.replace(new RegExp(val, 'gi'), m => `<span class="highlight-text">${m}</span>`);
                            li.addEventListener('click', function () {
                                supplierInput.value = item;
                                dropdown.style.display = 'none';
                                fetchFilteredData();
                            });
                            dropdown.appendChild(li);
                        }
                    });
                    dropdown.style.display = dropdown.childElementCount > 0 ? 'block' : 'none';
                    fetchFilteredData();
                }, 250);
            });

            poDateInput.addEventListener('change', fetchFilteredData);
            validityInput.addEventListener('change', fetchFilteredData);

            function fetchFilteredData() {
                PageMethods.GetFilteredPOHistory(supplierInput.value, poDateInput.value, validityInput.value, renderTable, err => console.error(err));
            }

            function renderTable(data) {
                const container = document.getElementById('popupTableContainer');
                if (!data || data.length === 0) {
                    container.innerHTML = '<p>No PO history found.</p>';
                    return;
                }

                let html = `<table id="popupDataTable">
        <thead>
            <tr>
                <th>Supplier Name</th>
                <th>PRS Type</th>
                <th>PO Number</th>
                <th>PO Date</th>
                <th>PO Payment Type</th>
                <th>Applicable Month</th>  <!-- Use Month instead -->
               
                <th>PO Amount</th>
                <th>Invoice Amount</th>
                <th>Nature Of Exp</th>
                <th>Agreement Start</th>
                <th>Agreement End</th>
                 <th>Status</th>            <!-- Show Processed/Pending -->
            </tr>
        </thead>
        <tbody>`;

                data.forEach((row, index) => {
                    let statusHTML = row.Status === 'Processed'
                        ? '<span style="background-color:#006400;color:#fff;padding:1px 8px;border-radius:4px;font-weight:100;">Processed</span>'
                        : '<span style="background-color:#6c757d;color:#fff;padding:1px 8px;border-radius:4px;font-weight:100;">Pending</span>';

                    html += `<tr data-index="${index}">
            <td>${row.SupplierName || ''}</td>
            <td>${row.prstype || ''}</td>
            <td>${row.PONumber || ''}</td>
            <td>${row.PODate || ''}</td>
            <td>${row.POPaymentType || ''}</td>
           <td>${row.PaymentsApplicable || ''}</td>
     <!-- Correct column -->
         
            <td class="numeric">${row.POAmount || ''}</td>
            <td class="numeric">${row.InvoiceAmount || ''}</td>
            <td>${row.natureofexp || ''}</td>
            <td>${row.AgreementStart || ''}</td>
            <td>${row.AgreementEnd || ''}</td>
               <td>${statusHTML}</td>
        </tr>`;
                });

                html += `</tbody></table>`;
                container.innerHTML = html;



                const table = document.getElementById('popupDataTable');
                let selectedRow = null;

                table.querySelectorAll('tbody tr').forEach(tr => {
                    tr.addEventListener('click', function () {
                        if (selectedRow) selectedRow.classList.remove('highlight');
                        selectedRow = this;
                        this.classList.add('highlight');

                        const cells = this.querySelectorAll('td');
                        const rowData = {
                            SupplierName: cells[0].innerText,
                            PRSType: cells[1].innerText,
                            PONumber: cells[2].innerText,
                            PODate: cells[3].innerText,
                            PaymentsApplicable: cells[5].innerText,
                            POAmount: cells[6].innerText,
                            NatureOfExp: cells[8].innerText
                        };

                        document.getElementById('<%= txtSupplierCombo.ClientID %>').value = rowData.SupplierName;
                        document.getElementById('<%= ddlPRSType.ClientID %>').value = rowData.PRSType;
                        document.getElementById('<%= txtPONumber.ClientID %>').value = rowData.PONumber;
                        document.getElementById('<%= txtPODate.ClientID %>').value = rowData.PODate;
                        document.getElementById('<%= txtPeriodMonth.ClientID %>').value = rowData.PaymentsApplicable;
                        document.getElementById('<%= txtAmount.ClientID %>').value = rowData.POAmount;
                        document.getElementById('<%= txtNatureOfExp.ClientID %>').value = rowData.NatureOfExp;

                        setTimeout(closePopup, 250);
                    });
                });
            }
        }

        // ---------- File Upload ----------
        let selectedFiles = [];
        function handleFileSelection(input) {
            const newFiles = Array.from(input.files);
            newFiles.forEach(file => {
                if (!selectedFiles.some(f => f.name === file.name && f.size === file.size)) selectedFiles.push(file);
            });
            renderFileList(input);
        }
        function renderFileList(input) {
            const container = document.getElementById('fileListContainer');
            container.innerHTML = '';
            selectedFiles.forEach((file, index) => {
                const div = document.createElement('div');
                const nameSpan = document.createElement('span');
                nameSpan.innerText = file.name;
                const removeBtn = document.createElement('button');
                removeBtn.type = 'button';
                removeBtn.className = 'btn btn-sm btn-outline-danger';
                removeBtn.innerText = '✖';
                removeBtn.onclick = () => { removeFile(index, input); };
                div.appendChild(nameSpan);
                div.appendChild(removeBtn);
                container.appendChild(div);
            });

            const dt = new DataTransfer();
            selectedFiles.forEach(f => dt.items.add(f));
            input.files = dt.files;
        }
        function removeFile(index, input) {
            selectedFiles.splice(index, 1);
            renderFileList(input);
        }

        // ---------- Clear Form ----------
        function clearForm() {
            document.querySelectorAll('.form-control').forEach(i => i.value = '');
            selectedFiles = [];
            renderFileList(document.getElementById('<%= fuDocument.ClientID %>'));
        }

        document.getElementById('<%= btnClear.ClientID %>')?.addEventListener('click', clearForm);

        // ---------- Format Amount with Commas ----------
        function formatAmount(input) {
            // Remove any character that is not a digit or dot
            let value = input.value.replace(/[^0-9.]/g, '');

            // Split integer and decimal parts
            let parts = value.split('.');

            // Format the integer part with commas
            parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');

            // Limit to 2 decimal places if decimal exists
            if (parts[1]) {
                parts[1] = parts[1].slice(0, 2);
            }

            input.value = parts.join('.');
        }


        // ---------- Main Autocomplete ----------
        const mainSupplierInput = document.getElementById('<%= txtSupplierCombo.ClientID %>');
        const mainSupplierDropdown = document.getElementById('supplierDropdown');
        const mainSupplierItems = <%= new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(supplierItems) %>;

        function showSupplierDropdown(filter) {
            mainSupplierDropdown.innerHTML = '';
            mainSupplierItems.forEach(item => {
                if (!filter || item.toLowerCase().includes(filter.toLowerCase())) {
                    let li = document.createElement('li');
                    li.innerHTML = item.replace(new RegExp(filter, 'gi'), m => `<span class="highlight-text">${m}</span>`);
                    li.addEventListener('click', function () {
                        mainSupplierInput.value = item;
                        mainSupplierDropdown.style.display = 'none';
                    });
                    mainSupplierDropdown.appendChild(li);
                }
            });
            mainSupplierDropdown.style.display = mainSupplierDropdown.childElementCount > 0 ? 'block' : 'none';
        }

        mainSupplierInput.addEventListener('input', function () { showSupplierDropdown(this.value); });
        document.getElementById('supplierToggle').addEventListener('click', function () { showSupplierDropdown(mainSupplierInput.value); mainSupplierInput.focus(); });
        document.addEventListener('click', function (e) {
            if (!mainSupplierInput.contains(e.target) && !mainSupplierDropdown.contains(e.target) && e.target.id !== 'supplierToggle')
                mainSupplierDropdown.style.display = 'none';
        });
    </script>
</asp:Content>