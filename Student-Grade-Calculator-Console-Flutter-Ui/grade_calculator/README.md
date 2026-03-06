# grade_calculator

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Recent improvements

* **Grading logic refactored** – moved `getGrade`/`gradeAccentColor` to
  table‑driven implementations and added a `Student` extension for
  `grade`/`accent` helpers.  This reduces repeated code in the UI and makes
  lookup effectively constant time.
* **Alias handling simplified** – column‑header aliases are stored in
  lowercase `Set`s; header detection now lowercases once and avoids extra
  iterations.
* **Parsing loop tightened** – row iteration uses a simple `for` loop instead
  of chained `map`/`whereType` calls, skipping blank rows early.
* **Shorter summaries** – `StringBuffer` expressions were consolidated in
  `file_service.dart`.
* **UI tweaks** – student cards and export logic use the new extensions,
  cutting boilerplate.

These changes make the codebase shorter, easier to read, and slightly faster
in critical paths.  The behaviour remains the same as before.  See `lib/utils`
for the adjusted functions if you need to review the refactor.
