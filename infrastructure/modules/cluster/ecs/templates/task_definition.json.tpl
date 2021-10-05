[
  {
    "name": "${container_name}",
    "image": "${container_image}",
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": ${host_port}
      }
    ],
    "memory": 128,
    "cpu": 100
  }
]