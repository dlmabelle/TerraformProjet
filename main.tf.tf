# main.tf

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.23.1"
    }
  }
}
provider "docker" {
 host = "tcp://localhost:2375"  # Docker daemon host (adjust as needed)
}

resource "docker_network" "prestashop_network" {
  # Déclaration du réseau Docker nommé "prestashop_network"
  name = "prestashop_network"
}
resource "docker_container" "db_container" {
  # Conteneur de base de données
  name  = "prestashop_db"
  image = "mysql:5.7"
  ports {
    internal = 3306
  }
  environment = {
    MYSQL_ROOT_PASSWORD = var.db_password
    # Autres variables d'environnement MySQL
  }
  networks_advanced {
    name = docker_network.prestashop_network.name
  }
}

resource "docker_container" "prestashop_container" {
  # Conteneur PrestaShop
  name  = "prestashop_app"
  image = "prestashop/prestashop:latest"
  ports {
    internal = 80
    external = 8080
  }
  environment = {
    DB_SERVER      = "prestashop_db"
    DB_USER        = var.db_user
    DB_PASSWORD    = var.db_password
    # Autres variables d'environnement PrestaShop
  }
  networks_advanced {
    name = docker_network.prestashop_network.name
  }
}
