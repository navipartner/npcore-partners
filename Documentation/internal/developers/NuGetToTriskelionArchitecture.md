# Integration of NuGet feeds with Triskelion

[[_TOC_]]

We have finished the first version of the integration of **NuGet feeds and packages** with **Triskelion**. 
We are talking about the direction that let us bring the packages from NuGet feeds into Triskelion and then to publish them.

# Common workflow available today

 * Go to **Nav Apps** page and find **NP Retail app**. 
 Currently, this is the only one app being configured. You can see a new button being active on this entry (app). The action is called **New App Version From NuGet**.

    ![](/.attachments/image-1e8a9b80-46e9-4d9b-a4f2-098b32065be3.png)

 * When you click on the button, you will see the list of the packages (*TODO: currently the list includes all packages for both, **prereleases** and **releases** and we will do some separation based on the server we will be deploying to*). The package list is a fresh fetch from the NuGet feed, there is currently no caching and maybe we will need to consider such a modification in the future (let’s see in the practical life 😉).

    ![](/.attachments/image-2f2dbdb7-3659-4194-bb66-e41676c9fb14.png)

 *	When you select the **package version** you want to be registered in Triskelion, confirm your selection and wait a few moments (*it might take some time to download, extract, move files + the rest of the process that has been there already since the first days*). Then your application is available in Triskelion and you can publish it to whatever tenant you need.

    ![](/.attachments/image-7fd31964-64e7-4108-a78c-53de0ac0fcc3.png)


--- 

# Setup of the integration

Just a short idea of how do the configurations work (not something that the common users will do, of course) brings the current section.

 * We can already register multiple sources (**feeds**). This will let us set up the integration for different products or groups of products. 
 Or even for different customers/partners who will give us access to their feeds via an URL and a token. There is currently only one repo for NP Retail app. You just specify the details here and register the feed by clicking on the action **Register NuGet Source**. This will register the source on the remote (NST) server.

    ![](/.attachments/image-a064a3b0-81e9-4003-bff9-add8dbb6115b.png)

 * Then for each supported application (*TODO: figure out the initialization in the case we will get the feed and token and there won’t be any single version of the app already in Triskelion, for NP Retail it was different, there are already apps/versions registered so we already know the AppId*) you just register the link between the app (**App Id**), **NuGet Source** and **NuGet Package Name**. Everything is driven by lookups so the steps are just:

    * Select app (lookup)
    * Select NuGet Source (lookup)
    * *Select Package (lookup):

        ![](/.attachments/image-dab64891-bf6a-496d-9d71-75ff4f7a0bbc.png)

    * And that’s all. Then the new button will appear for the specific app and you will be able to use NuGet integration.

 * As you could imagine, you can use also more than one combination of the package per app. This might be important for us to setup more than one major version support. So if there is:

    * Just one active (*can be enabled, disabled*) configuration (*mapping*) per App Id, then when you sync from NuGet to Triskelion, there is no additional request page or **CONFIRM** dialog.

        ![](/.attachments/image-fca27d23-bf10-41a5-8ea3-9a9996fe03f9.png)

    * If you set up more than one active configuration (e. g. for **Package NaviPartner.NPCore.BC180** once we will get there) you will be requested which package do you want to be uploaded and once you chose you will get the list of the versions for the specific package (e. g. BC17 or BC18 etc.).

 * Also, you have probably spotted two file names in the previous screenshot. This lets us to specify where is the APP file in the package and what is the file name (basically, the relative path). And yes, we can specify either full APP file or runtime APP file or both if available (as we have it today). Of course, we might need to adjust this once we will be getting e.g. app files with the variable filename (e. g. including the version in the file name)!!! This is to be seen and made once we will get into this situation 😉 Anyway, the priority today has the runtime app if you specify both. There is no **CONFIRM** dialog etc. to define your choice. We told that when publishing to live servers, we will publish always runtime app only.