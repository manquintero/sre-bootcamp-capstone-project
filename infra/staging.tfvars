# Generic
environment = "Staging"
# Elastic Container Service
ecs_desired_count    = 3
ecs_container_memory = 128
ecs_container_cpu    = 20
# Auto Scaling Group
asg_min_size                    = 6
asg_instance_type               = "t2.micro"
asg_enable_ssh_in               = false
asg_enable_autoscaling_schedule = true