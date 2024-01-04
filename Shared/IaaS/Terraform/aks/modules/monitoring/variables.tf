variable "enableAppInsights" {
  type = bool
  default = true
}

variable "enablePrometheus" {
  type = bool
  default = true
}

variable "resourceGroupName" {
  type = string
}

variable "location" {
  type = string
}

variable "clusterName" {
  type = string
}

variable "clusterId" {
  type = string
}

variable "logAnalyticsWorkspaceId" {
  type = string
}

variable "uniqueSuffix" {
  type = string
}