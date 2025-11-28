<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/SiteMaster.Master"
    AutoEventWireup="true" CodeBehind="dashboard.aspx.cs" Inherits="PRSwebapp.dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet" />

    <style>
        /* ===== OVERRIDE MASTER PAGE HEADER/MARGIN ===== */
        header, .navbar, .site-header, .main-content {
            margin: 0 !important;
            padding: 0 !important;
        }

        /* ===== CONTENT PADDING ===== */
      .content {
    margin-top: 20px; /* header + top nav */
    padding: 15px 20px;
}


        /* ===== DASHBOARD CARDS ===== */
        .dashboard-cards {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 25px;
            justify-content: center;
        }

        .dashboard-card {
            background: #fff;
            border-radius: 15px;
            padding: 25px 20px;
            text-align: center;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
            cursor: pointer;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
        }

        .dashboard-card img {
            width: 60px;
            margin-bottom: 15px;
        }

        .dashboard-card h5 {
            margin-bottom: 10px;
            font-weight: 600;
            color: #5a3fb5;
        }

        /* ===== RESPONSIVE ===== */
        @media (max-width: 1200px) { .dashboard-cards { grid-template-columns: repeat(3, 1fr); } }
        @media (max-width: 992px) { .dashboard-cards { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 576px) { .dashboard-cards { grid-template-columns: 1fr; } }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="content dashboard-content">
        <div class="dashboard-cards">
            <!-- Completed Card -->
            <div class="dashboard-card" onclick="window.location.href='CompletedTask.aspx?status=completed';">
                <img src="https://cdn-icons-png.flaticon.com/512/190/190411.png" alt="Completed">
                <h5>Completed</h5>
            </div>

            <!-- In Progress Card -->
            <div class="dashboard-card" onclick="window.location.href='Inprogress.aspx?status=inprogress';">
                <img src="https://cdn-icons-png.flaticon.com/512/565/565547.png" alt="In Progress">
                <h5>In Progress</h5>
            </div>

            <!-- My Tasks Card -->
            <div class="dashboard-card" onclick="window.location.href='pendingtask.aspx';">
                <img src="https://cdn-icons-png.flaticon.com/512/3062/3062634.png" alt="My Tasks">
                <h5>My Tasks</h5>
            </div>

            <!-- New PRS Card -->
            <div class="dashboard-card" onclick="window.location.href='PRS_Request.aspx';">
                <img src="https://cdn-icons-png.flaticon.com/512/1828/1828817.png" alt="New PRS">
                <h5>Vendor PRS</h5>
            </div>

            <!--Claims PRS -->
             <div class="dashboard-card" onclick="window.location.href='EmpClaim.aspx?status=completed';">
                 <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRS1TWnAEyHaP8ooyKzR3pb552x-bCGO2lVJdo39n-FCFmekr5IPOnePoiD9b61O5Abse0&usqp=CAU" alt="Claims">
                 <h5>Claims PRS</h5>
             </div>

            <!-- Supplier PO Entry Card -->
            <div class="dashboard-card" onclick="window.location.href='Supplierdetails.aspx';">
                <img src="https://cdn-icons-png.flaticon.com/512/1828/1828884.png" alt="Supplier PO">
                <h5>Supplier PO Entry</h5>
            </div>

            <!-- Supplier Registration Card -->
            <div class="dashboard-card" onclick="window.location.href='Supplier.aspx';">
                <img src="https://cdn-icons-png.flaticon.com/512/3135/3135715.png" alt="Supplier">
                <h5>Supplier Registration</h5>
            </div>
        </div>
    </div>
</asp:Content>
