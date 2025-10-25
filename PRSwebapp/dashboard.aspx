<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/SiteMaster.Master"
    AutoEventWireup="true" CodeBehind="dashboard.aspx.cs" Inherits="PRSwebapp.dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet" />
    <style>
        .content { padding:90px 30px 30px 30px; }
        .dashboard-cards { display:flex; flex-wrap:wrap; gap:20px; justify-content:center; }
        .dashboard-card { flex:1 1 250px; max-width:250px; background:#fff; border-radius:15px; padding:20px; text-align:center; box-shadow:0 8px 20px rgba(0,0,0,0.1); cursor:pointer; transition:transform 0.3s; }
        .dashboard-card:hover { transform:translateY(-5px); }
        .dashboard-card img { width:60px; margin-bottom:15px; }
        .dashboard-card h5 { margin-bottom:10px; font-weight:600; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="content">
        
        <div class="dashboard-cards">
            <div class="dashboard-card">
                <img src="https://cdn-icons-png.flaticon.com/512/3135/3135715.png" alt="Pending">
                <h5>Pending Tasks</h5>
            </div>
            <div class="dashboard-card">
                <img src="https://cdn-icons-png.flaticon.com/512/190/190411.png" alt="Completed">
                <h5>Completed Tasks</h5>
            </div>
            <div class="dashboard-card">
                <img src="https://cdn-icons-png.flaticon.com/512/1828/1828884.png" alt="Monthly">
                <h5>Monthly PRS Advance</h5>
            </div>
            <div class="dashboard-card">
                <img src="https://cdn-icons-png.flaticon.com/512/2331/2331941.png" alt="Local">
                <h5>Local Conveyance</h5>
            </div>
            <div class="dashboard-card">
                <img src="https://cdn-icons-png.flaticon.com/512/3077/3077243.png" alt="Capex">
                <h5>Capex Advance PRS</h5>
            </div>
            <div class="dashboard-card">
                <img src="https://cdn-icons-png.flaticon.com/512/2921/2921222.png" alt="Expense">
                <h5>Expense Claim</h5>
            </div>
            <div class="dashboard-card">
                <img src="https://cdn-icons-png.flaticon.com/512/2920/2920507.png" alt="Vendor">
                <h5>Regular Vendor Advance PRS</h5>
            </div>
            <div class="dashboard-card" >
                <img src="https://cdn-icons-png.flaticon.com/512/3039/3039435.png" alt="Reimbursement">
                <h5>Employee Reimbursement</h5>
            </div>
            <div class="dashboard-card" onclick="window.location.href='Supplier.aspx';">
                <img src="https://cdn-icons-png.flaticon.com/512/3135/3135715.png" alt="Supplier">
                <h5>Supplier Registration</h5>
            </div>
        </div>
    </div>
</asp:Content>
