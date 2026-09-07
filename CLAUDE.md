# Project Zomboid Codebase Analysis - CLAUDE.md

**THIS FILE IS INTENDED TO BE READ BY CLAUDE ONLY**  
**CURSOR SHOULD IGNORE THIS FILE**

## Project Overview
This is a Project Zomboid game files analysis project with two main purposes:

1. **AI Agent Code Analysis**: Enable AI agents to analyze and understand Project Zomboid code located in the `zombie42_11/`, `zombie42_19/`, `zombie42_20_4/`, `media/`, and `media42_20_4/` directories
2. **Mod Development Support**: Help with creating Project Zomboid mods by providing detailed understanding of game mechanics and systems

The project focuses on understanding and documenting various game mechanics through code examination. The primary goal is to create accurate, code-based documentation of game systems rather than speculation or outdated information.

## Directory Structure
- **claudeDocs/**: Technical analysis documents created by Claude
- **cursorDocs/**: Analysis documents from Cursor with reviews
- **media/**: Project Zomboid Lua scripts/configurations for the v42.19 build
- **media42_20_4/**: Project Zomboid Lua scripts/configurations for the v42.20.4 build
- **zombie42_11/**: Java source files for game engine, v42.11.0
- **zombie42_19/**: Java source files for game engine, v42.19 (decompiled)
- **zombie42_20_4/**: Java source files for game engine, v42.20.4 (decompiled)

When analyzing Lua behavior, match the `media*/` directory to the Java source directory of the same build (`media/` ↔ `zombie42_19/`, `media42_20_4/` ↔ `zombie42_20_4/`) — the two builds' Lua/Java can differ, so don't mix files across them unless explicitly comparing versions.

**Default to the latest build in all research.** Unless Ed names a specific version, points at a specific directory, or the task is explicitly a version comparison, research and analyze against the newest available build (currently `zombie42_20_4/` + `media42_20_4/`) — not whichever directory happens to return search hits first. Before starting any code-based analysis, confirm which build's directories are actually being read.

## Analysis Focus Areas
- **Farming Systems**: Plant growth, disease, fertilizer, water management
- **Fishing Mechanics**: Fish species, environmental factors, skill progression
- **Game Balance**: Risk-reward systems, player progression mechanics

## Key Principles
1. **Code-Based Analysis**: All documentation must be based on actual game code, not speculation
2. **Version Specificity**: Default analysis target is the latest available build (currently v42.20.4); only analyze an older build (v42.19, v42.11.0) when Ed asks for that version specifically or the task is a version comparison
3. **Accuracy Over Completeness**: Better to document verified mechanics than guess at incomplete systems
4. **Practical Application**: Technical details should serve actual gameplay decisions

## Documentation Standards
- Include code snippets with file references
- Provide line numbers for specific implementations
- Distinguish between active and disabled systems
- Compare findings against community sources (wikis) when relevant
- Include version information in all analyses

## Important Findings
- **Overwatering System**: Completely disabled (all waterNeededMax values commented out)
- **Fertilizer System**: Active with 3-tier risk system (1 beneficial, 2+ penalty, 3+ cursed)
- **Wiki Inaccuracies**: Community documentation often contains outdated or incorrect information

## File Naming Convention
- **Claude Documents**: Always place in `claudeDocs/` directory with `claude_` prefix (e.g., `claude_fertilizerAnalysis.md`)
- **Document Modifications**: Only modify cursorDocs files to add "Claude Review" sections
- **Naming Pattern**: Use descriptive names ending with "Analysis.md"
- Include creation/update dates in documents

## Directory Access Rules
- **claudeDocs/**: Full read/write access for new analyses and updates
- **cursorDocs/**: Read access + ability to add "Claude Review" sections only
- **Never**: Create new files in cursorDocs or modify existing content beyond adding reviews
- **Reading Restriction**: Do not read documents in cursorDocs unless specifically asked to review a document in that directory

## Reference Conventions
- **"Your document"**: When Ed refers to "your document", this means documents in the `claudeDocs/` directory
- **Document ownership**: claudeDocs contains Claude-authored analyses, cursorDocs contains Cursor-authored analyses

## Testing and Verification
- Always verify mechanics through code examination
- Test claims against actual game files when possible
- Cross-reference multiple code files for complex systems
- Document any assumptions or uncertainties clearly

## Review Process
- Peer review between Claude and Cursor for accuracy
- Add review sections to existing documents when requested
- Maintain collaborative improvement through feedback
- Update analyses when game versions change

## Development Process

Development follows the processes defined in `DevCycles/DevelopmentProcess.md`. Work is organized into DevCycles (the project's equivalent of sprints). Refer to that document for workflow, status values, naming conventions, and verification authority rules.

## Commands for Common Tasks
- **Lint/Typecheck**: No specific commands identified - ask user if needed
- **Search Pattern**: Use Grep tool for code searching across files
- **File Analysis**: Use Read tool for examining specific implementations
- 1