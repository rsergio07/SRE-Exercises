# Use an if-elif-else conditional
score = int(input("Enter your score (0–100): "))

if score >= 90:
    print("Excellent")
elif score >= 75:
    print("Good")
elif score >= 60:
    print("Satisfactory")
else:
    print("Needs improvement")
