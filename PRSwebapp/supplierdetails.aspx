<%@ Page Title="Supplier PO Entry" Language="C#" MasterPageFile="~/SiteMaster.Master"
    AutoEventWireup="true" CodeBehind="supplierdetails.aspx.cs" Inherits="PRSwebapp.supplier_details" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .form-card { 
            background: linear-gradient(180deg, #ffffff, #e6e0ff); 
            border-radius: 12px; padding: 30px; max-width: 1000px; 
            margin: 30px auto; box-shadow: 0 6px 18px rgba(0,0,0,0.12); border: 1px solid rgba(108,92,231,0.3); 
        }
        .form-card h2 { text-align:center; color:#6c5ce7; margin-bottom:25px; font-weight:bold; }
        .form-label { font-weight:500; color:#5a3fb5; font-size:14px; }
        .form-control, .form-check-input { border-radius:6px; border:1px solid #6c5ce7; box-sizing: border-box; width:100%; }
        .btn-custom { border-radius:6px; padding:8px 18px; font-weight:500; }
        .month-panel { border:1px solid #ddd; padding:8px; position:absolute; z-index:100; display:none; border-radius:5px; width:220px; background:#fff; box-shadow:0 4px 12px rgba(0,0,0,0.08); }
        .combo-container { position:relative; display:flex; }
        .combo-input { flex:1; width:100%; }
        .combo-toggle { border:1px solid #6c5ce7; background:#fff; cursor:pointer; padding:0 8px; height:36px; display:inline-flex; align-items:center; justify-content:center; }
        .dropdown-list { list-style:none; padding:0; margin:0; border:1px solid #6c5ce7; max-height:150px; overflow-y:auto; display:none; position:absolute; background:white; width:100%; z-index:1000; }
        .dropdown-list li { padding:5px 10px; cursor:pointer; }
        .dropdown-list li.highlight { background-color:#e6e0ff; }
        .highlight-text { font-weight:bold; background-color:#dcd6ff; }
        .po-radio input[type="radio"] { accent-color: black; width: 15px; height: 15px; margin-right: 6px; border: none; background: none; box-shadow: none; }
        .po-radio { font-weight: 500; color: #000; font-size: 13px; margin-right: 20px; }

        /* Popup */
        #supplierInfoPopup { position: fixed; top:0; left:0; width:100vw; height:100vh; background: rgba(0,0,0,0.6); z-index:9999; display:none; justify-content:center; align-items:center; }
        #popupContentWrapper { background:#fff; border-radius:12px; width:95%; max-width:1200px; max-height:85vh; overflow:auto; padding:20px; position:relative; box-shadow:0 8px 25px rgba(0,0,0,0.3); animation: popupFadeIn 0.3s ease; }
        #popupClose { position:absolute; top:10px; right:15px; cursor:pointer; font-weight:bold; color:#6c5ce7; font-size:20px; }
        #popupContentWrapper table { width:100%; border-collapse:collapse; font-size:13px; }
        #popupContentWrapper th, #popupContentWrapper td { border:1px solid #6c5ce7; padding:6px 8px; text-align:left; }
        #popupContentWrapper td.numeric { text-align:right; }
        #popupContentWrapper tr:hover { background-color: #f0ecff; }

        @keyframes popupFadeIn { from { opacity:0; transform:scale(0.95); } to { opacity:1; transform:scale(1); } }

        .small-input { font-size:13px; }
        .search-icon-container { position: relative; display: flex; align-items: center; }
        .search-icon-container .search-icon { position:absolute; right:35px; font-size:14px; color:#6c5ce7; cursor:pointer; }
        #popupContentWrapper input.form-control-sm { width:150px; margin-right:10px; }
        .badge { padding:0.35em 0.6em; font-size:0.75em; font-weight:500; }
        .bg-success { background-color:#28a745; color:#fff; }
        .bg-secondary { background-color:#6c757d; color:#fff; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />

    <div class="form-card">
        <h2>Supplier Purchase Order Entry</h2>
        <div class="row g-3">
            <!-- Supplier Name -->
            <div class="col-md-4 position-relative">
                <label class="form-label">Supplier Name</label>
                <div class="combo-container search-icon-container">
                    <asp:TextBox ID="txtSupplierCombo" runat="server" CssClass="form-control combo-input small-input" Placeholder="Supplier Name"></asp:TextBox>
                    <span class="search-icon" id="supplierSearchIcon">&#128269;</span>
                    <button type="button" class="combo-toggle" id="supplierToggle">&#9662;</button>
                </div>
                <ul id="supplierDropdown" class="dropdown-list"></ul>

                <!-- Popup -->
                <div id="supplierInfoPopup">
                    <div id="popupContentWrapper">
                        <span id="popupClose" onclick="closePopup()">✖</span>
                        <div id="popupContent"></div>
                    </div>
                </div>
            </div>

            <!-- Department -->
            <div class="col-md-4 position-relative">
                <label class="form-label">Department</label>
                <div class="combo-container">
                    <asp:TextBox ID="txtDepartmentCombo" runat="server" CssClass="form-control combo-input" Placeholder="Department Name"></asp:TextBox>
                    <button type="button" class="combo-toggle" id="deptToggle">&#9662;</button>
                </div>
                <ul id="departmentDropdown" class="dropdown-list"></ul>
            </div>

            <!-- PO Number & PO Date -->
            <div class="col-md-4">
                <label class="form-label">Ring Number</label>
                <asp:TextBox ID="txtRingNumber" runat="server" CssClass="form-control" placeholder="Ring Number" />
            </div>
            <div class="col-md-4">
                <label class="form-label">PO Number</label>
                <asp:TextBox ID="txtPONumber" runat="server" CssClass="form-control" placeholder="PO Number" />
            </div>
            <div class="col-md-4">
                <label class="form-label">PO Date</label>
                <asp:TextBox ID="txtPODate" runat="server" TextMode="Date" CssClass="form-control" />
            </div>
            <div class="col-md-4">
                <label class="form-label">PO Amount</label>
                <asp:TextBox ID="txtPOAmount" runat="server" CssClass="form-control" placeholder="Enter amount" onkeyup="formatAmount(this);" />
            </div>

            <!-- PO Payment Type -->
            <div class="col-md-4">
                <label class="form-label d-block">PO Payment Type</label>
                <asp:RadioButton ID="rbFixed" runat="server" GroupName="POAmountType" Text="Fixed" CssClass="po-radio" />
                <asp:RadioButton ID="rbUsage" runat="server" GroupName="POAmountType" Text="On Usage" CssClass="po-radio" />
            </div>

            <!-- Months -->
            <div class="col-md-4 position-relative">
                <label class="form-label">Payments Applicable (Months)</label>
                <asp:TextBox ID="txtMonths" runat="server" ReadOnly="true" CssClass="form-control" Placeholder="Select Months" OnClick="ToggleMonthDropdown();" />
                <asp:Panel ID="pnlMonthDropdown" runat="server" CssClass="month-panel">
                    <asp:CheckBoxList ID="chkListMonths" runat="server" RepeatDirection="Vertical">
                        <asp:ListItem Text="All" Value="All"></asp:ListItem>
                        <asp:ListItem Text="Jan" Value="Jan"></asp:ListItem>
                        <asp:ListItem Text="Feb" Value="Feb"></asp:ListItem>
                        <asp:ListItem Text="Mar" Value="Mar"></asp:ListItem>
                        <asp:ListItem Text="Apr" Value="Apr"></asp:ListItem>
                        <asp:ListItem Text="May" Value="May"></asp:ListItem>
                        <asp:ListItem Text="Jun" Value="Jun"></asp:ListItem>
                        <asp:ListItem Text="Jul" Value="Jul"></asp:ListItem>
                        <asp:ListItem Text="Aug" Value="Aug"></asp:ListItem>
                        <asp:ListItem Text="Sep" Value="Sep"></asp:ListItem>
                        <asp:ListItem Text="Oct" Value="Oct"></asp:ListItem>
                        <asp:ListItem Text="Nov" Value="Nov"></asp:ListItem>
                        <asp:ListItem Text="Dec" Value="Dec"></asp:ListItem>
                    </asp:CheckBoxList>
                </asp:Panel>
            </div>

            <div class="col-md-4">
                <label class="form-label">Invoice Amount</label>
                <asp:TextBox ID="txtInvoiceAmount" runat="server" CssClass="form-control" placeholder="Invoice Amount" onkeyup="formatAmount(this);" />
            </div>

            <div class="col-md-4">
                <label class="form-label">Agreement/Contract Validity</label>
                <asp:TextBox ID="txtValidity" runat="server" CssClass="form-control" TextMode="Date" />
            </div>
        </div>

        <div class="row mt-4">
            <div class="col-12 text-center">
                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-primary btn-custom me-2" OnClick="btnSave_Click" />
                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-secondary btn-custom" OnClientClick="clearForm(); return false;" />
            </div>
        </div>
    </div>

    <script type="text/javascript">
        // ---------- GLOBAL VARIABLES ----------
        var supplierItems = <%= new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(supplierItems) %>;
        var departmentItems = <%= new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(departmentItems) %>;

        // ---------- MONTH PANEL ----------
        function ToggleMonthDropdown() {
            var panel = document.getElementById('<%= pnlMonthDropdown.ClientID %>');
            panel.style.display = panel.style.display === 'block' ? 'none' : 'block';
        }
        function handleMonthSelection(chk) {
            var monthChecks = document.querySelectorAll('#<%= chkListMonths.ClientID %> input[type=checkbox]');
            if (chk.value === 'All') monthChecks.forEach(c => c.checked = chk.checked);
            else document.querySelector('#<%= chkListMonths.ClientID %> input[value="All"]').checked =
                Array.from(monthChecks).filter(c => c.value !== 'All').every(c => c.checked);
            var selected = Array.from(monthChecks).filter(c => c.checked && c.value !== 'All').map(c => c.value);
            document.getElementById('<%= txtMonths.ClientID %>').value = selected.join(',');
        }
        document.querySelectorAll('#<%= chkListMonths.ClientID %> input[type=checkbox]').forEach(c => c.addEventListener('click', function(){ handleMonthSelection(c); }));
        document.addEventListener('click', function(e){ 
            var panel = document.getElementById('<%= pnlMonthDropdown.ClientID %>');
            var input = document.getElementById('<%= txtMonths.ClientID %>');
            if(!panel.contains(e.target) && e.target!==input) panel.style.display='none';
        });

        // ---------- FORMAT AMOUNTS ----------
        function formatAmount(input) {
            let val = input.value.replace(/,/g,'').replace(/[^\d]/g,'');
            input.value = val==='' ? '' : parseInt(val).toLocaleString();
        }

        // ---------- CLEAR FORM ----------
        function clearForm() {
            document.querySelectorAll('.form-control').forEach(i => i.value='');
            document.querySelectorAll('input[type=radio]').forEach(r => r.checked=false);
            document.querySelectorAll('#<%= chkListMonths.ClientID %> input[type=checkbox]').forEach(c => c.checked=false);
            document.getElementById('<%= pnlMonthDropdown.ClientID %>').style.display='none';
            closePopup();
        }

        // ---------- POPUP ----------
        function closePopup(){ document.getElementById('supplierInfoPopup').style.display='none'; }

        document.getElementById('supplierSearchIcon').addEventListener('click', openPopup);
        document.getElementById('supplierToggle').addEventListener('click', function(){ showDropdown(mainSupplierInput.value); mainSupplierInput.focus(); });

        function openPopup(){
            var html='<div style="margin-bottom:15px; display:flex; gap:15px; flex-wrap:wrap; position:relative;">';
            html+='Supplier: <input type="text" id="popupSupplierName" class="form-control form-control-sm">';
            html+='<ul id="popupSupplierDropdown" class="dropdown-list" style="position:absolute; top:30px; left:0;"></ul>';
            html+='PO Date: <input type="date" id="popupPODate" class="form-control form-control-sm">';
            html+='Validity: <input type="date" id="popupPOValidity" class="form-control form-control-sm">';
            html+='</div><div id="popupTableContainer"><p>Start typing to search...</p></div>';
            document.getElementById('popupContent').innerHTML = html;
            document.getElementById('supplierInfoPopup').style.display='flex';

            var supplierInput = document.getElementById('popupSupplierName');
            var poDateInput = document.getElementById('popupPODate');
            var validityInput = document.getElementById('popupPOValidity');
            var dropdown = document.getElementById('popupSupplierDropdown');
            var currentFocus=-1;

            supplierInput.addEventListener('input', function(){
                dropdown.innerHTML=''; var val=supplierInput.value.toLowerCase();
                supplierItems.forEach(function(item){
                    if(!val || item.toLowerCase().includes(val)){
                        var li=document.createElement('li');
                        li.innerHTML=item.replace(new RegExp(val,'gi'), m=>'<span class="highlight-text">'+m+'</span>');
                        li.addEventListener('click', function(){ supplierInput.value=item; dropdown.style.display='none'; fetchFilteredData(); });
                        dropdown.appendChild(li);
                    }
                });
                dropdown.style.display=dropdown.childElementCount>0?'block':'none';
                fetchFilteredData();
            });

            supplierInput.addEventListener('keydown', function(e){
                var lis = dropdown.getElementsByTagName('li');
                if(e.keyCode===40){ currentFocus++; addActive(lis); }
                else if(e.keyCode===38){ currentFocus--; addActive(lis); }
                else if(e.keyCode===13){ e.preventDefault(); if(currentFocus>-1 && lis[currentFocus]){ supplierInput.value=lis[currentFocus].textContent; dropdown.style.display='none'; fetchFilteredData(); } currentFocus=-1; }
            });
            function addActive(lis){ removeActive(lis); if(lis.length===0) return; if(currentFocus>=lis.length) currentFocus=0; if(currentFocus<0) currentFocus=lis.length-1; lis[currentFocus].classList.add('highlight'); }
            function removeActive(lis){ Array.from(lis).forEach(li=>li.classList.remove('highlight')); }

            poDateInput.addEventListener('change', fetchFilteredData);
            validityInput.addEventListener('change', fetchFilteredData);

            function fetchFilteredData(){
                PageMethods.GetFilteredPOHistory(supplierInput.value, poDateInput.value, validityInput.value,
                    function(result){ renderTable(result); }, function(err){ console.error(err); });
            }
            function renderTable(data){
                var container=document.getElementById('popupTableContainer');
                if(!data || data.length===0){ container.innerHTML='<p>No PO history found.</p>'; return; }
                var html='<table><thead><tr>';
                for(let key in data[0]) html+='<th>'+key+'</th>';
                html+='</tr></thead><tbody>';
                data.forEach(function(row){
                    html+='<tr>';
                    for(let key in row){
                        let cls=key.toLowerCase().includes('amount')?' class="numeric"':'';
                        if(key==='ProcessStatus'){
                            var status=row[key]||'Not Processed';
                            var colorClass=status==='Processed'?'bg-success':'bg-secondary';
                            html+='<td><span class="badge '+colorClass+'">'+status+'</span></td>';
                        } else {
                            html+='<td contenteditable="true"'+cls+' onblur="updateCell(this,\''+key+'\',\''+row['ID']+'\')">'+row[key]+'</td>';
                        }
                    }
                    html+='</tr>';
                });
                html+='</tbody></table>'; container.innerHTML=html;
            }
        }

        function updateCell(td,key,id){
            PageMethods.UpdatePOCell(id,key,td.innerText,
                function(result){ console.log('Updated'); }, function(err){ console.error(err); });
        }

        

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


        // ---------- DEPARTMENT AUTOCOMPLETE ----------
        var deptInput = document.getElementById('<%= txtDepartmentCombo.ClientID %>');
        var deptDropdown = document.getElementById('departmentDropdown');
        var departmentItems = <%= new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(departmentItems) %>;
        var deptFocus = -1;

        function showDepartmentDropdown(filter) {
            deptDropdown.innerHTML = '';
            departmentItems.forEach(function (item) {
                if (!filter || item.toLowerCase().includes(filter.toLowerCase())) {
                    var li = document.createElement('li');
                    li.innerHTML = item.replace(new RegExp(filter, 'gi'), m => '<span class="highlight-text">' + m + '</span>');
                    li.addEventListener('click', function () { deptInput.value = item; deptDropdown.style.display = 'none'; });
                    deptDropdown.appendChild(li);
                }
            });
            deptDropdown.style.display = deptDropdown.childElementCount > 0 ? 'block' : 'none';
        }

        deptInput.addEventListener('input', function () { showDepartmentDropdown(deptInput.value); deptFocus = -1; });

        deptInput.addEventListener('keydown', function (e) {
            var lis = deptDropdown.getElementsByTagName('li');
            if (e.keyCode == 40) { deptFocus++; addDeptActive(lis); }
            else if (e.keyCode == 38) { deptFocus--; addDeptActive(lis); }
            else if (e.keyCode == 13) { e.preventDefault(); if (deptFocus > -1 && lis[deptFocus]) { deptInput.value = lis[deptFocus].textContent; deptDropdown.style.display = 'none'; } deptFocus = -1; }
        });
        function addDeptActive(lis) { removeDeptActive(lis); if (lis.length == 0) return; if (deptFocus >= lis.length) deptFocus = 0; if (deptFocus < 0) deptFocus = lis.length - 1; lis[deptFocus].classList.add('highlight'); }
        function removeDeptActive(lis) { Array.from(lis).forEach(li => li.classList.remove('highlight')); }

        document.getElementById('deptToggle').addEventListener('click', function () { showDepartmentDropdown(deptInput.value); deptInput.focus(); });
        document.addEventListener('click', function (e) { if (!deptInput.contains(e.target) && !deptDropdown.contains(e.target) && e.target.id !== 'deptToggle') deptDropdown.style.display = 'none'; });

    </script>
</asp:Content>