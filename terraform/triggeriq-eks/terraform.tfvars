environments = {
  default = {
    # Global variables
    cluster_name                   = "triggeriq-cluster"
    env                            = "default"
    region                         = "eu-west-3"
    vpc_id                         = "vpc-095e749736cb7dd5e"
    vpc_cidr                       = "10.0.0.0/16"
    public_subnet_ids              = ["subnet-0c4737b6d9ffd2502", "subnet-0c2052ed18df6d08f"]
    cluster_version                = "1.30"
    cluster_endpoint_public_access = true
    ecr_names                      = ["triggeriq"]

    # EKS variables
    eks_managed_node_groups = {
      triggeriq-nodes = {
        min_size       = 1
        max_size       = 2
        desired_size   = 1
        ami_type       = "AL2_x86_64"
        instance_types = ["t3.medium", "t3.large", "t3a.medium", "t3a.large"]
#         capacity_type  = "SPOT"
        disk_size      = 60
        ebs_optimized  = true
        iam_role_additional_policies = {
          ssm_access        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
          cloudwatch_access = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
          service_role_ssm  = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
          default_policy    = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
        }
      }
    }
    cluster_security_group_additional_rules = {}

    # EKS Cluster Logging
    cluster_enabled_log_types = ["audit"]
    eks_access_entries = {
      viewer = {
        user_arn = []
      }
      admin = {
        user_arn = ["arn:aws:iam::811904917041:user/triggeriq-admin"]
      }
    }
    # EKS Addons variables
    coredns_config = {
      replicaCount = 1
    }
  }

}
