[
  {
    "name": "nginx",
    "image": "public.ecr.aws/nginx/nginx:latest",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 8080
      }
    ],
    "memory": 128,
    "cpu": 100
  }
]