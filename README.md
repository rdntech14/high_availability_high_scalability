Purpose : To create high availability & high scalable system with 

**VPC - 1**

**Subnet - 3**

( DB - 1 subnet ( private) - sg_db, 

2 - web server subnet ( public) - sg_web, 

ELB - 1 associate with 2 subnets - sg_elb )

1 - Auto Scaling launch configuration for Web

1 - Auto Scaling Group associate with ELB for Web

**Create Instance with DB script**

Task 1: Create 1 VPC and 3 subnets

Task 2 : Create Internet Gateway and attach VPC

Task 3: Create 3 Security Group ( 1- ELB, 1 - Web, 1-DB)

Task 4: Create DB instance in Subnet #3 and attach security group sg_db and get DB IP

Task 5: ELB - 1 associate with subnet #1 & subnet #2 and security_group sg_elb

Task 6: Create 1 - Auto Scaling launch configuration for Web with Script Updated with DB ip

Task 7: Create 1 - Auto Scaling Group associate with ELB for Web
