# React Application Building, Image Creation, and Uploading to Docker Hub

This repository demonstrates a complete CI/CD pipeline to:
- Build a React application
- Create a Docker image for the React app
- Push the Docker image to Docker Hub

The process is automated using GitHub Actions, ensuring a smooth and efficient workflow for building, testing, and deploying the React app.

---

## 📝 Overview

### Objective

This project aims to showcase:
- Building a React app
- Creating and pushing a Docker image for the React app to Docker Hub
- Automating the CI/CD pipeline using GitHub Actions

### Technologies Used

- **React**: JavaScript library for building the frontend.
- **Docker**: Containerization tool used to build and run the app.
- **GitHub Actions**: Automates the CI/CD pipeline for building, testing, and deploying the app.
- **Node.js (v20)**: JavaScript runtime for running and building the React app.
- **Docker Hub**: Platform for storing and sharing Docker images.

---

## 🛠️ Step-by-Step Guide

### 1. **Setting Up the GitHub Repository**

- **Create a GitHub repository** to host the project code.
- Set up a **staging branch** called `sandbox`.
- Add a **branch protection rule** for `sandbox` to enforce code review and testing before merging.
- Add a **collaborator** (even if it's your other account) to simulate a real-world organizational setup.

### 2. **React App Development**

- **Create a React Application**: Use `create-react-app` or set up the React app manually.
- **Commit and Push**: Commit your changes to a feature branch and push them to GitHub.
- **Pull Request**: Create a pull request to merge the feature branch into the `sandbox` branch.

### 3. **Dockerfile Creation with Multi-Stage Build**

This Dockerfile uses a multi-stage build to optimize the container size. The first stage builds the React app, while the second stage serves it using Apache HTTP server.

#### Dockerfile

```Dockerfile
# Stage 1: Build the React app using Node.js
FROM node:20-alpine AS build

WORKDIR /frontend

# Copy the package.json and package-lock.json first (for caching purposes)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the React app
RUN npm run build

# Stage 2: Serve the React app using Apache HTTP server
FROM httpd:alpine

# Copy the build artifacts from the previous stage
COPY --from=build /frontend/dist /usr/local/apache2/htdocs/

# Expose port 80 for HTTP
EXPOSE 80

# Run Apache in the foreground
CMD ["httpd-foreground"]
```
