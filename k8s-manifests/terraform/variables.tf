# Common 
variable "application_name" {
    description = "What is the name of the k8s application/deployment?"
    type        = string
    default     = "nodejs-test"
}

variable "namespace" {
    description = "In which namespace resources should be deployed?"
    type        = string
    default     = "release"
}

variable "deployment_labels" {
    description = "What labels deployment should contain?"
    type        = map(string)
    default     = {
        priority                  = "system-node-critical"
        iscritical                = "yes"
        "app.kubernetes.io/name"  = "nodejs-test"
    }
}

# Deployment vars
variable "replicas" {
    description = "How many replicas deployment should have? [doesnt matter if HPA is enabled]"
    type        = string
    default     = "7"
}

variable "container_resources_cpu_requested" {
    description = "What should be the requested cpu? [minimum]"
    type        = string
    default     = "30m"
}

variable "container_resources_cpu_limit" {
    description = "What should be the limit for cpu? [maximum]"
    type        = string
    default     = "45m"
}

variable "container_resources_memory_requested" {
    description = "What should be the requested memory? [minimum]"
    type        = string
    default     = "64Mi"
}

variable "container_resources_memory_limit" {
    description = "What should be the limit for memory? [maximum]"
    type        = string
    default     = "128Mi"
}

variable "container_image" {
    description = "Which docker images should be used? [docker image URI]"
    type        = string
    default     = "267580519047.dkr.ecr.us-west-2.amazonaws.com/nodejs-test:latest"
}

variable "container_port" {
    description = "What port your application will expose?"
    type        = string
    default     = "3000"
}

# Service variables
variable "service_port" {
    description = "What port your k8s service will expose?"
    type        = string
    default     = "3000"
}

variable "service_type" {
    description = "What is the type of k8s service? [NodePort|ClusterIP|LoadBalancer]"
    type        = string
    default     = "LoadBalancer"
}


# HPA
variable "hpa_min_replicas" {
    description = "What will be the minimum number of replicas for HPA?"
    type        = string
    default     = "7"
}

variable "hpa_max_replicas" {
    description = "What will be the maximum number of replicas for HPA?"
    type        = string
    default     = "10"
}

variable "hpa_scale_target_ref_kind" {
    description = "What is the 'Kind' of target?"
    type        = string
    default     = "Deployment"
}

variable "hpa_scale_target_ref_api_version" {
    description = "What is the 'apiVersion' of target?"
    type        = string
    default     = "apps/v1"
}

variable "hpa_cpu_average_utilization" {
    description = "Deployment should scale when avg cpu utilisation % reached?"
    type        = string
    default     = "50"
}

variable "hpa_memory_average_utilization" {
    description = "Deployment should scale when avg memory utilisation % reached?"
    type        = string
    default     = "60"
}