# Drop CLI - Pass Cloud Service CLI For Drop

Welcome to `dropctl` – the official command-line interface for drop Service. This versatile CLI tool is designed to simplify your interactions with Pass Cloud Service,
making it easier to deploy applications, manage authentication, handle your apps, and manage organizations effortlessly.

## Introduction

Drop Service is a cutting-edge cloud platform that empowers developers to build, deploy, and scale applications with ease. With `dropctl`,
you can harness the full power of drop.io service directly from your terminal. Whether you're a seasoned developer or just getting started, this CLI tool is here to streamline your workflow.

## 📦 Installation

Prerequisites

Before you can install `dropctl`, make sure you have the following prerequisites:

- An active account on drop

### Install script

The easiest way to install `dropctl` is to run the following command in your terminal:

```sh
curl -sSL https://raw.githubusercontent.com/quarksgroup/drop-cli/main/install.sh | sh
```

## Install Manual

* Visit the [GitHub releases page](https://github.com/quarksgroup/drop-cli/releases) for `drop-cli`.
* Find the latest release tag (usually the one at the top) and note down its name (e.g., `v0.0.1`).
* Replace `v0.0.1` in the following command with the latest release tag:

### Debian/Ubuntu Linux:

```sh
curl -L https://github.com/quarksgroup/drop-cli/releases/download/v0.0.2/dropctl-linux-amd64.tar.gz \
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
curl -L https://github.com/quarksgroup/drop-cli/releases/download/v0.0.2/dropctl-darwin-amd64.tar.gz \
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
Invoke-WebRequest -Uri "https://github.com/quarksgroup/drop-cli/releases/download/v0.0.2/dropctl-windows-amd64.zip" -OutFile "droptcl.zip"
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
dropctl version
```

If you see the version number, you have successfully installed dropctl!

## Usage

### Authentication

Before using any other commands, you need to authenticate with your Pass Cloud Service account. Use the following command to login or signup:

Run below command to login your cli apps on drop.

```sh
dropctl auth login
```

Follow the prompts to provide your credentials and set up authentication.

Run below command to create account on drop apps.

```sh
dropctl auth signup
```

Provide the required detail to create account on drop platform.

```sh
 dropctl auth token
```

### Apps

Manage your drop apps using the apps command. List, create, or show apps with ease:

List all apps:

```sh
dropctl apps list
```

Create a new app:

```sh
dropctl apps create "App Name"
```

Show an app:

```sh
dropctl apps show "App Name"
```

### Deploy

Use the deploy command to deploy your applications to drop. Provide the path to your application directory or leave it empty to use the current path with `app-name` as follows:

```sh
 dropctl deploy <app-name>
```

You can specify additional options and flags as needed.

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

For more information on available commands and options, you can always refer to the help documentation:

```sh
dropctl --help
```

## Feedback and Contributions

We welcome your feedback and contributions to dropctl. If you encounter any issues or have suggestions for improvement, please open an issue on our GitHub repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
