# Write and read from a file
filename = "message.txt"
message = input("Enter a message to save: ")

with open(filename, "w") as f:
    f.write(message + "\n")

print("\nReading the file:")
with open(filename, "r") as f:
    print(f.read())
