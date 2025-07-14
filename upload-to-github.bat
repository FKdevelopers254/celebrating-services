@echo off
echo ========================================
echo    Upload to GitHub Script
echo ========================================

REM Set your repo URL here
set REPO_URL=https://github.com/FKdevelopers254/celebrating-services.git

echo.
echo Initializing git repository if needed...
if not exist ".git" (
    git init
)

echo.
echo Adding all files to git...
git add .

echo.
echo Committing changes...
git commit -m "Upload project to GitHub"

echo.
echo Setting remote origin if needed...
git remote -v | findstr "origin" >nul
if errorlevel 1 (
    git remote add origin %REPO_URL%
)

echo.
echo Setting branch to main...
git branch -M main


echo.
echo Pushing to GitHub...
git push -u origin main

echo.
echo ========================================
echo    Upload completed!
echo ========================================
pause 