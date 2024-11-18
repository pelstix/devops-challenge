provider "aws" {
  region = "eu-west-2"
}

module "network" {
  source = "./modules/network"
  instance = module.instances.k8s_bastion_instance_id
  
}

module "instances" {
  source = "./modules/ec2_instances"
  private_subnet_id   = module.network.private_subnet_id
  public_subnet_id   = module.network.public_subnet_id
  vpc_security_group_ids_1 = [module.security_groups.k8s_sg_id]
  vpc_security_group_ids_2 = [module.security_groups.bastion_sg_id]
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.network.vpc_id
}



module "autoscaling" {
  source = "./modules/asg"
  vpc_security_group_ids = [module.security_groups.worker_sg_id]
  private_subnet_id = module.network.private_subnet_id
  alb = module.alb.target_group_arn
  alb_2 = module.alb.target_group_arn_2
  master = module.instances.k8s_master_instance_id
}

module "alb" {
  source = "./modules/alb"
  security_groups = [module.security_groups.alb_sg_id]
  vpc_id = module.network.vpc_id
  subnet_id   = module.network.public_subnet_id
  subnet_id_b = module.network.public_subnet_id_2
}

