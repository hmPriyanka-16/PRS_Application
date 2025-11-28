<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RingiPopup.aspx.cs" Inherits="PRSwebapp.AcknowledgementPopup" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>RINGI Acknowledgement</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        .modal-content {
            border-radius: 12px;
            padding: 1.5rem;
            text-align: center;
            box-shadow: 0 6px 20px rgba(0,0,0,0.25);
        }

        .modal-header {
            justify-content: center;
            border-bottom: none;
            padding-bottom: 0;
        }

        .success-icon {
            font-size: 2.5rem;
            color: #fff;
            background-color: #198754;
            border-radius: 50%;
            padding: 0.5rem 0.6rem;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1rem;
        }

        .modal-title {
            font-weight: 600;
            font-size: 1.2rem;
        }

        .modal-body p {
            margin: 0.5rem 0;
            font-size: 1rem;
            color: #495057;
        }

        .btn-primary {
            background-color: #0d6efd;
            border: none;
            padding: 0.5rem 1.5rem;
            font-size: 1rem;
            border-radius: 6px;
        }

        .btn-primary:hover {
            background-color: #0b5ed7;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Modal -->
        <div class="modal fade" id="ringiModal" tabindex="-1" aria-labelledby="ringiModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-sm modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header flex-column">
                        <span class="success-icon">&#10004;</span>
                        <h5 class="modal-title" id="ringiModalLabel">Acknowledgement</h5>
                    </div>
                    <div class="modal-body">
                        <p><strong>PRS Number:</strong> <asp:Label ID="lblRingiNumber" runat="server"></asp:Label></p>
                        <p>Thank you for submitting your request. Your PRS will be forwarded for further processing.</p>
                    </div>
                    <div class="modal-footer justify-content-center">
                        <asp:Button ID="btnClose" runat="server" CssClass="btn btn-primary" Text="Close" OnClick="btnClose_Click" />
                    </div>
                </div>
            </div>
        </div>

        <script>
            // Show modal when page loads
            var ringiModal = new bootstrap.Modal(document.getElementById('ringiModal'));
            ringiModal.show();
        </script>
    </form>
</body>
</html>
