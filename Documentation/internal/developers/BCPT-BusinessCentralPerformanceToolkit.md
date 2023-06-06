# Business Central Performance Toolkit - BCPT

## Table of contents

1. [What is Business Central Performance Toolkit Extension](https://navipartner.visualstudio.com/NpCore/_git/NpCore?path=/Documentation/internal/developers/BCPT-BusinessCentralPerformanceToolkit.md&_a=preview&anchor=what-is-business-central-performance-toolkit-extension%3F)
2. [How to set Business Central environment in order to use Performance Toolkit](https://navipartner.visualstudio.com/NpCore/_git/NpCore?path=/Documentation/internal/developers/BCPT-BusinessCentralPerformanceToolkit.md&_a=preview&anchor=how-to-set-business-central-environment-in-order-to-use-performance-toolkit)
3. [Setting up the data necessary for using Performance Toolkit extension](https://navipartner.visualstudio.com/NpCore/_git/NpCore?path=/Documentation/internal/developers/BCPT-BusinessCentralPerformanceToolkit.md&_a=preview&anchor=setting-up-the-data-necessary-for-using-performance-toolkit-extension)
4. [Running BCPT Suites](https://navipartner.visualstudio.com/NpCore/_git/NpCore?path=/Documentation/internal/developers/BCPT-BusinessCentralPerformanceToolkit.md&_a=preview&anchor=running-bcpt-suites)
5. [BCPT - known limitations for running multiple concurrent sessions](https://navipartner.visualstudio.com/NpCore/_git/NpCore?path=/Documentation/internal/developers/BCPT-BusinessCentralPerformanceToolkit.md&_a=preview&anchor=bcpt---known-limitations-for-running-multiple-concurrent-sessions)
6. [Displaying results of BCPT Suites runs in Application Insight (Telemetry)](https://navipartner.visualstudio.com/NpCore/_git/NpCore?path=/Documentation/internal/developers/BCPT-BusinessCentralPerformanceToolkit.md&_a=preview&anchor=displaying-results-of-bcpt-suites-runs-in-application-insight-(telemetry))
7. [Useful material for learning and understanding the Business Central Performance Toolkit - BCPT](https://navipartner.visualstudio.com/NpCore/_git/NpCore?path=/Documentation/internal/developers/BCPT-BusinessCentralPerformanceToolkit.md&_a=preview&anchor=useful-material-for-learning-and-understanding-the-business-central-performance-toolkit---bcpt)

## What is Business Central Performance Toolkit Extension?

*The Performance Toolkit extension is built for Independent Solution Vendors (ISVs) and Value Added Resellers (VARs) who develop vertical solutions and customize Business Central for their customers. Because things change between released versions, it's important that ISVs and VARs can test the performance of their solutions to ensure that new versions don't introduce performance regressions when the volume of users grows. To help, the Performance Toolkit lets developers simulate workloads in realistic scenarios to compare performance between builds of their solutions.* More about it can be found [here](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-performance-toolkit).

## How to set Business Central environment in order to use Performance Toolkit

Performance Toolkit extension can be installed in SaaS sandbox environments and containers.

### How to set SaaS sandbox environment to use Performance Toolkit

**IMPORTANT**: Performance Toolkit extension cannot be installed in the SaaS production environments.

The following should be done from the Dynamics 365 Business Central Admin Center:

1. Click **New**, and then choose the desired **Environment Name**, set the **Type** to **Sandbox**, and choose the desired **Country**.

**NOTE**: It's suggested to use **DK** (Denmark) for the **Country/Region** when creating a sandbox environment since the Performance Toolkit requires having the [proper data](https://navipartner.visualstudio.com/NpCore/_git/NpCore?path=/Documentation/internal/developers/BCPT-BusinessCentralPerformanceToolkit.md&_a=preview&anchor=setting-up-the-data-necessary-for-using-performance-toolkit-extension).      

2. In the **Environments** tab, select the newly created sandbox environment and specify the **Application Insights Connection String**.

3. (Optional) In the **Authorized AAD Apps** tab click **Authorize Azure AD app** and set **e7aed49c-17a3-49ae-9385-bfa901e61e48** as the **Application (Client) ID**.     
    This step isn't mandatory, but it prevents the login dialog from popping up whenever the token is returned while running tests from Visual Studio Code.

4. From the newly created sandbox environment open the **Extension Marketplace**, search for the **Performance Toolkit** extension and install it. 

5. From the **Extension Marketplace** search for the **NP Retail** extension and install it.     
   This can be done from Visual Studio Code as well.

6. From Visual Studio Code install our **Performance Toolkit** extension which can be found in the NP Core repository inside the **Performance Toolkit** folder.

### How to set Crane containers to use Performance Toolkit

1. On the **Crane Containers** page choose the latest Core version as the **Container Template Code**.     
   This is important, since we want to import the data from [specific Rapid Start package](https://navipartner.visualstudio.com/NpCore/_git/NpCore?path=/Documentation/internal/developers/BCPT-BusinessCentralPerformanceToolkit.md&_a=preview&anchor=import-rapid-start-package-specific-to-performance-toolkit) manually.

**NOTE**: It's suggested to use **DK** (Denmark) under the **Artifact Name** when creating the Crane container environment since **Performance Toolkit** requires having the [proper data](https://navipartner.visualstudio.com/NpCore/_git/NpCore?path=/Documentation/internal/developers/BCPT-BusinessCentralPerformanceToolkit.md&_a=preview&anchor=setting-up-the-data-necessary-for-using-performance-toolkit-extension).

2. In the **Crane Container Parameters** page add the following generic parameters as true:

- TestTKImportToolkit
- TestTKIncludeTestLibrariesOnly
- TestTKIncludePerformanceToolkit

3. From the newly created Crane container environment open the **Extension Marketplace**, search for the **Performance Toolkit** extension and install it. 

4. From Visual Studio Code install our **Performance Toolkit** extension which can be found in the NP Core repository inside the **Performance Toolkit** folder.

## Setting up the data necessary for using Performance Toolkit extension

**NOTE**: Performance Toolkit requires having the proper data. Otherwise it would require creating so much data inside each BCPT Suite that it would significantly increase the time for running the BCPT Suite which would incorrectly measure how much time it takes for that BCPT Suite to be run.

### Import Rapid Start package specific to Performance Toolkit

1. From the page **RapidStart Base Data Imp.** import the package named **MINIMAL-NPRWITHBCPT.rapidstart**.

2. From the page **BCPT Suites** select **BCPT Suite** named **INITDATA**, and run it (running it in Single Run mode is sufficient).

**IMPORTANT**: BCPT Suite named **INITDATA** must be run before running any other BCPT Suite, since it creates some data necessary for properly running the other suites.

## Running BCPT Suites

Business Central Performance Toolkit Suites, or BCPT Suites for short, can be run from the PowerShell script, via the Performance Toolkit Visual Studio Code extension or by using a dedicated DevOps pipeline.

### Running BCPT Suites from PowerShell script

Inside the Performance Toolkit folder in the NP Core repo, there is a PowerShell script named **RunBcptSaaS.ps1**. It contains the following parameters which can be changed in order to use it for different types of environment or to run different BCPT Suites:

- BCType - supports the Cloud and Crane values which determine what type of Business Central environment should be used.
- Username
- Password
- SuiteCodes - specifies which BCPT Suites should be run.
- CompanyName - specifies from which company the BCPT Suites should be run.
- TenantId - specifies the tenant of the Business Central cloud environment (needed only for cloud).
- SandboxName - specifies the name of the Business Central sandbox cloud environment (needed only for cloud).
- TenantId - specifies the tenant of the Business Central cloud environment (needed only for cloud).
- ClientID - specifies the client of the Azure AD app which is used for returning the necessary token (needed only for cloud).
- TestPageId - specifies which test runner page should be used for running BCTP Suites.
- SingleRun - specifies whether BCPT Suites should be executed in the single run mode.
- SkipDelayBeforeStart - specifies whether there should be a delay between starting sessions or if the sessions should be started all at once in the multi session scenarios.

**NOTE**: The following code can be added to the launch.json file in Visual Studio Code which allows running the PowerShell script from the **Run and Debug** tab:

```
{
    "name": "PowerShell BCPT SaaS",
    "type": "PowerShell",
    "request": "launch",
    "script": ".\\scripts\\RunBcptSaaS.ps1",
    "args": [],
    "cwd": "${workspaceRoot}"
}
```

Once PowerShell script RunBcptSaaS.ps1 has finished, the results can be seen in the following ways:

- Under each BCPT Suite that has been run there are log entries which can be examined.
- In **Application Insight** (Telemetry) named **NPRetail-PerformanceTest**. At the very end of terminal there is KQL query which can be used to show traces specific to that run.

### Running BCPT Suites from the Performance Toolkit Visual Studio Code extension

#### Prerequisite

- Have the **Performance Toolkit** extension installed in Visual Studio Code.

#### Procedure

1. By choosing command the **BCPT: Run BCPT (PowerShell)** users would be asked to choose whether they want to target Docker or SaaS environment. Since we don't support Docker, unless someone has created their own, choose **SaaS**.
2. Choose in which sandbox SaaS environment BCTP should be run.
3. Type the name of the BCPT Suite which you want to be run.

Once command BCPT: Run BCPT (PowerShell) has finished the results can be seen in the following ways:

- Under each BCPT Suite that has been run there are log entries which can be examined.
- In **Application Insight** (Telemetry) named **NPRetail-PerformanceTest**.

### Running BCPT Suites from the dedicated DevOps pipeline

In Azure DevOps under pipelines there is there is a pipeline named **NpCore run BCPT on Containers** created for running BCPT Suites. This pipeline has 3 stages:

- current_branch - runs only when some dev branch is manually chosen.
- prerelease_latest - runs when the master branch is used (default).
- release_latest - runs always and using the latest release.

**NOTE** The pipeline **NpCore run BCPT on Containers** is using a dedicated virtual machine whose purpose is to run BCPT Suites, and therefore it should be stable regarding hardware performances.

**NOTE** The **NpCore run BCPT on Containers** pipeline is set to run stages prerelease_latest and release_latest every night.

If performances of some current development need to be checked or if it is necessary to run this pipeline on demand, do the following:

1. Select the **NPCore run BCPT on Containers** pipeline and click the **Run pipeline** action.
2. Select branch/tag against which you want to run the pipeline.        
   Master is the default one, but it can be changed to any dev branch if its performances need to be checked.
3. (Optional) Under **Variables** in the variable **SuiteCodes** you can specify which BCPT Suites will be run.     
   The default value at the moment includes all the BCPT Suites with fixed delays between iterations (there are also BCPT Suites with random delays).

**IMPORTANT**: The BCPT Suite INITDATA should always be specified, and should always be specified as the first one. If there is a need to run any of POS Direct Sale Voucher Usage BCPT Suites (their code starts with POS5S), the BCPT Suite for the POS Direct Sale Voucher Issue for the same number of sessions should be set first and the BCPT Suite POS5INIT should be set before it as well. For example, the variable SuiteCodes in this specific case can look like this: @('INITDATA','POS1S1F','POS4S1F','POS4S5F','POS4S10F','POS4S10F','POS5INIT','POS5S1F','POS5S5F','POS5S10F')

Once NPCore run BCPT on Containers pipeline has been completed, the results can be seen in the following ways:

- Under each stage there is a task **BCPT: Logs** in which you can see whether there are any errors for a specific BCPT Suite and what the errors are, if they exist. If there is any error at the bottom of the BCPT: Logs task, there is the text **Detailed error log** which can be expended to display more details about the error(s).
- In the **Application Insight** (Telemetry) named **NPRetail-PerformanceTest**. Under task **BCPT: Run** at its very bottom there is a KQL query which can be used to show traces specific to that pipeline run.

## BCPT - known limitations for running multiple concurrent sessions

- From the UI (directly from Business Central client) up to 10 concurrent sessions can be run.

- From Visual Studio Code extension or PowerShell script up to 100 concurrent sessions can be run (theoretically up to 500, but there is a limit set on the field **No. of Sessions** on the **BCPT Suite Line**).

## Displaying results of BCPT Suites runs in Application Insight (Telemetry)

**WORK IN PROGRESS**

## Useful material for learning and understanding the Business Central Performance Toolkit - BCPT

- [The Performance Toolkit Extension](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-performance-toolkit)
- Various blog posts can be found about BCPT [here](https://www.bertverbeek.nl/
)
- [Dynamics 365 Business Central: How to use Performance Toolkit blog](https://yzhums.com/13940/)
- [Microsoft’s GitHub repo where can be contributed with the changes](https://github.com/microsoft/ALAppExtensions/tree/main/Modules/DevTools/BusinessCentralPerformanceToolkit)
- [Microsoft’s GitHub repo where some BCPT samples can be found](https://github.com/microsoft/ALAppExtensions/tree/main/Other/Tests/BCPT-SampleTests)