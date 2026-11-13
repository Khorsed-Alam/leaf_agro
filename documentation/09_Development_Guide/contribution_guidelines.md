# AgriCare AI — Contribution Guidelines

## 1. Branching Strategy
AgriCare AI follows a trunk-based / GitFlow branch workflow:
- `main`: Production-ready, fully tested codebase.
- `feature/<feature-name>`: Feature branches for new screens or capabilities.
- `fix/<bug-description>`: Targeted bug-fix branches.

---

## 2. Commit Message Standards
Commit messages must be clear, concise, and descriptive:
```text
feat: Add recovery observation timeline on Screen 21
fix: Resolve ListTile ink splash background assertion
test: Add 11 widget tests for About Application Screen
docs: Complete AgriCare AI project documentation and user flow diagrams
```

---

## 3. Pull Request Requirements
Before submitting a pull request (PR):
1. Run `flutter analyze` and ensure **zero warnings or linter errors**.
2. Run `flutter test` and confirm **all 250+ automated tests pass**.
3. Verify dual-language compatibility in both English and Bengali.
4. Update or add relevant documentation in `documentation/`.

