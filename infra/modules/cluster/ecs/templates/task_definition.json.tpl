[
  {
    "name": "${container_name}",
    "image": "${container_image}:${container_tag}",
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": ${host_port}
      }
    ],
    "environment": [
      {"name": "DB_HOST", "value": "${db_host}"},
      {"name": "DB_USERNAME", "value": "${db_username}"},
      {"name": "COMMIT_SHA", "value": "${container_tag} (${environment})"}
    ],
    "secrets": [
      {"name": "DB_PASS", "valueFrom": "${db_password_arn}"}
    ],
    "memory": ${memory},
    "cpu": ${cpu},
    "tags": [
      {"key": "ENVIRONMENT", "value": "${environment}"}
    ]
  }
]
