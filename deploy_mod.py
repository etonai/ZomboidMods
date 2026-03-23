#!/usr/bin/env python3
"""
Deploy a mod from the development directory to the local Project Zomboid mods directory.

Usage:
    python deploy_mod.py PseudoShortBat
    python deploy_mod.py PseudoSaltRecipes
"""

import os
import sys
import shutil
from pathlib import Path


def read_config(config_file="config.txt"):
    """Read configuration file and return a dictionary of settings."""
    config = {}
    config_path = Path(__file__).parent / config_file

    if not config_path.exists():
        print(f"Error: Configuration file '{config_file}' not found.")
        sys.exit(1)

    with open(config_path, 'r') as f:
        for line in f:
            line = line.strip()
            # Skip comments and empty lines
            if not line or line.startswith('#'):
                continue

            if '=' in line:
                key, value = line.split('=', 1)
                config[key.strip()] = value.strip()

    return config


def deploy_mod(mod_name, config):
    """Copy mod from development directory to local mods directory."""
    dev_mods_dir = Path(config.get('DEV_MODS_DIR', './mymods'))
    local_mods_dir = Path(config.get('LOCAL_MODS_DIR'))

    if not local_mods_dir:
        print("Error: LOCAL_MODS_DIR not set in config.txt")
        sys.exit(1)

    # Source and destination paths
    source_mod = dev_mods_dir / mod_name
    dest_mod = local_mods_dir / mod_name

    # Validate source mod exists
    if not source_mod.exists():
        print(f"Error: Mod '{mod_name}' not found in {dev_mods_dir}")
        print(f"Looking for: {source_mod}")
        available_mods = [d.name for d in dev_mods_dir.iterdir() if d.is_dir()]
        if available_mods:
            print(f"\nAvailable mods:")
            for mod in available_mods:
                print(f"  - {mod}")
        sys.exit(1)

    # Create local mods directory if it doesn't exist
    local_mods_dir.mkdir(parents=True, exist_ok=True)

    # Define ignore function to skip .git directories
    def ignore_git(directory, contents):
        """Ignore .git directories and their contents during copy."""
        return ['.git'] if '.git' in contents else []

    # Remove existing mod files (except .git) if destination exists
    if dest_mod.exists():
        print(f"Updating existing mod at: {dest_mod}")
        # Remove all files/folders except .git
        for item in dest_mod.iterdir():
            if item.name != '.git':
                if item.is_dir():
                    shutil.rmtree(item)
                else:
                    item.unlink()
    else:
        print(f"Installing new mod at: {dest_mod}")

    # Copy mod to local mods directory (ignoring .git folders)
    print(f"Copying mod from: {source_mod}")
    print(f"             to: {dest_mod}")
    shutil.copytree(source_mod, dest_mod, ignore=ignore_git, dirs_exist_ok=True)

    print(f"\n[SUCCESS] Successfully deployed '{mod_name}' to local mods directory!")
    print(f"\nRestart Project Zomboid or reload mods to see changes.")


def main():
    if len(sys.argv) < 2:
        print("Usage: python deploy_mod.py <mod_name>")
        print("\nExample:")
        print("  python deploy_mod.py PseudoShortBat")
        sys.exit(1)

    mod_name = sys.argv[1]

    # Read configuration
    config = read_config()

    # Deploy the mod
    deploy_mod(mod_name, config)


if __name__ == "__main__":
    main()
