<img src="https://img.shields.io/azure-devops/build/navipartner/dragonglass/46/master">


# Dragonglass

Dragonglass is the central component of the NP Retail POS front-end. Dragonglass is based on React and Redux. This repo contains all source code required to build Dragonglass bundle to include in controladdin component in AL.

# Introduction

Dragonglass is a [monorepo](https://en.wikipedia.org/wiki/Monorepo) that contains several modules, with various degrees of inderdependency. Monorepo structure allows individual components to be developed in a relative isolation from one another and allows a lot of flexibility in workflow configuration.

## Package and dependency management (pnpm)

Dragonglass uses [**pnpm**](https://pnpm.js.org/) to manage dependencies, instead of plain npm. Using a simple package manager to handle a monorepo would cause too much manual work around maintenance and configuration. Pnpm is very powerful when it comes to managing a single dependency repository for the entire monorepo, which simplifies installation (one install task instead of one per package) and saves time during development.

It's just important to remember not to type `npm` but `pnpm` instead. Syntax is the same for most of the tasks.

Instead of:

```powershell
npm install foo-bar --save-dev
```

... you just type:

```powershell
pnpm install foo-bar --save-dev
```

Still, it's higly recommended to get familiar with what else pnpm can do. Check it out:
https://pnpm.js.org/

## Language (TypeScript and JavaScript)

Dragonglass uses both TypeScript and JavaScript. TypeScript is preferred, and should be used if possible. Helper packages (workflows, front-end-async, transcendence, etc.) are all maintained in pure TypeScript. React package is at this time in JavaScript. Over time, all packages will be moved to TypeScript.

Rules are:
| Action | Choice |
|--------|--------|
| Add a new satellite package | TypeScript |
| Add a new feature to an existing satellite package | TypeScript |
| Add a new feature to core React package | JavaScript |

## Unit Testing (Jest)

Unit tests are all written in [**Jest**](https://jestjs.io/). Jest is supported for both TypeScript and JavaScript, and writing tests in Jest is - as Jest advertises on their web page - delightful. It's really easy, takes no time to get started, and is highly encouraged. When you add a new class or a new function or something, write a unit test for it immediately.

# Getting Started with Development

To started developing or contributing to the Dragonglass repo, follow these instructions:

1. Clone this repo. Click **Clone** and then follow instructions, or run the following command:
    ```git clone https://navipartner.visualstudio.com/DefaultCollection/Dragonglass/_git/dragonglass```

2. If pnpm is not yet installed on your machine, you must install it globally:

    ```powershell
    npm install pnpm --global
    ```

3. After pnpm is installed, simply run `pnpm multi install` in the root of the cloned repo.
   
4. Enable automatic running of tasks in Visual Studio Code. To do this, run Visual Studio Code, then on the Command Palette run `>Tasks: Manage Automatic Tasks in Folder` and then choose `Allow Automatic Tasks in Folder`. Then restart Visual Studio Code.

Congratulations! You now have a working local repo of Dragonglass. Happy coding!

# Contributing

Not many rules for the time being, except for these:

## Don't include `package-lock.json` (obsolete, but leaving this for posterity)

In the days of npm, there were a `package-lock.json` per package. Unfortunately, for some reason, running an `npm-install` could result in dependency issues that npm couldn't resolve in another way than deleting `package-lock.json` and then installing dependencies from scratch. Since this invalidates the purpose of `package-lock.json` (which should be checked-in to guarantee that all machines have the same dependency tree at all times) another solution had to be found. One was not to include `package-lock.json` in git and have every developer rebuild the dependency tree from scratch every time they want to either build a new development environment from scratch or to refresh an existing one. The only downside of not checking in `package-lock.json` was that `npm install` would take more time to install everything.

However, since Dragonglass switched over to pnpm for package management, and since pnpm doesn't generate (or in any way use) `package-lock.json` (it maintains its own `pnpm-lock.yaml`) this section is largely obsoleted.

But, if anyone ever decides to switch over from pnpm to another tool which is npm-based, then consider the issues that `package-lock.json' poses. Don't commit it git in do it at any level, from any of monorepo packages! At this time, the repo is configured to .gitignore this file across the monorepo structure. Don't change it, it will break the installation and build process!

More info:
- https://dev.to/gajus/stop-using-package-lock-json-or-yarn-lock-3ddi
- https://github.com/npm/npm/issues/20603
