#!/bin/bash

function save-project-to-repo() {
    git remote rm origin
    git remote add origin $1
    git push
}

declare readonly gitRemotes=(
    git@bitbucket.org:pH_7/food-scanner-swift-app.git
    git@gitlab.com:pH-7/food-scanner-swift-app.git
    git@github.com:pH-7/Food-Scanner-Swift-App.git
)
for remote in "${gitRemotes[@]}"
do
    save-project-to-repo $remote
done
