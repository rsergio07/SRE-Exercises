# Table of Contents
- [Docker Hub Guide](#docker-hub-guide)
  - [Introduction to Docker Hub](#introduction-to-docker-hub)
  - [Creating a Docker Hub Account](#creating-a-docker-hub-account)
  - [Creating a Docker Repository](#creating-a-docker-repository)
- [Final Objective](#final-objective)

## Introduction to Docker Hub

Docker Hub is a cloud-based registry service where Docker images can be stored, shared, and managed. It allows developers to find and share container images with their team or the global community. Docker Hub provides a centralized resource for container image discovery, distribution, and change management, making it easier to build, ship, and run distributed applications.

### Key Features:
- **Image Repositories:** Store and share Docker images.
- **Automated Builds:** Automatically build images from a source code repository.
- **Webhooks:** Trigger actions after image updates.
- **Teams and Organizations:** Manage access to private repositories.
- **Official Images:** Verified images provided by Docker.

## Creating a Docker Hub Account

To start using Docker Hub, you'll need to create an account.

### Steps:
1. **Visit the Docker Hub website:**
   - Go to [Docker Hub](https://hub.docker.com/) in your web browser.

2. **Sign Up:**
   - Click on the "Sign Up" button at the top right corner.
   - Fill in the required details, including your username, email, and password.
   - Agree to the terms and conditions, then click "Sign Up."
   - You may need to verify your email address. Check your email inbox for a verification link.

3. **Log In:**
   - Once your account is created, you can log in by clicking on the "Log In" button.
   - Enter your username and password to access your Docker Hub account.

## Creating a Docker Repository

A Docker repository is a place where Docker images are stored and can be pulled from.

### Steps:
1. **Log In to Docker Hub:**
   - Ensure you are logged into your Docker Hub account.

2. **Create a New Repository:**
   - After logging in, click on the "Repositories" tab in the top navigation bar.
   - Click on the "Create Repository" button.

3. **Fill in Repository Details:**
   - **Name:** Provide a name for your repository. This name should be unique and descriptive.
   - **Description (optional):** Add a description of what the repository contains or its purpose.
   - **Visibility:** Choose between Public (anyone can pull the image) or Private (restricted access).
   - **Initialize with a README (optional):** Check this box if you want to start your repository with a README file.

4. **Create the Repository:**
   - After filling in the details, click on the "Create" button.

5. **Push Images:**
   - You can now push images to this repository using Podman commands from your terminal. For example:

 
   ```bash
   podman login docker.io
   podman tag local-image-name username/repository-name:tag
   podman push username/repository-name:tag
   ```
   At least for demostration purposes this is my personal registry with this image
 
   ```bash
   podman login docker.io
   podman build -t cguillenmendez/sre-abc-training-python-app:latest .
   podman push cguillenmendez/sre-abc-training-python-app:latest
   ```

   5. **Run Remote Images:**
   ```bash
   podman run --rm -it -p 5000:5000 cguillenmendez/sre-abc-training-python-app:latest
   ```

---
# Final Objective
At the end of this document, you should accomplished this:
> [!IMPORTANT]
> Once the container is running, open your web browser and go to `http://127.0.0.1:5000/`. You should see the text "Hello, World!" displayed.
> ![app](app.png)

