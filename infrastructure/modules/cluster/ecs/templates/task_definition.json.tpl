[
  {
    "name": "apache",
    "image": "httpd",
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