
# AWS Integration Platform on ECS, Lambda & SQS

## Overview
The integration platform built on AWS to securely ingest, process, and monitor HR / user data feeds.
Designed with asynchronous processing, strong security boundaries, retries, DLQs, and observability to support enterprise onboarding at scale.

This project reflects real-world Infrastructure & Implementation Engineering work: integrations, authentication, automation, and operational resilience.

---

## Highlights

- Asynchronous HR feed ingestion pipeline using API Gateway, Lambda (Python), SQS, and DLQ to prevent data loss and handle retries automatically
- OIDC authentication with AWS Cognito enforced at the Application Load Balancer (ALB)
- Failure isolation & observability via CloudWatch logs, DLQ alarms, and SNS notifications
- Terraform-managed IaC with modular design, remote state in S3, and state locking via DynamoDB
- Architecture designed to support multiple integration sources (HRIS, API, SFTP, admin tools, SCIM-style provisioning)

---

## Architecture

![ecs](https://github.com/user-attachments/assets/94e204e5-dafd-4b19-9788-2cf11fda42fc)
![ScreenRecording2025-12-16at11 28 41PM-ezgif com-video-to-gif-converter (1)](https://github.com/user-attachments/assets/473cc3b5-d856-41a5-b242-4b7cc6c3743a)

---


## Live Demo
<img width="740" height="450" alt="Screenshot 2025-12-16 at 11 07 17 PM" src="https://github.com/user-attachments/assets/042b214d-fca1-4128-807f-1aee1689b2c4" />
<img width="740" height="450" alt="Screenshot 2025-12-16 at 11 06 23 PM" src="https://github.com/user-attachments/assets/a094af8e-fa77-40e4-8cc6-327ab356fa3e" />

Protected Application:
- HTTPS enforced with ACM
- Cognito (OIDC) authentication at ALB
- ECS Fargate service behind ALB

Integration Endpoint:
POST /integrations/hr-feed

---

## Tech Stack

Integration & App:
- AWS API Gateway (HTTP API)
- AWS Lambda (Python)
- Amazon SQS + Dead Letter Queue (DLQ)

Infrastructure:
- AWS ECS Fargate
- Application Load Balancer (ALB)
- Route 53
- AWS Cognito (OIDC)
- AWS Certificate Manager (ACM)

Observability:
- Amazon CloudWatch Logs & Metrics
- CloudWatch Alarms
- Amazon SNS

Infrastructure as Code:
- Terraform (modular)
- S3 remote state
- DynamoDB state locking

---

## How It Works

1. External system sends HR/user data to API Gateway
2. Lambda (Ingest) validates payload and publishes message to SQS
3. SQS buffers messages and handles retries
4. Lambda (Consumer) processes messages asynchronously
5. Failed messages exceed retry limit and move to DLQ
6. CloudWatch alarm triggers SNS notification

This design ensures reliability, scalability, and zero data loss during customer onboarding.

---

## Architecture Decisions

Asynchronous Processing with SQS:
Decouples ingestion from processing.
Trade-off: Slightly higher latency
Benefit: Reliability, retries, back-pressure handling, and failure isolation

DLQ + Alarms vs Silent Failures:
Poison messages are isolated and surfaced immediately.
Benefit: Faster incident response and fewer support escalations

Cognito at ALB vs App-Level Authentication:
Authentication handled at the edge using ALB + Cognito.
Benefit: Simpler backend services and consistent security enforcement

Terraform Remote State (S3 + DynamoDB):
Single source of truth with state locking.
Benefit: Prevents concurrent applies and state corruption


---

## Author

Bekarys Janbatyrov

Infrastructure & Implementation Engineering

Vancouver, BC
