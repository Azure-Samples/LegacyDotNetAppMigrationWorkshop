# Investigating the source applications

## Overview

In this lab, you will login to your jump box of choice and checkout the sample applications The sample legacy applications will be used as the source for migrating to Azure.

Applications

* TimeTracker
* Classifieds
* Jobs
* IBuySpy

## Prerequisites

* You have the working source environment deployed on [Lab 01](../01-setup/README.md)

## Environment
When you deployed HoL 1, you deployed resources you will need for subsequent labs. To complete the labs, you will be working from one of the Virtual Machines that has been deployed. You have the choice of using a Windows Server 2008, 2012, 2016, or 2019 to complete the labs. The 2008 jump box does not have the IBuySpy application because it could not support .NET 4.8 therefore keep that in mind when completing the later labs that utilize the IBuySpy application. 

## Exercises

This hands-on-lab has the following exercises:
- [Investigating the source applications](#investigating-the-source-applications)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Environment](#environment)
  - [Exercises](#exercises)
    - [Exercise 1: Checkout the applications](#exercise-1-checkout-the-applications)
  - [Summary](#summary)
- [Next Step](#next-step)
  - [:arrow\_forward: Choose Migration Path](#arrow_forward-choose-migration-path)

### Exercise 1: Checkout the applications
1. Connect to the jump box of your choice using Bastion via [RDP](https://learn.microsoft.com/azure/bastion/bastion-connect-vm-rdp-windows) or [SSH](https://learn.microsoft.com/en-us/azure/bastion/bastion-connect-vm-ssh-windows). See [HOL 1](../01-setup/) if you haven't deployed the infrastructure already.
2. In the Windows Search box, search for *IIS Manager*. Expand *Sites* and you will see four applications:
   1. TimeTracker
   2. Classifieds
   3. Jobs
   4. IBuySpy
   
   You can open each of these applications and check out the UI. Each of these applications is using a SQL database located on the same virtual machine as its backend. If you'd like to checkout the databases, you can open SQL Server Management Studio to view the local databases. 

## Summary

In this hands-on lab, you learned how to:

* Login to your jump box of choice
* Open the legacy applications on IIS

# Next Step
:arrow_forward: [Choose Migration Path](../03-choose-migration-path/README.md)
----

Copyright 2023 Microsoft Corporation. All rights reserved. Except where otherwise noted, these materials are licensed under the terms of the MIT License. You may use them according to the license as is most appropriate for your project. The terms of this license can be found at https://opensource.org/licenses/MIT.