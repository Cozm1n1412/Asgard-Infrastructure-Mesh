# ==============================================================================
# 1. CORE PERSISTENCE LAYER (CACHE & DATABASE)
# ==============================================================================

# Redis container for Muninn and Gungnir state tracking
resource "docker_container" "redis_buffer" {
  name  = "asgard_redis_state"
  image = "redis:7-alpine"

  networks_advanced {
    name = docker_network.asgard_mesh.name
  }

  volumes {
    volume_name    = docker_volume.redis_storage.name
    container_path = "/data"
  }

  restart = "unless-stopped"
}

# PostgreSQL container for long-term telemetry persistence
resource "docker_container" "postgres_db" {
  name  = "asgard_postgres_storage"
  image = "postgres:15-alpine"

  env = [
    "POSTGRES_USER=cosmin_admin",
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "POSTGRES_DB=gungnir_telemetry" 
  ]

  networks_advanced {
    name = docker_network.asgard_mesh.name
  }

  volumes {
    volume_name    = docker_volume.postgres_storage.name
    container_path = "/var/lib/postgresql/data"
  }

  restart = "unless-stopped"
}

# ==============================================================================
# 2. CUSTOM APPLICATION IMAGES (BUILD LAYER)
# ==============================================================================

# Build the local Gungnir image from its root folder
resource "docker_image" "gungnir_image" {
  name = "gungnir-app:local"
  build {
    context = "/home/cozm1n/gungnir"
  }
}

# Build the local Muninn image from its app folder
resource "docker_image" "muninn_image" {
  name = "muninn-worker:local"
  build {
    context = "/home/cozm1n/muninn/app"
  }
}

# ==============================================================================
# 3. APPLICATION SERVICES (RUNTIME LAYER)
# ==============================================================================

# Deploy Gungnir Telemetry API container
resource "docker_container" "gungnir_api" {
  name  = "asgard_gungnir_api"
  image = docker_image.gungnir_image.image_id

  command = ["sh", "-c", "python database.py && uvicorn main:app --host 0.0.0.0 --port 8000"]

  env = [
    "REDIS_HOST=asgard_redis_state",
    "POSTGRES_HOST=asgard_postgres_storage",
    "POSTGRES_DB=gungnir_telemetry",
    "DB_USER=cosmin_admin",
    "DB_PASSWORD=${var.postgres_password}"
  ]

  networks_advanced {
    name = docker_network.asgard_mesh.name
  }

  depends_on = [
    docker_container.redis_buffer,
    docker_container.postgres_db
  ]

  restart = "unless-stopped"
}

# Deploy Gungnir Telemetry Worker container
resource "docker_container" "gungnir_worker" {
  name  = "asgard_gungnir_worker"
  image = docker_image.gungnir_image.image_id

  command  = ["python", "collector.py"]
  pid_mode = "host"

  env = [
    "REDIS_HOST=asgard_redis_state"
  ]

  networks_advanced {
    name = docker_network.asgard_mesh.name
  }

  depends_on = [
    docker_container.redis_buffer
  ]

  restart = "unless-stopped"
}

# Deploy Muninn Guardian Background Worker container
resource "docker_container" "muninn_worker" {
  name  = "asgard_muninn_worker"
  image = docker_image.muninn_image.image_id

  command = ["python", "worker.py"]

  env = [
    "REDIS_HOST=asgard_redis_state",
    "TELEGRAM_TOKEN=${var.telegram_bot_token}",
    "TELEGRAM_CHAT_ID=${var.telegram_chat_id}"
  ]

  networks_advanced {
    name = docker_network.asgard_mesh.name
  }

  depends_on = [
    docker_container.redis_buffer
  ]

  restart = "unless-stopped"
}
