The code for the controladdin is compiled by the web project inside the ./code/ folder.

# Minimum steps required to make changes:

1. Open /code/web.vscode-workspace to work on the web project. It has some dependencies:
a. NodeJS, NPM installed on your local machine
b. VSCode extensions: Prettier, eslint, svelte
c. Depending on how deep these folders are placed on your windows machine, you'll probably need to increase the old hardcoded 260 character path limit in windows to run "npm install" later.
See here how that is done globally on your machine: https://docs.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation?tabs=powershell#tabpanel_1_powershell 

2. First time setup, run command "npm install", this will download and install all dependencies.
3. To develop, run command "npm run dev". This will compile the code code and serve it up on a local webserver which can be used to preview the same code that will be embedded in the page showing the control addin.
4. To deploy, run command "npm run deploy". This will package all the web code into bundle.js and bundle.css files and overwrite the existing ones. 

