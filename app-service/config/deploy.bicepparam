using '../deployment/deploy.bicep'

param vmName = 'linux-vm'
param vmSize = 'Standard_B2ms'
param adminUsername = 'bpdev'
param adminPasswordOrKey = 'simplepassword1!'
param ubuntuOSVersion = 'Ubuntu-2004'

param virtualNetworkName = 'bpdev-vnet-cicd-test'
param subnetName = 'default'
