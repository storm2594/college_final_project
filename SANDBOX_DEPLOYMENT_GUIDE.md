# College Sandbox Deployment Guide

**IMPORTANT:** Because your AWS Sandbox entirely deletes your infrastructure when the session expires, you must recreate the AWS framework from scratch **before** GitHub Actions can deploy your code. 

Follow these exact steps every time you start a new lab session for your project demonstration.

---

## Step 1: Provision the AWS Infrastructure Locally
You must use Terraform to quickly rebuild the VPCs, Load Balancers, and Databases. GitHub Actions **cannot** do this for you.

1. Start your new AWS Lab session.
2. Copy your new AWS credentials (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`).
3. Open a terminal on your computer and navigate to the project's infrastructure folder:
   ```bash
   cd cloud-native-task-dashboard/infrastructure
   ```
4. Set your new AWS credentials in your terminal:
   **Windows (PowerShell):**
   ```powershell
   $env:AWS_ACCESS_KEY_ID="your_new_access_key"
   $env:AWS_SECRET_ACCESS_KEY="your_new_secret_key"
   $env:AWS_DEFAULT_REGION="us-east-1"
   ```
   **Mac/Linux:**
   ```bash
   export AWS_ACCESS_KEY_ID="your_new_access_key"
   export AWS_SECRET_ACCESS_KEY="your_new_secret_key"
   export AWS_DEFAULT_REGION="us-east-1"
   ```
5. Run the Terraform command to build the cloud architecture:
   ```bash
   terraform apply -var="db_password=SuperSecretDBPass123!" -auto-approve
   ```
   *(Wait ~10-15 minutes for Terraform to finish building the RDS Database and ECS Clusters).*

---

## Step 2: Update GitHub with the New Credentials
Now that the AWS infrastructure exists again, GitHub needs permission to push your React and Node.js code to it.

1. Go to your GitHub Repository: `https://github.com/storm2594/college_final_project`
2. Click **Settings** > **Secrets and variables** > **Actions**.
3. Click the pencil icon next to `AWS_ACCESS_KEY_ID` and paste your new key.
4. Click the pencil icon next to `AWS_SECRET_ACCESS_KEY` and paste your new secret key.

---

## Step 3: Trigger the Code Deployment
With the credentials updated, you can now tell GitHub to build and deploy your application.

1. Go to the **Actions** tab in your GitHub repository.
2. Click on the most recent workflow run on the list.
3. Click the **Re-run all jobs** button in the top right corner.
4. Wait approximately 3 to 5 minutes for the pipeline to finish building the Docker containers and deploying them to your newly created AWS clusters.

---

## Step 4: Access your Live Project!
Once the GitHub Action turns green, your project is fully live on the internet!

1. Open your terminal in the `infrastructure` folder again.
2. Run this command to get the public website link:
   ```bash
   terraform output primary_alb_dns
   ```
3. Copy that link, paste it into your browser, and present your Cloud-Native Dashboard!
