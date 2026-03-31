# Student Grade Calculator - Lecturer Presentation Guide

## Checklist and plan
- [x] Show app purpose and workflow in under 1 minute.
- [x] Show where the main source files are.
- [x] Map course requirements to exact functions/files.
- [x] Give a ready-made talk track you can read during presentation.
- [x] Include a short demo flow (manual add, import, export).

## 1) Quick talk track (what to say)
"This is a Flutter student grade calculator. It supports manual student entry, score validation, grade calculation, and Excel import/export. It also demonstrates higher-order functions, lambdas, and collection operations both in utility logic and file processing."

Then continue:
1. "The app starts in `lib/main.dart`, which configures theme and loads `HomeScreen`."
2. "`HomeScreen` in `lib/screens/home_screen.dart` manages student state, import/export actions, and the main UI layout."
3. "`Student` is the data model in `lib/models/student.dart`."
4. "Grade logic and higher-order utilities are in `lib/utils/grade_calculator.dart`."
5. "Excel import/export logic is in `lib/utils/file_service.dart`."

## 2) Main source files and what each one does
- `lib/main.dart`
  - App entry point (`main()`), orientation lock, app theme setup, and root widget `GradeCalculatorApp`.
- `lib/screens/home_screen.dart`
  - Main screen and state (`_students`).
  - Add student, clear list, import Excel, export Excel.
  - Passes lambdas/functions into services for import/export.
- `lib/models/student.dart`
  - Defines `Student` object (`name`, nullable `score`).
- `lib/utils/grade_calculator.dart`
  - Core grade calculation (`getGrade`).
  - Higher-order functions (`processStudents`, `filterStudents`, `reduceStudents`).
  - Lambda-returning function (`gradingFunction`).
  - `StudentExtensions` (`grade`, `accent`) used by UI.
- `lib/utils/file_service.dart`
  - Excel parsing and generation.
  - Import from `.xlsx` through device file picker.
  - Export to `.xlsx` then share/save via share sheet.
- `lib/widgets/student_form.dart`
  - Form input, validation, and callback to add students.
- `lib/widgets/student_card.dart`
  - Student display card with score/grade/accent color.
- `test/grade_calculator_test.dart`
  - Unit tests for `getGrade()` and `Student.toString()`.

## 3) Requirement mapping (where each requirement is in code)

### Requirement A: Use higher-order function(s) on list of objects
Evidence:
- `lib/utils/grade_calculator.dart`
  - `processStudents(...)` uses `map` on `List<Student>`.
  - `filterStudents(...)` uses `where` on `List<Student>`.
  - `reduceStudents(...)` uses `fold` on `List<Student>`.
- `lib/utils/file_service.dart`
  - Import flow uses `where` to skip empty rows.
  - Export flow uses `students.asMap().forEach(...)` to enumerate and write rows.

Suggested sentence:
"I used collection higher-order functions (`map`, `where`, `fold`, `forEach`) on student lists for transformation, filtering, reduction, and export row generation."

### Requirement B: Lambda passed to a custom higher-order function
Evidence:
- `lib/screens/home_screen.dart`
  - Import call: `importStudentsFromExcel(grader: getGrade)` passes grading function as parameter.
  - Export call passes lambda to `rowBuilder: (student) => [...]`.
- `lib/utils/file_service.dart`
  - `importStudentsFromExcel({ required String Function(int) grader })`
  - `exportStudentsToExcel({ required List<dynamic> Function(Student) rowBuilder })`

Suggested sentence:
"I inject behavior using function parameters. For example, import receives a grading function and export receives a row-builder lambda."

### Requirement C: Collection operation demo (filter list of items)
Evidence:
- `lib/utils/grade_calculator.dart`
  - `filterStudents(...)` explicitly demonstrates filtering.
- `lib/utils/file_service.dart`
  - `rows.skip(...).where(...)` filters Excel rows.

Suggested sentence:
"Filtering is demonstrated both on domain objects (`filterStudents`) and on imported Excel rows (`where` for non-empty rows)."

## 4) Demo script (3-5 minutes)
1. Launch app and show `HomeScreen`.
2. Add 2-3 students manually (including one with unknown score).
3. Show computed grades in student cards.
4. Tap **Import Excel** and explain picker opens device storage for `.xlsx`.
5. Explain that import can detect name/score/grade columns (or fallback positions).
6. Tap **Export Excel** and explain it generates and shares `.xlsx` with name, score, grade.
7. Point to higher-order functions in code quickly (`grade_calculator.dart`, `file_service.dart`).

## 5) If lecturer asks "where is the lambda demo?"
Answer:
- Import lambda/function injection: `home_screen.dart` -> `importStudentsFromExcel(grader: getGrade)`.
- Export lambda injection: `home_screen.dart` -> `rowBuilder: (student) => [...]`.
- Lambda-returning function: `gradingFunction` in `grade_calculator.dart`.

## 6) If lecturer asks "where is filter/map/forEach?"
Answer:
- `map`: `processStudents` in `grade_calculator.dart`.
- `filter/where`: `filterStudents` in `grade_calculator.dart`, row filtering in `file_service.dart`.
- `forEach`: export row writing in `file_service.dart` using `students.asMap().forEach(...)`.

## 7) Optional one-liner closing
"The project combines clean Flutter UI, typed model-driven logic, and function-based design (higher-order functions and lambdas) while supporting practical Excel import/export for real class workflows."
