@echo off
call flutter build web --base-href "/Task-app-new/" --release
git add .
git commit -m "Update Chore Quest"
git push origin main