# Project Deployment Documentation

This repository contains the necessary Terraform (`.tf`) files for deploying our team's services, along with Dockerfiles for building Docker images. Additionally, this README includes setup documentation for the services, 
assuming terrafrom was set-up (to even get to this repo).

## Prerequisites

- Create an account on **AWS**.
- Ensure you are in the `us-east-1` region.

## Setup Instructions

### AWS Configuration

1. **Create a Key Pair:**
   - Create a key pair named `split-keys`.

2. **Create an S3 Bucket:**
   - Set up an S3 bucket to store Terraform state files:
     ```terraform
     terraform {
       backend "s3" {
         bucket = "<bucket-name>"
         key    = "tgproc"
         region = "us-east-1"
       }
     }
     ```

3. **IAM Roles:**
   - Navigate to IAM and create an instance role named `log-role` with the necessary permissions (`fullsqs`, `sts:assumeRole`, `cloudwatchFull`).
   - Create a role for Terraform with administrative permissions for simplicity.
     
3. **RDS:**
   - Create free tier RDS instance with the public access and get it's credentials
  
     
### SQS Configuration

1. **Create SQS Queues:**
   - Go to SQS and create the following queues:
     - `live-response.fifo`
     - `main_test`
     - `response_queue`

### Continuous Integration and Deployment

1. **Run the CI/CD Pipeline:**
   - Execute the pipeline at `data-processor`.
   - Collect the ARNs of all resources created by Terraform and place them in their respective fields in other `.tf` files (e.g., VPC ARN goes to the VPC field in `telegram-proc`).

### Lambda and CloudWatch Configuration

1. **CloudWatch EventBridge:**
   - For Lambda deployment, create a rule in CloudWatch EventBridge.
   - Insert the role ARN into the Lambda "role" field in the `.tf` file.

2. **Set Up Logging:**
   - Go to CloudWatch and create a log group named `logs`.
   - Within the group, create a log stream with a name corresponding to the deployed services. (`data-proc`,`tg-management`,`telegram-proc` in this case)

### Final Steps

- Run all pipelines.
- Ensure that all services are up and running.
