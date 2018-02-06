#!/bin/bash

# Git user credentials are not checked in
echo "Enter full name for Git global config:"
read git_user_name
echo "Enter email address for Git global config:"
read git_user_email
printf \
"[user]\n\
\tname = %s\n\
\temail = %s\n\
#\tsigningkey = \n\
#[commit]\n\
#\tgpgSign = true\n" \
"$git_user_name" "$git_user_email" >> ~/.gitconfig_untracked

# Build list of files managed by this dotfiles repo
cd ./symlinked_files/
file_list=(*)
echo "${#file_list[@]} files to symlink found"

# Create backup directory for any existing versions of dotfiles
backup_dir=~/old_dotfiles
backup_dir_created=false
backup_count=0
echo "Creating backup directory $backup_dir"
mkdir $backup_dir
if [ $? -eq 0 ]; then
  backup_dir_created=true
fi

# Install the managed files
for file in ${file_list[@]}; do

  # Check for any exitisting versions of these files
  echo -e "\nChecking for existing version of .$file"
  find -f ~/.$file > /dev/null 2>&1
  if [ $? -eq 0 ]; then # Check the exit code of find
    echo "  Found existing vesion... moving to $backup_dir"
    mv ~/.$file $backup_dir
    backup_count=$((backup_count+1))
  else
    echo "  No existing version found"
  fi

  # Create symlink to the managed version
  echo "Creating symlink for .$file"
  ln -s `pwd`/$file ~/.$file

done

# Remove backup directory if there was nothing to backup
if [ $backup_count -eq 0 ] && [ $backup_dir_created == true ]; then
  echo -e "\nRemoving unused backup directory $backup_dir"
  rm -r $backup_dir
fi
