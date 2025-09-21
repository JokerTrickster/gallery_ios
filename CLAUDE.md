# CLAUDE.md

> Think carefully and implement the most concise solution that changes as little code as possible.

## Project Information
- **Repository**: JokerTrickster/gallery_ios
- **GitHub URL**: https://github.com/JokerTrickster/gallery_ios
- **Project**: iOS Gallery Cloud Sync App

## Philosophy

### iOS Development

- **Follow Apple HIG**: Adhere to Apple Human Interface Guidelines
- **Use native frameworks**: Prefer UIKit/SwiftUI, Photos framework, CloudKit over third-party solutions
- **Memory management**: Proper use of ARC, avoid retain cycles
- **Performance**: Optimize for smooth scrolling, lazy loading for large photo collections

### Architecture

- **MVVM Pattern**: Use Model-View-ViewModel architecture
- **Coordinator Pattern**: Use coordinators for navigation flow
- **Dependency Injection**: Use proper dependency injection for testability

## Tone and Behavior

- Criticism is welcome. Please tell me when I am wrong or mistaken, or even when you think I might be wrong or mistaken.
- Please tell me if there is a better approach than the one I am taking.
- Please tell me if there is a relevant standard or convention that I appear to be unaware of.
- Be skeptical.
- Be concise.
- Short summaries are OK, but don't give an extended breakdown unless we are working through the details of a plan.
- Do not flatter, and do not give compliments unless I am specifically asking for your judgement.
- Occasional pleasantries are fine.
- Feel free to ask many questions. If you are in doubt of my intent, don't guess. Ask.

## ABSOLUTE RULES:

- NO PARTIAL IMPLEMENTATION
- NO SIMPLIFICATION : no "//This is simplified stuff for now, complete implementation would blablabla"
- NO CODE DUPLICATION : check existing codebase to reuse functions and constants Read files before writing new functions. Use common sense function name to find them easily.
- NO DEAD CODE : either use or delete from codebase completely
- IMPLEMENT TEST FOR EVERY FUNCTIONS
- NO CHEATER TESTS : test must be accurate, reflect real usage and be designed to reveal flaws. No useless tests! Design tests to be verbose so we can use them for debuging.
- NO INCONSISTENT NAMING - read existing codebase naming patterns.
- NO OVER-ENGINEERING - Don't add unnecessary abstractions, factory patterns, or middleware when simple functions would work. Don't think "enterprise" when you need "working"
- NO MIXED CONCERNS - Don't put validation logic inside view controllers, network calls inside UI components, etc. instead of proper separation
- NO RESOURCE LEAKS - Don't forget to close file handles, remove observers, or clean up delegates
- ALWAYS COMMIT AND PUSH - After completing any implementation work, always commit changes and push to GitHub
- ALWAYS LOG TASKS - Every task execution must be logged to .claude/tasks folder with detailed context, status, and results for continuity and web display
