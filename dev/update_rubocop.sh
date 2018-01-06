#!/bin/bash
# Update Rubocop

mkdir .cookstyle

for style in cookstyle cookstyle_base default disabled disable_all enabled upstream
do
  curl -sL https://raw.githubusercontent.com/chef/cookstyle/master/config/${style}.yml -o .cookstyle/${style}.yml
done
