# Code Review Policy

AI must follow these code quality principles.

## Code Quality Standards

- One responsibility per class.
- Prefer explicit naming.
- Avoid Util / Helper / Manager.
- No static god classes.
- Namespace = folder.

## Naming Conventions

- Prefer explicit naming.
- Avoid technical-sounding abstractions without domain meaning.
- Avoid dumping shared logic into Shared or Utils folders.
- Prefer explicit responsibility-based naming.
- Prefer behavior-oriented class names.

## Code Organization

- Namespace = folder.
- No cross-layer naming leakage.
- One public type per file.
- File name = primary type name.

## Anti-Patterns to Avoid

- Manager / Helper / Util / Common / Base.
- Static god classes.
- Technical-sounding abstractions without domain meaning.
- Dumping shared logic into Shared or Utils folders.
