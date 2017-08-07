// Download the backup files from S3

// No SSL disable it below ...
provider "postgresql" {
  username = "${var.postgres_user}"
  host = "${var.postgres_host}"
  password = "${var.postgres_password}"
  sslmode = "disable"
}

resource "postgresql_role" "pgrole" {
  count = 1
  name = "${var.sandman_user}"
  bypass_row_level_security = false
  create_database = false
  create_role = false
  encrypted_password = true
  login = true
  replication = false
  inherit = false
  superuser = true
  password = "${var.sandman_password}"
}

resource "postgresql_database" "pgdb" {
  count = 1
  name = "${var.sandman_user}"
  allow_connections = true
  encoding = "UTF8"
  lc_collate = "C"
  lc_ctype = "C"
  owner = "${postgresql_role.pgrole.name}"
  // Restore the file via the use of execution ..
  provisioner "local-exec" {
    command = "sleep 5 && echo passw0rd | /Users/leow/POSTGRESQL/pg96/bin/pg_restore -h localhost -U sandman_development -v -d sandman_production --no-owner /Users/leow/POSTGRESQL/sandman-backup-2017-06-27_02-00-01"
  }
}

resource "postgresql_schema" "pgsch" {
  count = 0
  name = "myrestore"
  owner = "${postgresql_role.pgrole.name}"

  policy {
    usage = "true"
    role = "${postgresql_role.pgrole.name}"
  }
}

