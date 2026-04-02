<%@ Page Title="Supplier PO Entry" Language="C#" MasterPageFile="~/SiteMaster.Master"
    AutoEventWireup="true" CodeBehind="supplierdetails.aspx.cs" Inherits="PRSwebapp.supplier_details"
    UnobtrusiveValidationMode="None" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .form-card {
            background: linear-gradient(180deg, #ffffff, #e6e0ff);
            border-radius: 12px;
            padding: 30px;
            max-width: 1000px;
            margin: 30px auto;
            box-shadow: 0 6px 18px rgba(0,0,0,0.12);
            border: 1px solid rgba(108,92,231,0.3);
        }
        .form-card h2 {
            text-align:center;
            color:#6c5ce7;
            margin-bottom:25px;
            font-weight:bold;
        }
        .form-label {
            font-weight:500;
            color:#5a3fb5;
            font-size:14px;
        }
        .form-control, .form-check-input {
            border-radius:6px;
            border:1px solid #6c5ce7;
            box-sizing: border-box;
            width:100%;
        }
        .btn-custom {
            border-radius:6px;
            padding:8px 18px;
            font-weight:500;
        }
        .month-panel {
            border:1px solid #ddd;
            padding:8px;
            position:absolute;
            z-index:100;
            display:none;
            border-radius:5px;
            width:220px;
            background:#fff;
            box-shadow:0 4px 12px rgba(0,0,0,0.08);
        }
        .combo-container {
            position:relative;
            display:flex;
        }
        .combo-input {
            flex:1;
            width:100%;
        }
        .combo-toggle {
            border:1px solid #6c5ce7;
            background:#fff;
            cursor:pointer;
            padding:0 8px;
            height:36px;
            display:inline-flex;
            align-items:center;
            justify-content:center;
        }
        .dropdown-list {
            list-style:none;
            padding:0;
            margin:0;
            border:1px solid #6c5ce7;
            max-height:150px;
            overflow-y:auto;
            display:none;
            position:absolute;
            background:white;
            width:100%;
            z-index:1000;
        }
        .dropdown-list li {
            padding:5px 10px;
            cursor:pointer;
        }
        .dropdown-list li.highlight {
            background-color:#e6e0ff;
        }
        .highlight-text {
            font-weight:bold;
            background-color:#dcd6ff;
        }
        .po-radio input[type="radio"] {
            accent-color: black;
            width: 15px;
            height: 15px;
            margin-right: 6px;
            border: none;
            background: none;
            box-shadow: none;
        }
        .po-radio {
            font-weight: 500;
            color: #000;
            font-size: 13px;
            margin-right: 20px;
        }
        /* Popup */
        #supplierInfoPopup {
            position: fixed;
            top:0;
            left:0;
            width:100vw;
            height:100vh;
            background: rgba(0,0,0,0.6);
            z-index:9999;
            display:none;
            justify-content:center;
            align-items:center;
        }
        #popupContentWrapper {
            background:#fff;
            border-radius:12px;
            width:95%;
            max-width:1200px;
            max-height:85vh;
            overflow:auto;
            padding:20px;
            position:relative;
            box-shadow:0 8px 25px rgba(0,0,0,0.3);
            animation: popupFadeIn 0.3s ease;
        }
        #popupClose {
            position:absolute;
            top:10px;
            right:15px;
            cursor:pointer;
            font-weight:bold;
            color:#6c5ce7;
            font-size:20px;
        }
        #popupContentWrapper table {
            width:90%;
            border-collapse:collapse;
            font-size:10px;
        }
        #popupContentWrapper th, #popupContentWrapper td {
            border:1px solid #6c5ce7;
            padding:6px 8px;
            text-align:left;
        }
        #popupContentWrapper td.numeric {
            text-align:right;
        }
        #popupContentWrapper tr:hover {
            background-color: #f0ecff;
        }
        @keyframes popupFadeIn {
            from { opacity:0; transform:scale(0.95); }
            to { opacity:1; transform:scale(1); }
        }
        .small-input {
            font-size:13px;
        }
        .search-icon-container {
            position: relative;
            display: flex;
            align-items: center;
        }
        .search-icon-container .search-icon {
            position:absolute;
            right:35px;
            font-size:14px;
            color:#6c5ce7;
            cursor:pointer;
        }
        #popupContentWrapper input.form-control-sm {
            width:150px;
            margin-right:10px;
        }
        .badge {
            padding:0.35em 0.6em;
            font-size:0.75em;
            font-weight:500;
        }
        .bg-success { background-color:#28a745; color:#fff; }
        .bg-secondary { background-color:#6c757d; color:#fff; }

        /* File list styling */
        #fileListContainer div {
            display: flex;
            align-items: center;
            margin-top: 4px;
            gap: 6px;
        }

        #fileListContainer span {
            font-size: 12px; /* smaller file name */
            word-break: break-all;
         }

        #fileListContainer button {
            font-size: 10px;  /* smaller X */
            width: 18px;
            height: 18px;
            padding: 0;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
         }
    /* Wrapper for textbox with icon */
.input-icon-wrapper {
    position: relative;
}

.with-icon {
    padding-right: 30px; /* Space for the icon inside */
}

.input-icon {
    position: absolute;
    right: 10px;
    top: 50%;
    transform: translateY(-50%);
    cursor: pointer;
    font-weight: bold;
    color: #555;
    font-size: 25px;
}
#popupClose {
    position: absolute;
    top: 10px;
    right: 15px;
    cursor: pointer;
    width: 20px;
    height: 20px;
}

#popupClose::before {
    content: "\00d7";   /* Unicode X */
    font-size: 22px;
    color: #6c5ce7;
    font-weight: bold;
}
/* Row highlight */
.selected-row {
    background-color: #dcd6ff !important; /* light purple */
    font-weight: bold;
}

/* Underline highlighted cell */
.highlight-cell {
    text-decoration: underline;
    font-weight: bold;
    color: #6c5ce7;
}


    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />

  <div class="form-card">
    <h2>Supplier Purchase Order Entry</h2>
      <div class="row g-3">
  <!-- Ring Number -->
            <div class="col-md-4 position-relative">
                <label class="form-label">Ring Number
                    <asp:RequiredFieldValidator ID="rfvRingNumber" runat="server"
                        ControlToValidate="txtRingNumber" ErrorMessage="*" Text="*" ForeColor="Red" />
                </label>
                <div class="input-icon-wrapper">
                    <asp:TextBox ID="txtRingNumber" runat="server" CssClass="form-control with-icon"
                        Placeholder="Ring Number" OnTextChanged="txtRingNumber_TextChanged"></asp:TextBox>
                    <asp:Button ID="btnFetchRing" runat="server" CssClass="input-icon btn btn-link p-0"
                        OnClick="btnFetchRing_Click" Text="s" CausesValidation="false" />
                </div>
            </div>

            <!-- Supplier Name -->
            <div class="col-md-4 position-relative">
                <label class="form-label">Supplier Name
                    <asp:RequiredFieldValidator ID="rfvSupplier" runat="server"
                        ControlToValidate="txtSupplierCombo" ErrorMessage="*" Text="*" ForeColor="Red" />
                </label>
                <div class="combo-container search-icon-container">
                    <asp:TextBox ID="txtSupplierCombo" runat="server" CssClass="form-control combo-input small-input" Placeholder="Supplier Name"></asp:TextBox>
                    <span class="search-icon" id="supplierSearchIcon">&#128269;</span>
                    <button type="button" class="combo-toggle" id="supplierToggle">&#9662;</button>
                </div>
                <ul id="supplierDropdown" class="dropdown-list"></ul>
            </div>
                  <!-- Popup -->
<div id="supplierInfoPopup">
    <div id="popupContentWrapper">
       <span id="popupClose" onclick="closePopup()"></span>

        <div id="popupContent"></div>
    </div>
</div>

            <!-- Department -->
         

            <!-- PO Number -->
            <div class="col-md-4">
                <label class="form-label">PO Number
                    <asp:RequiredFieldValidator ID="rfvPONumber" runat="server"
                        ControlToValidate="txtPONumber" ErrorMessage="*" Text="*" ForeColor="Red" />
                </label>
                <asp:TextBox ID="txtPONumber" runat="server" CssClass="form-control" placeholder="PO Number" />
            </div>

            <!-- PO Date -->
            <div class="col-md-4">
                <label class="form-label">PO Date
                    <asp:RequiredFieldValidator ID="rfvPODate" runat="server"
                        ControlToValidate="txtPODate" ErrorMessage="*" Text="*" ForeColor="Red" />
                </label>
                <asp:TextBox ID="txtPODate" runat="server" TextMode="Date" CssClass="form-control" />
            </div>

            <!-- PRS Type -->
            <div class="col-md-4">
                <label class="form-label">PRS Type
                    <asp:RequiredFieldValidator ID="rfvPRSType" runat="server"
                        ControlToValidate="ddlPRSType" InitialValue="0" ErrorMessage="*" Text="*" ForeColor="Red" />
                </label>
                <asp:DropDownList ID="ddlPRSType" runat="server" CssClass="form-control small-input"></asp:DropDownList>
            </div>

            <!-- PO Amount -->
            <div class="col-md-4">
                <label class="form-label">PO Amount
                    <asp:RequiredFieldValidator ID="rfvPOAmount" runat="server"
                        ControlToValidate="txtPOAmount" ErrorMessage="*" Text="*" ForeColor="Red" />
                </label>
                <asp:TextBox ID="txtPOAmount" runat="server" CssClass="form-control" placeholder="Enter amount" onkeyup="formatAmount(this);" />
            </div>

            <!-- PO Payment Type -->
            <div class="col-md-4">
                <label class="form-label">PO Payment Type
                    <asp:CustomValidator ID="cvPOPaymentType" runat="server"
                        ErrorMessage="*" Text="*" ForeColor="Red"
                        OnServerValidate="ValidatePOPaymentType"
                        Display="Dynamic" />
                </label>
                <div style="margin-top:2px;">
                    <asp:RadioButton ID="rbFixed" runat="server" GroupName="POAmountType" Text="Fixed" CssClass="po-radio" /><br />
                    <asp:RadioButton ID="rbOnUsage" runat="server" GroupName="POAmountType" Text="On Usage" CssClass="po-radio" />
                </div>
            </div>

            <!-- Payments Applicable -->
            <div class="col-md-4 position-relative">
                <label class="form-label">Payments Applicable (Months)
                    <asp:RequiredFieldValidator ID="rfvMonths" runat="server"
                        ControlToValidate="txtMonths" ErrorMessage="*" Text="*" ForeColor="Red" />
                </label>
                <asp:TextBox ID="txtMonths" runat="server" CssClass="form-control" Placeholder="Enter months" />
            </div>

            <!-- Invoice Amount -->
            <div class="col-md-4">
                <label class="form-label">Invoice Amount
                    <asp:RequiredFieldValidator ID="rfvInvoiceAmount" runat="server"
                        ControlToValidate="txtInvoiceAmount" ErrorMessage="*" Text="*" ForeColor="Red" />
                </label>
                <asp:TextBox ID="txtInvoiceAmount" runat="server" CssClass="form-control"
                    placeholder="Invoice Amount" onkeyup="formatAmount(this);" />
            </div>

            <!-- Nature of Expense -->
            <div class="col-md-4">
                <label class="form-label">Nature of Exp. / Services
                    <asp:RequiredFieldValidator ID="rfvNatureOfExp" runat="server"
                        ControlToValidate="txtNatureOfExp" ErrorMessage="*" Text="*" ForeColor="Red" />
                </label>
                <asp:TextBox ID="txtNatureOfExp" runat="server" CssClass="form-control small-input"
                    Placeholder="Enter nature of expense or service"></asp:TextBox>
            </div>

            <!-- Agreement Start -->
            <div class="col-md-4">
                <label class="form-label">Agreement/Contract start
                    <asp:RequiredFieldValidator ID="rfvAgreementStart" runat="server"
                        ControlToValidate="txtAgreementStart" ErrorMessage="*" Text="*" ForeColor="Red" />
                </label>
                <asp:TextBox ID="txtAgreementStart" runat="server" CssClass="form-control" TextMode="Date" />
            </div>

            <!-- Agreement End -->
            <div class="col-md-4">
                <label class="form-label">Agreement/Contract end
                    <asp:RequiredFieldValidator ID="rfvAgreementEnd" runat="server"
                        ControlToValidate="txtAgreementEnd" ErrorMessage="*" Text="*" ForeColor="Red" />
                </label>
                <asp:TextBox ID="txtAgreementEnd" runat="server" CssClass="form-control" TextMode="Date" />
            </div>

            <!-- Upload Documents -->
            <div class="col-md-4">
                <label class="form-label">Upload Documents
                    <asp:RequiredFieldValidator ID="rfvFileUpload" runat="server"
                        ControlToValidate="fuDocument" ErrorMessage="*" Text="*" ForeColor="Red" />
                </label>
                <asp:FileUpload ID="fuDocument" runat="server" CssClass="form-control" AllowMultiple="true" onchange="handleFileSelection(this);" />
                <div id="fileListContainer"></div>
            </div>

        </div>

        <!-- Save/Clear Buttons -->
        <div class="row mt-4">
            <div class="col-12 text-center">
                <asp:Button ID="btnSave" runat="server" Text="Save"
                    CssClass="btn btn-primary btn-custom me-2" OnClick="btnSave_Click" TabIndex="100" />

                <asp:Button ID="btnClear" runat="server" Text="Clear"
                    CssClass="btn btn-secondary btn-custom" OnClientClick="clearForm(); return false;" />
            </div>
        </div>
    </div>
</div>
    <div id="notification" style="
    display:none; 
    position:fixed; 
    top:80px;  /* adjust this based on your header height */
    left:50%;
    transform:translateX(-50%);
    background:#e74c3c; 
    color:white; 
    padding:12px 20px; 
    border-radius:8px; 
    font-weight:500;
    box-shadow:0 4px 12px rgba(0,0,0,0.2);
    z-index:10000;
    transition: all 0.3s ease;
    text-align:center;
    min-width:250px;
    max-width:80%;
"></div>





    <script type="text/javascript">
        let selectedFiles = [];

        function handleFileSelection(input) {
            const newFiles = Array.from(input.files);
            newFiles.forEach(file => {
                // Avoid duplicates
                if (!selectedFiles.some(f => f.name === file.name && f.size === file.size)) {
                    selectedFiles.push(file);
                }
            });
            renderFileList(input);
        }

        function renderFileList(input) {
            const container = document.getElementById('fileListContainer');
            container.innerHTML = '';
            selectedFiles.forEach((file, index) => {
                const div = document.createElement('div');
                div.style.display = 'flex';
                div.style.alignItems = 'center';
                div.style.marginTop = '5px';
                div.style.gap = '8px';

                const nameSpan = document.createElement('span');
                nameSpan.innerText = file.name;

                const removeBtn = document.createElement('button');
                removeBtn.type = 'button';
                removeBtn.className = 'btn btn-sm btn-outline-danger';
                removeBtn.innerText = '✖';
                removeBtn.onclick = function () { removeFile(index, input); };

                div.appendChild(nameSpan);
                div.appendChild(removeBtn);
                container.appendChild(div);
            });

            // Update the FileUpload input
            const dt = new DataTransfer();
            selectedFiles.forEach(f => dt.items.add(f));
            input.files = dt.files;
        }

        function removeFile(index, input) {
            selectedFiles.splice(index, 1);
            renderFileList(input);
        }

      
        // Clear form example
        function clearForm() {

            // Clear all textboxes & dropdowns
            document.querySelectorAll('.form-control').forEach(i => i.value = '');

            // ✅ CLEAR PO PAYMENT TYPE RADIOS
            document.getElementById('<%= rbFixed.ClientID %>').checked = false;
            document.getElementById('<%= rbOnUsage.ClientID %>').checked = false;

            // Reset PRS Type dropdown
            document.getElementById('<%= ddlPRSType.ClientID %>').selectedIndex = 0;

           // Clear uploaded files
            selectedFiles = [];
            renderFileList(document.getElementById('<%= fuDocument.ClientID %>'));

            // Optional: reset validation UI
            if (typeof (Page_Validators) !== "undefined") {
                Page_Validators.forEach(v => v.isvalid = true);
            }
        }


        // ---------- GLOBAL VARIABLES ----------
        var supplierItems = <%= new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(supplierItems) %>;
        var departmentItems = <%= new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(departmentItems) %>;

       
        // ---------- FORMAT AMOUNTS ----------
        function formatAmount(input) {
            let val = input.value.replace(/,/g,'').replace(/[^\d]/g,'');
            input.value = val==='' ? '' : parseInt(val).toLocaleString();
        }

        // Show toast notification
        function showNotification(msg) {
            var notif = document.getElementById('notification');
            notif.innerText = msg;
            notif.style.opacity = '1';
            notif.style.display = 'block';
            // Auto hide after 3 seconds
            setTimeout(() => {
                notif.style.opacity = '0';
                setTimeout(() => { notif.style.display = 'none'; }, 300);
            }, 3000);
        }

        // Validate all ASP.NET validators before postback
        function validateAndNotify() {
            if (!Page_ClientValidate()) {
                showNotification("Please fill all required fields correctly!");
                return false; // Prevent form submission
            }
            return true; // Allow form submission
        }

        // Update Save button to use client-side validation
        var btnSave = document.getElementById('<%= btnSave.ClientID %>');
        btnSave.setAttribute('onclick', 'return validateAndNotify();');


        // ---------- POPUP ----------
        function closePopup(){ document.getElementById('supplierInfoPopup').style.display='none'; }

        document.getElementById('supplierSearchIcon').addEventListener('click', openPopup);
        document.getElementById('supplierToggle').addEventListener('click', function(){ showDropdown(mainSupplierInput.value); mainSupplierInput.focus(); });

        // Open Supplier PO Popup
        // ---------- POPUP ----------
        function closePopup() {
            document.getElementById('supplierInfoPopup').style.display = 'none';
        }

        document.getElementById('supplierSearchIcon').addEventListener('click', openPopup);
        document.getElementById('supplierToggle').addEventListener('click', function () {
            showDropdown(mainSupplierInput.value);
            mainSupplierInput.focus();
        });

        // Open Supplier PO Popup
       
        function closePopup() {
            document.getElementById('supplierInfoPopup').style.display = 'none';
        }

        document.getElementById('supplierSearchIcon').addEventListener('click', openPopup);

       
        function openPopup() {

            /* POPUP HTML DYNAMIC */
            document.getElementById('popupContent').innerHTML = `
        <div style="margin-bottom:15px; display:flex; gap:15px;">
            Supplier: <input type="text" id="popupSupplierName" class="form-control form-control-sm">
            Agreement Start: <input type="date" id="popupPODate" class="form-control form-control-sm">
            Agreement End: <input type="date" id="popupPOValidity" class="form-control form-control-sm">
        </div>
        <ul id="popupSupplierDropdown" class="dropdown-list"></ul>
        <div id="popupTableContainer"><p>Start typing to search...</p></div>
    `;

            document.getElementById('supplierInfoPopup').style.display = 'flex';

            const supplierInput = document.getElementById('popupSupplierName');
            const poDateInput = document.getElementById('popupPODate');
            const validityInput = document.getElementById('popupPOValidity');
            const dropdown = document.getElementById('popupSupplierDropdown');

            let debounceTimer;
            let currentFocus = -1;

            /* ------------------------------------------------------
                FIELD MAP (CLIENT IDs)
            ------------------------------------------------------ */
            const fieldMap = {
                "ringinumber": "<%= txtRingNumber.ClientID %>",
                "suppliername": "<%= txtSupplierCombo.ClientID %>",
                "prstype": "<%= ddlPRSType.ClientID %>",
                "ponumber": "<%= txtPONumber.ClientID %>",
                "podate": "<%= txtPODate.ClientID %>",
                "poamount": "<%= txtPOAmount.ClientID %>",
                "invoiceamount": "<%= txtInvoiceAmount.ClientID %>",
                "natureofexp": "<%= txtNatureOfExp.ClientID %>",
                "agreementstart": "<%= txtAgreementStart.ClientID %>",
                "agreementend": "<%= txtAgreementEnd.ClientID %>",
                "paymentsapplicable": "<%= txtMonths.ClientID %>",
                "popaymenttype": [
              "<%= rbFixed.ClientID %>", 
                    "<%= rbOnUsage.ClientID %>"
                ]
            };

            /* ------------------------------------------------------
                COLUMN NAME NORMALIZATION (IMPORTANT FIX)
            ------------------------------------------------------ */
            const columnAliasMap = {
                "ringino": "ringinumber",
                "ringinumber": "ringinumber",
                "ringno": "ringinumber",
                "ringnumber": "ringinumber",

                "prstypename": "prstype", 
                "prstype": "prstype",
                "prs type": "prstype",
                "prs_type": "prstype",
                "prs": "prstype",
                "prstyp": "prstype",
                "type": "prstype",

                "ponumber": "ponumber",
                "ponum": "ponumber",

                "podate": "podate",

                "paymenttype": "popaymenttype",
                "popaymenttype": "popaymenttype",

                "poamount": "poamount"
            };

            /* ------------------------------------------------------
                SUPPLIER AUTOCOMPLETE IN POPUP
            ------------------------------------------------------ */
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

            /* ------------------------------------------------------
                CALL SERVER - FILTERED HISTORY
            ------------------------------------------------------ */
            function fetchFilteredData() {
                PageMethods.GetFilteredPOHistory(
                    supplierInput.value,
                    poDateInput.value,
                    validityInput.value,
                    renderTable,
                    err => console.error(err)
                );
            }

            /* ------------------------------------------------------
                BUILD TABLE + AUTOFILL MAIN FORM
            ------------------------------------------------------ */
            function renderTable(data) {
                const container = document.getElementById('popupTableContainer');

                if (!data || data.length === 0) {
                    container.innerHTML = '<p>No PO history found.</p>';
                    return;
                }

                const columns = Object.keys(data[0]);

                let html = `<table id="popupDataTable"><thead><tr>`;
                columns.forEach(col => html += `<th>${col}</th>`);
                html += `</tr></thead><tbody>`;

                data.forEach((row, index) => {
                    html += `<tr data-index="${index}">`;
                    columns.forEach(col => {
                        html += `<td>${row[col] || ''}</td>`;
                    });
                    html += `</tr>`;
                });

                html += `</tbody></table>`;
                container.innerHTML = html;

                const table = document.getElementById('popupDataTable');

                table.querySelectorAll('tbody tr').forEach(tr => {
                    tr.addEventListener('click', function () {
                        const cells = this.querySelectorAll('td');

                        columns.forEach((col, i) => {

                            let rawKey = col.toLowerCase().trim().replace(/[^a-z0-9 ]/g, "");
                            rawKey = rawKey.replace(/\s+/g, " ");  // normalize spaces

                            let key = columnAliasMap[rawKey] || rawKey;

                            const val = cells[i].innerText.trim();

                            if (fieldMap[key]) {

                                if (key === "prstype") {
                                    const ddl = document.getElementById(fieldMap[key]);
                                    const popupValue = val.trim().toLowerCase();

                                    for (let i = 0; i < ddl.options.length; i++) {
                                        if (ddl.options[i].text.trim().toLowerCase() === popupValue) {
                                            ddl.selectedIndex = i;
                                            break;
                                        }
                                    }

                                    console.log("PRS TYPE Autofilled:", popupValue);
                                }



                                /* PAYMENT TYPE RADIO */
                                else if (key === "popaymenttype") {
                                    if (val.toLowerCase() === "fixed")
                                        document.getElementById(fieldMap[key][0]).checked = true;
                                    else
                                        document.getElementById(fieldMap[key][1]).checked = true;
                                }

                                /* NORMAL TEXT FIELD */
                                else {
                                    document.getElementById(fieldMap[key]).value = val;
                                }
                            }
                        });

                        setTimeout(closePopup, 250);
                    });
                });
            }

        } // END OPEN POPUP


      
      // ---------- MAIN SUPPLIER AUTOCOMPLETE ----------
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

        mainSupplierInput.addEventListener('input', function () {
            showSupplierDropdown(mainSupplierInput.value);
            mainFocus = -1;
        });

        mainSupplierInput.addEventListener('keydown', function (e) {
            var lis = mainSupplierDropdown.getElementsByTagName('li');
            if (e.keyCode === 40) { mainFocus++; addSupplierActive(lis); }
            else if (e.keyCode === 38) { mainFocus--; addSupplierActive(lis); }
            else if (e.keyCode === 13) { e.preventDefault(); if (mainFocus > -1 && lis[mainFocus]) { mainSupplierInput.value = lis[mainFocus].textContent; mainSupplierDropdown.style.display = 'none'; } mainFocus = -1; }
        });

        function addSupplierActive(lis) { removeSupplierActive(lis); if (lis.length === 0) return; if (mainFocus >= lis.length) mainFocus = 0; if (mainFocus < 0) mainFocus = lis.length - 1; lis[mainFocus].classList.add('highlight'); }
        function removeSupplierActive(lis) { Array.from(lis).forEach(li => li.classList.remove('highlight')); }

        document.getElementById('supplierToggle').addEventListener('click', function () { showSupplierDropdown(mainSupplierInput.value); mainSupplierInput.focus(); });
        document.addEventListener('click', function (e) { if (!mainSupplierInput.contains(e.target) && !mainSupplierDropdown.contains(e.target) && e.target.id !== 'supplierToggle') mainSupplierDropdown.style.display = 'none'; });


    </script>
</asp:Content>