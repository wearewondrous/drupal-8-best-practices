#!/bin/bash

if [[ ! ${1:0:1} == "@" ]]
then
    echo "Please provide the drush alias as first parameter. It needs to start with @ character!"
    exit 0
fi

echo
echo "Will do database updates, entity updates and locale updates for $1."

echo
echo "Database updates..."
drush $1 -y updb

echo
echo "Entity updates..."
drush $1 -y entup

echo
echo "Locale updates..."
drush $1 locale-update

echo
echo "Shall I run the crone job?"
read -p "Continue (Y/n)?" response

if [[ $response =~ [nN](oO)* ]]
then
    echo "No. We are done."
    exit 0
fi

echo
echo "Cron run..."
drush $1 -v cron
