Workflow of Automated Blue-Green Deployment

This Blue-Green deployment automation ensures that application updates are **seamlessly rolled out** with **zero downtime**. The workflow follows structured steps using **Terraform and Ansible**, integrating **validation checks, traffic switching, and rollback mechanisms**.

---

### **1. Infrastructure Setup with Terraform**
The process begins with **Terraform creating cloud resources**, including:
- Two environments: **Blue (active)** and **Green (inactive)**.
- A **Global Load Balancer** that routes traffic.
- **Backend services** that connect instances to the Load Balancer.

Terraform also **detects which environment is currently active**, storing it as an **output variable** for use in later steps.

**Command to initialize infrastructure:**
```sh
terraform init
terraform apply -auto-approve
```

---

### **2. Detect Active Environment**
Before deploying updates, we **check which environment (Blue or Green) is currently active** using a Python script.

This script reads the **Terraform output** to determine whether `blue_backend` or `green_backend` is receiving traffic.

**Command to detect active environment:**
```sh
python scripts/get_active_server.py
```
It returns:
```
Active Server: blue
```
or
```
Active Server: green
```
Based on this, we prepare to **deploy updates to the inactive environment**.

---

### **3. Deploy Updates to Inactive Environment**
With the inactive environment identified, Ansible deploys the latest application code to it.

- **Pulls the latest code from GitHub.**
- **Restarts the application service** on the inactive server.

Ansible ensures the inactive environment is **fully configured and updated** before switching traffic.

**Command to deploy code:**
```sh
ansible-playbook -i ansible/inventory.ini deploy.yaml
```

---

### **4. Validate the Updated Server**
Once the inactive server is updated, Ansible runs validation checks.

This includes:
- **Performing an HTTP health check** on the new deployment.
- **Ensuring the application responds correctly** before switching traffic.
- **Failing fast** if the update breaks functionality.

If the validation fails, the system **automatically rolls back** traffic.

**Validation is run using:**
```sh
ansible-playbook -i ansible/inventory.ini validate.yaml
```

---

### **5. Automatically Switch Traffic if Validation Succeeds**
If validation passes:
1. Ansible **updates the Load Balancer** to redirect traffic to the updated environment.
2. Terraform applies the change to the cloud configuration.
3. The inactive server **becomes the new active environment**.

The Load Balancer update is triggered by:
```sh
ansible-playbook -i ansible/inventory.ini switch_traffic.yaml
```
or
```sh
terraform apply -var="active_backend=google_compute_backend_service.green_backend.self_link" --auto-approve
```
This **redirects all traffic to the new deployment**, completing the switch.

---

### **6. Rollback to Previous Environment if Validation Fails**
If validation **fails**:
- The system **automatically switches traffic back** to the previously active environment.
- **Load Balancer restores traffic routing** to the working deployment.
- The new changes are **discarded** to prevent downtime.

Rollback happens with:
```sh
ansible-playbook -i ansible/inventory.ini rollback.yaml
```
or
```sh
terraform apply -var="active_backend=google_compute_backend_service.blue_backend.self_link" --auto-approve
```

---

### **Complete Automation in One Command**
Instead of running steps manually, everything is executed **sequentially with a single playbook**:
```sh
ansible-playbook -i inventory.ini deploy.yaml
```
This automates:
- Detecting the active environment.
- Deploying updates to the inactive server.
- Validating the new deployment.
- Switching traffic if validation succeeds.
- Rolling back if validation fails.

---

1. **Terraform initializes resources** (Blue, Green, Load Balancer).
2. **Python script detects the active environment**.
3. **Ansible deploys code to inactive environment**.
4. **Validation checks** ensure the update is stable.
5. **Traffic is switched to the updated environment**.
6. **Rollback occurs if validation fails**.
7. **Everything is automated via Ansible and Terraform**.
