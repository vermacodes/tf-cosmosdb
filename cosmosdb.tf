

resource "azurerm_resource_group" "rg" {
  name     = "av035p-temp-rg"
  location = var.location
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# You would need an account to house it all.
resource "azurerm_cosmosdb_account" "db_account" {
  name                = "temp-db-${random_integer.ri.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }
}

# A database is needed; Its a database afterall.
resource "azurerm_cosmosdb_sql_database" "sql_db" {
  name                = "TMUsers"
  resource_group_name = azurerm_cosmosdb_account.db_account.resource_group_name
  account_name        = azurerm_cosmosdb_account.db_account.name
  throughput          = 400
}


# A container is in the database.
resource "azurerm_cosmosdb_sql_container" "sql_container" {
  name                = "tmusers-container"
  resource_group_name = azurerm_cosmosdb_account.db_account.resource_group_name
  account_name        = azurerm_cosmosdb_account.db_account.name
  database_name       = azurerm_cosmosdb_sql_database.sql_db.name
  partition_key_path  = "/lastName"
  throughput          = 400
}


output "uri" {
  value = azurerm_cosmosdb_account.db_account.endpoint
}

output "key" {
  value = azurerm_cosmosdb_account.db_account.primary_master_key
}

output "database" {  value = azurerm_cosmosdb_sql_database.sql_db.name
}
