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
   /* ===== TASK CARD ===== */
.task-card {
    position: relative;
    overflow: hidden;
    border-radius: 18px;
}

/* Icon */
.card-icon img {
    width: 55px;
    margin-bottom: 10px;
}

/* ===== 🔥 ATTRACTIVE PENDING BADGE ===== */
.pending-badge {
    position: absolute;
    top: 12px;
    right: 12px;
    background: linear-gradient(135deg, #ff4d4d, #dc3545);
    color: #fff;

    /* ✅ Make everything same size */
    font-size: 13px;
    font-weight: 600;

    padding: 6px 12px;
    border-radius: 25px;
    min-width: 60px;

    display: flex;              /* ✅ align properly */
    align-items: center;
    justify-content: center;
    gap: 4px;

    text-align: center;
    box-shadow: 0 6px 15px rgba(220, 53, 69, 0.4);
    letter-spacing: 0.5px;
    animation: pulse 1.6s infinite;
}



/* ✨ Pulse animation */
@keyframes pulse {
    0% {
        box-shadow: 0 0 0 0 rgba(220, 53, 69, 0.6);
    }
    70% {
        box-shadow: 0 0 0 10px rgba(220, 53, 69, 0);
    }
    100% {
        box-shadow: 0 0 0 0 rgba(220, 53, 69, 0);
    }
}

/* ===== AMOUNT (Clean + Premium) ===== */
.task-amount {
    margin-top: 12px;
    font-size: 22px;
    font-weight: 700;
    color: #28a745;
}

/* ===== OPTIONAL STAT BOX (if you still use it) ===== */
.task-stats {
    display: flex;
    justify-content: space-between;
    margin-top: 15px;
    gap: 10px;
}

.stat-box {
    flex: 1;
    background: #f8f9fa;
    border-radius: 12px;
    padding: 12px;
    text-align: center;
    transition: 0.3s;
}

.dashboard-card:hover .stat-box {
    background: #eef2ff;
    transform: scale(1.03);
}

.stat-label {
    display: block;
    font-size: 12px;
    color: #6c757d;
}

.stat-value {
    font-size: 20px;
    font-weight: bold;
    color: #5a3fb5;
}

.stat-box.amount .stat-value {
    color: #28a745;
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

            <!-- Pending Tasks Card -->
            <div class="dashboard-card task-card" onclick="window.location.href='pendingtask.aspx';">
                <div class="pending-badge">
                    <asp:Label ID="lblPendingCount" runat="server" Text="0"></asp:Label>
                </div>
                <div class="card-icon">
                    <img src="https://cdn-icons-png.flaticon.com/512/3062/3062634.png" alt="My Tasks">
                </div>
                <h5>My Tasks</h5>
                <div class="task-amount">
                    <asp:Label ID="lblPendingAmount" runat="server" Text="0"></asp:Label>
                </div>
            </div>

            <!-- In Progress Card -->
<div class="dashboard-card task-card" onclick="window.location.href='Inprogress.aspx?status=inprogress';">
    
    <div class="pending-badge" style="background: linear-gradient(135deg, #dc3545, #b02a37);">
        <asp:Label ID="lblInProgressCount" runat="server" Text="0"></asp:Label>
    </div>

    <div class="card-icon">
        <img src="https://cdn-icons-png.flaticon.com/512/565/565547.png" alt="In Progress">
    </div>

    <h5>In Progress</h5>

    <div class="task-amount">
        <asp:Label ID="lblInProgressAmount" runat="server" Text="0"></asp:Label>
    </div>

</div>

            <!-- Completed Card -->
            <div class="dashboard-card" onclick="window.location.href='CompletedTask.aspx?status=completed';">
                <img src="https://cdn-icons-png.flaticon.com/512/190/190411.png" alt="Completed">
                <h5>Completed</h5>
            </div>
            <div class="dashboard-card task-card" onclick="window.location.href='rejecthold.aspx?status=rejected';">
    
    <div class="pending-badge" style="background: linear-gradient(135deg, #ff4d4d, #b02a37);">
        <asp:Label ID="lblRejectedCount" runat="server" Text="0"></asp:Label>
    </div>

    <div class="card-icon">
        <img src="https://cdn-icons-png.flaticon.com/512/753/753345.png" alt="Rejected">
    </div>

    <h5>Rejected</h5>

    <div class="task-amount">
        <asp:Label ID="lblRejectedAmount" runat="server" Text="0"></asp:Label>
    </div>

</div>
            <!-- New PRS Card -->
            <div class="dashboard-card" onclick="window.location.href='PRS_Request.aspx';">
                <img src="https://cdn-icons-png.flaticon.com/512/1828/1828817.png" alt="New PRS">
                <h5>Vendor PRS</h5>
            </div>

            <!-- Claims PRS -->
            <div class="dashboard-card" onclick="window.location.href='EmpClaim.aspx?status=completed';">
                <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRS1TWnAEyHaP8ooyKzR3pb552x-bCGO2lVJdo39n-FCFmekr5IPOnePoiD9b61O5Abse0&usqp=CAU" alt="Claims">
                <h5>Claims PRS</h5>
            </div>
            <div class="dashboard-card task-card" onclick="window.location.href='hold.aspx?status=hold';">
    
    <div class="pending-badge"style="background: linear-gradient(135deg, #ff4d4d, #b02a37);">
        <asp:Label ID="lblHoldCount" runat="server" Text="0"></asp:Label>
    </div>

    <div class="card-icon">
        <img src="https://cdn-icons-png.flaticon.com/512/595/595067.png" alt="Hold">
    </div>

    <h5>Hold</h5>

    <div class="task-amount">
        <asp:Label ID="lblHoldAmount" runat="server" Text="0"></asp:Label>
    </div>

</div>
            <div class="dashboard-card task-card" onclick="window.location.href='query.aspx';">
    
    <div class="pending-badge" style="background: linear-gradient(135deg, #ff4d4d, #b02a37);">
        <asp:Label ID="lblQueryCount" runat="server" Text="0"></asp:Label>
    </div>

    <div class="card-icon">
        <img src="https://cdn-icons-png.flaticon.com/512/4712/4712027.png" alt="Query">
    </div>

    <h5>Query</h5>

    <div class="task-amount">
        <asp:Label ID="lblQueryAmount" runat="server" Text="0"></asp:Label>
    </div>

</div>
            <!-- Supplier PO Entry Card -->
            <div id="divSupplierPO" runat="server" class="dashboard-card" onclick="window.location.href='Supplierdetails.aspx';">
                <img src="https://cdn-icons-png.flaticon.com/512/1828/1828884.png" alt="Supplier PO">
                <h5>Supplier PO Entry</h5>
            </div>

            <!-- Supplier Registration Card -->
            <div id="divSupplierreg" runat="server" class="dashboard-card" onclick="window.location.href='Supplier.aspx';">
                <img src="https://cdn-icons-png.flaticon.com/512/3135/3135715.png" alt="Supplier">
                <h5>Supplier Registration</h5>
            </div>

        </div>
    </div>
</asp:Content>
