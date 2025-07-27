# Azure Cost Optimization Archive Solution

### Objective
This project sets up a cost-efficient, serverless, archival solution on Microsoft Azure using Terraform. The architecture is designed to store and occasionally access billing or cost records while keeping infrastructure costs minimal. The system leverages Azure Functions for serverless compute and Azure Storage for long-term, low-cost data retention.

### Architecture Overview
Flow:


### Components and Rationale
1. Azure Storage (Hot/Cold/Archive Tiers)
Why? Archiving is the core goal. Azure Storage is the most cost-effective way to store data in Archive or Cool tier.

Benefit: Store large volumes of data with no compute cost unless retrieved.

2. Azure Functions (Linux, Python, Consumption Plan)
Why? Function Apps allow on-demand compute without always-on servers.

Benefit: Pay only per execution, perfect for intermittent billing/archive jobs.

3. Service Plan (SKU: Y1 - Free Tier)
Why? This keeps costs minimal. Y1 allows one free Linux consumption plan per region.

Benefit: No compute billing for small projects if within limits.

4. Terraform IaC
Why? Enables consistent, repeatable deployments across environments.

Benefit: Full automation, version control, easy rollback or updates.


### Deployment Constraints
1. The deployment could not be completed/tested due to the following issues:

2. Azure App Service Plan quota exceeded (Only one free Y1 plan allowed per region)

3. Terraform backend errors from .tfstate.lock.info due to manual lock deletion

4. Storage resource not found (likely due to partial creation or regional delay)

5. Despite these constraints, the Terraform configuration is complete and has been validated successfully.

### Benefits
1. Extremely Low Cost: No idle VMs, no compute bills when idle

2. Scalable: Serverless model allows scale to zero

3. Secure: Storage access is private; app settings are secured

4. Maintainable: Fully managed by Infrastructure-as-Code (IaC)
