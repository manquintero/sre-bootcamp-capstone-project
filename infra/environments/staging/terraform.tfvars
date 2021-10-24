# Generic
environment = "Staging"
# Elastic Container Service
ecs_desired_count    = 3
ecs_container_memory = 128
ecs_container_cpu    = 25
# Auto Scaling Group
asg_instance_type               = "t2.micro"
asg_enable_ssh_in               = true
asg_enable_autoscaling_schedule = false