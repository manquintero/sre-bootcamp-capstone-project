# Generic
environment = "Production"
# Elastic Container Service
ecs_desired_count    = 4
ecs_container_memory = 256
ecs_container_cpu    = 50
# Auto Scaling Group
asg_instance_type               = "t2.micro"
asg_enable_ssh_in               = false
asg_enable_autoscaling_schedule = true