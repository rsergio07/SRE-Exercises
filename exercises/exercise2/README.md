# Table of Contents
- [Python Application with Podman](#python-application-with-podman)
  - [What is Docker?](#what-is-docker)
  - [Prerequisites](#prerequisites)
  - [Project Structure](#project-structure)
  - [Building the Container Image](#building-the-container-image)
  - [Running the Container](#running-the-container)
  - [Conclusion](#conclusion)
- [Final Objective](#final-objective)

# Python Application with Podman
This README provides instructions on how to build and run a Python application using Podman. Podman is an open-source, container management tool that allows you to create and manage containers without requiring a daemon like Docker. This makes Podman a great option for running containers in environments where you prefer not to use Docker or need rootless container management.

## What is Docker?

Docker is a popular platform used for developing, shipping, and running applications inside containers. Containers allow developers to package an application with all of its dependencies and run it in a consistent environment across different systems. Docker simplifies the process of managing containerized applications by providing a consistent interface to interact with containers.

## Prerequisites

- [Podman](https://podman.io/getting-started/installation) installed on your system.
- A basic understanding of Python and containerization concepts.

## Project Structure

## Dockerfile

[Here](./Dockerfile) is a sample `Dockerfile` for the Python application:


Here's the README.md file formatted in Markdown:

markdown
Copiar código
# Python Application with Podman

This README provides instructions on how to build and run a Python application using Podman. Podman is an open-source, container management tool that allows you to create and manage containers without requiring a daemon like Docker. This makes Podman a great option for running containers in environments where you prefer not to use Docker or need rootless container management.

## What is Docker?

Docker is a popular platform used for developing, shipping, and running applications inside containers. Containers allow developers to package an application with all of its dependencies and run it in a consistent environment across different systems. Docker simplifies the process of managing containerized applications by providing a consistent interface to interact with containers.

## Prerequisites

- [Podman](https://podman.io/getting-started/installation) installed on your system.
- A basic understanding of Python and containerization concepts.

## Project Structure

classes/class2/ ├── Dockerfile ├── app.py └── requirements.txt

- `Dockerfile`: Contains instructions to build the container image.
- `app.py`: The Python application script.

## Dockerfile

Here is a sample `Dockerfile` for the Python application:

```Dockerfile
# Use the official Python image from the Docker Hub
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

# Specify the command to run the application
CMD ["python", "app.py"]
Building the Container Image
To build the container image using Podman, navigate to the project directory where the Dockerfile is located and run:

```bash
podman build -t my-python-app .
```
This command tells Podman to build an image with the tag my-python-app using the Dockerfile in the current directory.

Running the Container
To run the container using Podman, use the following command:

```bash
podman run --rm -it -p 5000:5000 my-python-app
```
This command runs the my-python-app container in interactive mode. The --rm flag ensures that the container is removed after it stops.

Conclusion
You now have a basic setup for building and running a Python application using Podman. Podman provides a similar experience to Docker but with additional benefits, such as rootless container management.

---
# Final Objective
At the end of this document, you should accomplished this:
> [!IMPORTANT]
> Once the container is running, open your web browser and go to `http://127.0.0.1:5000/`. You should see the text "Hello, World!" displayed.
> ![app](app.png)
