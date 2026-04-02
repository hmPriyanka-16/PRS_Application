<%@ Page Title="Employee Claim" Language="C#" MasterPageFile="~/SiteMaster.Master"
    AutoEventWireup="true" CodeBehind="EmpClaim.aspx.cs" Inherits="PRSwebapp.EmpClaim"
    UnobtrusiveValidationMode="None" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body {    
            background-color: #f5f6fa; 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 13px;
        }
        .form-card { 
            background: linear-gradient(180deg, #ffffff, #e6e0ff);
            border-radius: 12px; 
            padding: 20px; 
            max-width: 1100px; 
            margin: 20px auto; 
            box-shadow: 0 6px 18px rgba(0,0,0,0.12); 
            border: 1px solid rgba(108,92,231,0.3); 
        }
        .form-title { 
            font-weight: bold;
            font-size: 18px;
            text-align: center; 
            margin-bottom: 20px; 
            color: #6c5ce7;
        }
        label, .form-label { 
            font-weight: 500; 
            color:#5a3fb5; 
            font-size:12px;
        }
        .form-control, .form-check-input { 
            border-radius:6px; 
            border:1px solid #6c5ce7; 
            box-sizing: border-box; 
            width:100%; 
            font-size:12px; 
            padding: 3px 6px;
        }
        .form-control-sm {
            padding: 2px 6px;
            font-size: 11px;
        }
        .btn, .btn-custom { 
            border-radius:6px; 
            padding:5px 12px; 
            font-weight:500; 
            font-size:12px; 
        }
        .btn-headercolor {
            background-color: #6c5ce7; 
            color: #fff;
            border: none;
        }
        .btn-headercolor:hover {
            background-color: #5941c1;
            color: #fff;
        }
        .section-title { 
            font-size:16px; 
            font-weight:600; 
            color: #0d6efd; 
            margin-bottom: 10px; 
            border-bottom: 1px solid #eee; 
            padding-bottom: 4px; 
        }
        .nav-tabs .nav-link { 
            font-weight: 600; 
            color: #495057; 
            font-size:12px; 
        }
        .nav-tabs .nav-link.active { 
            background-color: #0d6efd; 
            color: #fff !important; 
            border-radius: 6px 6px 0 0; 
        }
        .btn-delete { 
            color: #fff; 
            background-color: #dc3545; 
            border: none; 
            padding: 2px 6px; 
            border-radius: 4px; 
            font-size:12px;
        }
        table th, table td { 
            font-size:12px; 
            padding: 4px 6px;
            text-align: center;
        }
        .tab-content { margin-top: 15px; }
        .upload-half {
            width: 50%;
        }
        .save-center {
            text-align: center;
            margin-top: 10px;
        }
        .btn-plus {
            font-size: 12px;        
            width: 22px;            
            height: 22px;           
            padding: 0;             
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 4px;
            color: #ffffff !important;
            background-color: #ff0000 !important;
            border: none;
        }
        #fileListContainer div,
        #expenseContainer div,
        #advanceContainer div,
        #localContainer div {
            display: flex; 
            align-items: center; 
            gap: 6px; 
            margin-top: 4px;
        }
        #fileListContainer span,
        #expenseContainer span,
        #advanceContainer span,
        #localContainer span {
            font-size: 12px; 
            word-break: break-all;
        }
        #fileListContainer button,
        #expenseContainer button,
        #advanceContainer button,
        #localContainer button {
            font-size: 10px; 
            width: 18px; 
            height: 18px; 
            padding: 0; 
            border-radius: 50%; 
            display: inline-flex; 
            align-items: center; 
            justify-content: center;
        }
        .error-star {
            color: red;
            font-weight: bold;
            margin-left: 2px;
        }
    @keyframes blinkAnimation {
    0%, 50%, 100% { color: red; }
    25%, 75% { color: orange; }
}

.blink {
    animation: blinkAnimation 1s infinite;
}
/* Prevent horizontal expansion */
#tblIndividual {
    table-layout: fixed;
    width: 100%;
}

#tblIndividual th,
#tblIndividual td {
    word-wrap: break-word;
    overflow-wrap: break-word;
}

#tblIndividual input {
    width: 100%;
    box-sizing: border-box;
}
/* FIX: Keep action buttons side by side */
#tblConveyance td:last-child {
    white-space: nowrap;
}

#tblConveyance td:last-child button {
    display: inline-block;
    vertical-align: middle;
}
    </style>

    <script>
        // ---- Serialize table rows into JSON ----
        function serializeTable(tableId) {

            let rows = document.querySelectorAll(`#${tableId} tr`);
            let data = [];

            rows.forEach(row => {

                let inputs = row.querySelectorAll("input");

                if (inputs.length > 0) {

                    // Expense Table
                    if (tableId === "tblExpense") {

                        data.push({
                            Particulars: inputs[0].value,
                            Purpose: inputs[1].value,
                            BillNo: inputs[2].value,
                            BillDate: inputs[3].value,
                            Amount: inputs[4].value
                        });

                    }

                    // Conveyance Table
                    else if (tableId === "tblConveyance") {

                        data.push({
                            Purpose: inputs[0].value,
                            FromLocation: inputs[1].value,
                            ToLocation: inputs[2].value,
                            Mode: inputs[3].value,
                            Distance: inputs[4].value,
                            Amount: inputs[5].value
                        });

                    }

                    // ✅ Individual PRS Table
                    else if (tableId === "tblIndividual") {

                        data.push({
                            Particulars: inputs[0].value,
                            Purpose: inputs[1].value,
                            BillNo: inputs[2].value,
                            BillDate: inputs[3].value,
                            Comments: inputs[4].value,
                            Amount: inputs[5].value
                        });

                    }
                }

            });

            return JSON.stringify(data);
        }
        // ---- Validate tables and populate hidden fields ----
        // ---- For Expense Tab Only ----
        function prepareExpenseFields() {
            let valid = true;
            document.querySelectorAll("#tblExpense tr").forEach((row) => {
                row.querySelectorAll("input").forEach((input) => {
                    if (!input.value.trim()) {
                        valid = false;
                        input.style.border = "1px solid red";
                        if (!row.querySelector(".error-star")) {
                            const star = document.createElement("span");
                            star.innerText = "*";
                            star.className = "error-star";
                            input.parentNode.appendChild(star);
                        }
                    } else {
                        input.style.border = "1px solid #6c5ce7";
                        const star = row.querySelector(".error-star");
                        if (star) star.remove();
                    }
                });
            });

            if (!valid) alert("Please fill all required fields in Expense table.");
            if (valid) document.getElementById('<%= hfExpenseData.ClientID %>').value = serializeTable("tblExpense");
            return valid;
        }

        // ---- For Conveyance Tab Only ----
        function prepareConveyanceFields() {
            let valid = true;
            document.querySelectorAll("#tblConveyance tr").forEach((row) => {
                row.querySelectorAll("input").forEach((input) => {
                    if (!input.value.trim()) {
                        valid = false;
                        input.style.border = "1px solid red";
                        if (!row.querySelector(".error-star")) {
                            const star = document.createElement("span");
                            star.innerText = "*";
                            star.className = "error-star";
                            input.parentNode.appendChild(star);
                        }
                    } else {
                        input.style.border = "1px solid #6c5ce7";
                        const star = row.querySelector(".error-star");
                        if (star) star.remove();
                    }
                });
            });

            if (!valid) alert("Please fill all required fields in Conveyance table.");
            if (valid) document.getElementById('<%= hfConveyanceData.ClientID %>').value = serializeTable("tblConveyance");
            return valid;
        }


        function prepareHiddenFields() {
            let expenseValid = validateExpenseRows();
            let conveyValid = validateConveyanceRows();
            if (!expenseValid || !conveyValid) {
                alert("Please fill all required fields in Expense and Conveyance tables.");
                return false;
            }
            document.getElementById('<%= hfExpenseData.ClientID %>').value = serializeTable("tblExpense");
            document.getElementById('<%= hfConveyanceData.ClientID %>').value = serializeTable("tblConveyance");
            return true;
        }

        // ---- Dynamic Expense Rows ----
        function addExpenseRow(particulars = '', purpose = '', billNo = '', billDate = '', amount = '') {

            var table = document.getElementById("tblExpense");

            // Remove existing plus buttons
            document.querySelectorAll("#tblExpense .btn-plus").forEach(btn => btn.remove());

            var row = table.insertRow(-1);

            row.innerHTML = `
        <td class='slno'></td>
        <td><input type='text' class='form-control' value='${particulars}' /></td>
        <td><input type='text' class='form-control' value='${purpose}' /></td>
        <td><input type='text' class='form-control' value='${billNo}' /></td>
        <td><input type='date' class='form-control' value='${billDate}' /></td>
        <td><input type='number' step='0.01' class='form-control amount-input'
                value='${amount}' oninput='updateExpenseTotal()'/></td>
        <td>
            <button type='button'
                class='btn btn-plus me-1'
                onclick='addExpenseRow()'>➕</button>

            <button type='button'
                class='btn-delete'
                onclick='deleteExpenseRow(this)'>✖</button>
        </td>`;

            updateExpenseSLNO();
            updateExpenseTotal();
            refreshPlusButton("tblExpense", "addExpenseRow");
        }

        function deleteExpenseRow(btn) {

            let tbody = document.getElementById("tblExpense");

            if (tbody.rows.length > 1)
                btn.closest("tr").remove();

            updateExpenseSLNO();
            updateExpenseTotal();

            refreshPlusButton("tblExpense", "addExpenseRow");
        }

        function updateExpenseSLNO() {
            document.querySelectorAll("#tblExpense tr").forEach((row, i) => row.querySelector(".slno").innerText = i + 1);
        }

        function updateExpenseTotal() {
            let total = 0;

            // Sum all expense amounts
            document.querySelectorAll('.amount-input').forEach(input => {
                let val = parseFloat(input.value);
                if (!isNaN(val)) total += val;
            });

            // Get advance taken
            let advanceVal = parseFloat(document.getElementById('advanceTaken').value);
            let advance = isNaN(advanceVal) ? 0 : advanceVal;

            // Update total
            document.getElementById('expenseTotal').innerText = total.toFixed(2);

            // Net payable (can be negative)
            let net = total - advance;
            document.getElementById('netPayable').innerText = net.toFixed(2);
        }



        // ---- Dynamic Conveyance Rows ----
        function addConveyanceRow(purpose = '', fromPlace = '', toPlace = '', mode = '', distance = '', amount = '') {

            var table = document.getElementById("tblConveyance");

            document.querySelectorAll("#tblConveyance .btn-plus").forEach(btn => btn.remove());

            var row = table.insertRow(-1);

            row.innerHTML = `
        <td class='slno'></td>
        <td><input type='text' class='form-control' value='${purpose}'/></td>
        <td><input type='text' class='form-control' value='${fromPlace}'/></td>
        <td><input type='text' class='form-control' value='${toPlace}'/></td>
        <td><input type='text' class='form-control' value='${mode}'/></td>
        <td><input type='text' class='form-control' value='${distance}'/></td>
        <td><input type='number' step='0.01'
                class='form-control conveyance-amount'
                value='${amount}'
                oninput='updateConveyanceTotal()'/></td>
        <td>
            <button type='button'
                class='btn btn-plus me-1'
                onclick='addConveyanceRow()'>➕</button>

            <button type='button'
                class='btn-delete'
                onclick='deleteConveyanceRow(this)'>✖</button>
        </td>`;

            updateConveyanceSLNO();
            updateConveyanceTotal();
            refreshPlusButton("tblConveyance", "addConveyanceRow");
        }

        function deleteConveyanceRow(btn) {

            let tbody = document.getElementById("tblConveyance");

            if (tbody.rows.length > 1)
                btn.closest("tr").remove();

            updateConveyanceSLNO();
            updateConveyanceTotal();

            refreshPlusButton("tblConveyance", "addConveyanceRow");
        }

        function updateConveyanceSLNO() {
            document.querySelectorAll("#tblConveyance tr").forEach((row, i) => row.querySelector(".slno").innerText = i + 1);
        }

        function updateConveyanceTotal() {
            let total = 0;
            document.querySelectorAll('.conveyance-amount').forEach(input => total += parseFloat(input.value) || 0);
            document.getElementById('conveyanceTotal').innerText = total.toFixed(2);
        }

        // ---- File Upload Handler ----
        let selectedFileGroups = { expense: [], advance: [], local: [], individual: [] };
        function handleFileSelection(input, type) {
            let container = document.getElementById(type + "Container");
            let filesArray = selectedFileGroups[type];
            const newFiles = Array.from(input.files);
            newFiles.forEach(file => {
                if (!filesArray.some(f => f.name === file.name && f.size === file.size)) filesArray.push(file);
            });
            renderFileList(type, input);
        }

        function renderFileList(type, input) {
            let container = document.getElementById(type + "Container");
            container.innerHTML = "";
            let filesArray = selectedFileGroups[type];
            filesArray.forEach((file, index) => {
                const row = document.createElement("div");
                row.innerHTML = `<span>${file.name}</span>
                    <button type="button" class="btn btn-sm btn-outline-danger">✖</button>`;
                row.querySelector("button").addEventListener("click", function () {
                    removeFile(type, index, input);
                });
                container.appendChild(row);
            });
            const dt = new DataTransfer();
            filesArray.forEach(f => dt.items.add(f));
            input.files = dt.files;
        }

        function removeFile(type, index, input) {
            selectedFileGroups[type].splice(index, 1);
            renderFileList(type, input);
        }

        window.onload = function () {
            addExpenseRow();
            addConveyanceRow();
            addIndividualRow();

        };
        function openAdvancePopup() {
            // Fetch data from server-side PageMethod
            PageMethods.GetAdvanceDetails(function (result) {
                let tableBody = document.getElementById("advanceTableBody");
                tableBody.innerHTML = ""; // Clear previous rows

                result.forEach(item => {
                    let row = document.createElement("tr");
                    row.innerHTML = `
                <td>
                    <input type="checkbox" class="advance-select" 
                           data-prsno="${item.PRSNo}" 
                           data-amount="${parseFloat(item.Inoviceamount).toFixed(2)}" />
                </td>
                <td>${item.PRSNo}</td>
                <td>${item.PRSdate}</td>
                <td>${parseFloat(item.Inoviceamount).toFixed(2)}</td>`;
                    tableBody.appendChild(row);
                });

                // Show modal
                let modal = new bootstrap.Modal(document.getElementById('advanceModal'));
                modal.show();

            }, function (error) {
                alert("Error loading advance data.");
            });
        }

        function applySelectedAdvances() {

            let total = 0;
            let selectedList = [];

            document.querySelectorAll(".advance-select:checked").forEach(cb => {

                let prsNo = cb.getAttribute("data-prsno");
                let amount = parseFloat(cb.getAttribute("data-amount")) || 0;

                total += amount;

                selectedList.push({
                    PRSNo: prsNo,
                    Amount: amount
                });
            });

            // Fill Advance Taken textbox
            document.getElementById("advanceTaken").value = total.toFixed(2);

            // Store selected advances in hidden field
            document.getElementById('<%= hfSelectedAdvances.ClientID %>').value =
                JSON.stringify(selectedList);

            updateExpenseTotal();

            // Close modal
            bootstrap.Modal.getInstance(document.getElementById('advanceModal')).hide();
        }
        // -------- Individual PRS --------

        function addIndividualRow(particulars = '', purpose = '', billNo = '', billDate = '', comments = '', amount = '') {

            var table = document.getElementById("tblIndividual");

            document.querySelectorAll("#tblIndividual .btn-plus").forEach(btn => btn.remove());

            var row = table.insertRow(-1);

            row.innerHTML = `
        <td class='slno'></td>
        <td><input type='text' class='form-control' value='${particulars}' /></td>
        <td><input type='text' class='form-control' value='${purpose}' /></td>
        <td><input type='text' class='form-control' value='${billNo}' /></td>
        <td><input type='date' class='form-control' value='${billDate}' /></td>
        <td><input type='text' class='form-control' value='${comments}' /></td>
        <td><input type='number' step='0.01'
                class='form-control individual-amount'
                value='${amount}'
                oninput='updateIndividualTotal()'/></td>
        <td>
            <button type='button'
                class='btn btn-plus me-1'
                onclick='addIndividualRow()'>➕</button>

            <button type='button'
                class='btn-delete'
                onclick='deleteIndividualRow(this)'>✖</button>

        </td>`;

            updateIndividualSLNO();
            updateIndividualTotal();
            refreshPlusButton("tblIndividual", "addIndividualRow");
        }

        function deleteIndividualRow(btn) {

            let tbody = document.getElementById("tblIndividual");

            if (tbody.rows.length > 1)
                btn.closest("tr").remove();

            updateIndividualSLNO();
            updateIndividualTotal();

            refreshPlusButton("tblIndividual", "addIndividualRow");
        }

        function updateIndividualSLNO() {
            document.querySelectorAll("#tblIndividual tr")
                .forEach((row, i) =>
                    row.querySelector(".slno").innerText = i + 1);
        }

        function updateIndividualTotal() {
            let total = 0;
            document.querySelectorAll(".individual-amount")
                .forEach(input => total += parseFloat(input.value) || 0);

            document.getElementById("individualTotal").innerText = total.toFixed(2);
        }

        function prepareIndividualFields() {

            let valid = true;

            document.querySelectorAll("#tblIndividual tr").forEach((row) => {
                row.querySelectorAll("input").forEach((input) => {
                    if (!input.value.trim()) {
                        valid = false;
                        input.style.border = "1px solid red";
                    } else {
                        input.style.border = "1px solid #6c5ce7";
                    }
                });
            });

            if (!valid) {
                alert("Please fill all required fields in Individual PRS.");
                return false;
            }

            document.getElementById('<%= hfIndividualData.ClientID %>').value =
                serializeTable("tblIndividual");

            return true;
        }
        function refreshPlusButton(tableId, addFunctionName) {

            let rows = document.querySelectorAll(`#${tableId} tr`);

            // Remove all existing plus buttons
            document.querySelectorAll(`#${tableId} .btn-plus`).forEach(btn => btn.remove());

            if (rows.length === 0) return;

            let lastRow = rows[rows.length - 1];
            let actionCell = lastRow.querySelector("td:last-child");

            if (!actionCell) return;

            let plusBtn = document.createElement("button");
            plusBtn.type = "button";
            plusBtn.className = "btn btn-plus me-1";
            plusBtn.innerHTML = "➕";
            plusBtn.onclick = function () {
                window[addFunctionName]();
            };

            actionCell.prepend(plusBtn);
        }
        // Force calendar open when clicking anywhere inside date input
        document.addEventListener("click", function (e) {
            if (e.target && e.target.type === "date") {
                if (e.target.showPicker) {
                    e.target.showPicker();   // Works in Chrome / Edge
                }
            }
        });
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />

    <asp:HiddenField ID="hfExpenseData" runat="server" />
    <asp:HiddenField ID="hfConveyanceData" runat="server" />
    <asp:HiddenField ID="hfSelectedAdvances" runat="server" />


    <div class="container mt-4 mb-5">

        <ul class="nav nav-tabs" id="claimTabs">
            <li class="nav-item"><a class="nav-link active" data-bs-toggle="tab" href="#expenseTab">Expense Claim</a></li>
            <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#advanceTab">Advance Claim</a></li>
            <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#localTab">Local Conveyance</a></li>
            <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#individualTab">Individual PRS</a>
</li>
        </ul>

        <div class="tab-content mt-3">

                   <!-- Expense Tab -->
       
           <div class="tab-pane fade show active" id="expenseTab">
    <div class="section-title" style="
        background-color: #4CB39A; 
        color: #000; 
        padding: 3px 0; 
        border-radius: 8px; 
        font-weight: bold; 
        text-align: center; 
        display: flex; 
        justify-content: center; 
        align-items: center;
        font-size: 15px;">
        Expense Claim
    </div>
               <!-- Total Advance Display -->
<!-- Total Advance Display -->
<div id="advanceDisplay" style="
        color:red;
        font-weight:bold;
        text-align:center;
        margin-bottom:10px;
        font-size:14px;">
    Total Advance: <span id="totalAdvanceBlink" class="blink">0.00</span>
</div>

                <table class="table table-bordered">
                    <thead class="table-light">
                        <tr>
                            <th>SL No</th>
                            <th>Particulars</th>
                            <th>Purpose</th>
                            <th>Bill No</th>
                            <th>Bill Date</th>
                            <th>Amount</th>
                         <th style="text-align:center;">Action</th>
                        </tr>
                    </thead>
                    <tbody id="tblExpense"></tbody>
                   <tfoot>
    <tr>
<td colspan="6" style="text-align:right;">
    <strong>
    <a href="javascript:void(0);" onclick="openAdvancePopup()" 
       style="color:#6c5ce7; text-decoration:underline;">
        Advance Taken:
    </a>
</strong>
        </td>
        <td colspan="2">
            <input type="number" step="0.01" id="advanceTaken"
                   class="form-control form-control-sm"
                   value="0"
                   oninput="updateExpenseTotal()" />
        </td>
    </tr>

    <tr>
        <td colspan="5" style="text-align:right;">
            <strong>Total:</strong>
        </td>
        <td colspan="2" id="expenseTotal">0.00</td>
    </tr>

    <tr>
        <td colspan="5" style="text-align:right;">
            <strong>Net Payable:</strong>
        </td>
        <td colspan="2" id="netPayable">0.00</td>
    </tr>
</tfoot>

                </table>

                <div class="upload-half">
                    <asp:FileUpload ID="fuExpenseDocs" runat="server" CssClass="form-control"
                        AllowMultiple="true" onchange="handleFileSelection(this, 'expense');" />
                    <div id="expenseContainer"></div>
                </div>

                <div class="save-center">
<asp:Button ID="btnSaveExpense" runat="server" CssClass="btn btn-headercolor"
    Text="💾 Save" OnClientClick="return prepareExpenseFields();" OnClick="btnSaveExpense_Click" />

                </div>
            </div>

                             <!-- Advance Tab -->
<div class="tab-pane fade" id="advanceTab">
    <div class="section-title" style="
        background-color: #4CB39A; 
        color: #000; /* black font */
        padding: 3px 0; 
        border-radius: 8px; 
        font-weight: bold; 
        text-align: center; 
        display: flex; 
        justify-content: center; 
        align-items: center;
        font-size: 15px;">
        Advance Claim
    </div>

    <div class="row g-2 mb-2">
        <div class="col-md-4">
            <label class="form-label">
                Purpose
                <asp:RequiredFieldValidator ID="rfvAdvPurpose" runat="server"
                    ControlToValidate="txtAdvPurpose"
                    InitialValue=""
                    Text="*" ForeColor="Red" />
            </label>
            <asp:TextBox ID="txtAdvPurpose" placeholder="Purpose" runat="server" CssClass="form-control" />
        </div>

        <div class="col-md-4">
            <label class="form-label">
                Nature
                <asp:RequiredFieldValidator ID="rfvAdvNature" runat="server"
                    ControlToValidate="txtAdvNature"
                    InitialValue=""
                    Text="*" ForeColor="Red" />
            </label>
            <asp:TextBox ID="txtAdvNature" placeholder="Nature" runat="server" CssClass="form-control" />
        </div>

        <div class="col-md-4">
            <label class="form-label">
                Amount
                <asp:RequiredFieldValidator ID="rfvAdvAmount" runat="server"
                    ControlToValidate="txtAdvAmount"
                    InitialValue=""
                    Text="*" ForeColor="Red" />
            </label>
            <asp:TextBox ID="txtAdvAmount" placeholder="Amount" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row g-2 mb-2">
        <div class="col-md-12">
            <label class="form-label">
                Comments
                <asp:RequiredFieldValidator ID="rfvAdvComments" runat="server"
                    ControlToValidate="txtAdvComments"
                    InitialValue=""
                    Text="*" ForeColor="Red" />
            </label>
            <asp:TextBox ID="txtAdvComments" placeholder="Comments" runat="server" 
                CssClass="form-control" TextMode="MultiLine" Rows="3" />
        </div>

        <div class="upload-half">
<asp:FileUpload ID="fuAdvanceDocs"
    runat="server"
    CssClass="form-control"
    AllowMultiple="true"
    onchange="handleFileSelection(this, 'advance');" />            <div id="advanceContainer"></div>
        </div>
    </div>
  <div class="save-center">
<asp:Button ID="btnSaveAdvance"
            runat="server"
            CssClass="btn btn-primary"
            Text="Save"
            OnClick="btnSaveAdvance_Click" />
      </div>
</div>



               <!-- Local Conveyance Tab -->
             <div class="tab-pane fade" id="localTab">
    <div class="section-title" style="
        background-color: #4CB39A; 
        color: #000; /* black font */
        padding: 3px 0; 
        border-radius: 8px; 
        font-weight: bold; 
        text-align: center; 
        display: flex; 
        justify-content: center; 
        align-items: center;
        font-size: 15px;">
        Local Conveyance
    </div>

                <table class="table table-bordered">
                    <thead class="table-light">
                        <tr>
                            <th>SL No</th>
                            <th>Purpose</th>
                            <th>From</th>
                            <th>To</th>
                            <th>Mode</th>
                            <th>Distance</th>
                            <th>Amount</th>
                            <th style="text-align:center;">Action</th>
                        </tr>
                    </thead>
                    <tbody id="tblConveyance"></tbody>
                    <tfoot>
                        <tr>
                            <td colspan="6" style="text-align:right;"><strong>Total:</strong></td>
                            <td colspan="2" id="conveyanceTotal">0.00</td>
                        </tr>
                    </tfoot>
                </table>

                <div class="upload-half">
                    <asp:FileUpload ID="fuLocalDocs" runat="server" CssClass="form-control"
                        AllowMultiple="true" onchange="handleFileSelection(this, 'local');" />
                    <div id="localContainer"></div>
                </div>
                <div class="save-center">
              <asp:Button ID="btnSaveLocal" runat="server" CssClass="btn btn-headercolor"
    Text="💾 Save" OnClientClick="return prepareConveyanceFields();" OnClick="btnSaveLocal_Click" />


                </div>
            </div>

  <!-- Individual PRS Tab -->
<div class="tab-pane fade" id="individualTab">

    <div class="section-title" style="
        background-color: #4CB39A; 
        color: #000; 
        padding: 3px 0; 
        border-radius: 8px; 
        font-weight: bold; 
        text-align: center; 
        display: flex; 
        justify-content: center; 
        align-items: center;
        font-size: 15px;">
        Individual PRS
    </div>
  <!--  <div class="row g-2 mb-3">

    <div class="col-md-2">
        <label class="form-label">Payment Method</label>
        <select id="ddlPaymentMethod" class="form-control">
            <option value="">-- Select --</option>
            <option>Bank Transfer</option>
            <option>Cash</option>
            <option>UPI</option>
            <option>Cheque</option>
        </select>
    </div>

    <div class="col-md-2">
        <label class="form-label">Account Holder</label>
        <asp:TextBox ID="txtAccHolder" runat="server" CssClass="form-control" />
    </div>

    <div class="col-md-2">
        <label class="form-label">Bank</label>
        <asp:DropDownList ID="ddlBankName" runat="server" CssClass="form-control">
            <asp:ListItem Text="-- Select --" Value="" />
            <asp:ListItem>State Bank of India</asp:ListItem>
            <asp:ListItem>HDFC Bank</asp:ListItem>
            <asp:ListItem>ICICI Bank</asp:ListItem>
            <asp:ListItem>Axis Bank</asp:ListItem>
        </asp:DropDownList>
    </div>

    <div class="col-md-3">
        <label class="form-label">Account No</label>
        <asp:TextBox ID="txtAccountNo" runat="server" CssClass="form-control" />
    </div>

    <div class="col-md-3">
        <label class="form-label">IFSC Code</label>
        <asp:TextBox ID="txtIFSC" runat="server" CssClass="form-control" />
    </div>

</div> -->
    <div class="table-responsive">   <!-- IMPORTANT FIX -->
        <table class="table table-bordered table-sm">
            <thead class="table-light">
                <tr>
                    <th>SL No</th>
                    <th>Vendor/Contractor Name</th>
                    <th>Purpose</th>
                    <th>Bill No</th>
                    <th>Bill Date</th>
                    <th>Comments</th>
                    <th>Amount</th>
                    <th style="text-align:center;">Action</th>
                </tr>
            </thead>

            <tbody id="tblIndividual"></tbody>

           <tfoot>
    <tr>
        <td colspan="6" style="text-align:right;">
            <strong>Total:</strong>
        </td>
        <td id="individualTotal">0.00</td>
        <td></td>
    </tr>
</tfoot>
        </table>
    </div>

    <asp:HiddenField ID="hfIndividualData" runat="server" />

    <div class="upload-half">
    <asp:FileUpload ID="fuIndividualDocs"
        runat="server"
        CssClass="form-control"
        AllowMultiple="true"
        onchange="handleFileSelection(this, 'individual');" />
    <div id="individualContainer"></div>
</div>
    <div class="save-center">
        <asp:Button ID="btnSaveIndividual"
            runat="server"
            CssClass="btn btn-headercolor"
            Text="💾 Save"
            OnClientClick="return prepareIndividualFields();"
            OnClick="btnSaveIndividual_Click" />
    </div>

</div>
            
        </div>
    </div>

 <div class="modal fade" id="advanceModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Advance Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">

                <table class="table table-bordered table-sm">
                    <thead class="table-light">
                        <tr>
                            <th>Select</th>
                            <th>PRS No</th>
                            <th>PRS Date</th>
                            <th>Amount</th>
                        </tr>
                    </thead>
                    <tbody id="advanceTableBody">
                    </tbody>
                </table>

            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-primary" onclick="applySelectedAdvances()">Apply Selected</button>
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>

        </div>
    </div>
</div>


    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</asp:Content>