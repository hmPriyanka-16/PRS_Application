<%@ Page Title="Query Answer" Language="C#" MasterPageFile="~/SiteMaster.Master"
    AutoEventWireup="true" CodeBehind="queryans.aspx.cs" Inherits="PRSwebapp.queryans" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" />
    <style>
        body, .card, .table { font-size: 0.825rem; }
        h5, h6, label { margin-bottom: 0.2rem; font-weight: 600; }
        .card { border-radius: 0.75rem; }
        .card-header { padding: 0.4rem 0.8rem; font-size: 0.9rem; }
        .card-body { padding: 0.6rem 0.8rem; }
        .file-upload-section { border: 1px dashed #6c757d; padding: 8px; border-radius: 0.5rem; background-color: #f8f9fa; font-size: 0.825rem; }
        .file-upload-section:hover { background-color: #e9ecef; }
        #selectedFilesContainer .badge { font-size: 0.825rem; cursor: default; margin:2px; }
        .table { margin-bottom: 0.4rem; font-size: 0.825rem; }
        .table thead th { padding: 0.35rem 0.5rem; }
        .table tbody td { padding: 0.35rem 0.5rem; }
        .table tbody tr:hover { background-color: #f1f3f5; }
        .gridview-actions a, .gridview-actions .btn { margin-right: 3px; font-size: 0.75rem; padding: 0.2rem 0.45rem; }
        .form-control, .btn { font-size: 0.825rem; }
        .btn { padding: 0.25rem 0.6rem; }
        #txtRemarks { font-size: 0.825rem; padding: 0.3rem 0.45rem; }
        hr { margin: 0.5rem 0; }
        .mb-4, .mb-3 { margin-bottom: 0.5rem !important; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <div class="container mt-3">
        <div class="card shadow-sm">
            <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                <h5 class="mb-0"><i class="bi bi-folder-fill"></i> PRS Query Response</h5>
            </div>

            <div class="card-body">
                <asp:UpdatePanel ID="updPanelPRS" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>

                        <asp:Panel ID="pnlDetails" runat="server"></asp:Panel>
                        <hr />

                        <!-- FILE UPLOAD -->
                        <div class="file-upload-section mb-3">
                            <label class="fw-bold mb-1">Upload Document</label>
                            <div class="d-flex gap-2 align-items-center">
                                <asp:FileUpload ID="fileUpload" runat="server" CssClass="form-control" multiple />
                            </div>
                            <div id="selectedFilesContainer" class="mt-2 d-flex flex-wrap gap-2"></div>
                        </div>

                        <!-- DOCUMENT LIST -->
                        <div class="mb-3">
                            <h6 class="fw-bold">Uploaded Documents</h6>
                            <asp:UpdatePanel ID="updDocs" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:GridView ID="gvDocs" runat="server" AutoGenerateColumns="false" CssClass="table table-hover table-bordered"
                                        OnRowCommand="gvDocs_RowCommand" GridLines="None">
                                        <Columns>
                                            <asp:BoundField DataField="FileName" HeaderText="File Name" />
                                            <asp:TemplateField HeaderText="View" ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <a href='<%# Eval("FilePath") %>' target="_blank" class="btn btn-outline-primary btn-sm">
                                                        <i class="bi bi-eye-fill"></i> View
                                                    </a>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Delete" ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="btnDelete" runat="server" Text="Delete" CommandName="DeleteDoc"
                                                        CommandArgument='<%# Eval("ID") %>' CssClass="btn btn-outline-danger btn-sm"
                                                        OnClientClick="return confirm('Are you sure you want to delete this file?');" />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>

                        <hr />

                        <!-- REMARKS -->
                        <div class="mb-3">
                            <label class="fw-bold">Remarks</label>
                            <asp:TextBox ID="txtRemarks" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"
                                placeholder="Enter remarks here..."></asp:TextBox>
                        </div>
                          <div class="d-flex justify-content-end">
                            <asp:Button ID="btnSubmit" runat="server" Text="Submit Response" CssClass="btn btn-primary"
                                OnClick="btnSubmit_Click" UseSubmitBehavior="true" />
    <asp:Button ID="btnReject" runat="server" Text="Reject" CssClass="btn btn-danger"
        OnClick="btnReject_Click" UseSubmitBehavior="true" />
</div>
                     

                    </ContentTemplate>
                    <Triggers>
                        <asp:PostBackTrigger ControlID="btnSubmit" />
                    </Triggers>
                </asp:UpdatePanel>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        let selectedFiles = [];

        const fileInput = document.getElementById('<%= fileUpload.ClientID %>');
        const container = document.getElementById('selectedFilesContainer');

        fileInput.addEventListener('change', function () {
            for (let i = 0; i < fileInput.files.length; i++) {
                let file = fileInput.files[i];
                if (!selectedFiles.some(f => f.name === file.name)) selectedFiles.push(file);
            }
            renderSelectedFiles();
        });

        function renderSelectedFiles() {
            container.innerHTML = '';
            selectedFiles.forEach((file, index) => {
                const tag = document.createElement('div');
                tag.className = 'badge bg-primary text-white d-flex align-items-center';
                tag.style.padding = '0.4rem 0.6rem';
                tag.style.fontSize = '0.825rem';
                tag.innerHTML = file.name + ' <span style="cursor:pointer; margin-left:5px;" onclick="removeFile(' + index + ')">&times;</span>';
                container.appendChild(tag);
            });
        }

        function removeFile(index) {
            selectedFiles.splice(index, 1);
            renderSelectedFiles();

            const dataTransfer = new DataTransfer();
            selectedFiles.forEach(f => dataTransfer.items.add(f));
            fileInput.files = dataTransfer.files;
        }
    </script>

</asp:Content>