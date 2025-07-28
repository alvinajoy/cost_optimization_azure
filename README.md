# Azure Cost Optimization Archive Solution

## Objective

This project sets up a **cost-efficient, serverless archival solution** on Microsoft Azure using Terraform. The architecture is designed to store and occasionally access billing or cost records while keeping infrastructure costs minimal. It leverages **Azure Functions** for serverless compute and **Azure Storage** for long-term, low-cost data retention.

---

## Architecture Overview

**Flow:**

<img width="731" height="320" alt="image" src="https://github.com/user-attachments/assets/6cb54d0e-e9de-412e-a3ac-5647bb68237b" />



---

## Components and Rationale

### 1. Azure Blob Storage (Cold/Archive Tiers)
- **Why:** Archiving is the core goal. Azure Storage provides the most cost-effective solution for storing data in Archive or Cool tiers.  
- **Benefit:** Store large volumes of data with no compute cost unless retrieved.

### 2. Azure Cosmos DB (Hot Tiers)
- **Why:** Used for storing recent or frequently accessed records (hot data).  
- **Benefit:** Provides low-latency access with flexible querying options

### 3. Azure Functions (Linux, Python, Consumption Plan)
- **Why:** Function Apps enable on-demand compute without always-on servers.  
- **Benefit:** Pay only per execution, ideal for intermittent billing/archive jobs.

### 4. Service Plan (SKU: Y1 - Free Tier)
- **Why:** Keeps compute costs minimal. Y1 allows one free Linux consumption plan per region.  
- **Benefit:** No compute billing for small-scale projects within the quota.

### 5. Terraform (Infrastructure as Code)
- **Why:** Enables consistent, repeatable, and automated deployments.  
- **Benefit:** Full automation, version control, easy rollback, and reproducibility across environments.

---

## Deployment Constraints

The deployment could not be fully completed due to the following constraints:

- Azure App Service Plan quota exceeded (Only one free Y1 plan allowed per region)

> Despite these issues, the Terraform configuration is complete, valid, and tested with `terraform validate`.

---

## Benefits

- **Extremely Low Cost:** No idle VMs; only pay per use
- **Scalable:** Automatically scales to zero when idle
- **Secure:** Storage access is private; environment variables and function secrets are secured
- **Maintainable:** Fully managed and reproducible through Terraform IaC

---

## Terraform Files

- `main.tf` – Declares all resources
- `variables.tf` – Input variable definitions
- `outputs.tf` – Outputs for reference (if applicable)
- `provider.tf` – Azure provider configuration

---

## How to Deploy

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed
- Azure CLI logged in (`az login`)
- An Azure subscription with appropriate permissions

---

### Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/your-repo-name.git
   cd your-repo-name
2. **Initialize Terraform:**
   ```bash
    terraform init
3. **Validate the configuration:**
    ```bash
    terraform validate
4. **Preview the execution plan:**
   ```bash
    terraform plan
5. **Apply the configuration:**
   ```bash
    terraform apply
