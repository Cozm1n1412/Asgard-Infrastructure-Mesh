variable "postgres_password" {
  type        = string
  description = "The password for the PostgreSQL root user"
  default     = "dev_secure_password_2026" # Safe for local GitHub portfolio
}

variable "telegram_bot_token" {
  type        = string
  description = "The token for the Muninn Telegram Bot"
  default     = "8937818194:AAFf3pJmm3Gg9mjV9nPWqmHqrV8Lj6dmk1w"
}

variable "telegram_chat_id" {
  type        = string
  description = "The Telegram chat ID where Muninn sends alerts"
  default     = "8612421320"
}
