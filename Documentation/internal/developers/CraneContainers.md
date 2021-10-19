# Important links and requirements:
* [Introduction to Crane Containers](https://web.microsoftstream.com/video/c4b67720-524d-4857-9cde-e70285d6ea5a)
* [Yammer Posts related to Crane](https://web.yammer.com/main/search/threads?search=crane)
* [Crane - Teams Channel](https://teams.microsoft.com/l/channel/19%3a5a2404d7ffbf4ebbb14e33b9e054b71d%40thread.skype/Crane?groupId=9f4af096-6dbf-467d-8a3c-e5029b7e7e7f&tenantId=ec3af438-38fc-4d9b-b8be-058101411d3a) to post or see global problems.
* If you have troubles and you think these might be related to Crane, please try to resolve them in the following order:
  * Be sure you understand how Crane containers work, especially it's necessary to understand the life-cycle of Crane containers (containers can be automatically destroyed to save resources, containers start sometime fast, sometimes it can take minutes even 15 minutes could be a normal time under some circumstances). If you think you might be missing some details, use the links posted above or ask your colleagues first.
  * If you understand but still have troubles, use [Portainer](#Portainer---GUI-allowing-container-management) and check the logs (EventLogs) from there. Usually, this is what I do first when I get cases from you. And very often this is all I need to do to identify the problems.
  * Try to use [Crane Troubleshooting](/Crane-Containers/Crane-Troubleshooting) section, maybe the problem will be described there.
  * If you still facing troubles, please, try to send the case to me. Of course, if this isn't too urgent or if you think this isn't a global problem for the entire Crane.
  * If you think this might be a general Crane problem (like a global failure affecting a lot of containers), use the dedicated channel on Teams mentioned above. It's better to discuss these problems in a public place if possible as others might benefit from this (they can see something is happening and not only to them).
  * If you need to discuss the problem with me and you have tried all previous things, please, don't hesitate and do. I will always try to help ;) if this is absolutely necessary :)
* There is a new section with the list of [Crane Features](/Crane-Containers/Crane-Features). This is the place where all new important changes will be described (instead of using Yammer posts).

---

# Creating a crane container

Open the Job Card for the case.
In the ribbon, click Actions, then "Request and View Containers".
What you see on screen now is the Crane Containers List page. It shows the containers that exist for the case.
Create a new record here, using lookup on the first column "Container Template Code" as a shortcut to fill out everything.
 If you are [unsure which template](/Crane-Containers/Crane-Features/Crane-Templates) to use then **CORE-DATA-18** (or higher BC version in the future) is a good default as it will preinstall latest npcore .app from the master branch along with a .rapidstart package that contains some POS test data.

Then click action "Create Container" to kick off the creation flow.
Keep in mind - creating a container takes time. This may take anywhere between 5 and 15 minutes.
If the landing page listed returns a "page not found" or "bad gateway" - then the container is still being created. Just wait until it's up and running.

The Crane Containers List page and landing page together shows all the relevant information you need to login into the BC instance inside the container.

Notice that these are always hosted on dynamics-retail.net with the case number as part of the URL which makes it easy to tell apart from customer production environment running on dynamics-retail.com

# Recreating a container
Since Crane containers consume resources on our container environment, they are periodically destroyed.
Containers with policy "DEFAULT" will be destroyed after 3 days without a comment in the case or when case is closed.
To recreate it, click "Create Container" once again.
**All data will be kept as the database is not wiped by this routine. Only the NST container.**


# Long living containers
"Container Policy Code" to CUST or PARTNER can be used to avoid the auto destruction of containers. This is useful for containers used by external parties that do not have access to this crane control panel to prevent them from bugging you too much to restart their container. 

# Containers linked to an azure restore
If you need a container pointing to a restore database of a customer hosted in azure, for example during prelive to iterate quickly on code from vscode while ping ponging with the customer for approval or to debug something where customer data will help, you can get a container linked to a restore:
1. Create a container request record as normal but don't start the container itself, just create the record.
2. Send the case to hosting (Group 5). They will setup a few fields and start restore directly from the case system. The container will be linked automatically with the restore (the database settings) and otherwise behave like a normal crane container.


# Portainer - GUI allowing container management

[Introduction to Crane Containers - Portainer](https://web.microsoftstream.com/video/c4b67720-524d-4857-9cde-e70285d6ea5a?st=7326) - please, this is an import part of the video covering some areas of Portainer that might be very helpful to you.

## Powershell access
Although we have actions on the crane page for common scenarios such as restarting NST, you might still need manual access to the container.
We allow access through the portainer webclient for this:

1. Goto Portainer (https://portainer.dynamics-retail.net) and login with the same crane container credentials you use in the BC webclient.
2. Press on "Containers" in the left side
3. Press on the small Powershell icon under Quick actions.
4. Press on "Connect"
5. Enter the following Powershell Script lines:
   .\Run\Prompt.ps1

This will load the standard BC powershell module you can use to invoke your container.