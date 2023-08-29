variable "ingestion_details" {
  default     = {}
  description = "To create ingestion related objects in snowflake"
  type = map(object({
    cloud_platform  = optional(string)
    region          = optional(string)
    bucket         = optional(string)
    subscription_id = optional(string)
    project_id      = optional(string)
    aws_role_arn    = optional(string)
    })
  )
}
