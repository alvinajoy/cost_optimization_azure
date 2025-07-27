provider "azurerm" {
  features {}
  subscription_id = "b98dd885-9570-48df-ad69-d88b686a2563"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Storage Account (for blobs + function code)
resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "archive" {
  name                  = "billing-archive"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

# Cosmos DB
resource "azurerm_cosmosdb_account" "cosmos" {
  name                = var.cosmos_account_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name                = "billing-db"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
}

resource "azurerm_cosmosdb_sql_container" "container" {
  name                = "billing-records"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  database_name       = azurerm_cosmosdb_sql_database.db.name
  throughput          = 400

  partition_key_paths = ["/partitionKey"]
  partition_key_version = 2
}


# Application Insights (required for Function Apps)
resource "azurerm_application_insights" "ai" {
  name                = "${var.prefix}-ai"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# Function App Plan
resource "azurerm_service_plan" "plan" {
  name                = "${var.prefix}-plan"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name = "F1"
}

# Archive Function App
resource "azurerm_linux_function_app" "archive_function" {
  name                       = "${var.prefix}-archive"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  functions_extension_version = "~4"

  site_config {
    application_stack {
      python_version = "3.10"
    }
  }

  app_settings = {
    "AzureWebJobsStorage" = azurerm_storage_account.sa.primary_connection_string
    "COSMOS_ENDPOINT"     = azurerm_cosmosdb_account.cosmos.endpoint
    "COSMOS_KEY"          = azurerm_cosmosdb_account.cosmos.primary_key
    "COSMOS_DB"           = azurerm_cosmosdb_sql_database.db.name
    "COSMOS_CONTAINER"    = azurerm_cosmosdb_sql_container.container.name
    "BLOB_CONN_STR"       = azurerm_storage_account.sa.primary_connection_string
    "BLOB_CONTAINER"      = azurerm_storage_container.archive.name
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.ai.instrumentation_key
  }

  zip_deploy_file = "${path.module}/dist/archive_function.zip"
}

resource "azurerm_linux_function_app" "read_proxy_function" {
  name                       = "${var.prefix}-read"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  functions_extension_version = "~4"

  site_config {
    application_stack {
      python_version = "3.10"
    }
  }

  app_settings = {
    "AzureWebJobsStorage" = azurerm_storage_account.sa.primary_connection_string
    "COSMOS_ENDPOINT"     = azurerm_cosmosdb_account.cosmos.endpoint
    "COSMOS_KEY"          = azurerm_cosmosdb_account.cosmos.primary_key
    "COSMOS_DB"           = azurerm_cosmosdb_sql_database.db.name
    "COSMOS_CONTAINER"    = azurerm_cosmosdb_sql_container.container.name
    "BLOB_CONN_STR"       = azurerm_storage_account.sa.primary_connection_string
    "BLOB_CONTAINER"      = azurerm_storage_container.archive.name
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.ai.instrumentation_key
  }

  zip_deploy_file = "${path.module}/dist/read_function.zip"
}
