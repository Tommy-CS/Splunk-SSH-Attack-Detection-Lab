# SSH Attack Detection Lab (Splunk + Linux)
This is a hands-on cybersecurity lab that uses Splunk Enterprise to simulate and detect SSH brute force attacks on a Linux VM. This project aims to explore local log monitoring, regex-based log parsing, and SIEM visualization using custom SPL queries.

## Tools & Technologies Used
- Ubuntu (Linux VM)
- PowerShell
- Splunk Enterprise (SIEM)
- Regex
- Secure Shell (SSH)
- /var/log/auth.log

## What This Lab Does
- Simulates failed SSH login attempts from a Windows VM to my Linux VM
- Uses PowerShell on Linux to monitor /var/log/auth.log for failed SSH logins in real time
- Extracts attacker metadata including:
  - Username attempted
  - Source IP address
  - Timestamp
- Logs all data to failed_rdp.log to use in Splunk
- Builds Splunk dashboards to:
  - Visualize failed login trends over time
  - Identify frequently used usernames
  - Display top attacking IPs
- Triggers alerts when a single IP attempts multiple usernames unsuccessfully

## Screenshots
### Failed SSH Attack Simulation (PowerShell):
![image](https://github.com/user-attachments/assets/7acb93ad-3f37-4b0e-a9a3-fdfe7fab78c1)

### Live SSH Attack Monitoring (Using auth.log):
![image](https://github.com/user-attachments/assets/71b4e092-62f0-4345-b755-568d8288e025)

### Splunk Dashboard:
![image](https://github.com/user-attachments/assets/c127b81d-ee7d-4633-a234-024eb3cd9e0d)

### Splunk Alert:
![image](https://github.com/user-attachments/assets/62362a93-458c-4fa8-8d08-77e3990ceeb2)
![image](https://github.com/user-attachments/assets/15f49ccc-16ed-4d9a-bc3f-a6a3df66c9ff)


## Lessons Learned
This project taught me how to build a working home lab for detecting brute force attacks using only local tools. From scripting on Linux using PowerShell to working with Splunk’s SPL syntax, every step deepened my understanding of log analysis and SIEM operations. Building custom dashboards helped me recognize how powerful data visualization is for identifying attack patterns quickly and effectively.

## Credits & Inspiration
This lab was inspired by Josh Madakor's RDP honeypot project on YouTube. Parts of the PowerShell script were adapted from his original code for educational purposes and reworked to use in a Linux-based environment.
