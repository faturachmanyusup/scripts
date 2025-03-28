# Scripts Collection Documentation
This repository contains a collection of useful scripts for various tasks and integrations. Below you'll find detailed information about each component and how to use them.

## Installation
Scripts are installed to `/usr/local/lib/scripts` and can be run directly after installation.

```bash
# Pattern
scripts <provider> <action>

# Example
scripts gitlab mr-create <target_branch>
```

The repository includes an installation script (`install.sh`) that:
- Installs the scripts to `/usr/local/lib/scripts`
- Sets up auto-completion for the scripts
- Requires root privileges to install
- Adds necessary bash completion configurations

To install, run:
```bash
sudo ./install.sh
```

## Available Scripts

### GitLab Integration

#### 1. Merge Request Creation (`gitlab/mr-create.sh`)
A script to automate merge request creation in GitLab.

**Features:**
- Automatically creates merge requests from current branch
- Uses GitLab API with private token authentication
- Extracts commit message as MR title
- Supports custom target branch selection
- Requires `GITLAB_PRIVATE_TOKEN` environment variable

**Usage:**
```bash
mr-create.sh [target-branch]
```

### ClickUp Integration

#### 1. Task Update (`clickup/task-update.sh`)
Manages ClickUp tasks through command line interface.

**Features:**
- Updates task status in ClickUp
- Handles multiple task IDs
- Requires `CU_PERSONAL_TOKEN` environment variable
- Supports parent task relationships

**Usage:**
```bash
task-update.sh [task-ids] [status]
```

### Microsoft Teams Integration

#### 1. Message Sending (`ms-teams/message-send.sh`)
Sends messages to Microsoft Teams channels via webhooks.

**Features:**
- Sends messages to Teams channels
- Uses webhook URLs for authentication
- Simple POST request implementation

**Usage:**
```bash
message-send.sh
```

### Life Utilities
Some unneccesary commands

## Requirements
- Bash shell environment
- `curl` for API requests
- `jq` for JSON processing
- `rsync` for installation
- Proper environment variables set for various integrations

## Environment Variables
The following environment variables are required for different scripts:

- `GITLAB_PRIVATE_TOKEN`: For GitLab operations
- `CU_PERSONAL_TOKEN`: For ClickUp operations

## Auto-completion
The installation process sets up command auto-completion for easier script usage. This is configured through:
- `/etc/bash_completion.d/scripts-autocomplete`
- Automatic registration in `.bashrc`

## Notes
- All scripts are executable shell scripts
- Each script performs input validation
- Error handling is implemented for API responses
- Scripts follow a consistent pattern for environment variable checking

<br>

![Yes](./image.png)

This documentation was generated by [Amazon Q](https://aws.amazon.com/q/developer/) with some adjustments.