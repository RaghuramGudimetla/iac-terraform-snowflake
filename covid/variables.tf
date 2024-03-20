variable "databases" {
  type    = map(object({
    comment = string
  }))
  default = {
    covid = {
      comment = "Database for covid data"
    }
  }
}

variable "schemas" {
  type    = map(object({
    comment = string
  }))
  default = {
    raw = {
      comment = "To land raw data"
    }
    staging = {
      comment = "To staging if there is any raw data"
    }
    data_warehouse = {
      comment = "To create facts and dimensions"
    }
    data_mart = {
      comment = "tables for end customers"
    }
  }
}

variable "access_roles" {
    type    = list(string)
    default = ["engineer", "modeller", "analyst"]
}

variable "users" {
    type = map(object({
        comment = string
    }))
    default = {
        engineer = {
            comment = "User having access to RAW data"
        }
        analyst = {
            comment = "User with data to facts and dimensions"
        }
    }
}

# https://docs.snowflake.com/en/user-guide/security-access-control-privileges
# This can be changed
variable "schema_grants" {
    type = list(string)
    default = [
        "USAGE"
    ]
}

variable "database_grants" {
    type = list(string)
    default = [
        "USAGE"
    ]
}

variable "table_grants" {
    type = list(string)
    default = [
        "SELECT"
    ]
}

variable "view_grants" {
    type = list(string)
    default = [
        "SELECT"
    ]
}