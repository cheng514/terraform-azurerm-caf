global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
}

resource_groups = {
  webapp_backup = {
    name   = "webapp-backup"
    region = "region1"
  }
}

# By default asp1 will inherit from the resource group location
app_service_plans = {
  asp1 = {
    resource_group_key = "webapp_backup"
    name               = "asp-backup"

    sku = {
      tier = "Standard"
      size = "S1"
    }
  }
}

# https://docs.microsoft.com/en-us/azure/storage/
storage_accounts = {
  sa1 = {
    name               = "sa-backup"
    resource_group_key = "webapp_backup"
    # Account types are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Defaults to StorageV2
    account_kind = "BlobStorage"
    # Account Tier options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid.
    account_tier = "Standard"
    #  Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS
    account_replication_type = "LRS" # https://docs.microsoft.com/en-us/azure/storage/common/storage-redundancy
    containers = {
      backup = {
        name = "webapp-backup"
      }
    }
  }
}

app_services = {
  webapp1 = {
    resource_group_key   = "webapp_backup"
    name                 = "webapp-backup"
    app_service_plan_key = "asp1"

    settings = {
      enabled = true

      backup = {
        name                = "test"
        enabled             = true
        storage_account_key = "sa1"
        container_key       = "backup"
        //storage_account_url = "https://cindstsabackup.blob.core.windows.net/webapp-backup?sv=2018-11-09&sr=c&st=2021-02-08T07%3A07%3A42Z&se=2021-03-10T07%3A07%3A42Z&sp=racwdl&spr=https&sig=5LX%2ByDoE4YQsf%2F0L5f42eML9mk%2Fu5ejjZYVIs81Keng%3D"

        sas_policy = {
          expire_in_days = 30
          rotation = {
            #
            # Set how often the sas token must be rotated. When passed the renewal time, running the terraform plan / apply will change to a new sas token
            # Only set one of the value
            #

            # mins = 1 # only recommended for CI and demo
            days = 7
            # months = 1
          }
        }

        schedule = {
          frequency_interval       = 1
          frequency_unit           = "Day"
          keep_at_least_one_backup = true
          retention_period_in_days = 1
          start_time               = "2021-02-08T00:00:00Z"
        }
      }
    }
  }
}