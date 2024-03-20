locals {

  functional_role_details = {
    engineer = {
      comment = "Access as a data engineer"
    }
    modeller = {
      comment = "Access as a modeller"
    }
    analyst = {
      comment = "Access as an analyst"
    }
  }

  functional_roles = flatten(
    [
        for role_name, details in local.functional_role_details : {
          role_name = upper("${role_name}")
          comment = details["comment"]
        }
    ]
  )

  functional_role_grants = flatten(
    [
      for db_name, db_details in var.databases : [
        for role_name, comment in local.functional_role_details : {
          role_name = upper("${role_name}")
          grant_role_name = upper("${db_name}_${role_name}")
        }
      ]
    ]
  )

}


resource "snowflake_role" "functional_roles" {
  for_each = {
    for role in local.functional_roles : role.role_name => role
  }
  name    = each.key
  comment = each.value.comment
}

# Grants of roles to functional roles
resource "snowflake_role_grants" "grant_to_functional_roles" {
  for_each = {
    for role in local.functional_roles : role.role_name => role
  }
  role_name = each.key
  roles     = ["SYSADMIN", "TERRAFORM_ROLE"]
}

resource "snowflake_warehouse_grant" "functional_warehouse_grant" {
  enable_multiple_grants = true
  for_each = {
    for role in local.functional_roles : role.role_name => role
  }
  warehouse_name = "COVID_WH"
  privilege      = "USAGE"
  roles = [each.key]
  with_grant_option = false
}