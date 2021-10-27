#!/bin/bash

# ECS config: ${cluster_id}
{
  echo "ECS_CLUSTER=${cluster_name}"
} >> /etc/ecs/ecs.config

start ecs

echo "Done"