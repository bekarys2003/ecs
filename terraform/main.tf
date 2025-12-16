module "network" {
  source = "./modules/network"

  name                 = local.name
  vpc_cidr             = local.vpc_cidr
  azs                  = local.azs
  public_subnet_cidrs  = local.public_subnet_cidrs
  private_subnet_cidrs = local.private_subnet_cidrs
}

module "alb" {
  source = "./modules/alb"

  name           = local.name
  vpc_id         = module.network.vpc_id
  public_subnets = module.network.public_subnet_ids
  app_port       = var.app_port

  enable_https    = true
  certificate_arn = module.acm.certificate_arn

  enable_cognito_auth         = true
  cognito_user_pool_arn       = module.cognito.user_pool_arn
  cognito_user_pool_client_id = module.cognito.client_id
  cognito_user_pool_domain    = module.cognito.domain
  app_fqdn                    = var.route53_record_name
  cognito_hosted_domain       = module.cognito.hosted_domain
}



module "ecs" {
  source = "./modules/ecs"

  name             = local.name
  vpc_id           = module.network.vpc_id
  private_subnets  = module.network.private_subnet_ids
  alb_sg_id        = module.alb.alb_sg_id
  target_group_arn = module.alb.target_group_arn

  app_port      = var.app_port
  desired_count = var.desired_count

  # hello-world container (public). You can swap later to your ECR image.
  container_image = "public.ecr.aws/nginx/nginx:latest"
}

module "route53" {
  source = "./modules/route53"

  zone_name    = var.route53_zone_name
  record_name  = var.route53_record_name
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}

module "acm" {
  source = "./modules/acm"

  zone_name   = var.route53_zone_name
  domain_name = var.route53_record_name # ecs.bekarys2003.com
}

module "cognito" {
  source = "./modules/cognito"

  name     = local.name
  app_fqdn = var.route53_record_name
}

module "hr_feed_queue" {
  source = "./modules/sqs"
  name   = "${local.name}-hr-feed-queue"
}

module "integration_iam" {
  source    = "./modules/iam"
  name      = "${local.name}-integration"
  queue_arn = module.hr_feed_queue.queue_arn
}

module "hr_feed_ingest_lambda" {
  source   = "./modules/lambda_ingest"
  name     = "${local.name}-hr-feed-ingest"
  role_arn  = module.integration_iam.lambda_role_arn
  queue_url = module.hr_feed_queue.queue_url
  # tags    = local.tags  # only if you defined local.tags
}

module "integrations_api" {
  source                = "./modules/apigw_http"
  name                  = "${local.name}-integrations-api"
  lambda_invoke_arn      = module.hr_feed_ingest_lambda.invoke_arn
  lambda_function_name   = module.hr_feed_ingest_lambda.function_name
  # tags                 = local.tags
}

module "hr_feed_consumer_lambda" {
  source    = "./modules/lambda_consumer"
  name      = "${local.name}-hr-feed-consumer"
  queue_arn = module.hr_feed_queue.queue_arn
  # tags    = local.tags  # only if you defined local.tags
}

module "dlq_alarm" {
  source   = "./modules/alarms"
  name     = local.name
  dlq_name = "${local.name}-hr-feed-queue-dlq"
}
