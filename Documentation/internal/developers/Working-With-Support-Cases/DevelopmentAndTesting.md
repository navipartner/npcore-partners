# Development and testing

When coding, do your best to make the code:
- Readable - help the next developer understand what the code does
- Upgradeable - when a customer gets upgraded, your code needs to be easy to upgrade
- Manageable - write the code so it’s easy to add changes to it (publishers)

Always write code in English, this includes any comments and variables.
Keep an eye on developer’s team channel and yammer for any tips & tricks or coding suggestions

## Coding
### AL or C/AL?
In versions older than BC17 this is not easy to detect since we have every combination possible. In some cases apps were created where C/AL was supposed to be used and now it shows up in DevOps and developers think it's correct choice. Although the best approach is to ask the developers that are often working with specific customers, you can use these general guidelines:
 - Check the latest changes in C/AL and on DevOps. If there were more changes made on C/AL, it's most likely C/AL
 - On multitenant it's most likely AL, but on versions NAV2018 and older it's probably pure C/AL or combination of both

### AL

Before you start making changes to a customer app, please make sure repo has the same app version as is installed on live.
Compare repo with Version mentioned in Extension Management on live environment and with Triskilion, Nav App Publications:

![checking customer app version](../.attachments/CheckingCustomerAppVersion.png)

This gives us enough confidence that repo has the latest source code.

Please be aware of following when working on NAV2018 customers:
 - you need to have AL Language extension installed specifically for version 2018. AL Language for Dynamics 365 Business Central will not work. You can try to find one the market or install it from vsix file. As an example, version 0.12.25327 works fine. Don't forget to disable other AL Language extension and Reload Window. 
 -  DotNet data type is not supported so if you need to have one, combine your app with C/AL in which you'll handle DotNet

#### Known issues when working with NAV2018 apps in VSCode

---
Process: Downloading symbols

Error: **No Server has been chosen**

Solution: Usually means you opened the repo as a workspace. Try opening Application folder directly

Solution Source: https://community.dynamics.com/nav/f/microsoft-dynamics-nav-forum/307997/nav2018-extensions-no-server-has-been-chosen/894950

---
Process: Running the app with F5 or Ctrl+F5

Error: **Couldn't find a debug adapter descriptor for debug type 'al' (extension might have failed to activate)**

Solution: Since app has been successfully created, install it through Triskelion. Other solution found in the Solution Source.

Solution Source: https://www.dynamicsuser.net/t/vs-code-error-on-publishing-couldnt-find-a-debug-adapter-descriptor-for-debug-type-al-extension-might-have-failed-to-activate/68244

---

### Known issues when working with BC14 apps in VSCode

---
Process: Opening repo and getting error in app file

Error: **A package with publisher 'Microsoft', name 'Test', and a version compatible with '11.0.0.0' could not be found in the package cache folders: ...\SpejderSport\Application\.alpackages**

Solution: Downgrade your AL Language extension to version 9.5

---

### C/AL

If you received a fresh restore from hosting, which will have latest objects from live environment, you’re good to start coding. If you’re working on a restore from another case or on a permanent test environment, please compare and merge changes from live first. This can greatly improve quality of deployment later.

If doing changes on tables, depending on the environment, you may need to perform service sync. You’ll know as you’ll get an error in development environment when trying to save and compile table. If you do, in development environment choose option Later when saving object:

![save table synchronization schema later](../.attachments/SaveTableSyncSchemaLater.png)

Sync is performed in Triskilion2018 by selecting the service for test environment and clicking on Sync NAV Tables action:

![schema sync triskilion2018](../.attachments/SchemaSyncTriskilion2018.png)

Popup will appear:

![schema sync confirmation popup](../.attachments/SchemaSyncConfirmationPopup.png)

Choose Sync, or other options. Try to avoid using ForceSync unless you need to.

On Triskelion 2016:

![schema sync triskelion2016](../.attachments/SchemaSyncTriskelion2016.png)

## Versioning
### AL
If you're working on customers app the only version you should care about is app version. Version is usually in format 1.0.0.xx where xx is the number we increase by 1.

For example:

![app version increase](../.attachments/AppVersionIncrease.png)

If you're doing changes to core please read core documentation for [versioning logic and flows](../Versioning-logic-and-flows.md)

Some of our customer projects (ZAL) are alligned with our standard NP Core development protocols. This means:
 - No need to update app.json
 - Use releases/ and topic/ folders for branches
 - Create pull requests
 - Do not locally compile and publish new app versions
 - Workitems mandatory

List of ZAL projects enabled:
 - Sport24
 - MaxiZoo
 - AliceButik
 - Blaafarveværket
 - Enigma-MuseumForTele
 - FunSport
 - Hartmanns
 - ImageHolte
 - Nasjonalmuseet

### C/AL
There are several types of versions tags you may come across:
- Standard Microsoft version

    This includes W1 and any localization, for example NAVW111.00.00.20348,NAVDK11.00.00.20348. You should not manually alter these versions unless you’re specifically installing a cumulative update  
- NaviPartner Retail version NPR

    For example, NPR9.00.00.5.23. Note that last version deployed in this format was 5.55. You should not alter this version tag
- NaviPartner Kunde version NPK

    For example, NPK1.12. You’re allowed to modify it
- Other module versions

    For example, TSD1.00, TM90.1.35, VRT1.20, and many more. There are many different modules installed on customers NAV/BC version. If you want to know more about them, please ask. You should not alter these versions (unless you’re the owner of these modules and you know what you’re doing)  
- Hashtag (#) version

    For example, #123456. This represents either a development in progress or a hotfix for NPR. This is a version you’ll mostly use for customer cases, combined with NPK. More details below. 

You always start coding with hashtag version on development/test environment.

Code needs to be encased in this block:
```
//-#<case no> [<case no>]
Your code in here
//+#<case no> [<case no>]
```

For example,

![new code hashtag version](../.attachments/NewCodeHashtagVersion.png)

Documentation trigger should look like this:
```
#<case no>/<your initials>/<yyyymmdd> CASE <case no> <short description>
```
Where ```<yyyymmd>``` is the date when the code is added

For example,

![documentation trigger hashtag version](../.attachments/DocumentationTriggerHashtagVersion.png)

On the object list, version list should be updated with:
```
#<case no>
```

For example,

![object version list hashtag version](../.attachments/ObjectVersionListHashtagVersion.png)

## Testing
Always test your code keeping in mind to:
- code works given the process requirements
- code works in border scenarios
- code isn't working when not supposed to

Once your test is successful you need to send the case to customer to perform test on their own.






