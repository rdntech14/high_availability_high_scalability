This creates high availability & high scalable
VPC - 1
Subnet - 3

DB - 1 subnet ( private) - sg_db
2 - web server subnet ( public) - sg_web
ELB - 1 associate with 2 subnets - sg_elb

1 - Auto Scaling launch configuration for Web
1 - Auto Scaling Group associate with ELB for Web

Create Instance with DB script

Task 1: Create 1 VPC and 3 subnets
Task 2: create DB instance and get DP IP
Task 3: Create 3 Security Group ( 1- ELB, 1 - Web, 1-DB)
Task 3: ELB - 1 associate with 2 subnets - sg_elb
Task 3: Create 1 - Auto Scaling launch configuration for Web with Script Updated with DB ip
Task 4: Create 1 - Auto Scaling Group associate with ELB for Web
