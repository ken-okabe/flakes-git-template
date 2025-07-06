# NixOS Installation: A GitHub-Centric Flakes Workflow

This guide details a modern, reproducible method for installing NixOS using Flakes. The core philosophy is to use a personal GitHub repository as the "single source of truth" for your entire system configuration. This approach ensures that your system setup is version-controlled, easily shareable, and can be reliably reproduced on any hardware.

## Key Advantages of This Approach

### 🏗️ Architecture & Design

- **Single Source of Truth**: Complete system state managed through GitHub repository
- **Clean Directory Separation**: Working directory isolated from Git repository for optimal workflow
- **Pure Configuration Paradigm**: Eliminates configuration.nix to prevent conflicting management approaches
- **Clean Tree Structure**: `tree` command shows only Nix files, not Git's complex directory structure

### 🔧 Development Experience

- **Modern Editor Compatibility**: Full VSCode/IDE support through user-space configuration placement
- **Minimal sudo Usage**: Daily workflow operates without elevated privileges
- **One-Command Synchronization**: Complete configuration sync with single rsync command

### 🔒 Security & Operations

- **Dual Repository Strategy**: Supports both private repos (with password hash) and public repos (with dummy hash)
- **Atomic Configuration**: System remains stable if build fails, with immediate testing capability
- **Complete Reproducibility**: Identical environment deployment across different hardware

### 🎯 Practical Benefits

- **Seamless Inheritance**: New installations automatically inherit latest configuration
- **Version-Controlled Infrastructure**: Full system history and rollback capabilities
- **Long-term Maintainability**: Sustainable workflow for ongoing system evolution

## Part 1: Preparation

### 1.1. Create Your Flakes Repository

First, generate your own configuration repository from a template.

1.  Go to **[https://github.com/ken-okabe/flakes-git-template](https://www.google.com/search?q=https://github.com/ken-okabe/flakes-git-template)**
    
2.  Click "Use this template" -> "Create a new repository" to create your own copy, which will be at:
    
    https://github.com/GITHUB_USER_NAME/flakes-git

    _(Reference: [Creating a repository from a template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template))_

    ![image](https://raw.githubusercontent.com/ken-okabe/web-images5/main/img_1751777619728.png)

3.  **Repository Privacy Settings**: Since your configuration will include a password hash string (not the password itself, of course), you should make this repository private. Alternatively, if you prefer a public repository, you can replace the password hash with a dummy string before each git commit (detailed in the workflow section below).

     ![image](https://raw.githubusercontent.com/ken-okabe/web-images5/main/img_1751777708137.png)

### 1.2. Prepare Live ISO Media

Download the NixOS installer from the official website: **[https://nixos.org/download](https://nixos.org/download)**

You can use either the **Graphical (GNOME) ISO** or the **Minimal ISO**. Since this guide does not use the graphical installer, either will work. However, the graphical version provides a full desktop environment, which is convenient for partitioning with GParted and setting up wireless networks.

## Part 2: Installation Process

### 2.1. Boot from Live ISO

Boot your machine from the USB drive. Once on the desktop or command line, connect to the internet (and connect your Bluetooth keyboard, if needed).

### 2.2. Disk Partitioning and Mounting

Use a partitioning tool like GParted (available in the graphical ISO) or command-line tools (`gdisk`, `fdisk`) to prepare your disk.

**Example for a UEFI System:**

-   `/dev/nvme0n1p1`: **EFI System Partition (ESP)**, 512MB, FAT32, `boot` & `esp` flags.
    
-   `/dev/nvme0n1p2`: **Root (`/`) Partition**, remaining space, ext4 (or btrfs, etc.).
    
-   `/dev/nvme0n1p3`: **SWAP Partition**, e.g., 16GB, linux-swap.

Once partitioned, format and mount the filesystems.

```sh
# Format the partitions (skip if done in GParted)
# sudo mkfs.fat -F 32 /dev/nvme0n1p1
# sudo mkfs.ext4 /dev/nvme0n1p2
# sudo mkswap /dev/nvme0n1p3

# Mount the partitions
sudo mount /dev/nvme0n1p2 /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/nvme0n1p1 /mnt/boot
sudo swapon /dev/nvme0n1p3
```

### 2.3. Clone and Configure Your Flake

Create the necessary directories on the target disk and clone your repository. Replace `USER` and `GITHUB_USER_NAME` with your own details.

#### For Private Repositories:

Choose one of the following methods to access your private repository:

**Method 1: Personal Access Token (Recommended)**

```sh
sudo mkdir -p /mnt/home/USER/flakes
cd /mnt/home/USER
# Replace TOKEN with your GitHub Personal Access Token
sudo git clone https://GITHUB_USER_NAME:TOKEN@github.com/GITHUB_USER_NAME/flakes-git

```

**Method 2: USB Transfer**

```sh
# Pre-clone the repository on another machine and copy to USB
# Then copy from USB to target system
sudo mkdir -p /mnt/home/USER/flakes
cd /mnt/home/USER
sudo cp -r /media/usb/flakes-git ./

```

#### For Public Repositories:

```sh
sudo mkdir -p /mnt/home/USER/flakes
cd /mnt/home/USER
sudo git clone https://github.com/GITHUB_USER_NAME/flakes-git

```

At this point, your user's home directory on the target disk contains two directories: the empty `flakes` directory (which will be our build directory) and `flakes-git` (which holds the version-controlled configuration). The structure is as follows:

```
/mnt/home/USER/
├── flakes/
└── flakes-git/
```

Next, edit your core configuration file inside the `flakes-git` directory.

```sh
sudo nano /mnt/home/USER/flakes-git/flake.nix

```

Modify the `let` block with your personal settings.

```nix
let
  # --- System Hostname ---
  hostname = "nixos"; # e.g. "my-laptop"

  # --- System Architecture ---
  system = "x86_64-linux";

  # --- NixOS Version ---
  stateVersion = "25.05";

  # --- User Information ---
  username = "USER"; # Your desired username
  passwordHash = "PASSWORD_HASH"; # Your generated password hash

  # --- Git Information ---
  gitUsername = "Your Git Name";
  gitUseremail = "your.email@example.com";

```

To generate the `PASSWORD_HASH`, open a new terminal and run this one-liner. It asks for a password twice and only outputs the hash if they match.

```sh
echo -n "Password: "; read -s pass1; echo; echo -n "Confirm: "; read -s pass2; echo; [ "$pass1" = "$pass2" ] && echo "$pass1" | mkpasswd -m sha-512 -s || echo "Passwords do not match"

```

Copy the resulting hash string (it starts with `$6$`) and paste it into `flake.nix`.

### 2.4. Prepare the Build Directory

Copy only the essential Nix files from your cloned git repository to your build directory.

```sh
sudo rsync -av --exclude '.*' --exclude 'README.md' /mnt/home/USER/flakes-git/ /mnt/home/USER/flakes/
```

**Note on Directory Separation:** We create two distinct directories for a clear and deliberate reason:

-   `/mnt/home/USER/flakes-git/`: Contains the complete Git repository structure, including hidden management files and documentation.
    
    ```
    /mnt/home/USER/flakes-git/
    ├── flake.nix
    ├── .git/
    ├── .gitignore
    ├── README.md
    └── sub/
    ```
    
-   `/mnt/home/USER/flakes/`: Contains only the "pure" Nix files required for the build. The `rsync` command with `--exclude '.*'` filters out all dotfiles (`.git/`, `.gitignore`) and `--exclude 'README.md'` filters out documentation files, leaving only the essential configuration:
    
    ```
    /mnt/home/USER/flakes/
    ├── flake.nix
    └── sub/
    ```

This separation prevents Nix from processing unintended files from your Git history and documentation, making the build environment cleaner and more predictable.

### 2.5. Generate Hardware Configuration

Generate a hardware-specific configuration file for your machine and place it inside your flake's `sub` directory.

```sh
sudo nixos-generate-config --root /mnt --dir /mnt/home/USER/flakes/sub
```

The command above also creates a default `configuration.nix`, which we don't need. Remove it.

```sh
sudo rm /mnt/home/USER/flakes/sub/configuration.nix
```

**Note on configuration.nix Removal:** Traditionally, NixOS systems are managed through `configuration.nix` as the primary configuration file. However, in a Flakes-based setup, keeping both `flake.nix` and `configuration.nix` is equivalent to having different versions of APIs coexisting in the same system—it creates nothing but confusion and potential conflicts. The two approaches represent fundamentally different configuration paradigms: the legacy imperative style versus the modern declarative Flakes approach. There is absolutely no benefit to retaining the auto-generated `configuration.nix` file, as all system configuration is now centrally managed through `flake.nix`. Removing it eliminates any ambiguity about which configuration system is authoritative and ensures a clean, single-source-of-truth architecture.

### 2.6. Install NixOS

You are now ready to install. Change into your flake's root directory and run the installer.

```sh
cd /mnt/home/USER/flakes
sudo nixos-install --flake .
```

The installer will read the `flake.nix` in the current directory, build the system, and install it to `/mnt`. It will automatically detect the pre-existing `/mnt/home/USER` directory, set the correct ownership, and preserve all your configuration files within it.

Once finished, reboot the system.

```sh
sudo reboot
```

## Part 3: Post-Installation and Workflow

### 3.1. First Boot and Ownership Fix

After rebooting and logging in as your new user, the first thing you should do is manually verify and fix file ownership. This is a failsafe step to ensure you have full control over your configuration files.

```sh
sudo chown -R $USER:users /home/$USER/flakes
sudo chown -R $USER:users /home/$USER/flakes-git
```

### 3.2. The Daily Workflow

**Your system is now managed entirely by the files in `~/flakes`.**

Here is the standard workflow for making changes.

1. Edit Your Configuration

Make any desired changes to your system configuration in the working directory.

```sh
cd ~/flakes
code .  # Or your favorite editor
```

2. Test and Apply Changes

Build and apply your new configuration. The nix flake update command ensures your package sources (inputs) are up-to-date.

```sh
sudo nix flake update && sudo nixos-rebuild switch --flake .
```

If the build succeeds, the changes are applied immediately. If it fails, your system remains untouched.

3. Persist Changes to `flakes-git`

Once you are happy with a successful change, sync it from your working directory (`~/flakes`) to your Git directory (`~/flakes-git`). This is done with a safe, targeted one-liner command.

```sh
# Sync changes with the safe, targeted one-liner command
rsync -av --delete ~/flakes/sub/ ~/flakes-git/sub/ && rsync -av ~/flakes/flake.nix ~/flakes-git/flake.nix
```

#### Command Rationale and Validity

This one-liner combines two `rsync` commands with `&&` to safely and accurately synchronize your configuration for daily use.

1.  **`rsync -av --delete ~/flakes/sub/ ~/flakes-git/sub/`**
    
    -   **What it does**: This first command mirrors the `sub` directory, where your Nix modules are stored. The `-av` options ensure efficient file transfer, and the `--delete` option removes any files from the destination (`~/flakes-git/sub/`) that no longer exist in the source (`~/flakes/sub/`).
        
    -   **Why it's valid**: By limiting the scope of this operation to the `sub` directory, there is no risk of accidentally deleting repository-level files like `.git` or `README.md`. It allows you to safely propagate file deletions from your configuration to your repository.
        
2.  **`&&`**
    
    -   **What it does**: This operator ensures that the command on its right only executes if the command on its left succeeds.
        
    -   **Why it's valid**: If an error occurs during the `sub` directory synchronization, the subsequent command will not run. This prevents a chain of operations from proceeding incorrectly and enhances the reliability of the workflow.
        
3.  **`rsync -av ~/flakes/flake.nix ~/flakes-git/flake.nix`**
    
    -   **What it does**: This second command copies and overwrites the top-level `flake.nix` file to its destination.
        
    -   **Why it's valid**: Since this targets a single file, the `--delete` option is not needed. By synchronizing the `sub` directory with the first command and `flake.nix` with this one, all configuration changes (additions, updates, and deletions) are fully and correctly reflected in the `flakes-git` directory.
        

4. Commit and Push to GitHub Repository

After safely synchronizing, commit the changes and push them to GitHub.

Since your configuration contains a password hash, you need to be mindful of repository security:

**Password Hash Security Management:**

- **For Private Repositories**: If your GitHub repository is private, you can safely commit the password hash as-is. This allows seamless inheritance of your password during the next installation.

- **For Public Repositories**: You must replace the password hash with a dummy string before committing. This is also an optional security practice even for private repositories.

**Workflow Options:**

- **Option A - Keep Password Hash (Private repos only)**: If you keep the actual password hash in your commits, it will be automatically inherited during future installations, eliminating the need to repeat the password hash generation process.

- **Option B - Use Dummy Password Hash**: If you replace the password hash with a dummy string before committing, you'll need to repeat the password hash generation and configuration process during each new installation.

```sh
# Commit and push to your repository
cd ~/flakes-git

# Optional: Replace password hash with dummy if using public repo
# sed -i 's/passwordHash = ".*";/passwordHash = "DUMMY_HASH_REPLACE_DURING_INSTALL";/' flake.nix

git add -A -v
git commit -m "feat: updated system configuration" # Or any descriptive message
git push
```

With this, the user information and all other settings you've configured are now permanently saved to your GitHub repository.

**The next time you install NixOS, for example on different hardware, the installation process will now begin from this updated repository. This allows you to reproduce and inherit the exact, most recent state of your NixOS system.**

## Why Use `~/flakes`? (A Comparison with the Default `/etc/nixos`)

***Your system is now managed entirely by the files in ~/flakes.***

This fact can be described as the single greatest feature of NixOS. It directly connects to the immense benefit of having **a complete backup of your entire OS on a GitHub repository**, simply by managing all system configuration within a single directory.

It's important to note that in a default NixOS setup, the configuration files (`configuration.nix` or `flake.nix`) reside in `/etc/nixos/`, not `~/flakes/` as we have done. However, this default location has two very significant problems, which we have intentionally avoided.

First, there is an issue with design philosophy. In any practical setup, `flake.nix` will include user-space settings via a tool called [Home Manager](https://nixos.wiki/wiki/Home_Manager), which configures files within a user's home directory (`/home/USER/`). Placing this user-specific configuration within a system-wide directory like `/etc/nixos/` is inconsistent with standard Linux conventions and can be considered a broken design.

Second, and most importantly, is the practical issue of permissions. Any file under the `/etc/nixos/` directory requires `sudo` privileges to edit. If the "only set of configuration files we ever need to touch" resides here, every single edit in our daily workflow would require `sudo`. While using `sudo nano` is fine for a single file, as we did during the initial installation, it becomes completely impractical when you need to frequently edit an entire directory of configuration files. The critical issue is that **modern editors like VSCode are, for security reasons, restricted from opening system-level directories that require root access.** This means `/etc/nixos/` is effectively unusable for editing in VSCode. This is a massive drawback. Therefore, to enable a sane and productive workflow, the Flakes configuration **must** reside in the user's home space (`/home/USER/`).

## Next Step: Making the System Your Own

Now that your system is running, the most crucial next step is to establish a "flawless development setup." As you have come to understand, managing NixOS is almost exclusively about editing configuration files. Therefore, your most powerful weapon will be a high-function IDE (Integrated Development Environment).

Start by installing an editor like VSCode and adding one of the excellent Nix language extensions available. The benefits of syntax highlighting, autocompletion, and error checking will dramatically improve your configuration workflow.

Once you are set up, open your configuration's entry point, `~/flakes/flake.nix`, in your IDE. You will see that your entire system is composed of a collection of `modules`, just like this:

```nix
      modules = [
        # System state version
        {
          system.stateVersion = stateVersion; # Did you read the comment?
        }
        # Import the Home Manager NixOS module first
        home-manager.nixosModules.home-manager
        # Then import your home configuration module
        ./sub/home.nix
        # Import other necessary system-wide modules
        ./sub/hardware-configuration.nix
        ./sub/boot.nix
        ./sub/user.nix # System-wide user settings
        ./sub/gnome-desktop.nix
        ./sub/key-remap.nix
        ./sub/system-packages.nix
        ./sub/system-settings.nix
      ];
```

These modules are your system. Here is a guide to some of the key files:

-   `boot.nix`
    
    This Flake controls the system's boot behavior. The bootloader is currently systemd-boot, but you should change it to GRUB if necessary. It uses the linux_zen kernel, but you should change it to match your style. NixOS allows you to easily select and roll back to previous versions at boot time, and this file also lets you configure the rules for clearing that history to save disk space.
    
-   `gnome-desktop.nix`
    
    Currently, this system uses GNOME as its desktop environment, and its settings are consolidated in this file. If you prefer KDE or another environment, you should challenge yourself to switch it out. If you show the contents of gnome-desktop.nix to an AI and ask, "I want to change this to KDE," it will surely provide powerful assistance.
    
-   `key-remap.nix`
    
    The author is a heavy user of the Apple Magic Keyboard, so this file contains special key remapping settings. This is not for everyone. You should feel free to edit it to match your style, or delete the file entirely. An AI can also assist you with this task.
    
-   `system-packages.nix`
    
    This is a straightforward list of application packages to be installed system-wide. You can find over 120,000 packages on the NixOS packages search website.
    
    https://search.nixos.org/packages
    
-   `system-settings.nix`
    
    Here, low-level system settings are defined, such as TimeZone configuration, keyboard layout, the audio service to use, and Firewall settings.
    
-   `user.nix`

    Configures system users, including the primary user account, password settings, and sudo privileges.

-   `home.nix`
    
    Your individual user environment settings are centralized here. The author is a native Japanese speaker, so the defaults are optimized for a Japanese environment.
    
    -   **Shell**: The default shell is ZSH, pre-configured with useful features and the Powerlevel10k theme.
        
    -   **Fonts & Language**: Fonts are set up to display Japanese characters correctly.
        
    -   **Input Method**: The system is configured for Japanese input using Fcit5 and Mozc.
        
    -   **Terminal**: The terminal application is **Ghostty**, which includes its own custom keybindings.

You should actively edit all of these files through your IDE. That is the one true way to make this system your own.