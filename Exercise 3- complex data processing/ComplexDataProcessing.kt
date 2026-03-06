// ── Exercise 3: Complex Data Processing ───────────────────────────────────
//
// Task: Find the average age of people whose names start with 'A' or 'B'.
// Print the result rounded to one decimal place.

// ── Data class ─────────────────────────────────────────────────────────────
data class Person(val name: String, val age: Int)

fun main() {

    val people = listOf(
        Person("Alice",   25),
        Person("Bob",     30),
        Person("Charlie", 35),
        Person("Anna",    22),
        Person("Ben",     28)
    )

    // ── Step 1: filter (higher-order function) ─────────────────────────────
    // Keep only people whose name starts with 'A' or 'B'.
    // The lambda (Person) -> Boolean is passed to filter.
    val filtered: List<Person> = people.filter { person ->
        person.name.startsWith("A") || person.name.startsWith("B")
    }

    // ── Step 2: map (higher-order function) ───────────────────────────────
    // Extract the age from each remaining Person using a lambda.
    val ages: List<Int> = filtered.map { person -> person.age }

    // ── Step 3: calculate average ──────────────────────────────────────────
    // average() returns a Double; we guard against an empty list with
    // a lambda passed to takeIf so division by zero is impossible.
    val average: Double = ages
        .takeIf { it.isNotEmpty() }
        ?.average()
        ?: 0.0

    // ── Step 4: format and print ───────────────────────────────────────────
    // "%.1f".format() rounds to one decimal place.
    println("Average age of people whose name starts with 'A' or 'B': ${"%.1f".format(average)}")

    // ── Bonus: show which people were included ─────────────────────────────
    println("\nIncluded people:")
    filtered.forEach { println("  ${it.name} (age ${it.age})") }
}

