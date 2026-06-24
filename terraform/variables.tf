variable "postgres_password" {
  type        = string
  description = "The password for the PostgreSQL root user"
  default     = "dev_secure_password_2026" # Safe for local GitHub portfolio
}

variable "telegram_bot_token" {
  type        = string
  description = "The token for the Muninn Telegram Bot"
  default = "secret-stored-in-jenkins"
}

variable "telegram_chat_id" {
  type        = string
  description = "The Telegram chat ID where Muninn sends alerts"
  default     = "secret-stored-in-jenkins"
}
