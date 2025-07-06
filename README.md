# Windows Server and Active Directory (AD) Setup Guide

## 🛠️ Phase 1: Windows Server 2019 Installation & Domain Controller Setup

### Step 1: Install Windows Server 2019

#### Requirements:

* VirtualBox installed
* Windows Server 2019 ISO
* At least 2 GB RAM, 2 CPUs, 50 GB storage

#### Installation:

1. Create a new VM in VirtualBox:

	* Name: `Windows Server 2019`
	* Type: Microsoft Windows
	* Version: Windows 2019 (64-bit)
	* Network: Bridge Adapter
2. Attach the Windows Server 2019 ISO and start the VM.
3. Follow the installer:

	* Choose **Windows Server 2019 Standard (Desktop Experience)**
	* Choose **Custom installation**
	* Create a new partition and proceed
4. Set the Administrator password when prompted.

---

### Step 2: Initial Configuration

After installation:

1. **Login as Administrator**.
2. Open **Server Manager**.
3. Change the computer name:

	* Server Manager → Local Server → Computer Name → Change
	* Example name: `DC01`
4. Set a **static IP address**:

	* Local Server → Ethernet
	* In the Network Connections window, right-click the active network adapter, then Properties.
	* Select Internet Protocol Version 4 (TCP/IPv4), then Properties.
	* Set IPv4 to something like:

		```
		IP: 192.168.56.10
		Subnet: 255.255.255.0
		Gateway: 192.168.56.1 (or leave empty)
		DNS: 192.168.56.10 (self)
		```

---

### Step 3: Install Active Directory Domain Services (AD DS)

1. Open **Server Manager → Manage → Add Roles and Features**.
2. In Installation Type select Role-based installation → Select your server.
3. On the Roles screen, **check**:

	* ✅ Active Directory Domain Services
	* ✅ DNS Server (check if not auto-selected)

4. Click **Next → Install**.
5. After installation completes, do **not restart yet**.

---

### Step 4: Promote to Domain Controller

1. In Server Manager → Click the **Notification flag icon** in the top bar.
2. Select **“Promote this server to a domain controller”**.
3. Select **Add a new forest**, enter `lab.local`, click Next.
4. Choose Forest Functional Level and Domain Functional Level (default is fine).
5. Set a DSRM password (Directory Services Restore Mode).
6. Keep defaults for DNS and NetBIOS name.
7. Confirm and click **Install**.
8. The server will **reboot automatically** after promotion.

---

### Step 5: Verify Domain Controller Status

1. After reboot, log in as `lab\Administrator`.
2. Open **Server Manager**. You should now see **AD DS** and **DNS** listed as roles.
3. Open **Active Directory Users and Computers**. You should see the new domain: `lab.local`.

## 🛠️ Phase 2: Create Organizational Units (OUs)

### Step 1: Open Active Directory Users and Computers

1. Press `Win + S`, type `Active Directory Users and Computers`, and press Enter
	— or —
	Press `Win + R`, type `dsa.msc`, and press Enter
	— or —
	Open **Server Manager → Tools → Active Directory Users and Computers**.

2. Expand your domain (e.g., `lab.local`) to view existing containers.

---

### Step 2: Create Organizational Units (OUs)

1. Right-click the domain (e.g., `lab.local`) → **New → Organizational Unit**.
2. Name the OU (e.g., `Users`, `Computers`, `Admins`, `LabClients`).
3. Repeat to organize your lab structure logically:

	* `LabUsers`
	* `ITAdmins`
	* `TestAccounts`

---

### Step 3: Create Groups

1. Right-click an OU (e.g., `ITAdmins`) → **New → Group**.
2. Provide a **Group Name** (e.g., `Helpdesk`, `LocalAdmins`).
3. Choose group scope/type (default: `Global / Security` is fine for now).
4. Click **OK**.

---

### Step 4: Create Users

1. Right-click the OU you created (e.g., `LabUsers`) → **New → User**.
2. Fill in:

	* First name: `Test`
	* User logon name: `testuser1`
3. Set a password (e.g., `P@ssword123`).
4. Uncheck **"User must change password at next logon"**.
5. Click **Finish**.

Repeat for more users like:

* `testuser2`
* `adminuser`

---

### Step 5: Add User to a Group

1. Right-click the user you just created → **Add to a group...**.
2. Type the name of the group (e.g., `ITAdmins`) and click **Check Names**.
3. Click **OK** to confirm.

## 🛠️ Phase 3: Configure Group Policy (GPO)

### Step 1: Open Group Policy Management

1. Press `Win + R`, type `gpmc.msc`, and press Enter.
	— or —
	Press `Win + S`, type `Group Policy Management`, and press Enter
	— or —
	Go to **Server Manager → Tools → Group Policy Management**.

2. Expand your forest and domain:

---

### Step 2: Create a New GPO

1. Expand your domain.
2. Right-click **Group Policy Objects** → **New**.
3. Name your GPO (e.g., `PasswordPolicy`, `UserRestrictions`, `AuditPolicy`).
4. Click **OK**.

> You can create multiple GPOs based on purpose or keep all settings in one.

---

### Step 3: Edit the GPO

1. Right-click your new GPO → **Edit**.
2. Apply settings under:
	* Navigate to `Computer Configuration → Policies → Windows Settings → Security Settings → Account Policies → Password Policy`
		* Enforce password history: `24`
		* Maximum password age: `30`
		* Minimum password length: `12`
		* Password must meet complexity requirements: `Enabled`
	* Navigate to `Computer Configuration → Policies → Windows Settings → Security Settings → Advanced Audit Policy Configuration → Audit Policies`. 
		* Logon: `Success`, `Failure`.
		* Privilege Use: `Success`, `Failure`.

---

### Step 4: Link the GPO to an OU

1. Right-click the OU (e.g., `LabUsers`) → **Link an Existing GPO**.
2. Choose your GPO (e.g., `PasswordPolicy`) and click **OK**.

### Step 5: Force & Verify Policy

1. Open Command Prompt or PowerShell as Administrator and run:

	```powershell
	gpupdate /force
	```

2. Verify:

	```powershell
	auditpol /get /category:*
	```

3. Check logs in **Event Viewer → Windows Logs → Security**

	Look for:

	* `4624`: Successful login
	* `4625`: Failed login
	* `4672`: Admin privilege assigned

## 🛠️ Phase 4: Set Up Logging Software on Local Host

### Option 1: Use Built-in **Event Viewer**

* Already logs security, system, and application events
* No installation needed

To view logs:

* Press `Win + R`, type `eventvwr.msc`
* Check:

  * `Windows Logs → Security`
  * `Windows Logs → System`

---

### Option 2: Enable Local Log File Archiving

To store logs for long-term usage:

1. Open Event Viewer → Right-click **Security**
2. Choose **Properties**
3. Increase log size (e.g., 128 MB)
4. Enable **Overwrite events as needed**

---

### Option 3: Install Logging Tools (Optional)

You can install third-party tools for better log management:

#### 🔹 Example: NxLog or Sysmon (from Sysinternals)

* **Sysmon** logs detailed process creation and network events
* Must be manually installed via shared folder or ISO

> These are optional for now — default Event Viewer is enough for basic auditing.

## 🛠️ Phase 5: PowerShell Script for System Info

## 🛠️ Phase 6: Harden Network (Disable LLMNR & NBT-NS)

## 🛠️ Phase 7: Red/Blue Team Recon & Attacks

## 🛠️ Phase 8: Advanced Attacks

