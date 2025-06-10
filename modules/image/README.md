<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_shared_image.avd-win11](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hyper_v_generation"></a> [hyper\_v\_generation](#input\_hyper\_v\_generation) | Hyper V Generation of the VM created | `string` | `"V2"` | no |
| <a name="input_location"></a> [location](#input\_location) | Location of the shared image gallery | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of resource group for the shared gallery | `string` | n/a | yes |
| <a name="input_shared_image_gallery_name"></a> [shared\_image\_gallery\_name](#input\_shared\_image\_gallery\_name) | Name of existing shared image gallery to put the shared image in | `string` | n/a | yes |
| <a name="input_shared_image_name"></a> [shared\_image\_name](#input\_shared\_image\_name) | Name of the shared image being created | `string` | n/a | yes |
| <a name="input_shared_image_offer"></a> [shared\_image\_offer](#input\_shared\_image\_offer) | Offer of the source image the golden image will be created from | `string` | `"windows-11"` | no |
| <a name="input_shared_image_publisher"></a> [shared\_image\_publisher](#input\_shared\_image\_publisher) | Publisher of the source image the golden image will be created from | `string` | `"MyOrg"` | no |
| <a name="input_shared_image_sku"></a> [shared\_image\_sku](#input\_shared\_image\_sku) | SKU of the source image the golden image will be created from | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->