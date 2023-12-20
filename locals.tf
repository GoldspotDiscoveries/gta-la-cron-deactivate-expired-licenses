# THIS FILE CONTAINS THE VALUES WE SET DEPENDING ON THE WORKSPACES
locals {
  environment = local.environment_value["${terraform.workspace}"] != null ? local.environment_value["${terraform.workspace}"] : "${terraform.workspace}"
  # Mapping of workspace to environment
  environment_value = {
    default = "test",
    prod    = "prod",
  }
  # Mapping of workspace to environment
  timeout = local.timeout_value["${terraform.workspace}"]
  timeout_value = {
    # lots of more garbage in TEST
    default = 60,
    prod    = 30,
  }
}
