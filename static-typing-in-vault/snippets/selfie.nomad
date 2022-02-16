job "selfie" {
  type = "service"
  datacenters = ["main"]
  vault {
    policies = ["application"]
  }

  group "server" {
    count = 1

    network {
      port "http" {
        to = 80
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "nginx:latest"
        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 50
      }

      template {
        data = <<-EOF
{{with secret "secret/production/selfie/s3-creds"}}
AWS_KEY_ID={{.Data.access_key_id}}
AWS_KEY_SECRET={{.Data.access_key_secret}}
S3_BUCKET={{.Data.bucket}}
S3_REGION={{.Data.region}}
{{end}}
EOF
        destination = "local/env"
        env = true
      }
    }
  }
}
