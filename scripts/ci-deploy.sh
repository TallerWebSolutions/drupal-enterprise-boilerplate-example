#!/bin/bash

set -e

ACQUIA_DIR=/home/runner/drupal-enterprise-teste

ssh-keyscan svn-6185.devcloud.hosting.acquia.com >> /home/runner/.ssh/known_hosts

git clone --branch master boilerplate@svn-6185.devcloud.hosting.acquia.com:boilerplate.git $ACQUIA_DIR

# Checkout to the branch, if doesn't exit create and checkout to it.
(
  cd $ACQUIA_DIR

  if [[ `git branch -a | grep $BRANCH_NAME` ]]; then
    git checkout ${BRANCH_NAME}
  else
    git checkout -b ${BRANCH_NAME}
  fi
)

# Remove git submodules.
find $SEMAPHORE_PROJECT_DIR -type d -name ".git" | xargs sudo rm -rf

# Remove old directories.
sudo rm -Rf $ACQUIA_DIR/docroot
sudo rm -Rf $ACQUIA_DIR/config
sudo rm -Rf $ACQUIA_DIR/hooks
sudo rm -Rf $ACQUIA_DIR/vendor
sudo rm -Rf $ACQUIA_DIR/bin
sudo rm -Rf $ACQUIA_DIR/composer.json
sudo rm -Rf $ACQUIA_DIR/composer.lock
sudo rm -Rf $ACQUIA_DIR/README.md

# Copy new directories.
cp -r ./web $ACQUIA_DIR/docroot
cp -r ./config $ACQUIA_DIR/config
cp -r ./scripts/acquia_hooks $ACQUIA_DIR/hooks
cp -r ./vendor $ACQUIA_DIR/vendor
cp -r ./bin $ACQUIA_DIR/bin
cp ./composer.json $ACQUIA_DIR/composer.json
cp ./composer.lock $ACQUIA_DIR/composer.lock
cp ./README.md $ACQUIA_DIR/README.md

# Make Acquia hooks executable.
sudo chmod -R +x $ACQUIA_DIR/hooks

# Configure GIT.
git config --global core.autocrlf true
git config --global user.email "email@email.com"
git config --global user.name "username"

(
  cd $ACQUIA_DIR

  # Add all the things.
  git add --all .

  # Commit only if there's something new.
  if [ ! "$(git status | grep 'nothing to commit')" ]; then
    echo 'Has things to commit.'

    git commit -m "Deploy by Taller's SemaphoreCI: $REVISION."
    git push origin $BRANCH_NAME
  else
    echo 'Nothing to commit.'
  fi
)
