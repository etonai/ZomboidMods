# Project Zomboid Codebase Analysis - CLAUDE.md

**THIS FILE IS INTENDED TO BE READ BY CLAUDE ONLY**  
**CURSOR SHOULD IGNORE THIS FILE**

## Project Overview
This is a Project Zomboid game files analysis project with two main purposes:

1. **AI Agent Code Analysis**: Enable AI agents to analyze and understand Project Zomboid code located in the `zombie/` and `media/` directories
2. **Mod Development Support**: Help with creating Project Zomboid mods by providing detailed understanding of game mechanics and systems

The project focuses on understanding and documenting various game mechanics through code examination. The primary goal is to create accurate, code-based documentation of game systems rather than speculation or outdated information.

## Directory Structure
- **claudeDocs/**: Technical analysis documents created by Claude
- **cursorDocs/**: Analysis documents from Cursor with reviews
- **media/**: Project Zomboid game files (Lua scripts, configurations)
- **zombie/**: Java source files for game engine

## Analysis Focus Areas
- **Farming Systems**: Plant growth, disease, fertilizer, water management
- **Fishing Mechanics**: Fish species, environmental factors, skill progression
- **Game Balance**: Risk-reward systems, player progression mechanics

## Key Principles
1. **Code-Based Analysis**: All documentation must be based on actual game code, not speculation
2. **Version Specificity**: Analysis is for Project Zomboid version 42.11.0
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

## Commands for Common Tasks
- **Lint/Typecheck**: No specific commands identified - ask user if needed
- **Search Pattern**: Use Grep tool for code searching across files
- **File Analysis**: Use Read tool for examining specific implementations
- 1