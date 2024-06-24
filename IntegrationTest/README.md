# Playwright E2E tests
## Get the toolchain in place
This test suite is based on Javascript and NodeJS, hence you need to have some tools installed locally in order to proceed.

### NodeJS
First check if you already have Node and NPM installed locally by running:
```bash
node --version
v18.16.0
```

```bash
npm --version
9.7.1
```

Versions does not have to match, but it is recommended that the Node version is version 18 (LTS).

If you do not have Node installed, then install it from here: https://nodejs.org/en

### PNPM
PNPM is a wrapper around npm, which makes it up to 3x faster and reduces the space usage locally. 

Check if it already installed with:
```bash
pnpm --version
8.15.3
```

If not, then install it with the command:
```bash
npm install -g pnpm
```

## Run the tests
### Install dependencies
First we need to install the dependencies with:
```bash
pnpm install
```

### Add a local .env file
Copy the `env.example` file and call it `.env`. In this file you need to provide 3 variables:
* `E2E_URL`: The url to the container page, e.g. https://np60xyz.hetzner.dynamics-retail.net/
* `E2E_USERNAME`: The username to the container user
* `E2E_PASSWORD`: The password to the container user

### Run the tests
The tests can be run in 3 different ways: headless, headed and debug.

In headless mode the tests will just run in the background
```
pnpm run e2e
```

In headed mode the tests will open a browser window such that you can follow the test execution
```
pnpm run e2e:headed
```

In debug mode the tests will open a browser window and the test code, such that you can follow exactly what action it is running and visually see it in the browser.
```
pnpm run e2e:debug
```


## Testing on Crane container

* Create a Crane container with template `CORE-23` (At the moment, there is an issue with admin rights with `CORE-24` template)
* Wait until the container is fully created and you're able to login
* Run `SetupCranePlaywright.ps1` script in PowerShell to import all required data and add new BC users. The script can take up to 10mins to complete.
* Set `E2E_URL` in `.env`
* Run e2e tests