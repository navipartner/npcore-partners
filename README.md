# Legal
The code in this repository is NOT licensed for usage without a commercial relationship with NaviPartner that explicitly grants usage rights. We provide this code publicly solely for the purpose of Partner PTE development, troubleshooting, and feedback purposes.

# Intro
Welcome to the NP Retail partner repository.  
This repo contains our daily commits, our release feed and our release notes.  
This readme.md file serves as a "Getting Started" section for working with NP Retail as a partner developer.

## Releases & changelogs 
See the "Releases" section in this github repo for release notes.  
Every sunday evening a new release is created with fresh improvements and bug fixes from our master branch.  
We deploy this to our own direct customers within 2 weeks in BC SaaS, starting monday morning, so these releases get instantly tested by us.

# PTE Examples 

### POS Actions
A common task when creating PTEs on top of NP Retail is to create a POS action, which can be configured on buttons in the POS.  
To help with this we have a VSCode extension that you should install to get intellisense, linting and minification for your javascript code that needs to be embedded into codeunits:  
https://marketplace.visualstudio.com/items?itemName=NaviPartner.np-retail-workflow-language-support  

We also have a hello world POS Action example repo here:  
(Coming soon)

# Extendability and public APIs
Just like when looking for extension points in the baseapp from Microsoft, you should use this repos source access and the Event Recorder (https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-events-discoverability) to figure out where you can hook into NP Retail.

If you get blocked by a fully internal API or missing events then reach out to your point of contact from NP. 

# Breaking Changes
We strive to avoid breaking changes in our releases but when it cannot be avoided we will aim for at least a year of ObsoletePending.
Our tags are set to the date our developer added the Obsolete warning.

# Release feed
You can manually download our release artifacts under the "Releases" section of this repo.

If you want to programmatically compile against our latest apps, for example from a github action, you need access to our release feed. 
Long term MS has announced they will have a unified ISV app feed but until then, we are maintaining a NuGet feed for partners in azure devops.
Please reach out to your point of contact from NP to get access. The process is documented here:    
https://docs.navipartner.com/docs/partner/artifact_feeds/

# Pipelines
If you develop a PTE with a dependency on NP Retail then you should use AL-Go to setup a nightly pipeline that downloads latest release from NaviPartner & Microsoft and compiles + runs your tests against.
You should also have a warning-only pipeline that attempts to compile against latest insider (unreleased) version from NaviPartner and Microsoft so you can catch future problems early, especially upcoming breaking changes.