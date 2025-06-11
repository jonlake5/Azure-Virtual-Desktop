## Overview

This module deploys and configures multiple Azure Automation runbooks per the definition. Each runbook is documented below.

## Runbooks

### addHostToDomain.ps1

#### Overview

This script will add an Azure Virtual machine to an Active Directory Domain based on the inputs provided. This functionality has
been ported into the CreateVM.ps1 runbook and should not be needed.

For all runbooks the inputs are provided as the POST call payload via the webhook.

#### Inputs

`resourceGroupName` - The resource group name the VM will be added to

`vmName` - The name of the VM to be added to the domain

`domainName` - The name of the domain for the VM to be added to

`ouPath` - The OU Path the VM should be added to

`user` - The username used to join the VM to the domain

`vaultName` - A keyvault is used to store the password used to join the domain

`secretName` - The secret within the keyvault that stores the domain join password

### addHostToPool.ps1

#### Overview

This script will add an Azure Virtual machine to an Azure Virtual Desktop host pool.

#### Inputs

`resourceGroupName` - The resource group name the VM and host pool are in

`vmName` - The name of the VM to be added to the host pool

`hostPoolName` - The name of the host pool the VM will be added to

### assignMaintenancePlanToVm.ps1

#### Overview

This script will associate an Azure Update maintenance plan with a VM

#### Inputs

`resourceGroupName` - The resource group name the VM and maintenance plan are in

`vmName` - The name of the VM to be added to the host pool

`location` - The Azure Region the VM is in

`maintenanceConfigName` - The name of the Maintenance Configuration to associate with the VM

### createHost.ps1

#### Overview

This script will create a VM based off of a shared image gallery image definition. It will use the version marked as "latest".
The VM can then either be entra joined or AD joined depending on the inputs provided. A maintenance plan can also be associated
with the VM if desired.

#### Inputs

`location` - The Azure Region the VM and vNet are in

`maintenanceConfigName` - The name of the Maintenance Configuration to associate with the VM

`galleryImage` - Defines what Compute Gallery Image Definition to use for deploying the VM. Expected format is `<GalleryName>/<imageDefinitionName>`

`vmSize` - The size of the VM to be created. Example is `Standard_B2as_v2`

`vNetName` - Defines the vNet the VM nic will be associated with

`subnetName` - Defines which subnet in the vNet the VM NIC will be associated with.

`joinType` - Defines whether the VM will be Active Directory or Entra joined. Can be either `AD` or `Entra`

`domainName` - \[Optional\] The domain name the VM will be joined to. Required if joinType is AD.

`OUPath` - \[Optional\] The OU the vm will be joined to. Expected format is `OU=foo,DC=bar,DC=com`. Required if joinType is AD.

`user` - \[Optional\] The domain user that will be used to join the VM to the domain. Format can be either UPN, DOMAIN\samAccountName or just samAccountName. Required if joinType is AD.

`vaultName` - \[Optional\] A keyvault is used to store the password used to join the domain. Required if joinType is AD.

`secretName` - \[Optional\] The secret within the keyvault that stores the domain join. Required if joinType is AD.

`maintenanceConfigName` - \[Optional\] The name of the Maintenance Configuration to associate with the VM.

`vmName` - \[Optional\] The name of the VM to be created. See note below on VM Naming

`hostPoolName` - \[Optional\] The host pool to reference when determining VM name. See note below on VM Naming.

`hostPrefix` - \[Optional\]The host prefix to be used when determining the VM Name. See note below on VM Naming

**Note: VM Naming**

The script will use a few methods to determine the name of the VM.

**vmName**

If vmName is defined it will use this static value and not consider the host prefix or hostPoolName. If the vmName doesn't end with a hyphen and number, -1 will be automatically appended to it.

**hostPoolName**

If hostPoolName is set (and vmName is not set), the script will first collect the hostnames of all the hosts in the host pool. It will then take the one with the highest number and use that as the naming standard.

For example, consider a host pool that has the following hosts in it; avd-xhost-1, avd-host-3, and avd-host-7. It will use avd-host-7 as the template. It will strip the number, increase it by 1, and then formulate the next host name. In this scenario, the new host name will be avd-host-8.

This overrides setting a host prefix in the input which may help with avoiding typos in the hostPrefix value and also not requiring hostPrefix to be set. This should always be set when creating VMs that will be added to a host pool that already has hosts in it because it will avoid duplicate naming conflicts of VMs.
Do take into consideration the name is only incremented from hosts already in the host pool. If you want to create mutliple VMs at the same time for the same host pool, use the vmName option.

**hostPrefix**

If there are no VMs in the host pool, the hostPrefix will be used to name the first VM. For example, consider a new host pool and the first VM should be named avd-host-1. This value should be set to avd-host. It will append -1 to the end of the VM when it is created.

### createRemediationPlan.ps1

#### Overview

This script will create remediation tasks for all policies that are assigned to the provided resource group/

#### Inputs

`resourceGroupName` - The resource group name the VM and maintenance plan are in

`subscriptionId` - The subscription holding the policies that will have remediation tasks created for.

`locationFilter` - The policies will only remediate against objects that are in this location.

### disableScalingPlan.ps1

#### Overview

This script will disable the scaling plan for a particular host pool, and power on any VMs in that host pool that are powered off. This is to assist with Azure Update patching windows.

#### Inputs

`resourceGroupName` - The name of the resource group the VMs and scaling plan are in.

`scalingPlanName` - The name of the scaling plan to disable for the host pool.

`hostPoolName` - The name of the host pool the scaling plan will be disabled from.

### enableScalingPlan.ps1

#### Overview

This script will enable the scaling plan for a particular host pool. This is to assist with Azure Update patching windows.

#### Inputs

`resourceGroupName` - The name of the resource group the VMs and scaling plan are in.

`scalingPlanName` - The name of the scaling plan to enable for the host pool.

`hostPoolName` - The name of the host pool the scaling plan will be enabled for.

<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                                         | Version |
| ------------------------------------------------------------ | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                             | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [azurerm_automation_account.automation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account)                      | resource    |
| [azurerm_automation_powershell72_module.module](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_powershell72_module)  | resource    |
| [azurerm_automation_runbook.runbook](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook)                         | resource    |
| [azurerm_automation_variable_string.account_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_string)      | resource    |
| [azurerm_automation_variable_string.string](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_string)          | resource    |
| [azurerm_automation_webhook.webhook](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_webhook)                         | resource    |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault)                                         | resource    |
| [azurerm_key_vault_secret.secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret)                              | resource    |
| [azurerm_role_assignment.managed_identity_read_write_key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource    |
| [azurerm_role_assignment.tf_read_write_key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)               | resource    |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config)                                | data source |

## Inputs

| Name                                                                                                                     | Description                                                  | Type                                                                                                                | Default | Required |
| ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- | ------- | :------: |
| <a name="input_automation_account_name"></a> [automation_account_name](#input_automation_account_name)                   | Name of the automation account                               | `string`                                                                                                            | n/a     |   yes    |
| <a name="input_automation_account_sku_name"></a> [automation_account_sku_name](#input_automation_account_sku_name)       | SKU of automation account                                    | `string`                                                                                                            | n/a     |   yes    |
| <a name="input_automation_variables"></a> [automation_variables](#input_automation_variables)                            | List of variables to apply to the automation account         | `list(object({ key = string, value = string }))`                                                                    | `[]`    |    no    |
| <a name="input_domain_join_password"></a> [domain_join_password](#input_domain_join_password)                            | Password used for domain join of the AVD hosts               | `string`                                                                                                            | n/a     |   yes    |
| <a name="input_identity"></a> [identity](#input_identity)                                                                | n/a                                                          | <pre>list(object({<br/> identity_ids = list(string)<br/> identity_type = string<br/> }))</pre>                      | n/a     |   yes    |
| <a name="input_keyvault_name"></a> [keyvault_name](#input_keyvault_name)                                                 | Name of keyvault used to store domain join password          | `string`                                                                                                            | n/a     |   yes    |
| <a name="input_keyvault_secret_name"></a> [keyvault_secret_name](#input_keyvault_secret_name)                            | Name of Key Vault secret that holds the domain join password | `string`                                                                                                            | n/a     |   yes    |
| <a name="input_location"></a> [location](#input_location)                                                                | Azure region                                                 | `string`                                                                                                            | n/a     |   yes    |
| <a name="input_managed_identity_principal_id"></a> [managed_identity_principal_id](#input_managed_identity_principal_id) | Principal ID of the Managed Identity used to access keyvault | `string`                                                                                                            | n/a     |   yes    |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name)                               | Name of resource group for the shared gallery                | `string`                                                                                                            | n/a     |   yes    |
| <a name="input_runbooks"></a> [runbooks](#input_runbooks)                                                                | Map of objects defining the runbook                          | <pre>map(object({<br/> file_name = string<br/> webhook = bool<br/> type = string<br/> enabled = bool<br/> }))</pre> | n/a     |   yes    |
| <a name="input_tenant_id"></a> [tenant_id](#input_tenant_id)                                                             | Tenant ID of Azure account                                   | `string`                                                                                                            | n/a     |   yes    |

## Outputs

| Name                                                                             | Description |
| -------------------------------------------------------------------------------- | ----------- |
| <a name="output_keyvault_name"></a> [keyvault_name](#output_keyvault_name)       | n/a         |
| <a name="output_keyvault_secret"></a> [keyvault_secret](#output_keyvault_secret) | n/a         |
| <a name="output_webhook_url"></a> [webhook_url](#output_webhook_url)             | n/a         |

<!-- END_TF_DOCS -->
