##############
# CAF MODULE #
##############

module "CAFResourceNames" {
  source      = "../naming"
  workload    = "aksgsma"
  environment = "dev"
  region      = "eus"
  instance    = "001"
}