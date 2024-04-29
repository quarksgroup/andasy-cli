# Drop CLI

Welcome to `dropctl` – the official command-line interface for drop Service. This versatile CLI tool is designed to simplify your interactions with Pass Cloud Service, Making it easier to deploy applications, manage authentication, handle your apps services, and manage organizations effortlessly.

## Introduction

Drop Service is a cutting-edge cloud platform that empowers developers to build, deploy, and scale applications with ease. With `dropctl`,
you can harness the full power of drop.rw service directly from your terminal. Whether you're a seasoned developer or just getting started, this CLI tool is here to streamline your workflow.

## 📦 Installation

Prerequisites

Before you can install `dropctl`, make sure you have the following prerequisites:

- An active account on [drop](https://drop.rw/)

### Install script

The easiest way to install `dropctl` is to run the following command in your terminal:

```sh
curl -sSL https://raw.githubusercontent.com/quarksgroup/drop-cli/main/install.sh | sh
```

## Manual Installation

* Visit the [GitHub releases page](https://github.com/quarksgroup/drop-cli/releases) for `drop-cli`.
* Find which version you want to install or use the latest release provided.

### Debian/Ubuntu Linux:

```sh
curl -L https://github.com/quarksgroup/drop-cli/releases/download/v0.1.5/dropctl-linux-amd64.tar.gz \
  | tar xz
```

Make the executable file executable and move it to a directory in your PATH (e.g., /usr/local/bin)

```sh
chmod +x dropctl
sudo mv dropctl /usr/local/bin
```

### MacOS:

**Download the macOS (64-bit) executable**

```sh
curl -L https://github.com/quarksgroup/drop-cli/releases/download/v0.1.5/dropctl-darwin-amd64.tar.gz \
  | tar xz
```

Make the executable file executable and move it to a directory in your PATH (e.g., /usr/local/bin)

```sh
chmod +x dropctl
sudo mv dropctl /usr/local/bin
```

### Windows:

**Download the Windows (64-bit) executable using PowerShell**

```powershell
Invoke-WebRequest -Uri "https://github.com/quarksgroup/drop-cli/releases/download/v0.1.5/dropctl-windows-amd64.zip" -OutFile "droptcl.zip"
```

**Extract the executable from the ZIP file**

```powershell
Expand-Archive -Path "dropctl.zip" -DestinationPath "."
```

Add the location of the executable to your system's PATH

**(You might need to open a new command prompt or PowerShell window for the change to take effect)**

```powershell
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";$pwd", [System.EnvironmentVariableTarget]::Machine)
```

### Test your installation

open your terminal or power shell and type below command:

```sh
dropctl
```

You will see the output related to this:

```
dropctl is a command line interface to the drop.rw platform.

Usage:
  dropctl [flags]
  dropctl [command]

Here's a few commands to get you started:
  dropctl auth     Manage authentication and access
  dropctl orgs     For managing your drop organizations
  dropctl apps     For managing your drop applications
  dropctl setup    setup of applications, dockerfile, config file on Drop using Drop CLI and all .
  dropctl deploy   For deploy your apps to Drop
  dropctl machine  Managing your drop machines
  dropctl volume   For managing your drop volumes

If you need help along the way:
  Use open https://github.com/quarksgroup/drop-cli.git
  Use dropctl <command> --help for more information about a command.

For a full list of commands, run 
```

For instance you can run below command to check the version you are running:

```
dropct version
```

If you see the version number, you have successfully installed dropctl!

## Usage

### Authentication

Before using any other commands, you need to be authenticated with your [drop](https://drop.rw/) account. Use the following command to login or signup:

Run below command to login your cli apps on drop, you can also use `-i` flag to LogIn with an email and password interactively cause the default is web.

```sh
dropctl auth login
```

Follow the prompts to provide your credentials and set up authentication.

Run below command to create account on drop apps.

```sh
dropctl auth signup
```

Provide the loggedIn in account token

```sh
 dropctl auth token
```

Logout your account from the current machine

```sh
 dropctl auth logout
```

### Apps

The apps commands focus on managing your drop applications. Start with the CREATE command to register your application then you can list them or even restart your app once it is not reache able.

1. Create a new app:

```sh
dropctl apps create <app-name-here>
```

2. List all apps that you have registered or those one you have access to:

```sh
dropctl apps list
```

3. Show an app:

```sh
dropctl apps show <app-name-here>
```

4. Application restart command that will refresh your app services, Make sure that

```sh
dropctl apps restart <app-name-here>
```

### Deploy

Use the deploy command to deploy your applications to drop. Provide the path to your application directory or leave it empty to use the current path with `-a app-name flag`  , leave it to use your service configuration `.hcl` file to pick app-name but it in order for your application to be deployed drop, Below are steps needed before running deploy command so you need alteast to have executed below command.

1. The app need's to be already created with `dropctl apps create app-name` command or through web.
2. The `setup` command need to be executed at least once so we can generate the config file and Dockerfile if it is not available.

#### The deployment guide line:

Run **setup** command to generate all required deployment requirements

```sh
 dropctl setup
```

Run **secret** **(`s`)** command to publish your secret environment variable to be associated with your application once is being deployed

```
dropctl secrets set FOO=bar BAZ=foobar -a app-name
```

Run **deploy** command to ship your application to drop where our platform will make sure that your app is live and available to the internet and return with accessable link that point's to your service.

```
dropctl deploy
```

You can specify additional options and flags as needed, just run `deploy` command with `-h` flag that stand for --help

### Organizations

Manage your orgs on drop platform and organizations using the orgs command. Create, list, or show organizations with ease:

Create a new organization:

```sh
dropctl orgs create <org-name>
```

List all organizations:

```sh
dropctl orgs list
```

Show organization by slug:

```sh
dropctl orgs show <org-slug>
```

### Database

The database command is for mananging the databases as an apps service for instance like postgres.

Create postgres applications service with backed up volume storage of your data run below shell command that will return `psql` connection string

```
dropctl databases pg create
```

You can run the above command with `-h` flag to see all available command.

For more information on available commands and options, you can always refer to the help documentation:

```sh
dropctl --help
```

## Feedback and Contributions

We welcome your feedback and contributions to dropctl. If you encounter any issues or have suggestions for improvement, please open an issue on our GitHub repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Happy Coding 💻
