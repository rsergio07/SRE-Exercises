# **GitHub Fundamentals**

## **Table of Contents**

- [Overview](#overview)
- [What is GitHub?](#what-is-github)
- [Key Concepts](#key-concepts)
  - [Repositories](#repositories)
  - [Commits and Version History](#commits-and-version-history)
  - [Branches](#branches)
  - [Pull Requests](#pull-requests)
  - [Issues](#issues)
  - [Forks and Cloning](#forks-and-cloning)
- [Getting Started: Basic Workflow](#getting-started-basic-workflow)
- [Best Practices for GitHub Collaboration](#best-practices-for-github-collaboration)
  - [Commit Best Practices](#commit-best-practices)
  - [Pull Request Best Practices](#pull-request-best-practices)
  - [Issue Management Best Practices](#issue-management-best-practices)
- [Branching Strategies](#branching-strategies)
  - [Main Only](#main-only)
  - [Feature Branching](#feature-branching)
  - [Git Flow](#git-flow)
  - [Trunk-Based Development](#trunk-based-development)
  - [Choosing a Strategy](#choosing-a-strategy)
- [Essential GitHub Commands](#essential-github-commands)
- [Exercise: Practice the Fundamentals](#exercise-practice-the-fundamentals)
- [Summary](#summary)

---

## **Overview**

**GitHub** is the world’s most popular platform for collaborative software development. It builds on top of the Git version control system, enabling teams to manage code, track changes, and collaborate efficiently—whether open source or within organizations. This topic introduces the foundational concepts and practical workflows to help you become productive on GitHub.

---

## **What is GitHub?**

GitHub is a web-based platform for hosting Git repositories. It provides a user-friendly interface for managing code, tracking issues, reviewing changes, and collaborating with others. Developers and teams use GitHub to:

- Collaborate on projects
- Review and merge code changes
- Track bugs and feature requests
- Document project progress

---

## **Key Concepts**

### **Repositories**

A **repository** (or "repo") is a project’s home on GitHub. It contains all files, folders, and revision history, as well as metadata like issues and pull requests.

- **Public Repositories:** Visible to everyone. Used for open-source projects.
- **Private Repositories:** Visible only to selected collaborators or organizations.
- **README file:** Most repos have a `README.md` file to describe the project and provide usage instructions.
- **LICENSE file:** Important for specifying how others can use your code.

### **Commits and Version History**

A **commit** records a snapshot of your project’s files and directories at a point in time. Each commit has a unique ID (SHA) and a message describing the change.

- **Commit Message:** Should be concise and describe what was changed and why.
- **Atomic Commits:** Each commit should represent a single logical change.
- **Version History:** Lets you track, compare, and revert code changes.
- **Blame View:** Helps identify who made changes to a specific line/file.

### **Branches**

A **branch** is an independent line of development. The default branch is usually called `main` or `master`.

- **Feature Branches:** Used to develop new features or fixes in isolation.
- **Hotfix Branches:** For urgent fixes to production code.
- **Merging:** Combines changes from one branch into another (often via pull requests).
- **Branch Naming:** Use clear, descriptive names like `feature/login-page`, `bugfix/typo-navbar`, or `hotfix/critical-crash`.

### **Pull Requests**

A **pull request (PR)** is a proposal to merge changes from one branch into another. It is the core of GitHub’s collaborative workflow.

- **Code Review:** Team members can comment, suggest changes, and approve PRs.
- **Discussion:** PRs allow for discussion, context, and clarification before merging.
- **Merge Conditions:** PRs may require checks, reviews, or status updates before they can be merged.

### **Issues**

**Issues** are used to track tasks, bugs, ideas, or feature requests.

- **Labels:** Help categorize and prioritize issues (e.g., `bug`, `enhancement`).
- **Assignees:** Assign issues to team members for ownership.
- **Milestones:** Group issues and PRs for a specific release or project phase.
- **Templates:** Use issue templates to standardize bug reports or feature requests.

### **Forks and Cloning**

- **Fork:** A personal copy of someone else’s repository, used to propose changes to upstream projects.
- **Clone:** A local copy of a repository, used for offline work and development.
- **Upstream:** The original repository from which a fork was created.

---

## **Getting Started: Basic Workflow**

1. **Fork or Clone a Repository**
   ```bash
   git clone https://github.com/username/repository.git
   ```
2. **Create a New Branch**
   ```bash
   git checkout -b feature/my-feature
   ```
3. **Make Changes and Commit**
   ```bash
   git add .
   git commit -m "Add my new feature"
   ```
4. **Push to GitHub**
   ```bash
   git push origin feature/my-feature
   ```
5. **Open a Pull Request**
   - Go to your repository on GitHub and click "Compare & pull request."
6. **Review and Merge**
   - Collaborators review, approve, and merge your changes.

---

## **Best Practices for GitHub Collaboration**

### **Commit Best Practices**
- **Write meaningful commit messages:** Begin with a short summary, followed by an optional detailed description.
- **Make atomic commits:** Each commit should contain a single logical change.
- **Reference issues:** Use keywords like `Fixes #42` or `Closes #7` in commit messages or PR descriptions to link changes to issues.
- **Avoid committing sensitive data:** Never commit passwords, API keys, or confidential information.

### **Pull Request Best Practices**
- **Keep PRs focused:** One feature, fix, or topic per pull request.
- **Describe your changes:** Clearly explain what and why in the PR description.
- **Request reviews:** Tag appropriate reviewers or teams.
- **Use draft PRs:** For work in progress or early feedback.
- **Resolve conversations:** Address comments and mark them as resolved.

### **Issue Management Best Practices**
- **File issues for bugs, enhancements, and questions:** Don’t let problems go undocumented.
- **Use labels and milestones:** Organize and prioritize work.
- **Assign ownership:** Make it clear who is responsible for each issue.
- **Close issues when done:** Keep the issue tracker tidy and up to date.

---

## **Branching Strategies**

A branching strategy defines how your team uses branches to manage features, fixes, and releases. Choosing the right strategy helps maintain code quality, enables parallel development, and eases collaboration.

### **Main Only**

- **Description:** All changes go directly to the `main` branch.
- **Best for:** Very small projects or solo development.
- **Drawbacks:** No isolation for features or fixes; risk of unstable code.

### **Feature Branching**

- **Description:** Create a new branch for each new feature or bugfix.
- **Workflow:**
  1. Branch off `main` (or `develop`): `feature/login-page`
  2. Complete work and push branch.
  3. Open a pull request to merge back to `main`.
- **Benefits:** Isolates work, encourages code review, keeps the main branch stable.
- **Best for:** Most small-to-medium teams and projects.

### **Git Flow**

- **Description:** A structured workflow with dedicated branches for features, releases, and hotfixes.
- **Key Branches:**
  - `main` — live, production-ready code
  - `develop` — integration branch for features
  - `feature/*` — new features
  - `release/*` — preparation for releases
  - `hotfix/*` — urgent fixes to production
- **Benefits:** Scales well for larger teams and projects with regular releases.
- **Drawbacks:** More complex; requires discipline and clear process.
- **Best for:** Projects with scheduled releases and multiple contributors.

### **Trunk-Based Development**

- **Description:** Developers work in short-lived branches or directly on the main branch, merging early and often.
- **Benefits:** Encourages continuous integration, reduces merge conflicts, faster delivery.
- **Best for:** Teams practicing continuous delivery or deployment.

### **Choosing a Strategy**

- For most teams, **feature branching** is a good starting point.
- Use **Git Flow** for complex projects with many contributors and planned releases.
- Try **trunk-based development** if you have strong automated testing and CI/CD pipelines.
- Regardless of strategy, keep branches short-lived and merge regularly.

---

## **Essential GitHub Commands**

```bash
# Clone a repository
git clone <repository-url>

# Check repository status
git status

# Stage changes
git add <file-or-folder>

# Commit staged changes
git commit -m "Describe your changes"

# Create a new branch
git checkout -b <new-branch-name>

# Push branch to GitHub
git push origin <branch-name>

# Pull latest changes
git pull origin <branch-name>

# View commit history
git log --oneline --graph --all
```

---

## **Exercise: Practice the Fundamentals**

Try the following to reinforce your understanding of GitHub basics:

1. **Create a new repository** on your own GitHub account.
2. **Clone** the repository to your local machine.
3. **Create a new branch** called `feature/hello-world`.
4. **Add a new file** called `hello.txt` with the contents:  
   ```
   Hello, GitHub!
   ```
5. **Commit** your changes with a meaningful message.
6. **Push** the branch to GitHub.
7. **Open a pull request** from your branch to `main`.
8. **Merge** the pull request once it’s reviewed (you can self-approve if working solo).
9. **Create an issue** labeled `enhancement` suggesting a new feature for your repository.
10. **Try using a branching strategy:** For your next change, create a branch named `bugfix/typo-in-readme` or follow another branching convention.

---

## **Summary**

GitHub is the backbone of modern collaborative software development. Understanding repositories, commits, branches, pull requests, and issues empowers you to contribute effectively, track your work, and collaborate with others. By following best practices and adopting a clear branching strategy, you ensure your projects remain organized, maintainable, and ready for team collaboration.

---