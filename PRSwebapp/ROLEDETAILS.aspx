<%@ Page Title="Role Details"
    Language="C#"
    MasterPageFile="~/SiteMaster.Master"
    AutoEventWireup="true"
    CodeBehind="ROLEDETAILS.aspx.cs"
    Inherits="PRSwebapp.ROLEDETAILS" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        .supplier-page { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f4f9; padding: 20px 0; }
        .supplier-page .content-container { max-width: 1000px; margin: 0 auto; padding: 0 15px; }
        .supplier-page .supplier-card { background: linear-gradient(180deg, #ffffff, #e6e0ff); border-radius: 12px; padding: 20px; box-shadow: 0 6px 18px rgba(0,0,0,0.12); border: 1px solid rgba(108,92,231,0.3); }
        .supplier-page .page-title { text-align: center; font-size: 28px; font-weight: bold; color: #6c5ce7; margin-bottom: 25px; }
        .supplier-page .form-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; }
        .supplier-page .form-group { display: flex; flex-direction: column; position: relative; }
        .supplier-page .form-group label { font-weight: 500; color: #5a3fb5; margin-bottom: 6px; font-size: 14px; }
        .supplier-page .form-control, .supplier-page .status-dropdown { padding: 10px 12px; border-radius: 6px; border: 1px solid #6c5ce7; font-size: 14px; width: 100%; box-sizing: border-box; }
        .supplier-page .btn-group { grid-column: 1 / -1; display: flex; justify-content: center; gap: 20px; margin-top: 25px; }
        .supplier-page .btn { padding: 10px 28px; border-radius: 6px; border: none; font-weight: 500; cursor: pointer; background: linear-gradient(90deg, #4e3ec7, #8c61ff); color: #fff; transition: all 0.3s ease; }
        .supplier-page .btn:hover { background: linear-gradient(90deg, #3b2fc1, #6f49e6); transform: translateY(-2px); }
        .supplier-page .message { grid-column: 1 / -1; text-align: center; font-weight: 600; margin-bottom: 10px; color: green; font-size: 14px; }

        /* Department autocomplete styles */
        .combo-container { position: relative; }
        .combo-toggle { position: absolute; right: 5px; top: 50%; transform: translateY(-50%); border: none; background: transparent; cursor: pointer; }
        .dropdown-list { position: absolute; top: 100%; left: 0; width: 100%; max-height: 200px; overflow-y: auto; border: 1px solid #6c5ce7; background: #fff; z-index: 1000; display: none; list-style: none; padding: 0; margin: 0; border-radius: 4px; }
        .dropdown-list li { padding: 8px 12px; cursor: pointer; }
        .dropdown-list li.highlight, .dropdown-list li:hover { background-color: #e6e0ff; }
        .highlight-text { font-weight: bold; color: #6c5ce7; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="supplier-page">
        <div class="content-container">
            <div class="supplier-card">
                <div class="page-title">Employee Role Details</div>

                <div class="form-grid">
                    <!-- Employee Code -->
                    <div class="form-group">
                        <label>Employee Code</label>
                        <asp:TextBox ID="txtEmpCode"  Placeholder="Employee Code" runat="server" CssClass="form-control" />
                    </div>

                    <!-- Employee Name -->
                    <div class="form-group">
                        <label>Employee Name</label>
                        <asp:TextBox ID="txtEmpName" Placeholder="Employee Name" runat="server" CssClass="form-control" />
                    </div>

                    <!-- Email ID -->
                    <div class="form-group">
                        <label>Email ID</label>
                        <asp:TextBox ID="txtEmail"  Placeholder="Email ID" runat="server" CssClass="form-control" TextMode="Email" />
                    </div>

                    <!-- Phone Number -->
                    <div class="form-group">
                        <label>Phone Number</label>
                        <asp:TextBox ID="txtPhone"  Placeholder="Phone Number" runat="server" CssClass="form-control" MaxLength="10" />
                    </div>

                    <!-- PRS Role -->
                    <div class="form-group">
                        <label>PRS Role</label>
                        <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-control status-dropdown">
                            <asp:ListItem Text="-- Select Role --" Value="" />
                        </asp:DropDownList>
                    </div>

                    <!-- Hospital Dropdown -->
                    <div class="form-group">
                        <label>Hospital</label>
                        <asp:DropDownList ID="ddlHospital" runat="server" CssClass="form-control status-dropdown">
                            <asp:ListItem Text="-- Select Hospital --" Value="" />
                        </asp:DropDownList>
                    </div>

                    <!-- Department Autocomplete -->
                    <div class="form-group">
                        <label>Department</label>
                        <div class="combo-container search-icon-container">
                            <asp:TextBox ID="txtDepartmentCombo" runat="server" CssClass="form-control combo-input small-input" Placeholder="Department Name"></asp:TextBox>
                            <asp:HiddenField ID="hfDepartmentID" runat="server" />

                            <button type="button" class="combo-toggle" id="deptToggle">&#9662;</button>
                        </div>
                        <ul id="deptDropdown" class="dropdown-list"></ul>
                    </div>

                    <!-- Buttons -->
                    <div class="btn-group">
                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn" OnClick="btnSave_Click" />
                        <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn" CausesValidation="false" OnClick="btnClear_Click" />
                    </div>

                    <!-- Message -->
                    <div class="message">
                        <asp:Label ID="lblMessage" runat="server" />
                    </div>
                </div>
            </div>
        </div>
    </div>

   <script type="text/javascript">
       var deptInput = document.getElementById('<%= txtDepartmentCombo.ClientID %>');
       var deptHidden = document.getElementById('<%= hfDepartmentID.ClientID %>');
    var deptDropdown = document.getElementById('deptDropdown');
    var deptFocus = -1;

    // ✅ FULL department dictionary (Name → ID)
    var deptData = <%= new System.Web.Script.Serialization.JavaScriptSerializer()
        .Serialize(DepartmentDict) %>;

       function showDeptDropdown(filter) {
           deptDropdown.innerHTML = '';
           deptFocus = -1;

           for (var name in deptData) {
               if (!filter || name.toLowerCase().includes(filter.toLowerCase())) {

                   var li = document.createElement('li');
                   li.innerHTML = name;

                   li.onclick = function () {
                       deptInput.value = this.textContent;
                       deptHidden.value = deptData[this.textContent]; // ✅ SET ID
                       deptDropdown.style.display = 'none';
                   };

                   deptDropdown.appendChild(li);
               }
           }

           deptDropdown.style.display =
               deptDropdown.childElementCount > 0 ? 'block' : 'none';
       }

       // typing
       deptInput.addEventListener('input', function () {
           deptHidden.value = ''; // reset if user types manually
           showDeptDropdown(this.value);
       });

       // keyboard support
       deptInput.addEventListener('keydown', function (e) {
           var items = deptDropdown.getElementsByTagName('li');

           if (e.key === "ArrowDown") {
               deptFocus++;
           } else if (e.key === "ArrowUp") {
               deptFocus--;
           } else if (e.key === "Enter") {
               e.preventDefault();
               if (deptFocus > -1 && items[deptFocus]) {
                   items[deptFocus].click();
               }
               return;
           }

           for (var i = 0; i < items.length; i++) {
               items[i].classList.remove('highlight');
           }

           if (deptFocus >= items.length) deptFocus = 0;
           if (deptFocus < 0) deptFocus = items.length - 1;
           if (items[deptFocus]) items[deptFocus].classList.add('highlight');
       });

       // toggle button
       document.getElementById('deptToggle').addEventListener('click', function () {
           showDeptDropdown(deptInput.value);
           deptInput.focus();
       });

       // outside click
       document.addEventListener('click', function (e) {
           if (!deptInput.contains(e.target) &&
               !deptDropdown.contains(e.target) &&
               e.target.id !== 'deptToggle') {
               deptDropdown.style.display = 'none';
           }
       });
   </script>

</asp:Content>
