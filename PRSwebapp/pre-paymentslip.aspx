<%@ Page Title="" Language="C#" MasterPageFile="~/SiteMaster.Master" AutoEventWireup="true" CodeBehind="pre-paymentslip.aspx.cs" Inherits="PRSwebapp.pre_payment_slip" %>

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
        .combo-input { width:100%; }
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

        /* Fullscreen Popup */
        #supplierInfoPopup { position: fixed; top:0; left:0; width:100vw; height:100vh; background: rgba(0,0,0,0.6); z-index:9999; display:none; justify-content:center; align-items:center; }
        #popupContentWrapper { background:#fff; border-radius:12px; width:95%; max-width:1200px; max-height:85vh; overflow:auto; padding:20px; position:relative; box-shadow:0 8px 25px rgba(0,0,0,0.3); animation: popupFadeIn 0.3s ease; }
        #popupClose { position:absolute; top:10px; right:15px; cursor:pointer; font-weight:bold; color:#6c5ce7; font-size:20px; }
        #popupContentWrapper table { width:100%; border-collapse:collapse; font-size:13px; }
        #popupContentWrapper th, #popupContentWrapper td { border:1px solid #6c5ce7; padding:6px 8px; text-align:left; }
        #popupContentWrapper td.numeric { text-align:right; }
        #popupContentWrapper tr:hover { background-color: #f0ecff; }

        @keyframes popupFadeIn { from { opacity:0; transform:scale(0.95); } to { opacity:1; transform:scale(1); } }

        /* Selected row highlight */
        #popupContentWrapper tr.highlight {
            background-color: #d9d4ff !important;
        }

        #popupContentWrapper input.form-control-sm { width:150px; margin-right:10px; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />

    <div class="form-card">
        <h2>Pre-payment Slip</h2>
        <div class="row g-3">
            <!-- Supplier Name -->
            <div class="col-md-4">
                <label class="form-label">Supplier Name</label>
                <div class="combo-container search-icon-container">
                    <asp:TextBox ID="txtSupplierCombo" runat="server" CssClass="form-control combo-input small-input" Placeholder="Supplier Name"></asp:TextBox>
                    <span class="search-icon" id="supplierSearchIcon">&#128269;</span>
                    <button type="button" class="combo-toggle" id="supplierToggle">&#9662;</button>
                    <ul id="supplierDropdown" class="dropdown-list"></ul>
                </div>
            </div>

            <!-- Other Inputs -->
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
                <label class="form-label">Amount</label>
                <asp:TextBox ID="txtAmount" runat="server" CssClass="form-control small-input" Placeholder="Enter amount"></asp:TextBox>
            </div>

            <div class="col-md-8">
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
            <div class="text-center mt-2">
                <button type="button" class="btn btn-primary btn-sm" onclick="savePopupHeader()">Select</button>
            </div>
        </div>
    </div>

    <script>
        // ---------- POPUP ----------
        document.getElementById('supplierSearchIcon').addEventListener('click', openPopup);
        function closePopup() { document.getElementById('supplierInfoPopup').style.display = 'none'; }

        function openPopup() {
            var html = '';
            html += '<div style="margin-bottom:15px; display:flex; gap:15px; flex-wrap:wrap; position:relative;">';
            html += 'Supplier: <input type="text" id="popupSupplierName" class="form-control form-control-sm">';
            html += '<ul id="popupSupplierDropdown" class="dropdown-list" style="position:absolute; top:30px; left:0;"></ul>';
            html += 'PO Date: <input type="date" id="popupPODate" class="form-control form-control-sm">';
            html += 'Validity: <input type="date" id="popupPOValidity" class="form-control form-control-sm">';
            html += '</div>';
            html += '<div id="popupTableContainer"><p>Start typing to search...</p></div>';

            document.getElementById('popupContent').innerHTML = html;
            document.getElementById('supplierInfoPopup').style.display = 'flex';
            document.getElementById('popupSupplierName').focus();

            var supplierInput = document.getElementById('popupSupplierName');
            var poDateInput = document.getElementById('popupPODate');
            var validityInput = document.getElementById('popupPOValidity');
            var dropdown = document.getElementById('popupSupplierDropdown');
            var supplierItems = <%= new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(supplierItems) %>;
            var currentFocus = -1;

            let debounceTimer;
            supplierInput.addEventListener('input', function () {
                clearTimeout(debounceTimer);
                debounceTimer = setTimeout(function () {
                    dropdown.innerHTML = '';
                    var val = supplierInput.value.toLowerCase();
                    supplierItems.forEach(item => {
                        if (!val || item.toLowerCase().includes(val)) {
                            var li = document.createElement('li');
                            li.innerHTML = item.replace(new RegExp(val, 'gi'), m => '<span class="highlight-text">' + m + '</span>');
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

            supplierInput.addEventListener('keydown', function (e) {
                var lis = dropdown.getElementsByTagName('li');
                if (e.keyCode == 40) { currentFocus++; addActive(lis); }
                else if (e.keyCode == 38) { currentFocus--; addActive(lis); }
                else if (e.keyCode == 13) {
                    e.preventDefault();
                    if (currentFocus > -1 && lis[currentFocus]) {
                        supplierInput.value = lis[currentFocus].textContent;
                        dropdown.style.display = 'none';
                        fetchFilteredData();
                    }
                    currentFocus = -1;
                }
            });

            function addActive(lis) { removeActive(lis); if (lis.length == 0) return; if (currentFocus >= lis.length) currentFocus = 0; if (currentFocus < 0) currentFocus = lis.length - 1; lis[currentFocus].classList.add('highlight'); }
            function removeActive(lis) { Array.from(lis).forEach(li => li.classList.remove('highlight')); }

            document.getElementById('supplierInfoPopup').addEventListener('click', function (e) {
                var wrapper = document.getElementById('popupContentWrapper');
                if (!wrapper.contains(e.target)) closePopup();
            });

            function fetchFilteredData() {
                PageMethods.GetFilteredPOHistory(supplierInput.value, poDateInput.value, validityInput.value,
                    function (result) { renderTable(result); }, function (err) { console.error(err); });
            }

            poDateInput.addEventListener('change', fetchFilteredData);
            validityInput.addEventListener('change', fetchFilteredData);

            // ---------- RENDER TABLE ----------
            function renderTable(data) {
                var container = document.getElementById('popupTableContainer');
                if (!data || data.length === 0) { container.innerHTML = '<p>No PO history found.</p>'; return; }

                var htmlTable = '<table id="popupDataTable"><thead><tr>';
                for (let key in data[0]) htmlTable += '<th>' + key + '</th>';
                htmlTable += '</tr></thead><tbody>';

                data.forEach((row, index) => {
                    htmlTable += `<tr data-index="${index}">`;
                    for (let key in row) {
                        let cls = key.toLowerCase().includes('amount') ? ' class="numeric"' : '';
                        htmlTable += `<td${cls}>${row[key]}</td>`;
                    }
                    htmlTable += '</tr>';
                });
                htmlTable += '</tbody></table>';
                container.innerHTML = htmlTable;

                var table = document.getElementById('popupDataTable');
                var selectedRow = null;

                table.querySelectorAll('tbody tr').forEach((tr) => {
                    tr.addEventListener('click', function () {
                        if (selectedRow) selectedRow.classList.remove('highlight');
                        selectedRow = this;
                        this.classList.add('highlight');

                        const headers = Array.from(table.querySelectorAll('th')).map(h => h.innerText);
                        const rowData = {};
                        headers.forEach((h, idx) => rowData[h] = this.cells[idx].innerText);
                        window.selectedPopupData = rowData;

                        // Auto-fill main form
                        if (rowData.SupplierName) document.getElementById('<%= txtSupplierCombo.ClientID %>').value = rowData.SupplierName;
                        if (rowData.PaymentsApplicable) document.getElementById('<%= txtPeriodMonth.ClientID %>').value = rowData.PaymentsApplicable;
                        if (rowData.POAmount || rowData.Amount) document.getElementById('<%= txtAmount.ClientID %>').value = rowData.POAmount || rowData.Amount;
                        if (rowData.PONumber) document.getElementById('<%= txtPONumber.ClientID %>').value = rowData.PONumber;
                    });
                });
            }
        }

        function savePopupHeader() {
            closePopup();
        }

        // ---------- MAIN AUTOCOMPLETE ----------
        var mainSupplierInput = document.getElementById('<%= txtSupplierCombo.ClientID %>');
        var mainSupplierDropdown = document.getElementById('supplierDropdown');
        var mainSupplierItems = <%= new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(supplierItems) %>;
        var mainFocus = -1;

        function showSupplierDropdown(filter) {
            mainSupplierDropdown.innerHTML = '';
            mainSupplierItems.forEach(function (item) {
                if (!filter || item.toLowerCase().includes(filter.toLowerCase())) {
                    var li = document.createElement('li');
                    li.innerHTML = item.replace(new RegExp(filter, 'gi'), m => '<span class="highlight-text">' + m + '</span>');
                    li.addEventListener('click', function () {
                        mainSupplierInput.value = item;
                        mainSupplierDropdown.style.display = 'none';
                    });
                    mainSupplierDropdown.appendChild(li);
                }
            });
            mainSupplierDropdown.style.display = mainSupplierDropdown.childElementCount > 0 ? 'block' : 'none';
        }

        mainSupplierInput.addEventListener('input', function () { showSupplierDropdown(mainSupplierInput.value); mainFocus = -1; });
        mainSupplierInput.addEventListener('keydown', function (e) {
            var lis = mainSupplierDropdown.getElementsByTagName('li');
            if (e.keyCode === 40) { mainFocus++; addSupplierActive(lis); }
            else if (e.keyCode === 38) { mainFocus--; addSupplierActive(lis); }
            else if (e.keyCode === 13) {
                e.preventDefault();
                if (mainFocus > -1 && lis[mainFocus]) {
                    mainSupplierInput.value = lis[mainFocus].textContent;
                    mainSupplierDropdown.style.display = 'none';
                }
                mainFocus = -1;
            }
        });

        function addSupplierActive(lis) { removeSupplierActive(lis); if (lis.length === 0) return; if (mainFocus >= lis.length) mainFocus = 0; if (mainFocus < 0) mainFocus = lis.length - 1; lis[mainFocus].classList.add('highlight'); }
        function removeSupplierActive(lis) { Array.from(lis).forEach(li => li.classList.remove('highlight')); }

        document.getElementById('supplierToggle').addEventListener('click', function () { showSupplierDropdown(mainSupplierInput.value); mainSupplierInput.focus(); });
        document.addEventListener('click', function (e) { if (!mainSupplierInput.contains(e.target) && !mainSupplierDropdown.contains(e.target) && e.target.id !== 'supplierToggle') mainSupplierDropdown.style.display = 'none'; });
    </script>
</asp:Content>
