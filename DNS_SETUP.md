# Post-Deployment DNS & SSL Setup Guide

Once Terraform has provisioned the infrastructure, follow these steps to securely expose your Custom Domain.

## 1. Domain Registration & Route53 Integration
The Terraform plan assumes you have registered a domain name and it is managed via Amazon Route 53 in the primary AWS account. 
If your domain is managed externally (e.g., GoDaddy, Namecheap):
- Go to the Route53 Console.
- Note the NS (Name Server) records generated for your Hosted Zone.
- Update your domain registrar with these NS records.

## 2. Setting up HTTPS / SSL Certificates
By default, the ALBs are provisioned to listen on HTTP (Port 80) for immediate access. For a production deployment, you should secure the endpoints:
1. Navigate to **AWS Certificate Manager (ACM)** in `us-east-1` (Primary).
2. Request a public certificate for your domain (e.g., `*.example.com` and `example.com`).
3. Use DNS validation and click "Create records in Route 53".
4. Repeat the same steps in `us-east-2` (Secondary) because ACM certificates are region-specific.

## 3. Updating the ALBs with HTTPS
You must update the ALB Listeners in `alb.tf` to listen on Port 443. 
For both Primary and Secondary ALBs, add the SSL certificate ARN:

```hcl
resource "aws_lb_listener" "primary_https" {
  provider          = aws.primary
  load_balancer_arn = aws_lb.primary.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/XXXXX"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.primary_frontend.arn
  }
}
```

Don't forget to update your `aws_security_group` resources to allow inbound traffic on Port 443!

## 4. GitHub Actions Setup
Before pushing to the `main` branch:
1. Go to your GitHub Repository -> Settings -> Secrets and variables -> Actions.
2. Add the following Repository Secrets:
   - `AWS_ACCESS_KEY_ID`: and IAM user with ECS, ECR permissions.
   - `AWS_SECRET_ACCESS_KEY`: the corresponding secret key.

You are now fully automated and globally available!
