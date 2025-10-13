# Supplier Registration Web Application

This project is a **Supplier Registration System** built using **ASP.NET Web Forms (C#)** with a **SQL Server Database**. It allows users to register suppliers, search supplier names with autocomplete, save data into the database, and manage supplier details.

---

## 🚀 Features

* ✍️ **Supplier Registration Form** (Code, Name, Email, Mobile, GSTIN, Address, Status)
* 🔎 **Autocomplete Supplier Name** using AJAX & jQuery
* 💾 **Save Supplier Details** to SQL Server
* 🧹 **Clear Form Functionality**
* ✅ **Success Message with Auto-Hide (3 seconds)**
* 📦 Database Integration using `PRSConnectionString`

---

## 🛠️ Tech Stack

| Technology   | Description               |
| ------------ | ------------------------- |
| ASP.NET (C#) | Web Application Framework |
| SQL Server   | Database Backend          |
| ADO.NET      | Database Connectivity     |
| jQuery UI    | Autocomplete Feature      |
| HTML/CSS     | UI Design & Styling       |

---

## 📁 Project Structure

```
├── Supplier.aspx          # Frontend UI Page
├── Supplier.aspx.cs       # Backend Code (C#)
├── Web.config             # Database Connection
├── SiteMaster.Master      # Master Page (Layout)
```

---

## 🔧 Database Table (SUPPLIERS)

Make sure you have a table named **SUPPLIERS**:

```sql
CREATE TABLE Suppliers
(
    SupplierID int Identity(1,1),  
    SupplierCode NVARCHAR(50) NOT NULL,
    SupplierName NVARCHAR(300) NOT NULL,
    Email NVARCHAR(100) NULL,
    Mobile NVARCHAR(20) NULL,
    GSTIN NVARCHAR(20) NULL,
    Address NVARCHAR(250) NULL,
    Status NVARCHAR(20) NULL,  
    CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    EndDateTime DATETIME NULL,
    Createdby varchar(20) 
);
```

---

## 🔌 Database Connection (Web.config)

```xml
<connectionStrings>
    <add name="PRSConnectionString"
         connectionString="Server=YOUR_SERVER_NAME;Database=PRSDB;User ID=sa;Password=YOUR_PASSWORD;"
         providerName="System.Data.SqlClient" />
</connectionStrings>
```

---

## ▶️ How to Run

1️⃣ Clone the repository:

```bash
git clone https://github.com/your-username/your-repo-name.git
```

2️⃣ Open in **Visual Studio**

3️⃣ Restore NuGet packages (if required)

4️⃣ Update **Web.config** with your SQL Server credentials

5️⃣ Run the project using **IIS Express** or **Local IIS**

---

## 💡 Future Enhancements

* 🗂️ Supplier List with Edit/Delete
* 🔍 Search Supplier by Code/Name
* 📄 Export to Excel / PDF

---

## 🤝 Contributing

Contributions are welcome! Feel free to fork and create a pull request.

---

## 📜 License

This project is open-source and free to use.

---

## 🙌 Author

**PRIYANKA H M**
Project Developed for Supplier Registration Management

---

Thank you for using this Supplier Registration System! 😊
