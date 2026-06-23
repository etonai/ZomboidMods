# CURSOR.md - Project Zomboid Technical Analysis Guide

*This file is intended for use by Cursor only.*

*Last Updated: August 21, 2025*

## Overview

This document serves as a comprehensive guide for using Cursor effectively in the Project Zomboid Technical Analysis Project. It outlines workflows, standards, and best practices for creating accurate, code-verified documentation of game mechanics.

## Project Purposes

This project serves two primary purposes:

### **1. AI Agent Code Analysis**
- **Enable AI agents to analyze Project Zomboid source code** located in the `zombie42_11/`, `zombie42_19/`, and `media/` directories
- **Provide comprehensive technical documentation** of game mechanics for AI consumption
- **Create verified, code-based analyses** that AI agents can rely on for accurate information
- **Support AI-driven game understanding** through structured, validated documentation

### **2. Mod Development Support**
- **Assist in creating Project Zomboid mods** by providing detailed system understanding
- **Document game mechanics** that modders need to integrate with or modify
- **Provide code examples and implementation details** for mod development
- **Support mod testing and validation** through accurate game system documentation

## Project Structure

### **Directory Organization**
```
zomboid_42_X/
├── claudeDocs/          # Claude-generated technical analyses
├── cursorDocs/          # Cursor-generated technical analyses  
├── media/               # Game assets and Lua files (gitignored)
├── zombie42_11/         # Java source code, v42.11.0 (gitignored)
├── zombie42_19/         # Java source code, v42.19 (decompiled, gitignored)
├── .gitignore          # Git ignore patterns
├── CURSOR.md           # This file - project guide
├── summary.txt         # Project summary (gitignored)
└── zomboid_42_X.iml   # IntelliJ project file (gitignored)
```

### **Document Types**
- **Technical Analysis**: Code-based examination of game mechanics
- **Peer Review**: Collaborative validation of technical accuracy
- **Wiki Response**: Critical analysis of community documentation
- **Strategic Guidance**: Practical advice for players

## Core Principles

### **1. Accuracy Over Completeness**
- **Always verify mechanics through actual game code**
- **Never speculate about undocumented systems**
- **Document only what can be proven through code examination**
- **Flag any unverified information clearly**

### **2. Code-First Approach**
- **Start with code analysis, not gameplay observation**
- **Include file paths and line numbers for all code references**
- **Provide sufficient context around code snippets**
- **Verify code functionality before documenting**

### **3. Player-Centric Documentation**
- **Focus on practical application over technical detail**
- **Include risk assessment and strategic guidance**
- **Provide clear recommendations for different skill levels**
- **Explain both "how" and "why" of game mechanics**

### **4. Document Directory Rules**
- **All new analyses must be created in `cursorDocs/` directory**
- **Never modify existing files in `claudeDocs/` directory**
- **Only exception: Adding/modifying "Cursor Review" sections in claudeDocs**
- **Maintain clear separation between Claude and Cursor generated content**
- **All Cursor-generated documents must be prefixed with `cursor_`**
- **When user refers to "your" document, they mean documents in `cursorDocs/` directory**
- **Responses to user questions should be added to `cursorDocs/` documents, not `claudeDocs/`**
- **Do not read documents in `claudeDocs/` unless explicitly asked to review a document in that directory**

## Cursor Workflows

### **New Analysis Creation**

#### **Step 1: System Identification**
```bash
# Use Cursor's file search to locate relevant code files
# Example: Search for "fertilizer" in media/lua/ directory
# Identify key functions and data structures
```

#### **Step 2: Code Examination**
```bash
# Open relevant files in Cursor
# Use multi-file search to trace mechanic implementation
# Document file paths, line numbers, and function names
```

#### **Step 3: Analysis Structure**
```bash
# Create analysis document with consistent format:
# - Overview and mechanics
# - Code evidence and implementation details
# - Risk assessment and strategic guidance
# - Integration with other systems
```

#### **Step 4: Verification**
```bash
# Cross-reference findings across multiple files
# Verify all claims against actual code
# Test edge cases and error conditions
# Validate mathematical calculations
```

### **Peer Review Process**

#### **Reviewer Responsibilities**
- **Technical Accuracy**: Verify all code references and mechanics
- **Practical Value**: Ensure documentation helps players make decisions
- **Completeness**: Check for missing critical information
- **Clarity**: Ensure explanations are understandable

#### **Author Response**
- **Address all feedback constructively**
- **Provide additional code context when requested**
- **Clarify any ambiguous explanations**
- **Update documentation based on valid concerns**

### **Documentation Updates**

#### **Version Tracking**
- **Always specify game version** (e.g., Project Zomboid 42.11.0)
- **Update with each major patch**
- **Flag deprecated or changed mechanics**
- **Maintain change log for significant updates**

#### **Quality Maintenance**
- **Regular accuracy reviews**
- **Cross-reference with new code changes**
- **Update based on community feedback**
- **Remove outdated information promptly**

## Code Analysis Standards

### **Citation Requirements**

#### **File References**
```lua
-- Always include full file path
-- From media/lua/shared/SPlantGlobalObject.lua:45-52
function SPlantGlobalObject:fertilize(args)
    -- Function implementation
end
```

#### **Line Number References**
```lua
-- Include line numbers for specific code sections
-- From farming_vegetableconf.lua:285-288
if planting.fertilizer >= 1 then
    planting.fertilizer = planting.fertilizer - 1
end
```

#### **Function Context**
```lua
-- Provide surrounding code context
-- Show function parameters and return values
-- Include relevant variable declarations
```

### **Code Verification Process**

#### **Multi-File Validation**
- **Trace mechanic implementation across files**
- **Verify function calls and data flow**
- **Check for conditional logic and edge cases**
- **Validate mathematical calculations**

#### **Error Handling**
- **Document what happens when things go wrong**
- **Include health checks and death conditions**
- **Explain penalty systems and consequences**
- **Provide troubleshooting guidance**

## Documentation Templates

### **Technical Analysis Structure**

```markdown
# [System Name] Analysis in Project Zomboid

*Updated: [Date]*
*Game Version: [Version Number]*

## Overview
[Brief description of the system and its purpose]

## Core Mechanics
[Detailed explanation of how the system works]

## Code Implementation
[Code snippets with proper citations]

## Risk Assessment
[Analysis of potential dangers and consequences]

## Strategic Guidance
[Practical advice for players]

## Integration
[How this system interacts with others]

## Conclusion
[Summary of key points and recommendations]
```

### **Peer Review Response**

```markdown
## [Author Name] Response

### Addressing Feedback
[Constructive response to review comments]

### Validation of Approach
[Explanation of methodology choices]

### Moving Forward
[Commitment to improvements]

### Key Takeaway
[Main insight from the review process]
```

## Quality Control Checklist

### **Pre-Review Checklist**
- [ ] All mechanics verified through code examination
- [ ] File paths and line numbers included
- [ ] Mathematical calculations verified
- [ ] Risk assessment included
- [ ] Strategic guidance provided
- [ ] Version information specified

### **Review Checklist**
- [ ] Technical accuracy confirmed
- [ ] Code references verified
- [ ] Practical value assessed
- [ ] Clarity and organization reviewed
- [ ] Integration analysis complete
- [ ] Recommendations actionable

### **Post-Review Checklist**
- [ ] All feedback addressed
- [ ] Documentation updated
- [ ] Accuracy maintained
- [ ] Version information current
- [ ] Ready for player use

## Common Pitfalls

### **1. Speculation vs. Verification**
- **❌ Don't**: Describe mechanics based on gameplay observation
- **✅ Do**: Examine actual code implementation

### **2. Incomplete Citations**
- **❌ Don't**: Reference code without file paths
- **✅ Do**: Include full file paths and line numbers

### **3. Missing Risk Assessment**
- **❌ Don't**: Focus only on benefits
- **✅ Do**: Explain dangers and consequences

### **4. Outdated Information**
- **❌ Don't**: Document mechanics from old versions
- **✅ Do**: Verify against current game version

### **5. Over-Complexity**
- **❌ Don't**: Include unnecessary technical details
- **✅ Do**: Focus on practical player guidance

## Tools and Resources

### **Cursor Features for This Project**

#### **File Navigation**
- **File Search**: Quick location of relevant code files
- **Multi-File Search**: Cross-reference mechanics across files
- **Symbol Search**: Find specific functions and variables
- **Recent Files**: Quick access to frequently used files

#### **Code Analysis**
- **Syntax Highlighting**: Clear code structure visualization
- **Error Detection**: Identify potential code issues
- **Refactoring Tools**: Clean up code examples
- **Version Control**: Track documentation changes

#### **Documentation Support**
- **Markdown Preview**: Real-time formatting validation
- **Auto-completion**: Consistent formatting and structure
- **Search and Replace**: Efficient bulk updates
- **Multi-cursor Editing**: Parallel content creation

### **External Resources**
- **Project Zomboid Source**: Primary code reference
- **Community Wikis**: For comparison and validation
- **Game Patches**: For version-specific updates
- **Player Feedback**: For practical application validation

## Maintenance Schedule

### **Regular Tasks**
- **Weekly**: Review recent documentation for accuracy
- **Monthly**: Cross-reference with game code for changes
- **Quarterly**: Comprehensive accuracy review
- **Patch Release**: Immediate validation of affected systems

### **Update Triggers**
- **Game Updates**: Verify all documented mechanics
- **Community Reports**: Investigate reported discrepancies
- **Code Changes**: Update affected documentation
- **New Discoveries**: Add newly verified mechanics

## Conclusion

This CURSOR.md file serves as the foundation for maintaining high-quality technical documentation of Project Zomboid's game systems. By following these guidelines, we ensure that:

- **All documentation is code-verified and accurate**
- **Players receive reliable, actionable information**
- **The project maintains its reputation for quality**
- **Documentation evolves with the game**

**Remember**: Accuracy is more important than completeness. It's better to document fewer mechanics correctly than many mechanics incorrectly.

---

*This document should be updated as the project evolves and new best practices are discovered.*
