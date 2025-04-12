# Example of error handling
try:
    number = int(input("Enter a number to divide 100: "))
    result = 100 / number
    print("Result is:", result)
except ZeroDivisionError:
    print("You cannot divide by zero!")
except ValueError:
    print("Please enter a valid number.")
