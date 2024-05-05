disable_mlock = true
ui = true
api_addr = ""
default_lease_ttl = "168h"
max_lease_ttl = "0h"
log_level = "Debug"

listener "tcp" {
    address = "0.0.0.0:8200"
    tls_disable = 1
}

backend "file" {
    path = "/vault/file"
}

