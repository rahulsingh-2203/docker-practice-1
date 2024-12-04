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
#### YAML script
```
name: React application building, image creation, and uploading to Docker Hub

on:
  push:
    branches:
      - sandbox

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout GitHub repository
        uses: actions/checkout@v4

      - name: Set up node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
        
      - name: Install dependencies
        run: npm install
    
      # Optionally, run tests (currently commented out)
      #- name: Run tests
        #run: npm test
    
      - name: Build React app
        run: npm run build
    
      - name: Upload build artifact
        uses: actions/upload-artifact@v4
        with:
          name: react-build
          path: ./dist

  docker_deploy:
    runs-on: ubuntu-latest
    needs: build-and-test

    steps:
      - name: Checkout GitHub repository
        uses: actions/checkout@v4

      - name: Download build artifact
        uses: actions/download-artifact@v4
        with:
          name: react-build
          path: ./dist

      - name: Set up Docker
        uses: docker/setup-buildx-action@v3
    
      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: List directory contents
        run: |
          ls -alh

      - name: Build Docker image
        run: |
          IMAGE_TAG="${GITHUB_RUN_ID}-${GITHUB_SHA}"
          IMAGE_NAME="${{ secrets.DOCKER_USERNAME }}/frontend"
          echo "Building Docker image with IMAGE_TAG: ${IMAGE_TAG}"
          echo "IMAGE_NAME: ${IMAGE_NAME}"
          docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
          docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
        
      - name: Push Docker image to Docker Hub
        run: |
          IMAGE_TAG="${GITHUB_RUN_ID}-${GITHUB_SHA}"
          IMAGE_NAME="${{ secrets.DOCKER_USERNAME }}/frontend"
          echo "Pushing Docker image ${IMAGE_NAME}:${IMAGE_TAG}"
          echo "Pushing Docker image ${IMAGE_NAME}:latest"
          docker push ${IMAGE_NAME}:${IMAGE_TAG}
          docker push ${IMAGE_NAME}:latest

      - name: Clean up Docker images
        if: success()
        run: |
          IMAGE_TAG="${GITHUB_RUN_ID}-${GITHUB_SHA}"
          IMAGE_NAME="${{ secrets.DOCKER_USERNAME }}/frontend"
          docker rmi ${IMAGE_NAME}:${IMAGE_TAG}
          docker rmi ${IMAGE_NAME}:latest
```
---
## 🌍 Project Deployment and Access
After the CI/CD pipeline runs successfully, two Docker image tags will be pushed to Docker Hub:

- latest: The most recent stable version.
- `<GITHUB_RUN_ID>-<GITHUB_SHA>`: A versioned tag based on the GitHub run ID and commit SHA.
### How to Access the Docker Image:
- Log in to Docker Hub.

- Pull the image with the following command:

```bash
docker pull <your-docker-username>/frontend:<tag>
```
Run the container:
```bash
docker run -p 80:80 <your-docker-username>/frontend:<tag>
Your React app will be accessible on http://localhost:80.
```
