# Generic
environment = "Development"
# Elastic Container Service
ecs_desired_count    = 2
ecs_container_memory = 64
ecs_container_cpu    = 10
# Auto Scaling Group
asg_instance_type               = "t2.micro"
asg_enable_ssh_in               = true
asg_enable_autoscaling_schedule = false