# Python Basics

## Overview

This exercise introduces the foundational elements of Python for students entering the SRE Academy. The goal is to build a strong baseline in Python, preparing participants for scripting, automation, and infrastructure-focused tasks later in the curriculum. Python is a core skill for SREs, and this module is designed for beginners, regardless of their technical background.

The folder contains standalone `.py` scripts to demonstrate essential concepts, along with three practice labs to reinforce learning.

---

## Topics Covered

| File | Topic | Description |
|------|-------|-------------|
| `00_hello_world.py` | Hello World | Introduces Python syntax and print statements. |
| `01_variables.py` | Variables and Data Types | Shows how to store and display values using strings, integers, and booleans. |
| `02_conditionals.py` | Conditionals | Covers `if`, `elif`, and `else` statements for decision-making logic. |
| `03_loops.py` | Loops | Demonstrates the use of `for` loops and basic iteration. |
| `04_functions.py` | Functions | Explains how to define and call reusable functions. |
| `05_modules.py` | Modules and Imports | Introduces Python's built-in `math` module and how to use external functions. |
| `06_file_io.py` | File I/O | Shows how to write to and read from files using Python. |
| `07_exceptions.py` | Exception Handling | Introduces error handling using `try`, `except` blocks. |

---

## Prerequisites

- Install Python:
  ```bash
  sudo apt update && sudo apt install -y python3 python3-venv python3-pip
  ```
- Python 3.x installed. You can check using:
  ```bash
  python3 --version
  ```

To run the files:
```bash
python3 00_hello_world.py
```

No external dependencies are required.

---

## Learning Objectives

By the end of this module, students will:

- Understand Python’s syntax and indentation rules.
- Use variables and data types to store information.
- Control program flow using conditionals and loops.
- Create and reuse logic through functions.
- Work with external modules.
- Read from and write to files.
- Handle exceptions and avoid runtime errors.
- Apply these fundamentals through structured practices.

---

## Detailed Script Breakdown

### `00_hello_world.py`
- Introduces `print()` – Python’s standard output function.
- Explains Python indentation and file execution basics.

### `01_variables.py`
- Demonstrates how to declare variables using different types: `str`, `int`, `bool`.
- Introduces f-strings (`f"{var}"`) for clean and readable string formatting.

### `02_conditionals.py`
- Shows how to perform logical tests using `if`, `elif`, and `else`.
- Demonstrates relational operators like `>=`, `==`, and `<`.
- Emphasizes code blocks and indentation.

### `03_loops.py`
- Uses `for` loop and `range()` to iterate over sequences.
- Discusses the importance of loop counters and termination.

### `04_functions.py`
- Introduces how to define a function using `def`.
- Teaches how to pass arguments and return values.
- Useful for abstraction and reducing repetition in code.

### `05_modules.py`
- Introduces Python’s modularity.
- Demonstrates importing and using the `math` module.
- Encourages use of the Python Standard Library.

### `06_file_io.py`
- Explains how to use `open()` with context manager (`with`).
- Covers file writing (`"w"` mode) and reading (`"r"` mode).
- Discusses when files are closed and how file paths work.

### `07_exceptions.py`
- Explains runtime errors and how to catch them using `try/except`.
- Example shows `ZeroDivisionError` and how to handle it gracefully.

---

## Practice Exercises

These are structured hands-on tasks located in the `exercises/` subfolder. Each practice is designed to reinforce a specific concept.

### [Practice 1 – Variables and Input](./exercises/practice_1_variables.md)

- Accept user input for name and age.
- Store these values in variables and print a formatted response.
- Reinforces:
  - `input()`
  - Data types
  - String formatting

### [Practice 2 – Loops and Conditions](./exercises/practice_2_loops.md)

- Ask for a number.
- Determine if the number is even or odd.
- Count down from the number to 0.
- Reinforces:
  - Modulo operator (`%`)
  - Loop logic
  - Conditionals

### [Practice 3 – File I/O and Error Handling](./exercises/practice_3_file_io.md)

- Write user input to a file.
- Read the file and display the content.
- Catch potential file I/O errors.
- Reinforces:
  - File handling
  - Exception handling

---

## Final Objective

By completing this exercise, students will:

✅ Understand the core principles of Python syntax and structure  
✅ Write clean scripts using conditionals, loops, and functions  
✅ Manipulate files and handle common exceptions  
✅ Be ready to automate repetitive tasks and analyze logs in future SRE labs

This foundational module is essential for all upcoming automation and observability exercises in the SRE Academy.

---