# **Implementing CI/CD with GitHub Actions**

## **Table of Contents**

- [Overview](#overview)
- [Why GitHub Actions in SRE?](#why-github-actions-in-sre)
- [What You’ll Learn](#what-youll-learn)
- [Navigate to the Directory](#navigate-to-the-directory)
- [Preconfigured Project Structure](#preconfigured-project-structure)
- [Understanding the Files](#understanding-the-files)
  - [Python App](#python-app)
  - [Dockerfile](#dockerfile)
  - [GitHub Actions Workflow](#github-actions-workflow)
- [How the CI Workflow Works](#how-the-ci-workflow-works)
- [Expected Outcome](#expected-outcome)
- [Validate the Workflow](#validate-the-workflow)
- [Cleanup](#cleanup)

---

## **Overview**

This practice introduces **GitHub Actions** — a cloud-native CI/CD platform fully integrated with GitHub. You'll learn how to automate code validation tasks such as building and running a Python application every time you push changes to the repository.

In this scenario, we simulate how a real-world **Site Reliability Engineer (SRE)** sets up automation to ensure consistent code quality and faster feedback cycles.

---

## **Why GitHub Actions in SRE?**

GitHub Actions empowers SRE teams to:

- Enforce quality gates
- Automate build and test pipelines
- Reduce manual errors in deployments
- Enable faster incident response through automation
- Integrate CI/CD directly into the version control system

---

## **What You’ll Learn**

By the end of this lab, you’ll be able to:

- Understand how GitHub Actions workflows are structured  
- Observe how automation runs on each `git push`  
- Execute and monitor pipelines using the GitHub UI  
- Explain how CI/CD fits within an SRE operating model

---

## **Navigate to the Directory**

Before starting, navigate to the correct exercise folder:

```bash
cd sre-abc-training/exercises/exercise16
```

---

## **Preconfigured Project Structure**

The following files are already created for you. 
🔒 Do not manually create these files — just explore and understand how they work.

```
.
├── Dockerfile
├── README.md
├── app/
│   ├── app.py
│   └── requirements.txt
└── .github/
    └── workflows/
        └── python-app.yml
```

---

## **Understanding the Files**

### **Python App**

**app/app.py**:  
A simple Python function that prints a message. This simulates the type of lightweight microservice often used in training labs.

```python
def handler(event=None, context=None):
    return {
        "message": "Hello from GitHub Actions"
    }

if __name__ == "__main__":
    print(handler())
```

**app/requirements.txt**:  
Contains any external Python dependencies. In this case, it’s empty:

```txt
# No external dependencies
```

---

### **Dockerfile**

Defines how to containerize the application. GitHub Actions does not build the Docker image in this lab, but it’s included to simulate real-world application packaging.

```Dockerfile
FROM python:3.10-slim

WORKDIR /app

COPY app/ ./app/

WORKDIR /app/app

RUN pip install -r requirements.txt

CMD ["python", "app.py"]
```

---

### **GitHub Actions Workflow**

**.github/workflows/python-app.yml**:  
This file defines a GitHub Actions workflow that runs on every push to the `main` branch.

```yaml
name: Python CI

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout source code
      uses: actions/checkout@v4

    - name: Set up Python
      uses: actions/setup-python@v5
      with:
        python-version: '3.10'

    - name: Install dependencies
      run: |
        cd app
        pip install -r requirements.txt

    - name: Run Python App
      run: |
        cd app
        python app.py
```

---

## **How the CI Workflow Works**

Every time you push a change to the main branch:
1. GitHub spins up a new runner (`ubuntu-latest`).
2. Code is cloned into the runner.
3. Python is set up with version 3.10.
4. The app’s dependencies (if any) are installed.
5. The application is executed, and the result is printed in the Actions tab logs.

This simulates the “CI” phase — validating that the app builds and runs correctly.

---

## **Expected Outcome**

If everything is set up correctly, after pushing to `main`, you should see:

- A successful GitHub Actions run
- Output logs showing the printed message from your `app.py`
- GitHub workflow history in the Actions tab of your repository

---

## **Validate the Workflow**

Run the following commands:

```bash
git status
git add .
git commit -m "Add Practice #16 - GitHub Actions CI workflow"
git push origin main
```

Then open your GitHub repository → Go to the Actions tab  
Monitor the latest workflow run and check the logs.

---

## **Cleanup**

There are no Kubernetes, Docker, or cloud resources to clean up.  
The GitHub Actions workflow runs only in the GitHub environment.

---