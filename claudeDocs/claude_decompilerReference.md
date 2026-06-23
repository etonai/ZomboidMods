# Decompiler Reference - CLAUDE.md

**Created:** June 23, 2026
**Purpose:** Record which tool was used to decompile Project Zomboid's Java source into `zombie42_19/`, so the same process can be repeated for future game updates.

## Tools Used

- **ZomboidDecompiler**: https://github.com/demiurgeQuantified/ZomboidDecompiler
  - Wraps the decompilation workflow specifically for Project Zomboid's game jars.
- **Vineflower**: https://github.com/Vineflower/vineflower
  - The underlying Java decompiler that ZomboidDecompiler drives.

## Notes

- Follow the setup/usage instructions in the ZomboidDecompiler repo itself rather than a fixed procedure here — those instructions may change between Project Zomboid updates.
- The current decompiled output for v42.19 lives in `zombie42_19/` (gitignored, kept locally as a reference per the project README).
- When a new Project Zomboid version is released, re-run ZomboidDecompiler against the new game jars and place the output in a correspondingly versioned directory (e.g. `zombie42_XX/`).
- REMEMBER TO ADD THE DECOMPILED OUTPUT TO THE .gitignore file
