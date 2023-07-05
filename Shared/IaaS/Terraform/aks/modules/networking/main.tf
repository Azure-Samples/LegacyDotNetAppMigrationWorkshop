##############
# CAF MODULE #
##############

module "CAFResourceNames" {
  source      = "../naming"
  workload    = "gsma"
  environment = "dev"
  region      = "eus"
  instance    = "001"
}