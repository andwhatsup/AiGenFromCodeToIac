resource "kubernetes_cron_job_v1" "nextcloud-backup" {
  metadata {
    name = "nextcloud-backup"
  }
  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 5
    schedule                      = "5 3 * * *"
    timezone                      = "Etc/UTC"
    starting_deadline_seconds     = 10
    successful_jobs_history_limit = 10
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 10
        template {
          metadata {}
          spec {
            container {
              name              = "nextcloud-backup-cron"
              image             = "ghcr.io/tonlie/k8s-cron-nc-backup:main"
              image_pull_policy = "Always"
              env {
                name = "DB_USER"
                value_from {
                  secret_key_ref {
                    name = "nc-mariadb-secret"
                    key  = "username"
                  }
                }
              }
              env {
                name = "DB_PASS"
                value_from {
                  secret_key_ref {
                    name = "nc-mariadb-secret"
                    key  = "password"
                  }
                }
              }
              env {
                name = "DB_NAME"
                value_from {
                  secret_key_ref {
                    name = "nc-mariadb-secret"
                    key  = "database"
                  }
                }
              }
              env {
                name = "DB_HOST"
                value_from {
                  secret_key_ref {
                    name = "nc-mariadb-secret"
                    key  = "dbhost"
                  }
                }
              }
              env {
                name = "FTP_USER"
                value_from {
                  secret_key_ref {
                    name = "fritz-ftp-secret"
                    key  = "username"
                  }
                }
              }
              env {
                name = "FTP_PASS"
                value_from {
                  secret_key_ref {
                    name = "fritz-ftp-secret"
                    key  = "password"
                  }
                }
              }
              env {
                name = "FTP_HOST"
                value_from {
                  secret_key_ref {
                    name = "fritz-ftp-secret"
                    key  = "host"
                  }
                }
              }
              volume_mount {
                mount_path = "/home/nextcloud"
                name       = "nextcloud-pvc"
              }
            }
            image_pull_secrets {
              name = "container-reg"
            }
            volume {
              name = "nextcloud-pvc"
              persistent_volume_claim {
                claim_name = "nextcloud-pvc"
              }
            }
          }
        }
      }
    }
  }
}