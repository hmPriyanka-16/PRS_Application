<%@ Page Title="PRS Request" Language="C#" MasterPageFile="~/SiteMaster.Master"
    AutoEventWireup="true"
    CodeBehind="PRS_Request.aspx.cs"
    Inherits="PRSwebapp.PRS_Request"
    ValidateRequest="false"
    UnobtrusiveValidationMode="None" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }

        /* Form card styling */
        .form-card {
            background: linear-gradient(180deg,#fff,#e6e0ff);
            border-radius:12px;
            padding:40px 50px;
            max-width:1200px;
            margin:40px auto;
            box-shadow:0 8px 25px rgba(0,0,0,0.15);
            border:1px solid rgba(108,92,231,0.3);
            overflow-x:auto;
        }

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

        #supplierInfoPopup { 
            position: fixed; top:0; left:0; width:100vw; height:100vh; 
            background: rgba(0,0,0,0.6); z-index:9999; display:none; 
            justify-content:center; align-items:center; overflow-y:auto;
        }

        #popupContentWrapper { 
            background:#fff; border-radius:12px; width:95%; max-width:1200px; max-height:85vh; 
            overflow:auto; padding:20px; position:relative; box-shadow:0 8px 25px rgba(0,0,0,0.3); 
            animation: popupFadeIn 0.3s ease; 
        }

        #popupClose {
            position:absolute;
            top:10px;
            right:15px;
            cursor:pointer;
            width:24px;
            height:24px;
            display:flex;
            justify-content:center;
            align-items:center;
            z-index:999999;
        }

        #popupClose::after {
            content:"\00d7";
            font-size:24px;
            font-weight:bold;
            color:#6c5ce7;
            line-height:24px;
        }

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

        /* Notification */
        #notification {
            display:none;
            position:fixed;
            top:80px;
            left:50%;
            transform:translateX(-50%);
            background:#e74c3c;
            color:white;
            padding:12px 20px;
            border-radius:8px;
            font-weight:500;
            box-shadow:0 4px 12px rgba(0,0,0,0.2);
            z-index:10000;
            transition: all 0.5s ease;
            text-align:center;
            min-width:250px;
            max-width:80%;
        }

        /* Invoice table styling */
        #invoiceTable input.form-control {
            padding: 4px 6px;
            font-size: 13px;
            width: 100%;
        }

        #invoiceTable th, #invoiceTable td {
            padding: 4px 6px;
            font-size: 13px;
            white-space: nowrap;
        }

        #invoiceTable th {
            font-weight: 500;
        }

        #invoiceTable td.numeric {
            text-align: right;
            width: 90px;
        }

        #invoiceTable td input.amount {
            text-align: right;
        }

        #invoiceTable thead th {
            background-color: #e6e0ff;
            color: #3f2fa5;
            font-weight: 600;
            text-align: center;
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .form-card { padding:20px 15px; }
            .form-card h2 { font-size: 20px; margin-bottom: 15px; }
            .row.g-3 > [class*='col-'] { margin-bottom: 10px; }
            #invoiceTable th, #invoiceTable td { font-size: 12px; padding: 3px 5px; }
            #invoiceTable th, #invoiceTable td input { font-size: 12px; padding: 2px 4px; }
            .btn-custom { font-size: 12px; padding: 6px 12px; }
            #fileListContainer span { font-size: 11px; }
        }

        @media (max-width: 576px) {
            .col-md-3, .col-md-6, .col-md-12 { flex: 0 0 100%; max-width: 100%; }
            .row.g-3 > .col-md-3 { margin-bottom: 10px; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />

    <div class="form-card">
        <h2>Payment Request Slip</h2>
        <div class="row g-3">

            <!-- Supplier Name -->
            <div class="col-md-3">
                <label class="form-label">
                    Supplier Name
                    <asp:RequiredFieldValidator ID="rfvSupplierName" runat="server"
                        ControlToValidate="txtSupplierCombo"
                        ErrorMessage="*" Text="*" ForeColor="Red"
                        ValidationGroup="SavePRS" />
                </label>

                <div class="combo-container search-icon-container">
                    <asp:TextBox ID="txtSupplierCombo" runat="server"
                        CssClass="form-control combo-input small-input"
                        Placeholder="Supplier Name"></asp:TextBox>

                    <span class="search-icon" id="supplierSearchIcon">&#128269;</span>
                    <button type="button" class="combo-toggle" id="supplierToggle">&#9662;</button>
                    <ul id="supplierDropdown" class="dropdown-list"></ul>
                </div>
            </div>

            <!-- PRS Type -->
            <div class="col-md-3">
                <label class="form-label">
                    PRS Type
                    <asp:RequiredFieldValidator 
                        ID="rfvPRSType"
                        runat="server"
                        ControlToValidate="ddlPRSType"
                        InitialValue="0"
                        ErrorMessage="*"
                        Text="*"
                        ForeColor="Red"
                        ValidationGroup="SavePRS" />
                </label>

                <asp:DropDownList ID="ddlPRSType" runat="server" CssClass="form-control small-input">
                    <asp:ListItem Text="-- Select PRS Type --" Value="" Selected="True" />
                    <asp:ListItem Text="Capex advance PRS" Value="Capex advance PRS" />
                    <asp:ListItem Text="Pre-payment PRS" Value="Pre-payment PRS" />
                    <asp:ListItem Text="Non capex PRS" Value="Non capex PRS" />
                    <asp:ListItem Text="Monthly PRS" Value="Monthly PRS" />
                </asp:DropDownList>
            </div>

            <!-- PO Date -->
            <div class="col-md-3">
                <label class="form-label">PO Date</label>
                <asp:TextBox ID="txtPODate" runat="server" TextMode="Date"
                    CssClass="form-control small-input" />
            </div>

            <!-- PO Number -->
            <div class="col-md-3">
                <label class="form-label">PO Number</label>
                <asp:TextBox ID="txtPONumber" runat="server"
                    CssClass="form-control"
                    placeholder="PO Number" />
            </div>
        </div>

        <!-- Invoice Details -->
        <div class="col-md-12 mt-4">
            <h5 style="color:#6c5ce7;font-weight:bold;">Invoice Details</h5>

            <div class="table-responsive">
                <table class="table table-bordered" id="invoiceTable">
                    <thead>
                        <tr>
                            <th style="width:40px;">SL No</th>
                            <th style="width:170px;">Invoice/Bill Num</th>
                            <th style="width:40px;">Bill Date</th>
                            <th style="width:40px;">Due Date</th>
                            <th style="width:40px;">Bill Period From</th>
                            <th style="width:40px;">Bill Period To</th>
                            <th style="width:170px;">Invoice Amount</th>
                            <th style="width:200px;">Nature of Expense / Service</th>
                            <th style="width:60px;">Action</th>
                        </tr>
                    </thead>
                    <tbody id="invoiceTableBody">
                        
                           <tr>
    <td class="slNo"></td>
    <td><input type="text" class="form-control billNo" name="billNo" placeholder="Bill Number"/></td>
    <td><input type="date" class="form-control billDate" name="billDate"/></td>
    <td><input type="date" class="form-control dueDate" name="dueDate"/></td>
    <td><input type="date" class="form-control billPeriodFrom" name="billPeriodFrom"/></td>
    <td><input type="date" class="form-control billPeriodTo" name="billPeriodTo"/></td>
    <td><input type="number" class="form-control amount" name="amount" placeholder="Invoice Amount" onkeyup="calculateTotal()"/></td>
    <td><input type="text" class="form-control natureOfExp small-input" name="natureOfExp" placeholder="Enter nature of expense or service"/></td>
    <td class="text-center actions"></td>
</tr>
                        </tr>
                    </tbody>
                    <tfoot>
                        <tr>
                            <td colspan="6" style="text-align:right; font-weight:bold;">Total:</td>
                            <td id="totalAmount" style="text-align:right; font-weight:bold;">0.00</td>
                            <td colspan="2"></td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </div>

        <!-- Comments and Upload Document -->
        <div class="row g-3 mt-3">
            <div class="col-md-6">
                <label class="form-label">Comments</label>
                <asp:TextBox ID="txtComments" runat="server"
                    TextMode="MultiLine"
                    Rows="1"
                    CssClass="form-control small-input"
                    Placeholder="Enter any remarks">
                </asp:TextBox>
            </div>

            <div class="col-md-6">
                <label class="form-label">Upload Documents</label>
                <asp:FileUpload ID="fuDocument" runat="server"
                    CssClass="form-control" AllowMultiple="true"
                    onchange="handleFileSelection(this);" />
                <div id="fileListContainer"></div>
            </div>
        </div>

        <!-- Buttons -->
        <div class="col-md-12 text-center mt-3">
            <asp:Button ID="btnSave" runat="server" Text="Submit"
                CssClass="btn btn-primary btn-custom me-2"
                OnClick="btnSave_Click"
                ValidationGroup="SavePRS"
                OnClientClick="return validateAndNotify();" />

            <asp:Button ID="btnClear" runat="server" Text="Clear"
                CssClass="btn btn-secondary btn-custom"
                OnClick="btnClear_Click"
                CausesValidation="false" />
        </div>
    </div>

    <!-- Notification -->
    <div id="notification"></div>

    <!-- Popup -->
    <div id="supplierInfoPopup">
        <div id="popupContentWrapper">
            <span id="popupClose" onclick="closePopup()"></span>
            <div id="popupContent"></div>
        </div>
    </div>

   <script>
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

       // ---------- Notification ----------
       function showNotification(msg) {
           const notif = document.getElementById('notification');
           notif.innerText = msg;
           notif.style.display = 'block';
           notif.style.opacity = '1';
           setTimeout(() => {
               notif.style.opacity = '0';
               setTimeout(() => { notif.style.display = 'none'; }, 500);
           }, 1000);
       }

       // ---------- Form Validation ----------
       function validateAndNotify() {
           if (!Page_ClientValidate('SavePRS')) {
               showNotification("Please fill all required fields (*) before submitting.");
               return false;
           }

           if (!validateInvoiceRows()) {
               return false;
           }

           return true;
       }

       // ---------- Clear Form ----------
       function clearForm() {
           document.querySelectorAll('.form-control').forEach(i => i.value = '');
           selectedFiles = [];
           renderFileList(document.getElementById('<%= fuDocument.ClientID %>'));
       }
       document.getElementById('<%= btnClear.ClientID %>')?.addEventListener('click', clearForm);

    // ---------- Calculate Total ----------
    function calculateTotal() {
        const amounts = document.querySelectorAll('#invoiceTableBody .amount');
        let total = 0;
        amounts.forEach(input => {
            const val = parseFloat(input.value);
            if (!isNaN(val)) total += val;
        });
        document.getElementById('totalAmount').innerText = total.toFixed(2);
    }

    // ---------- Invoice Table ----------
       function setupInvoiceRowEvents() {
           // Amount fields
           document.querySelectorAll('#invoiceTableBody .amount').forEach(input => {
               input.onkeyup = calculateTotal;
           });

           // Date fields
           document.querySelectorAll('#invoiceTableBody input[type="date"]').forEach(input => {
               input.addEventListener('click', function () {
                   if (this.showPicker) this.showPicker();
               });
           });
       }
    function addInvoiceRow() {
        const tableBody = document.getElementById('invoiceTableBody');
        const row = document.createElement('tr');

        row.innerHTML = `
            <td class="slNo"></td>
            <td><input type="text" class="form-control billNo" name="billNo" placeholder="Bill Number" /></td>
            <td><input type="date" class="form-control billDate" name="billDate" /></td>
            <td><input type="date" class="form-control dueDate" name="dueDate" /></td>
            <td><input type="date" class="form-control billPeriodFrom" name="billPeriodFrom" /></td>
            <td><input type="date" class="form-control billPeriodTo" name="billPeriodTo" /></td>
            <td><input type="number" class="form-control amount" name="amount" placeholder="Invoice Amount" onkeyup="calculateTotal()" /></td>
            <td><input type="text" class="form-control natureOfExp small-input" name="natureOfExp" placeholder="Enter nature of expense or service" /></td>
            <td class="text-center actions"></td>
        `;

        tableBody.appendChild(row);
        setupInvoiceRowEvents();
        updateInvoiceActions();
    }

    function updateInvoiceActions() {
        const tableBody = document.getElementById('invoiceTableBody');
        const rows = tableBody.querySelectorAll('tr');

        rows.forEach((row, index) => {
            row.querySelector('.slNo').innerText = index + 1;

            const actionCell = row.querySelector('.actions');
            actionCell.innerHTML = '';

            // Add '+' only to last row
            if (index === rows.length - 1) {
                const addBtn = document.createElement('button');
                addBtn.type = 'button';
                addBtn.className = 'btn btn-success btn-sm me-1';
                addBtn.innerText = '+';
                addBtn.onclick = addInvoiceRow;
                actionCell.appendChild(addBtn);
            }

            // Add delete button if more than one row
            if (rows.length > 1) {
                const delBtn = document.createElement('button');
                delBtn.type = 'button';
                delBtn.className = 'btn btn-danger btn-sm';
                delBtn.innerText = '✖';
                delBtn.onclick = () => { deleteInvoiceRow(row); };
                actionCell.appendChild(delBtn);
            }
        });

        calculateTotal();
    }

    function deleteInvoiceRow(row) {
        row.remove();
        updateInvoiceActions();
    }

       function initializeInvoiceTable() {
           setupInvoiceRowEvents();
           updateInvoiceActions();
       }

    // ---------- Popup ----------
    function closePopup() {
        document.getElementById('supplierInfoPopup').style.display = 'none';
    }

    // ---------- Supplier Autocomplete ----------
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
       document.getElementById('supplierToggle').addEventListener('click', function () {
           showSupplierDropdown(mainSupplierInput.value);
           mainSupplierInput.focus();
       });

       document.addEventListener('click', function (e) {
           if (!mainSupplierInput.contains(e.target) && !mainSupplierDropdown.contains(e.target) && e.target.id !== 'supplierToggle')
               mainSupplierDropdown.style.display = 'none';
       });

       // ---------- Date Picker Fix for Chrome/Edge ----------
       document.querySelectorAll('input[type="date"]').forEach(function (el) {
           el.addEventListener('click', function () {
               if (this.showPicker) this.showPicker();
           });
       });

       // ---------- Initialize on page load ----------
       document.addEventListener('DOMContentLoaded', () => {
           initializeInvoiceTable();

           if (window.invoiceData && window.invoiceData.length > 0) {
               const tbody = document.getElementById('invoiceTableBody');
               tbody.innerHTML = '';

               window.invoiceData.forEach(data => {
                   const row = document.createElement('tr');
                   row.innerHTML = `
                <td class="slNo"></td>
                <td><input type="text" class="form-control billNo" name="billNo" value="${data.billNo || ''}"/></td>
                <td><input type="date" class="form-control billDate" name="billDate" value="${data.billDate || ''}"/></td>
                <td><input type="date" class="form-control dueDate" name="dueDate" value="${data.dueDate || ''}"/></td>
                <td><input type="date" class="form-control billPeriodFrom" name="billPeriodFrom" value="${data.from || ''}"/></td>
                <td><input type="date" class="form-control billPeriodTo" name="billPeriodTo" value="${data.to || ''}"/></td>
                <td><input type="number" class="form-control amount" name="amount" value="${data.amount || ''}" onkeyup="calculateTotal()"/></td>
                <td><input type="text" class="form-control natureOfExp" name="natureOfExp" value="${data.nature || ''}"/></td>
                <td class="text-center actions"></td>
            `;
                   tbody.appendChild(row);
               });

               updateInvoiceActions();
           }
       });

       function validateInvoiceRows() {

           const rows = document.querySelectorAll('#invoiceTableBody tr');
           let isValid = true;

           let billMap = {};
           let duplicateRows = [];
           let errorRows = [];

           // 🔁 Single loop (clean & correct)
           rows.forEach((row, index) => {

               const billNoInput = row.querySelector('.billNo');
               const dueDateInput = row.querySelector('.dueDate');
               const amountInput = row.querySelector('.amount');
               const natureInput = row.querySelector('.natureOfExp');

               const billNo = billNoInput.value.trim();
               const dueDate = dueDateInput.value.trim();
               const amount = amountInput.value.trim();
               const nature = natureInput.value.trim();

               // 🔄 Reset styles
               row.querySelectorAll('input').forEach(i => i.classList.remove('border-danger'));

               let rowHasError = false;

               // ✅ Required validations
               if (!billNo) {
                   isValid = false;
                   rowHasError = true;
                   billNoInput.classList.add('border-danger');
               }

               if (!dueDate) {
                   isValid = false;
                   rowHasError = true;
                   dueDateInput.classList.add('border-danger');
               }

               if (!amount || parseFloat(amount) <= 0) {
                   isValid = false;
                   rowHasError = true;
                   amountInput.classList.add('border-danger');
               }

               if (!nature) {
                   isValid = false;
                   rowHasError = true;
                   natureInput.classList.add('border-danger');
               }

               // ✅ Track error rows
               if (rowHasError) {
                   errorRows.push(index + 1);
               }

               // ✅ Duplicate check (CORRECT)
               if (billNo) {
                   const key = billNo.toLowerCase();

                   if (billMap[key] !== undefined) {

                       isValid = false;

                       // mark both rows
                       billNoInput.classList.add('border-danger');
                       rows[billMap[key]].querySelector('.billNo').classList.add('border-danger');

                       duplicateRows.push(index + 1);
                       duplicateRows.push(billMap[key] + 1);

                   } else {
                       billMap[key] = index;
                   }
               }
           });

           // 🧠 Remove duplicates in row numbers
           const uniqueDuplicateRows = [...new Set(duplicateRows)];
           const uniqueErrorRows = [...new Set(errorRows)];

           // 🎯 Show message priority: Duplicate > Required
           if (uniqueDuplicateRows.length > 0) {
               showNotification("Duplicate Bill Numbers at Rows: " + uniqueDuplicateRows.join(', '));
           }
           else if (!isValid) {
               showNotification("Please fill required fields at Rows: " + uniqueErrorRows.join(', '));
           }

           return isValid;
       }

   </script>
</asp:Content>