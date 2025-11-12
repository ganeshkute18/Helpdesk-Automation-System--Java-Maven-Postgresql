# AWS Deployment Guide

## Overview
This guide covers deploying the Helpdesk Automation System to AWS using CloudFormation, RDS for PostgreSQL, and Elastic Beanstalk or EC2.

## Architecture (AWS)

```
┌─────────────────────────────────────────────────────────┐
│                   Internet Gateway                       │
└────────────────────────┬────────────────────────────────┘
                         │
┌─────────────────────────▼────────────────────────────────┐
│                Application Load Balancer                 │
│                 (Port: 80/443)                          │
└────────────────────────┬────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
    ┌────▼────┐    ┌────▼────┐    ┌────▼────┐
    │   EC2   │    │   EC2   │    │   EC2   │
    │ Instance│    │ Instance│    │ Instance│ (Auto Scaling Group)
    └────┬────┘    └────┬────┘    └────┬────┘
         │              │              │
         └──────────────┼──────────────┘
                        │
    ┌───────────────────▼──────────────────┐
    │       RDS PostgreSQL Database        │
    │   (Multi-AZ, Automated Backups)      │
    └────────────────────────────────────┘
```

## Prerequisites
- AWS Account with IAM permissions
- AWS CLI configured
- CloudFormation access
- Backend JAR file (build: `mvn clean package`)

## Deployment Steps

### 1. Build Backend JAR

```powershell
cd .\backend
mvn clean package -DskipTests
```

This creates: `backend\target\helpdesk-backend-0.0.1-SNAPSHOT.jar`

### 2. Upload JAR to S3

```powershell
# Create S3 bucket
aws s3 mb s3://helpdesk-app-bucket-YOUR-ACCOUNT-ID

# Upload JAR
aws s3 cp .\backend\target\helpdesk-backend-0.0.1-SNAPSHOT.jar `
  s3://helpdesk-app-bucket-YOUR-ACCOUNT-ID/helpdesk-app.jar
```

### 3. Create CloudFormation Stack

See `cloudformation-template.yml` for the complete IaC template.

**Deploy via AWS CLI:**

```powershell
aws cloudformation create-stack `
  --stack-name helpdesk-automation-stack `
  --template-body file://cloudformation-template.yml `
  --parameters `
    ParameterKey=ApplicationJarUrl,ParameterValue=s3://helpdesk-app-bucket-YOUR-ACCOUNT-ID/helpdesk-app.jar `
    ParameterKey=DBUsername,ParameterValue=admin `
    ParameterKey=DBPassword,ParameterValue=YourSecurePassword123! `
    ParameterKey=EnvironmentName,ParameterValue=production `
  --capabilities CAPABILITY_IAM
```

**Or via AWS Console:**
1. Go to CloudFormation → Create Stack
2. Upload `cloudformation-template.yml`
3. Fill in parameters (database credentials, jar URL, etc.)
4. Review and create

### 4. Verify Deployment

```powershell
# Check stack status
aws cloudformation describe-stacks `
  --stack-name helpdesk-automation-stack `
  --query 'Stacks[0].StackStatus'

# Get ALB DNS name
aws elbv2 describe-load-balancers `
  --query 'LoadBalancers[?contains(LoadBalancerName, `helpdesk`)].DNSName'
```

### 5. Test Deployed Application

```powershell
# Replace with your ALB DNS name
$albDns = "helpdesk-alb-123456.us-east-1.elb.amazonaws.com"

# Create ticket
$body = @{
    userId = 101
    category = "network"
    description = "Production network issue"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://$albDns/tickets" `
  -Method Post `
  -ContentType 'application/json' `
  -Body $body

# Get ticket
Invoke-RestMethod -Uri "http://$albDns/tickets/1" -Method Get
```

---

## CloudFormation Template Resources

The `cloudformation-template.yml` includes:

- **VPC & Networking**: Custom VPC, subnets, security groups
- **RDS PostgreSQL**: Multi-AZ database with automated backups
- **IAM Roles & Policies**: EC2 instance profiles
- **EC2 Auto Scaling**: Launch configuration, Auto Scaling Group
- **Application Load Balancer**: Health checks, target groups
- **Security Groups**: Ingress rules for HTTP/HTTPS and database access
- **CloudWatch Monitoring**: Alarms for instance health, CPU, disk

---

## Configuration for AWS Deployment

Create `backend/src/main/resources/application-aws.yml`:

```yaml
spring:
  profiles:
    active: aws
  datasource:
    url: jdbc:postgresql://${RDS_ENDPOINT}:5432/helpdeskdb
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
server:
  port: 8080
  compression:
    enabled: true
```

Set environment variables in EC2 launch configuration (or Parameter Store):
```
RDS_ENDPOINT=helpdesk-db.c123456xyz.us-east-1.rds.amazonaws.com
DB_USERNAME=admin
DB_PASSWORD=your_secure_password
```

---

## Scaling & Performance

### Auto Scaling Configuration
```
Min Instances: 2
Max Instances: 10
Target CPU Utilization: 70%
Scale Up Threshold: 80%
Scale Down Threshold: 30%
```

### Database Optimization
- Enable Multi-AZ for high availability
- Use read replicas for reporting queries
- Enable automated backups (7-day retention)
- Monitor slow query logs

---

## Monitoring & Logging

### CloudWatch Dashboards
- EC2 CPU, Memory, Disk I/O
- RDS Connection Count, Query Performance
- ALB Request Count, Latency
- Application Errors & Log Streams

### Example CloudWatch Logs Query
```
fields @timestamp, @message, @duration
| filter @message like /ERROR/
| stats count() by bin(5m)
```

---

## Cost Optimization

- Use t3.micro instances for dev/test (eligible for free tier)
- Schedule auto-scaling for business hours
- Enable RDS automated backups with shorter retention
- Use CloudFront for static assets

---

## Disaster Recovery

### Backup Strategy
- **Database**: Automated daily snapshots, 30-day retention
- **Application**: Build JAR stored in S3 with versioning
- **Infrastructure**: CloudFormation template version controlled

### Recovery Procedure
```powershell
# Restore RDS from snapshot
aws rds restore-db-instance-from-db-snapshot `
  --db-instance-identifier helpdesk-db-restored `
  --db-snapshot-identifier helpdesk-snapshot-id

# Update CloudFormation stack with new RDS endpoint
# Redeploy application via Elastic Beanstalk
```

---

## Troubleshooting

### EC2 Instance not starting
- Check CloudWatch logs: `var/log/cloud-init-output.log`
- Verify security group allows SSH (port 22) for debugging
- Check Auto Scaling Group activity

### Database connection failures
- Verify RDS security group allows traffic from EC2 security group
- Check RDS endpoint and credentials
- Monitor RDS event logs

### Application errors
- SSH into EC2: `ssh -i your-key.pem ec2-user@instance-ip`
- Check application logs: `/opt/helpdesk/logs/application.log`
- Verify JAR permissions and Java version

---

## Next Steps
- Implement CI/CD with AWS CodePipeline
- Set up AWS Systems Manager for patch management
- Enable AWS WAF for DDoS protection
- Integrate with AWS Secrets Manager for credential rotation
