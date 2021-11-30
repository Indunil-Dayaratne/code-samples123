# Brit Terraform Modules

## Introduction

This repo contains Terraform Modules designed to be re-used in new pipelines and deployments. It allows for centralised management and standardisation of the infrastructure being deployed with Terraform.

## Getting Started

To use one of the modules in your own configuration, you will need to follow these steps:

1. Include the _TerraformModules_ repo in your pipeline
2. Checkout the appropriate release/tag for the module version you are using
3. When referencing the module in your configuration, use the relative path to the module - see below for an example
4. Finally, to ensure you do not encounter any issues, always use interpolation syntax where possible when providing input to the module

## Build and Test

All of the modules have basic validation run against them to ensure that they do not have syntax errors. The aim is for each module to also have a pester test associated with it that will deploy the module using known inputs in a test environment and then verify that the correct infrastructure is in Azure, before destroying it.

## Contribute

Feel free to add additional modules as required, but do bear this in mind: A module should be a mini-configuration that we will want to deploy again, e.g. Virtual Machine, where we want the majority of options to be standardised. It is *not* appropriate to create a module for something that will only be used once or where there is some very specific or non-standard configuration required.
