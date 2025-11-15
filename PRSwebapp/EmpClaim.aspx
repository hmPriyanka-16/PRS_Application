<%@ Page Title="Employee Claim" Language="C#" MasterPageFile="~/SiteMaster.Master"
    AutoEventWireup="true" CodeBehind="EmpClaim.aspx.cs" Inherits="PRSwebapp.EmpClaim" %>

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
            max-width: 1000px; 
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
        #fileListContainer div {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 3px;
        }
        #fileListContainer div { display: flex; align-items: center; margin-top: 4px; gap: 6px; }
        #fileListContainer span { font-size: 12px; word-break: break-all; }
        #fileListContainer button { font-size: 10px; width: 18px; height: 18px; padding: 0; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; }
        .total-box {
            margin-top: 5px;
            font-weight: bold;
            text-align: right;
        }

        /* Small + button style */
        .btn-plus {
            font-size: 12px;        
            width: 22px;            
            height: 22px;           
            padding: 0;             
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 4px;
        }

        /* Secondary button hover */
        .btn-secondary {
            background-color: #6c757d;  
            color: #fff;
            border: none;
            padding: 2px 6px;
            font-size: 12px;
            border-radius: 4px;
            transition: background-color 0.3s ease;
        }

        .btn-secondary:hover {
            background-color: #5941c1;  
            cursor: pointer;
        }
    </style>

    <script>
        let selectedFiles = [];

        // --- EXPENSE ROWS ---
        function addExpenseRow(particulars = '', purpose = '', billNo = '', billDate = '', amount = '') {
            var table = document.getElementById("tblExpense");
            var row = table.insertRow(-1);
            row.innerHTML = "<td><input type='text' class='form-control' value='" + particulars + "'/></td>" +
                "<td><input type='text' class='form-control' value='" + purpose + "'/></td>" +
                "<td><input type='text' class='form-control' value='" + billNo + "'/></td>" +
                "<td><input type='date' class='form-control' value='" + billDate + "'/></td>" +
                "<td><input type='number' step='0.01' class='form-control amount-input' value='" + amount + "' oninput='updateExpenseTotal()'/></td>" +
                "<td><button type='button' class='btn-delete' onclick='deleteExpenseRow(this)'>✖</button></td>";
            updateExpenseTotal();
        }

        function deleteExpenseRow(btn) {
            var table = btn.closest("tbody");
            if (table.rows.length > 1) {
                var row = btn.parentNode.parentNode;
                row.parentNode.removeChild(row);
            } else {
                alert("At least one row must be present.");
            }
            updateExpenseTotal();
        }

        function updateExpenseTotal() {
            var table = document.getElementById("tblExpense");
            var total = 0;
            table.querySelectorAll('.amount-input').forEach(input => {
                var val = parseFloat(input.value) || 0;
                total += val;
            });
            document.getElementById('expenseTotal').innerText = total.toFixed(2);
        }

        // --- LOCAL CONVEYANCE ROWS ---
        function addConveyanceRow(purpose = '', fromPlace = '', toPlace = '', mode = '', distance = '', amount = '') {
            var table = document.getElementById("tblConveyance");
            var row = table.insertRow(-1);
            row.innerHTML = "<td><input type='text' class='form-control' value='" + purpose + "'/></td>" +
                "<td><input type='text' class='form-control' value='" + fromPlace + "'/></td>" +
                "<td><input type='text' class='form-control' value='" + toPlace + "'/></td>" +
                "<td><input type='text' class='form-control' value='" + mode + "'/></td>" +
                "<td><input type='number' class='form-control' value='" + distance + "'/></td>" +
                "<td><input type='number' step='0.01' class='form-control conveyance-amount' value='" + amount + "' oninput='updateConveyanceTotal()'/></td>" +
                "<td><button type='button' class='btn-delete' onclick='deleteConveyanceRow(this)'>✖</button></td>";
            updateConveyanceTotal();
        }

        function deleteConveyanceRow(btn) {
            var table = btn.closest("tbody");
            if (table.rows.length > 1) {
                var row = btn.parentNode.parentNode;
                row.parentNode.removeChild(row);
            } else {
                alert("At least one row must be present.");
            }
            updateConveyanceTotal();
        }

        function updateConveyanceTotal() {
            var table = document.getElementById("tblConveyance");
            var total = 0;
            table.querySelectorAll('.conveyance-amount').forEach(input => {
                var val = parseFloat(input.value) || 0;
                total += val;
            });
            document.getElementById('conveyanceTotal').innerText = total.toFixed(2);
        }

        // --- FILE UPLOAD HANDLING ---
        function handleFileSelection(input) {
            const newFiles = Array.from(input.files);
            newFiles.forEach(file => {
                if (!selectedFiles.some(f => f.name === file.name && f.size === file.size))
                    selectedFiles.push(file);
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

        // --- CLEAR FUNCTIONS ---
        function clearExpenseForm() {
            document.getElementById("tblExpense").innerHTML = "";
            addExpenseRow();
            document.getElementById('expenseTotal').innerText = "0.00";
            selectedFiles = [];
            const fileInput = document.getElementById('fuExpense');
            fileInput.value = '';
            document.getElementById('fileListContainer').innerHTML = '';
        }

        function clearAdvanceForm() {
            document.getElementById('<%= txtAdvPurpose.ClientID %>').value = '';
            document.getElementById('<%= txtAdvNature.ClientID %>').value = '';
            document.getElementById('<%= txtAdvAmount.ClientID %>').value = '';
            document.getElementById('<%= txtAdvComments.ClientID %>').value = '';
        }

        function clearConveyanceForm() {
            document.getElementById("tblConveyance").innerHTML = "";
            addConveyanceRow();
            document.getElementById('conveyanceTotal').innerText = "0.00";
        }

        window.onload = function () {
            addExpenseRow();
            addConveyanceRow();
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="container mt-4 mb-5">

    <!-- EMPLOYEE DETAILS -->
    <div class="form-card">
        <div class="form-title">Employee Details</div>
        <div class="row g-2 mb-3">
            <div class="col-md-3"><label>Employee ID</label><asp:TextBox ID="txtEmpID" placeholder="Employee ID" runat="server" CssClass="form-control" /></div>
            <div class="col-md-3"><label>Name</label><asp:TextBox ID="txtName" placeholder="Name" runat="server" CssClass="form-control" /></div>
            <div class="col-md-3"><label>Department</label><asp:TextBox ID="txtDept" Placeholder="Department" runat="server" CssClass="form-control" /></div>
            <div class="col-md-3"><label>Designation</label><asp:TextBox ID="txtDesig" placeholder="Designation" runat="server" CssClass="form-control" /></div>
        </div>
        <div class="row g-2 mb-3">
            <div class="col-md-3"><label>Date</label><asp:TextBox ID="txtDate" runat="server" TextMode="Date" CssClass="form-control" /></div>
        </div>

        <!-- NAV TABS -->
        <ul class="nav nav-tabs" id="claimTabs">
            <li class="nav-item"><a class="nav-link active" data-bs-toggle="tab" href="#expenseTab">Expense Claim</a></li>
            <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#advanceTab">Advance Claim</a></li>
            <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#localTab">Local Conveyance</a></li>
        </ul>

        <div class="tab-content mt-3">

            <!-- EXPENSE CLAIM -->
            <div class="tab-pane fade show active" id="expenseTab">
                <div class="section-title">Expense Claim</div>
                <div class="table-responsive">
                <table class="table table-bordered">
                    <thead class="table-light">
                        <tr>
                            <th>Particulars</th>
                            <th>Purpose</th>
                            <th>Bill No</th>
                            <th>Bill Date</th>
                            <th>Amount</th>
                            <th style="display: flex; align-items: center; justify-content: center; gap: 4px;">
                                Action
                                <button type="button" class="btn btn-secondary btn-plus" onclick="addExpenseRow()">➕</button>
                            </th>
                        </tr>
                    </thead>
                    <tbody id="tblExpense"></tbody>
                    <tfoot>
                        <tr>
                            <td colspan="4" style="text-align:right;"><strong>Total:</strong></td>
                            <td colspan="2" id="expenseTotal">0.00</td>
                        </tr>
                    </tfoot>
                </table>
                </div>

                <div class="mb-2 d-flex align-items-center">
                    <input type="file" id="fuExpense" multiple class="form-control form-control-sm w-auto" style="max-width: 250px;" onchange="handleFileSelection(this)" />
                    <div id="fileListContainer" class="ms-3"></div>
                </div>

                <asp:Button ID="btnSaveExpense" runat="server" CssClass="btn btn-headercolor" Text="💾 Save" />
                <asp:Button ID="btnClearExpense" runat="server" CssClass="btn btn-secondary ms-2" Text="🧹 Clear" OnClientClick="clearExpenseForm(); return false;" />
            </div>

            <!-- ADVANCE CLAIM -->
            <div class="tab-pane fade" id="advanceTab">
                <div class="section-title">Advance Claim</div>
                <div class="row g-2 mb-2">
                    <div class="col-md-4"><label>Purpose</label><asp:TextBox ID="txtAdvPurpose" placeholder="Purpose" runat="server" CssClass="form-control" /></div>
                    <div class="col-md-4"><label>Nature Of Exp</label><asp:TextBox ID="txtAdvNature" placeholder="Nature Of Exp" runat="server" CssClass="form-control" /></div>
                    <div class="col-md-4"><label>Amount</label><asp:TextBox ID="txtAdvAmount" placeholder="Amount" runat="server" CssClass="form-control" /></div>
                </div>
                <div class="row g-2 mb-2">
                    <div class="col-md-12"><label>Comments</label><asp:TextBox ID="txtAdvComments" placeholder="Comments" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" /></div>
                </div>
                <asp:Button ID="btnSaveAdvance" runat="server" CssClass="btn btn-headercolor" Text="💾 Save" />
                <asp:Button ID="btnClearAdvance" runat="server" CssClass="btn btn-secondary ms-2" Text="🧹 Clear" OnClientClick="clearAdvanceForm(); return false;" />
            </div>

            <!-- LOCAL CONVEYANCE -->
            <div class="tab-pane fade" id="localTab">
                <div class="section-title">Local Conveyance</div>
                <div class="table-responsive">
                <table class="table table-bordered">
                    <thead class="table-light">
                        <tr>
                            <th>Purpose</th>
                            <th>From</th>
                            <th>To</th>
                            <th>Mode</th>
                            <th>Distance</th>
                            <th>Amount</th>
                            <th style="display: flex; align-items: center; justify-content: center; gap: 4px;">
                                Action
                                <button type="button" class="btn btn-secondary btn-plus" onclick="addConveyanceRow()">➕</button>
                            </th>
                        </tr>
                    </thead>
                    <tbody id="tblConveyance"></tbody>
                    <tfoot>
                        <tr>
                            <td colspan="5" style="text-align:right;"><strong>Total:</strong></td>
                            <td colspan="2" id="conveyanceTotal">0.00</td>
                        </tr>
                    </tfoot>
                </table>
                </div>
                <asp:Button ID="btnSaveLocal" runat="server" CssClass="btn btn-headercolor" Text="💾 Save" />
                <asp:Button ID="btnClearLocal" runat="server" CssClass="btn btn-secondary ms-2" Text="🧹 Clear" OnClientClick="clearConveyanceForm(); return false;" />
            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</asp:Content>
