This article is intended for non-developers that are not already familiar with the details of visual studio code, git and the markdown format.
It highlights the minimum technical requirements to contribute to our product documentation - both the quick edit of existing articles without installing anything locally along with how to setup a full documentation editing workflow on your local machine.

# Overview

## Azure DevOps

Azure Devops is the platform you are reading this article on. It is Microsofts tool to develop software with everything that comes along with that: Tracking and planning work, making code changes, documentation changes, wiki changes, creating releases, changelogs, running automatic tests, approving QA flows and deploying releases and more.
In NP we only use a sub-set of the functionality today.
Under the Repos tab (orange icon on the left) you will see our files.

![azure_devops_files.png](images/azure_devops_files.png)

Make sure the master branch is selected up top, otherwise you are not seeing the latest version of them.
The Application, DevOps and Test folders contain code for NPRetail.
The Documentation folder is what we are focused on here.
Inside it, we have the following:


* The /internal folder contains this guide and anything else not published on the documentation website.
* the /api folder contains technical webservice reference documentation that is maintained solely by developers.
* the /.tools folder contain the scripts used to build the website automatically.
* the /product folder is the main focus - it contains the product documentation that we are interesting in here.

You are encouraged to open up the product folder and look around it, while comparing the structure to the menu structure you see on docs.navipartner.com.
What you should notice is that the .md files (markdown files) are structured in a folder heirarchy that matches the website structure and that the toc.yml files (table of content files) declare the menu structure for the website.

You are also encouraged to explore on the Azure Devops portal to get more familiar with it - a couple of highlights:
* Under Repos -> "Commits" you will see all changes done to both code & documentation
* Under Repos -> "Pull requests" you will see pending changes to both code & documentation, not yet approved for various reasons.

## Why are we doing this? Word, sharepoint, confluence or notepad is easier to use!

There is a trend in the software industry, most relevant examples being docs.microsoft.com and docs.continia.com to treat documentation-as-code by writing in a format called markdown and then generating the HTML for a website automatically, based on the markdown files.
Don't worry, this does not mean you have to learn to code before you can contribute to the documentation but it is an acknowledgment of the fact that most software is living, meaning it changes constantly, and so any documentation of that software has to be living as well.
The easiest way to keep that documentation up to date and as relevant as possible is to re-use many of the procedures invented to track text changes for software development, instead of keeping documentation stored in a 3rd party tool where it can slowly rot away, out of sight and out of mind.
The upside to this is that you will get more familiar with the vocabulary of the software developers in NaviPartner, since you will be using some of the same tools such as "Pull requests" here on Azure Devops, along with "Visual Studio Code" and "Git".
Another upside is that it means that collaboration with developers on documentation changes is easier, as any documentation change is treated the same way as code changes, inside one shared tool. That also means there is less of an excuse for a developer to not write or update documentation and ping-pong with non-developer employees about it as the code changes :)
All of this come at the cost of a learning curve at the start compared to using word and notepad etc. - we hope that the benefits detailed above, along with the fact that we are guiding you towards habits of modern software documentation, helps ease that burden.
We are many people involved in this documentation project and that means there are many people that can help if you hit an edge case.

## .md (Markdown) files

Markdown is the .md files that make up the actual text of our documentation. This article is written in markdown.
It is a bare minimum syntax required to get just-enough structure onto text, without opening up the door to picking between fonts, sizes, colors etc.
Those things are irrelevant when focus is on the content and they can be added automatically later when generating the HTML for the documentation website.

Since markdown is commonly used format, there are many online ressources the syntax, i.e. how to create headlines, bold, numbered lines etc.
One of the best examples that you should check out is: https://www.markdownguide.org/cheat-sheet/

## toc.yml (Table of contents) files

if you take a look in the /product folder structure you will see a toc.yml config file is placed a at various folder levels.
These reference each other and tell the website generator how to structure the menus.
Note: The top-level toc.yml outside the /articles folder is special - it only controls the top blue navigation bar.
All the other toc.yml files are connected and structure the documentation articles.

The file format is called yaml (.yml). It is intended as a simpler version of json & xml, for human readability/editability.
It is key/value pairs with the option of children for nested elements.
To manage our tables of contents, we only need 3 keys: 
* name: The caption displayed on the website menu.
* href: The relative "link" to a subfolder.
* items: (optional) if there are any nested article sections, this key can be used to group them.

Instead of jumping into reading the technical reference documentation of the toc.yml file (https://dotnet.github.io/docfx/tutorial/intro_toc.html) you are instead encouraged to copy/paste from existing toc.yml files and adjust as needed, if creating new module folders or adding new articles.

## Pull Requests

Whenever you are doing any changes to files you will be doing it on your own branch.
A branch is git terminology for having "your own copy" of the files, that you can work on without disturbing anyone else.
Pull request is another git term for making a change request from your branch to the master branch, when you feel that your changes are ready to be distributed to everyone else looking at the master branch.
The meaning of the term comes from the fact that you are requesting the target to "pull your changes" into his/her branch.

In the NpCore project, where we maintain documentation, we have only 2 rules that are important to know (but don't worry, both are enforced automatically):
1. All branches where people work should be named topic/* at the start. So for example, when adding documentation for configuring POS menus, you would create a branch based on the master branch (since this is the most recent version of our files based on everyones work) into your own temporary branch and name it:
   
    topic/initials/pos_menus_docs 

    Note, everything after topic/ is optional. By using your own initials you make sure you never hit a colleagues branch name.

2. All merges to master requires a pull request. This means, you cannot bypass the approval process of a pull request when merging to master.

All your file changes will be done on your topic branches and when you are done with each, you would make sure your changes are committed and pushed, and then finally create a pull request from your topic branch to the master branch.

At this point, your colleagues has a chance to approve your changes, make sure you didn't make a mistake, ping-pong with you if improvements are needed before approval, and finally approve it, at which point your documentation will be merged to the master branch (so everyone else starting new work by branching from master in the future will see your changes).

You can create however many branches as you want, and creating a new one every time you need to do isolated work is encouraged to keep things from overlapping unnecessarily.

These git concepts will be shown more in detail later in the document.

## Images

All images can be placed into a /images folder next to your .md files, that needs to show them.
You can always refer to these with the markdown image tag as such:

```
![image name (not visible on website)](images/image_file_name.png)
```

# Quick edits to existing documents

If you are not creating brand new articles, images or tables of contents, and you only need to extend an article or fix a mistake then you can use the browser-based approach inside Azure Devops to edit articles instead of installing anything locally.

## Video example


# Setting up the local machine

If you need to do more than one file change, such as creating a new article, with one new image and updating the table of contents to show your new article in a menu, you will be more efficient if doing this on your local machine. This way you can group all the related changes into one pull request at the end.

## Visual Studio Code
Explanation

Install link

markdown extension?

## Git
Explanation

how to clone the NpCore project with git inside visual studio code.

How to use the changes tab.

## Video example
The following gif shows all the steps involved in creating a new article with images and table of content update, with the full local setup:

1. NpCore Project is cloned to local machine using vscode (Only needed on fresh machines)
2. "Git Pull" is done on the master branch using vscode (Only needed just before you create a new topic branch to make sure it's up-to-date locally)
3. Git branch is done from master into a topic branch dedicated for the new article we want to add.
4. Article markdown file is created.
5. Image folder is created next to it with a new image inside.
6. Article markdown file is updated to use the new image file.
7. toc.yml file is updated to reference the new article.
8. Changes are committed via the git tab in vscode.
9. Changes are pushed to the topic branch on the server via "Git Push" in vscode. (up until now the topic branch was only on your local machine)
10. In the azure devops webclient, we create a pullrequest from our topic branch to the master branch.
11. We confirm via the file tab that our changes are visible and correct on the pull request.

## Making changes on an existing pull request
If you created your pull request and realised that you made a mistake, or you got feedback from a reviewer that must be fixed, then you can repeat the normal process of making changes on the same topic branch you used to create the pull request originally.
As soon as you git push an updated set of changes, the azure devops pull request website will pick up those changes and show them in an entry.

## Visual Studio Code Extensions
There are some helper extensions in visual studio code that can speed up the process of writing markdown.