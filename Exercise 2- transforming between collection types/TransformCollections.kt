// ── Exercise 2: Transforming Between Collection Types ─────────────────────
//
// Task: Given a list of strings, create a map where the keys are the strings
// and the values are their lengths. Then print only the entries where the
// length is greater than 4.

fun main() {

    val words = listOf("apple", "cat", "banana", "dog", "elephant")

    // ── Step 1: associateWith (higher-order function) ──────────────────────
    // associateWith takes a lambda (String) -> V and builds a Map<String, V>
    // where each key is an element of the list and each value is produced by
    // the lambda.
    val wordLengthMap: Map<String, Int> = words.associateWith { it.length }

    // ── Step 2: filter (higher-order function) ─────────────────────────────
    // filter on a Map takes a lambda (Map.Entry<K,V>) -> Boolean and returns
    // a new Map containing only the entries that satisfy the predicate.
    val longWords: Map<String, Int> = wordLengthMap.filter { (_, length) ->
        length > 4
    }

    // ── Step 3: forEach (higher-order function) ────────────────────────────
    // forEach iterates over every remaining entry and executes the lambda.
    longWords.forEach { (word, length) ->
        println("$word has length $length")
    }
}

