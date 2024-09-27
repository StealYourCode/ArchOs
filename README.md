# ArchOs

**ArchOs** is a personal repository that contains my school notes in the `Notes` directory, along with scripts in the `Gentoo` directory to install and configure everything necessary to run Gentoo Linux, including partitioning, installing drivers, and other essential steps.

## Overview
This repository simplifies the Gentoo Linux installation process by providing automated scripts for tasks like disk partitioning, driver installation, and system setup. Additionally, the `Notes` directory contains personal notes from my coursework, covering topics such as system configuration, Linux commands, and more.

## Notes
The `Notes/` directory contains markdown files with school notes arranged in the same order as they were covered in my courses. These include topics on system configuration and Linux commands.
Notes are arranged in the same order as seen in the course.

## Gentoo Installation Scripts
The `Gentoo/` directory contains several bash scripts to automate key steps in the Gentoo Linux installation process, from disk partitioning to post-install configuration.

### Pre-requisites
Before using the scripts, ensure the following:

- You have access to a live Gentoo environment (such as a VM or a physical machine with a Gentoo live CD).
- You have a stable internet connection.

  
## Installation Steps
1. Clone this repository into your local machine:

```bash
git clone https://github.com/StealYourCode/ArchOs.git
cd Archos/Gentoo
```

2. Transfer the required scripts to the Gentoo environment:

```bash 
scp Script.sh GENTOO-USER@GENTOO-IP:/home/GENTOO-USER
```

3. Switch to the superuser and make the scripts executable:

```bash
su -
chmod +x *.sh
```

4. Run the script with the required arguments:

```bash
./Script-Name {arguments as needed}
```

> **Note: Review each script before running them to ensure they align with your disk setup and system configuration.**

## Contributing
Contributions are welcome! Feel free to submit a pull request if you have improvements or fixes to the notes or scripts. Make sure your changes are well-documented and tested before submitting.

