# PostgreSQL Port 5432 Troubleshooting Guide

## Problem: Connection Failing on localhost:5432

This guide helps fix the most common PostgreSQL connection issues.

---

## ✅ Quick Fix Checklist

### 1. **Is PostgreSQL Running?**

Open PowerShell and check if PostgreSQL service is running:

```powershell
# Check PostgreSQL service status
Get-Service postgres* | Format-Table Name, Status
```

**Expected Output:**
```
Name                Status
----                ------
postgresql-x64-15   Running
```

If status is **"Stopped"**, start it:

```powershell
# Start PostgreSQL service
Start-Service postgresql-x64-15
```

(Replace `postgresql-x64-15` with your actual service name from the list above)

---

### 2. **Verify Port 5432 is Listening**

Check if PostgreSQL is listening on port 5432:

```powershell
# Check if port 5432 is in use
netstat -ano | findstr :5432
```

**Expected Output:**
```
TCP    127.0.0.1:5432         0.0.0.0:0            LISTENING       1234
```

If no output appears, PostgreSQL is not running on port 5432.

---

### 3. **Test PostgreSQL Connection with psql**

Try connecting with the command-line tool:

```powershell
# Connect to PostgreSQL
psql -U postgres -h localhost -p 5432
```

When prompted, enter your PostgreSQL password (the one you set during installation).

**Expected Output:**
```
psql (15.x)
Type "help" for help.

postgres=#
```

If you get a connection error, see solutions below.

---

## 🔧 Solutions by Error Message

### Error: "could not translate host name 'localhost' to address"

**Solution:** Use IP address instead:

```powershell
psql -U postgres -h 127.0.0.1 -p 5432
```

---

### Error: "Server doesn't listen on '127.0.0.1:5432'"

**Solution 1:** Restart PostgreSQL service

```powershell
# Stop the service
Stop-Service postgresql-x64-15

# Wait 2 seconds
Start-Sleep -Seconds 2

# Start the service
Start-Service postgresql-x64-15

# Wait for startup
Start-Sleep -Seconds 3

# Verify it's running
Get-Service postgresql-x64-15
```

**Solution 2:** Check PostgreSQL is configured to listen on localhost

Edit `C:\Program Files\PostgreSQL\15\data\postgresql.conf`:

1. Open the file with Notepad
2. Find the line: `listen_addresses = 'localhost'`
3. Make sure it's **not** commented out (no `#` at the start)
4. Save and restart PostgreSQL

---

### Error: "password authentication failed for user 'postgres'"

**Solution:** Verify you're using the correct password

The password you set during installation is what you need. If you forgot it:

1. Stop PostgreSQL service
2. Edit `C:\Program Files\PostgreSQL\15\data\pg_hba.conf`
3. Find the line with `127.0.0.1/32  md5` and change it to `127.0.0.1/32  trust`
4. Restart PostgreSQL
5. Run: `psql -U postgres -h 127.0.0.1`
6. Reset password:
   ```sql
   ALTER USER postgres PASSWORD 'newpassword';
   ```
7. Change pg_hba.conf back to `md5`
8. Restart PostgreSQL

---

### Error: "FATAL: role 'postgres' does not exist"

**Solution:** PostgreSQL wasn't installed correctly. Reinstall:

1. Uninstall PostgreSQL (Control Panel → Programs)
2. Delete folder: `C:\Program Files\PostgreSQL`
3. Delete folder: `C:\ProgramData\PostgreSQL` (if exists)
4. Restart computer
5. Download and reinstall PostgreSQL from https://www.postgresql.org/download/
6. During installation, set postgres password and remember it
7. Verify installation with `psql -U postgres -h localhost`

---

## 🐛 Advanced Debugging

### Check PostgreSQL Logs

PostgreSQL logs are in: `C:\Program Files\PostgreSQL\15\data\log\`

Look for recent log files and check for errors:

```powershell
# View recent PostgreSQL logs
Get-ChildItem "C:\Program Files\PostgreSQL\15\data\log\" -Name | Sort-Object -Descending | Select-Object -First 5
```

---

### Verify PostgreSQL Installation

```powershell
# Check if PostgreSQL is installed
Get-Program | findstr PostgreSQL

# Check version
psql --version

# Check PostgreSQL binaries location
where psql
```

---

### Check Windows Firewall

PostgreSQL might be blocked by Windows Firewall:

```powershell
# Open Windows Defender Firewall Advanced Settings
# Navigate to: Inbound Rules
# Look for: PostgreSQL (if missing, PostgreSQL isn't firewalled)
```

Or allow it programmatically:

```powershell
# Add PostgreSQL to firewall (run as Administrator)
netsh advfirewall firewall add rule name="PostgreSQL" dir=in action=allow program="C:\Program Files\PostgreSQL\15\bin\postgres.exe" enable=yes
```

---

## ✅ Verification Steps

Once you've tried the fixes above, run this verification:

```powershell
# 1. Check PostgreSQL service is running
Write-Host "1. Checking PostgreSQL service..."
$service = Get-Service postgresql-x64-15
Write-Host "Status: $($service.Status)"

# 2. Check port 5432 is listening
Write-Host "`n2. Checking port 5432..."
$port = netstat -ano | findstr :5432
if ($port) { Write-Host "Port 5432 is listening" } else { Write-Host "ERROR: Port 5432 not listening" }

# 3. Test connection with psql (requires password prompt)
Write-Host "`n3. Testing connection with psql..."
Write-Host "Running: psql -U postgres -h localhost -p 5432 -c 'SELECT version();'"
psql -U postgres -h localhost -p 5432 -c "SELECT version();"
```

---

## 🔄 If Still Failing: Full Reset

**Last Resort - Complete Reinstall:**

1. **Uninstall PostgreSQL:**
   ```powershell
   # Control Panel → Programs and Features → PostgreSQL → Uninstall
   ```

2. **Delete all PostgreSQL files:**
   ```powershell
   Remove-Item -Recurse -Force "C:\Program Files\PostgreSQL" -ErrorAction SilentlyContinue
   Remove-Item -Recurse -Force "C:\ProgramData\PostgreSQL" -ErrorAction SilentlyContinue
   ```

3. **Restart computer:**
   ```powershell
   Restart-Computer
   ```

4. **Reinstall PostgreSQL:**
   - Download: https://www.postgresql.org/download/
   - Run installer
   - **Important:** Remember the postgres password you set
   - Select port: **5432**
   - Don't skip any components

5. **Verify installation:**
   ```powershell
   psql -U postgres -h localhost -p 5432 -c "SELECT 1;"
   ```

---

## 📝 Common Installation Mistakes

❌ **Mistake 1:** Changing default port from 5432  
✅ **Fix:** Use default port 5432, or update application config if you change it

❌ **Mistake 2:** Forgetting postgres password  
✅ **Fix:** Follow the "password authentication failed" solution above

❌ **Mistake 3:** PostgreSQL set to network only (not localhost)  
✅ **Fix:** Edit postgresql.conf and ensure `listen_addresses = 'localhost'`

❌ **Mistake 4:** Installing PostgreSQL but not starting the service  
✅ **Fix:** Manually start the service or reboot the computer

---

## ✅ Success Indicators

You'll know it's working when:

1. ✅ `Get-Service postgresql-x64-15` shows **"Running"**
2. ✅ `netstat -ano | findstr :5432` shows **LISTENING**
3. ✅ `psql -U postgres -h localhost -p 5432` connects successfully
4. ✅ `psql -U postgres -c "SELECT 1;"` returns `1`

---

## 🆘 Still Not Working?

If you're still seeing errors after trying all solutions above:

1. Run verification steps and copy the full error message
2. Check PostgreSQL logs: `C:\Program Files\PostgreSQL\15\data\log\`
3. Try the "Full Reset" section above
4. If Windows antivirus is blocking it, add exception for PostgreSQL

---

## Next Steps After Fixing

Once PostgreSQL is running, go back to the main setup:

```powershell
cd C:\OneDrive\Documents\helpdesk-automation-system
.\setup-local.ps1 -DBPassword "postgres"
```

---

**Need more help?** See `SETUP_REQUIRED.md` for complete installation guide.

