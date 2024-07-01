resource "aws_ecs_service" "calendar_ecs-service" { //configuration required for calendar ecs service 
  name                               = "${var.service-2}-ecs_service"
  cluster                            = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition                    = aws_ecs_task_definition.calendar-service_ecs_task.arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  desired_count                      = 2
  enable_ecs_managed_tags            = true
  force_new_deployment               = true

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.calander_service_fargates.arn
    container_name   = "${var.service-2}-container"
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

}
