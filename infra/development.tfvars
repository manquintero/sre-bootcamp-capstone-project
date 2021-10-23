# Generic
environment = "Development"
# Elastic Container Service
ecs_desired_count    = 2
ecs_container_memory = 64
ecs_container_cpu    = 10
# Auto Scaling Group
asg_min_size      = 2
asg_max_size      = 2
asg_instance_type = "t2.micro"