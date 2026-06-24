resource "docker_volume" "postgres_storage" {
  name = "asgard_postgres_data"
}

resource "docker_volume" "redis_storage" {
  name = "asgard_redis_data"
}
