// ── Exercise 1: Higher-Order Functions ────────────────────────────────────
//
// Task: Write a function processList that takes a list of integers and a
// lambda (Int) -> Boolean, and returns a new list containing only the
// elements that satisfy the predicate.

/**
 * Higher-order function that filters [numbers] using the given [predicate]
 * lambda and returns a new list of only the elements that satisfy it.
 *
 * @param numbers   The input list of integers.
 * @param predicate A lambda (Int) -> Boolean used to test each element.
 * @return          A new list containing only the elements for which
 *                  [predicate] returns true.
 */
fun processList(
    numbers: List<Int>,
    predicate: (Int) -> Boolean
): List<Int> {
    // Use the standard higher-order function `filter`, passing the
    // caller-supplied predicate lambda as the filtering condition.
    return numbers.filter(predicate)
}

// ── Main: test the function ────────────────────────────────────────────────
fun main() {
    val nums = listOf(1, 2, 3, 4, 5, 6)

    // Pass a trailing lambda that keeps only even numbers.
    val even = processList(nums) { it % 2 == 0 }
    println(even)  // [2, 4, 6]

    // ── Extra demonstrations ───────────────────────────────────────────────

    // Keep only odd numbers
    val odd = processList(nums) { it % 2 != 0 }
    println(odd)   // [1, 3, 5]

    // Keep numbers greater than 3
    val greaterThanThree = processList(nums) { it > 3 }
    println(greaterThanThree)  // [4, 5, 6]

    // Store the predicate as a named lambda variable, then pass it
    val isMultipleOfThree: (Int) -> Boolean = { it % 3 == 0 }
    val multiplesOfThree = processList(nums, isMultipleOfThree)
    println(multiplesOfThree)  // [3, 6]
}

