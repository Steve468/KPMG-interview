from azure.identity import ClientSecretCredential
from azure.mgmt.compute import ComputeManagementClient

credential = ClientSecretCredential(
client_id = 'd2572e8f-4f9f-4552-8d76-c6f0faa1a14c',
client_secret = 'clC8Q~ZRXQdG-.EjHzybia5xIUVrPa4.Uqsabb0r',
tenant_id = '02a8664d-3660-433f-a6d8-806ee5dff2ab'
)

compute_client = ComputeManagementClient(
    credential=credential,
    subscription_id=subscription_id
)

# VM resource group and name
resource_group_name = 'KPMGinterview'
vm_name = 'webServer'

# Get the metadata of the VM
metadata = compute_client.virtual_machines.instance_view(resource_group_name, vm_name).serialize()

# Convert the metadata to JSON format
metadata_json = json.dumps(metadata, indent=4)

print(metadata_json)

# List all Virtual Machines in the specified subscription
def list_virtual_machines():
    for vm in compute_client.virtual_machines.list_all():
        print(vm.name)

#list_virtual_machines()
