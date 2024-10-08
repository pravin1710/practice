# data "aws_secretsmanager_secret" "secret_arn" { //fetch details about a secret stored in AWS Secrets Manager          
#   name = aws_secretsmanager_secret.rds_credential.name
# }

resource "aws_ecs_cluster" "aws-ecs-cluster" { //creates ecs-cluster
  name = "${var.app_name}-${var.app_environment}-cluster"

  tags = {
    Name        = "${var.app_name}-ecs"
    Environment = var.app_environment
  }
}

resource "aws_cloudwatch_log_group" "log-group" { ##Log Group on CloudWatch to get the containers logs
  name = "${var.app_name}-${var.app_environment}-logs"

  tags = {
    Application = var.app_name
    Environment = var.app_environment
  }
}

resource "aws_ecs_task_definition" "calendar-service_ecs_task" { //task definition for calendar-service
  family                   = "${var.service-2}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "1024"
  cpu                      = "512"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn


  container_definitions = jsonencode([
    {
      name      = "${var.service-2}-container"
      image     = "${var.aws_account_id}.dkr.ecr.us-east-1.amazonaws.com/calendar-service:latest"
      cpu       = 512
      memory    = 1024
      essential = true
      healthCheck = 
                command = ["CMD-SHELL","curl -f http://localhost/health || exit 1"],
                interval = 30,
                timeout = 5,
                retries = 3
            }

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
    # secrets = [
    #     {
    #       valueFrom = "${data.aws_secretsmanager_secret.secret_arn.arn}:RDS_DB_NAME::",
    #       name      = "RDS_DB_NAME"
    #     },
    #     {
    #       valueFrom = "${data.aws_secretsmanager_secret.secret_arn.arn}:CALENDAR_SCOPE::",
    #       name      = "CALENDAR_SCOPE"
    #     },
    #     {
    #       valueFrom = "${data.aws_secretsmanager_secret.secret_arn.arn}:CALENDAR_CLIENT_ID::",
    #       name      = "CALENDAR_CLIENT_ID"
    #     },
    #     {
    #       valueFrom = "${data.aws_secretsmanager_secret.secret_arn.arn}:CALENDAR_CLIENT_SECRET::",
    #       name      = "CALENDAR_CLIENT_SECRET"
    #     },
    #     {
    #       valueFrom = "${data.aws_secretsmanager_secret.secret_arn.arn}:NEWRELIC_APP_NAME::",
    #       name      = "NEWRELIC_APP_NAME"
    #     },
    #     {
    #       valueFrom = "${data.aws_secretsmanager_secret.secret_arn.arn}:NEWRELIC_KEY::",
    #       name      = "NEWRELIC_KEY"
    #     },
    #     {
    #       valueFrom = "${data.aws_secretsmanager_secret.secret_arn.arn}:AUTH_URI::",
    #       name      = "AUTH_URI"
    #     },
    #     {
    #       valueFrom = "${data.aws_secretsmanager_secret.secret_arn.arn}:RDS_HOSTNAME::",
    #       name      = "RDS_HOSTNAME"
    #     },
    #     {
    #       valueFrom = "${data.aws_secretsmanager_secret.secret_arn.arn}:AWS_ACCESS_KEY_ID::",
    #       name      = "AWS_ACCESS_KEY_ID"
    #     },
    #     {
    #       valueFrom = "${data.aws_secretsmanager_secret.secret_arn.arn}:AWS_SECRET_ACCESS_KEY::",
    #       name      = "AWS_SECRET_ACCESS_KEY"
    #     },
    #     {
    #       valueFrom = "${data.aws_secretsmanager_secret.secret_arn.arn}:RDS_PASSWORD::",
    #       name      = "RDS_PASSWORD"
    #     },
    #     {
    #       valueFrom = "${data.aws_secretsmanager_secret.secret_arn.arn}:RDS_USERNAME::",
    #       name      = "RDS_USERNAME"
    #     },
    #     {
    #       valueFrom = "${data.aws_secretsmanager_secret.secret_arn.arn}:RDS_PORT::",
    #       name      = "RDS_PORT"
    #     },
    #     {
    #       valueFrom = "${data.aws_secretsmanager_secret.secret_arn.arn}:RAILS_LOG_TO_STDOUT::",
    #       name      = "RAILS_LOG_TO_STDOUT"
    #     }

      # ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-create-group"  = "true",
          "awslogs-group"         = "${aws_cloudwatch_log_group.log-group.name}"
          "awslogs-region"        = "${var.aws_region}"
          "awslogs-stream-prefix" = "ecs"
        }
      }

    }
  ])
}
