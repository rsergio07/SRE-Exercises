# Practice 3 – File I/O and Error Handling

## Goal

Create a script that does the following:
1. Asks the user to enter a message.
2. Writes that message to a file named `message.txt`.
3. Reads the file content and displays it back to the user.
4. Handles potential file-related errors gracefully.

---

## Requirements

- Use `input()` to get user input.
- Use the `with open()` syntax to write and read the file.
- Add exception handling using `try` and `except`.

---

## Example Output

```
Enter a message: Hello, world!
Message saved to file.

Reading message...
Hello, world!
```

---

## Bonus

- After displaying the message, delete the file automatically.
- Confirm deletion with a print statement like:
  ```
  File deleted successfully.
  ```

---

## Expected Learning Outcomes

By completing this practice, you will:
- Understand how to write to and read from files in Python.
- Learn to manage file operations using context managers.
- Handle exceptions properly to build more reliable scripts.
```