variable "address" {
  description = "Web address to check (including scheme)"
}

variable "enabled" {
  description = "Whether to do anything at all. Accepts the string 'true' or 'false'."
  default = "true"
}
variable "schedule_expression" {
  description = "The cloudwatch schedule expression used to run the updater lambda."
  default = "cron(*/5 * * * ? *)"
}

variable "sns_topic_arn" {
  description = "The SNS topic to trigger if site is not responsive"
  default = "server_maintenance"
}
