# Andasy CLI

Welcome to `andasy` – the official command-line interface for andasy Service. This versatile CLI tool is designed to simplify your interactions with Pass Cloud Service, Making it easier to deploy applications, manage authentication, handle your apps services, and manage organizations effortlessly.

## Introduction

andasy Service is a cutting-edge cloud platform that empowers developers to build, deploy, and scale applications with ease. with `andasy`,
you can harness the full power of andasy.io service directly from your terminal. Whether you're a seasoned developer or just getting started, this CLI tool is here to streamline your workflow.

## 📦 Installation

Prerequisites

Before you can install `andasy`, make sure you have the following prerequisites:

- An active account on [andasy](https://andasy.io/)

### Install script

The easiest way to install `andasy` is to run the following command in your terminal:

```sh
curl -sSL https://andasy.io/install.sh | sh
```

Or on windows

```powershell
pwsh -Command "iwr https://andasy.io/install.ps1 -useb | iex"
```

## Manual Installation

* Visit the [GitHub releases page](https://github.com/quarksgroup/andasy-cli/releases) for `andasy-cli`.
* Find which version you want to install or use the latest release provided.

### Debian/Ubuntu Linux:

```sh
curl -L https://github.com/quarksgroup/andasy-cli/releases/download/v0.2.39/andasy-linux-amd64.tar.gz \
  | tar xz
```

Make the executable file executable and move it to a directory in your PATH (e.g., /usr/bin)

```sh
chmod +x andasy
sudo mv andasy /usr/bin
```

### MacOS:

**Download the macOS (64-bit) executable**

```sh
curl -L https://github.com/quarksgroup/andasy-cli/releases/download/v0.2.39/andasy-darwin-amd64.tar.gz \
  | tar xz
```

Make the executable file executable and move it to a directory in your PATH (e.g., /usr/local/bin)

```sh
chmod +x andasy
sudo mv andasy /usr/local/bin
```

### Windows:

**Download the Windows (64-bit) executable using PowerShell**

```powershell
Invoke-WebRequest -Uri "https://github.com/quarksgroup/andasy-cli/releases/download/v0.2.39/andasy-windows-amd64.zip" -OutFile "andasy.zip"
```

**Extract the executable from the ZIP file**

```powershell
Expand-Archive -Path "andasy.zip" -DestinationPath "."
```

Add the location of the executable to your system's PATH

**(You might need to open a new command prompt or PowerShell window for the change to take effect)**

```powershell
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";$pwd", [System.EnvironmentVariableTarget]::Machine)
```

### Test your installation

open your terminal or power shell and type below command:

```sh
andasy
```

You will see the output related to this:

```
andasy is a command line interface to the andasy.io platform.

Usage:
  andasy [flags]
  andasy [command]

Here's a few commands to get you started:
  andasy auth     Manage authentication and access
  andasy orgs     For managing your andasy organizations
  andasy apps     For managing your andasy applications
  andasy setup    setup of applications, dockerfile, config file on andasy using andasy CLI and all .
  andasy deploy   For deploy your apps to andasy
  andasy machine  Managing your andasy machines
  andasy volume   For managing your andasy volumes
  andasy update   For updating your cli version to latest version

If you need help along the way:
  Use open https://github.com/quarksgroup/andasy-cli.git
  Use andasy <command> --help for more information about a command.

For a full list of commands, run 
```

For instance you can run below command to check the version you are running:

```
andasy version
```

If you see the version number, you have successfully installed andasy!

## Usage

### Authentication

Before using any other commands, you need to be authenticated with your [andasy](https://andasy.io/) account. Use the following command to login or signup:

Run below command to login your cli apps on andasy, you can also use `-i` flag to LogIn with an email and password interactively cause the default is web.

```sh
andasy auth login
```

Follow the prompts to provide your credentials and set up authentication.

Run below command to create account on andasy apps.

```sh
andasy auth signup
```

Provide the loggedIn in account token

```sh
 andasy auth token
```

Logout your account from the current machine

```sh
 andasy auth logout
```

### Apps

The apps commands focus on managing your andasy applications. Start with the CREATE command to register your application then you can list them or even restart your app once it is not reache able.

1. Create a new app:

```sh
andasy apps create <app-name-here>
```

2. List all apps that you have registered or those one you have access to:

```sh
andasy apps list
```

3. Show an app:

```sh
andasy apps show <app-name-here>
```

4. Application restart command that will refresh your app services, Make sure that

```sh
andasy apps restart <app-name-here>
```

### Deploy

Use the deploy command to deploy your applications to andasy. Provide the path to your application directory or leave it empty to use the current path with `-a app-name flag`  , leave it to use your service configuration `.hcl` file to pick app-name but it in order for your application to be deployed andasy, Below are steps needed before running deploy command so you need alteast to have executed below command.

1. The app need's to be already created with `andasy apps create app-name` command or through web.
2. The `setup` command need to be executed at least once so we can generate the config file and Dockerfile if it is not available.

#### The deployment guide line:

Run **setup** command to generate all required deployment requirements

```sh
 andasy setup
```

Run **secret** **(`s`)** command to publish your secret environment variable to be associated with your application once is being deployed

```
andasy secrets set FOO=bar BAZ=foobar -a app-name
```

Run **deploy** command to ship your application to andasy where our platform will make sure that your app is live and available to the internet and return with accessable link that point's to your service.

```
andasy deploy
```

You can specify additional options and flags as needed, just run `deploy` command with `-h` flag that stand for --help

### Organizations

Manage your orgs on andasy platform and organizations using the orgs command. Create, list, or show organizations with ease:

Create a new organization:

```sh
andasy orgs create <org-name>
```

List all organizations:

```sh
andasy orgs list
```

Show organization by slug:

```sh
andasy orgs show <org-slug>
```

### Database

The database command is for mananging the databases as an apps service for instance like postgres.

Create postgres applications service with backed up volume storage of your data run below shell command that will return `psql` connection string

```
andasy databases pg create
```

You can run the above command with `-h` flag to see all available command.

For more information on available commands and options, you can always refer to the help documentation:

```sh
andasy --help
```

## Feedback and Contributions

We welcome your feedback and contributions to andasy. If you encounter any issues or have suggestions for improvement, please open an issue on our GitHub repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Happy Coding 💻
