# Introduction
ESB - Enterprise Service Bus is the async messaging solution for Brit Insurance

Note, this repository pre-dates BRIT's implementation of Terraform, hence there are serveral Infrastructure folders which are maintained and deployed independently.

* ESB.Infrastructure: Legacy ARM templates used to initially deploy ESB Infrastructure. Pre-dates Terraform. Should no longer be extended.

* ESB.ServiceBus.Infrastructure: Extensions to ESB.Infrastructure for Azure Service Bus and Storage related components. Now using Terraform.

    * Pipelines: https://dev.azure.com/britgroupservices/Apps/_release?_a=releases&view=all&path=%5Cuwac-platform-esb

* ESB.FunctionApp.Infrastructure. Extensions to ESB.Infrastructure for Notification Function related componenets. Now using Terraform

    * Pipelines: https://dev.azure.com/britgroupservices/Apps/_release?_a=releases&view=all&path=%5Cuwac-platform-notification-function
    

