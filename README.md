UC:1 - Setting Up ALB and Listener Rules for Different Request Paths

Review below diagram carefully for incoming requests that can be classified based on homepage(default), register, image. Configure ALB and Listener rules to route requests to the below paths. Each of the types described below needs to be served separately. Use a custom VPC and Subnets and ensure three EC2 instances running in one AZ each.



We have used user_data (sample below) attribute with a script that installs and runs the nginx service. Further, each nginx is configured separately to serve separate paths:

Instance A – responds to root path

Instance B – responds to /images path

Instance C – responds to /register path


Access the homepage for Instance A, ./images/ path for Instance B and ./register/ path for Instance C.

Expected Outcome:

Ensure the traffic is routed correctly to the appropriate EC2 instance based on the listener rules.

Verify that the EC2 instances are serving the requests appropriately and that the ALB correctly distributes the traffic.

Homepage Requests: Requests to the root URL (/) are routed to the EC2 instance in AZ1 handling the homepage.

Register Requests: Requests to /register are routed to the EC2 instance in AZ2 handling the registration page.

Image Requests: Requests to /image are routed to the EC2 instance in AZ3 serving image-related
