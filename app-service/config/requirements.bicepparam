using '../deployment/requirements.bicep'

param virtualNetworkName = 'bpdev-vnet-cicd-test'
param location = 'westeurope'
param addressSpace = '10.0.0.0/16'

param subnets = [
  {
    name: 'default'
    properties: {
      addressPrefix: '10.0.1.0/24'
    }
  }
]
