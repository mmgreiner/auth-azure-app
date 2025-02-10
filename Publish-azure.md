You can deploy your **Ruby on Rails** application to **Azure using Docker and Kamal**. Here's a step-by-step guide to achieving this.

---

# **🚀 Overview**
1. **Containerize the Rails App** (Docker + Kamal)
2. **Set Up Azure Resources** (Azure VM + Container Registry)
3. **Deploy Using Kamal**  
4. **Automate with GitHub Actions (Optional)**

---

## **1️⃣ Install Kamal**
First, install **Kamal** (formerly **MRSK**), a zero-downtime deployment tool for containers.

```sh
gem install kamal
```

Then, inside your Rails project, initialize Kamal:
```sh
kamal init
```
This generates a `config/deploy.yml` file.

---

## **2️⃣ Create a `Dockerfile` for Rails**
Create a `Dockerfile` in your Rails project root:

```dockerfile
# Use official Ruby image
FROM ruby:3.2.2

# Set the working directory
WORKDIR /app

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs npm postgresql-client

# Install bundler
COPY Gemfile* ./
RUN gem install bundler && bundle install

# Copy application files
COPY . .

# Precompile assets
RUN bundle exec rake assets:precompile

# Set up the command to run the app
CMD ["rails", "server", "-b", "0.0.0.0"]
```

---

## **3️⃣ Create a `.dockerignore` File**
Create `.dockerignore` to prevent unnecessary files from being copied:

```txt
.git
log/*
tmp/*
node_modules
vendor/bundle
```

---

## **4️⃣ Build & Test Locally**
Test the Docker image before deploying:

```sh
docker build -t my-rails-app .
docker run -p 3000:3000 my-rails-app
```
Visit `http://localhost:3000` to ensure it works.

---

## **5️⃣ Set Up Azure Resources**
### **🔹 Create an Azure Virtual Machine (VM)**
If you don’t have a VM, create one:

```sh
az login
az group create --name myResourceGroup --location eastus
az vm create --resource-group myResourceGroup --name myRailsVM \
  --image Ubuntu2204 --admin-username azureuser --generate-ssh-keys
```

Get the **public IP** of your VM:
```sh
az vm show --show-details --resource-group myResourceGroup --name myRailsVM --query publicIps -o tsv
```

### **🔹 Install Docker on the VM**
SSH into the VM and install Docker:

```sh
ssh azureuser@YOUR_VM_IP

# Install Docker
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Add user to the Docker group
sudo usermod -aG docker $USER
exit
```
Reconnect to your VM to apply group changes.

---

## **6️⃣ Configure Kamal for Azure Deployment**
Edit `config/deploy.yml`:

```yaml
service: my-rails-app

image:
  name: myregistry.azurecr.io/my-rails-app

servers:
  - YOUR_VM_IP

builder:
  multiarch: false

env:
  secret:
    - RAILS_MASTER_KEY
```

---

## **7️⃣ Push Docker Image to Azure Container Registry (ACR)**
### **🔹 Create an ACR Registry**
```sh
az acr create --resource-group myResourceGroup --name myregistry --sku Basic
az acr login --name myregistry
```

### **🔹 Tag & Push Image**
```sh
docker tag my-rails-app myregistry.azurecr.io/my-rails-app:latest
docker push myregistry.azurecr.io/my-rails-app:latest
```

---

## **8️⃣ Deploy Rails App Using Kamal**
Deploy the application:

```sh
kamal deploy
```

Check if the container is running:
```sh
ssh azureuser@YOUR_VM_IP
docker ps
```

---

## **9️⃣ Automate Deployment with GitHub Actions (Optional)**
Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Azure

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Log in to Azure
        run: az login --service-principal -u ${{ secrets.AZURE_CLIENT_ID }} -p ${{ secrets.AZURE_CLIENT_SECRET }} --tenant ${{ secrets.AZURE_TENANT_ID }}

      - name: Log in to Azure Container Registry
        run: az acr login --name myregistry

      - name: Build and push Docker image
        run: |
          docker build -t myregistry.azurecr.io/my-rails-app:latest .
          docker push myregistry.azurecr.io/my-rails-app:latest

      - name: Deploy with Kamal
        run: kamal deploy
```

---

## **🎯 Summary**
✅ **Containerized Rails app using Docker**  
✅ **Used Kamal for deployment**  
✅ **Set up Azure VM & Container Registry**  
✅ **Pushed Docker image to ACR & deployed it**  
✅ **Automated with GitHub Actions** (optional)  

🚀 **Now your Rails app is running on Azure with Docker & Kamal!** 🚀  
Let me know if you need help! 😊