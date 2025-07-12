#!/bin/bash

# Set your repo URL here
REPO_URL="https://github.com/FKdevelopers254/celebrating-services.git"

# Initialize git if not already
echo "Initializing git repository if needed..."
if [ ! -d ".git" ]; then
  git init
fi

# Add all files
echo "Adding all files to git..."
git add .

# Commit (change the message if you want)
echo "Committing changes..."
git commit -m "Upload project to GitHub"

# Add remote if not already set
echo "Setting remote origin if needed..."
if ! git remote | grep -q origin; then
  git remote add origin "$REPO_URL"
fi

# Set main branch (if not already)
echo "Setting branch to main..."
git branch -M main

# Push to GitHub
echo "Pushing to GitHub..."
git push -u origin main 