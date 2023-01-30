# task_4_Virtualization_and_Cloud_Basic_and_Cloud_Basic_Azure

Prerequisites 

Create azure subscription 

Create azure devops organization 

Read information about github flow branching strategy 

terraform should be installed  

Terraform knowledge is also required to do the stuff 

Az cli should be installed 

Homework 

Part 1 – Configure application 

Create a service connection in a Azure DevOps project to your subscription - https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml 

Find a .net pet project for the experiments 

Build your app locally .net project via dotnet tool. dotnet restore/build/run 

Create an Azure DevOps repo - https://learn.microsoft.com/en-us/azure/devops/repos/git/create-new-repo?view=azure-devops  You can use import repository to import from existing source control version like github 

Create a branching policy for you application. Added yourself as a reviewer - https://learn.microsoft.com/en-us/azure/devops/repos/git/branch-policies?view=azure-devops&tabs=browser As branching strategy use a github flow (It will be applied by default when you strict commit to your main branch) 

Part 2 – Configure a pipeline to deploy infrastructure  

Below is describing on how to do it via terraform. If you want to use terraform you need to create service connection in manual way. Otherwise you won’t be able to deploy your iac – Navigate to the last section 

Terraform storage account  

Create a separate resource group and deploy azure storage account - https://learn.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal 

Create a container with the name “tfstate” and remember the name. use portal settings Graphical user interface, application

Description automatically generated Graphical user interface, text, application

Description automatically generated 

In this storage account you will be store your tf state file 

Terraform preparation 

Create another repo to store devops code 

Create a folder terraform 

Add app service implementation - https://learn.microsoft.com/en-us/azure/app-service/provision-resource-terraform  

Integrate application insights with app service 

Updated backend “azurerm” according to the guide - https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli Graphical user interface, application, Word

Description automatically generated 

Run az login or Connect-AzAccount to connect the azure subscription from your local 

Run terraform apply to deploy infrastructure  

Important note: Use only freshest version of tf module like https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app 

Important note: Don’t forget to destroy your application once completed 

Create a terraform pipeline 

Create a yaml pipeline with the following steps: terraform install, terraform init, terraform plan/apply. Plan is an optional one  

Inside yaml pipeline add trigger to main branch. The scenario – when main is updated, pipeline should run automatically - https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema/trigger?view=azure-pipelines 

Added 3 steps – terraform install, terraform init, terraform plan/apply. Plan is an optional one. You may add it as 4th step 

Part 3 – Create a deploy pipeline to app service 

Add yml pipeline to the application folder 

Your pipeline structure should contain 2 stages. 1st – build, create zip archieve, and publish an artifact. 2nd – download an artifact and deploy it to azure app service  

To deploy .zip to app service use azure app service deployment task 

Service connection – manual way 

https://4bes.nl/2019/07/11/step-by-step-manually-create-an-azure-devops-service-connection-to-azure/ 

Don’t forget to grant access on the subscription level for your enterprise application (service principal) 

Useful readings  

How to share variables A picture containing graphical user interface

Description automatically generated 

Templates example for variables - https://learn.microsoft.com/en-us/samples/azure-samples/azure-pipelines-variable-templates/azure-pipelines-variable-templates/ 

Good example how to do a pipeline to build .net app and deplot tf iac - https://azuredevopslabs.com/labs/vstsextend/terraform/ Only via UI. Hence don’t forget about view yaml button in UI 

Example of the Angular application from lecture 2 - https://epam-my.sharepoint.com/:u:/p/yevhen_husiev/EWXdflfwT7pBijqGNXZnvRgBRdpB_EXlN0cJy8_SFA6_eA?e=Fc3LQW password – AQ!sw2DE£fr4 