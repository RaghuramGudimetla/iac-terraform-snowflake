locals {

  access_roles_grants = {
    analyst = {
      schemas = [
        "data_mart"
      ]
    }
    modeller = {
      schemas = [
        "data_warehouse",
        "data_mart"
      ]
    }
    engineer = {
      schemas = [
        "raw",
        "staging",
        "data_warehouse",
        "data_mart"
      ]
    }
  }

  access_roles = flatten(
    [
      for db_name, db_details in var.databases : [
        for role in var.access_roles : {
          role_name = upper("${db_name}_${role}")
          database = upper("${db_name}")
          comment = "Role as ${role} to the database ${db_name}"
        }
      ]
    ]
  )

  access_role_schema_grants = flatten(
    [
      for db_name, db_details in var.databases : [
        for role, details in local.access_roles_grants : [
          for schema_name in details["schemas"] : {
            database = upper(db_name)
            schema = upper(schema_name)
            role_name = upper("${db_name}_${role}")
          }
        ]
      ]
    ]
  )


  functional_role_grants_from_access_roles = flatten(
    [
      for db_name, db_details in var.databases : [
        for role, details in local.access_roles_grants : {
          role_name = upper("${db_name}_${role}")
          parent_role = upper(role)
        }
      ]
    ]
  )

}

resource "snowflake_role" "access_roles" {
  for_each = {
    for role in local.access_roles : role.role_name => role
  }
  name    = each.value.role_name
  comment = each.value.comment
}

# Grants of roles to functional roles
resource "snowflake_role_grants" "grant_to_access_roles" {
  for_each = {
    for role in local.access_roles : role.role_name => role
  }
  role_name = each.value.role_name
  roles     = ["SYSADMIN", "TERRAFORM_ROLE"]
}


# Grants of roles to functional roles
resource "snowflake_role_grants" "grant_access_roles_to_functional_roles" {
  for_each = {
    for role in local.functional_role_grants_from_access_roles : role.role_name => role
  }
  role_name = each.value.role_name
  roles     = [each.value.parent_role]
}

# Grants 
resource "snowflake_database_grant" "database_grants" {
  enable_multiple_grants = true
  for_each = {
    for role in local.access_roles : role.role_name => role
  }
  database_name     = each.value.database
  privilege         = "USAGE"
  roles             = [each.value.role_name]
  with_grant_option = false

  depends_on = [
    snowflake_database.databases,
    snowflake_role.access_roles
  ]
}


resource "snowflake_schema_grant" "schema_grants" {
  enable_multiple_grants = true
  for_each = {
    for role in local.access_role_schema_grants : "${role.database}.${role.schema}.${role.role_name}" => role
  }
  database_name     = each.value.database
  schema_name       = each.value.schema
  privilege         = "USAGE"
  roles             = [each.value.role_name]
  with_grant_option = false

  depends_on = [
    snowflake_database.databases,
    snowflake_role.access_roles
  ]
}


resource "snowflake_table_grant" "table_grants" {
  enable_multiple_grants = true
  for_each = {
    for role in local.access_role_schema_grants : "${role.database}.${role.schema}.${role.role_name}" => role
  }
  database_name     = each.value.database
  schema_name       = each.value.schema
  privilege         = "SELECT"
  roles             = [each.value.role_name]
  on_future         = true
  with_grant_option = false

  depends_on = [
    snowflake_database.databases,
    snowflake_role.access_roles
  ]
}


resource "snowflake_view_grant" "view_grants" {
  enable_multiple_grants = true
  for_each = {
    for role in local.access_role_schema_grants : "${role.database}.${role.schema}.${role.role_name}" => role
  }
  database_name     = each.value.database
  schema_name       = each.value.schema
  privilege         = "SELECT"
  roles             = [each.value.role_name]
  on_future         = true
  with_grant_option = false

  depends_on = [
    snowflake_database.databases,
    snowflake_role.access_roles
  ]
}

resource "snowflake_warehouse_grant" "access_warehouse_grant" {
  enable_multiple_grants = true
  for_each = {
    for role in local.access_roles : role.role_name => role
  }
  warehouse_name = "COVID_WH"
  privilege      = "USAGE"
  roles = [each.value.role_name]
  with_grant_option = false
}