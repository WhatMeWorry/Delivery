

Requirements: 

Git needs to be installed on you machine.
If not, go to https://git-scm.com/download

Visual Studio Code needs to be installed.
If not, go to https://code.visualstudio.com/download


================== Git(ting) an existing GitHub Repo ==============================


Go to WhatMeWorry/Delivery or https://github.com/WhatMeWorry/Delivery

click on green "Clone or download" button and then "copy to clipboard"

At desktop, open the Visual Studio Code application.

At the drop down menus of VSC select:
View > Integrated Terminal  (Ctrl+`)

```
kheaser@IT-ASST-SB MINGW64 ~
$ pwd
/c/Users/kheaser
```

We want to put all of our repos under user kheaser so we are conviently at the 
right location. You may certainly create a new directory or move to a different path.


type in "git clone" and right click your mouse to paste the clipboard content from above.
The type return.

```
$git clone https://github.com/WhatMeWorry/Delivery.git

Cloning into 'Delivery'...
remote: Enumerating objects: 4, done.
remote: Counting objects: 100% (4/4), done.
remote: Compressing objects: 100% (4/4), done.
remote: Total 2216 (delta 0), reused 0 (delta 0), pack-reused 2212
Receiving objects: 100% (2216/2216), 75.48 MiB | 6.74 MiB/s, done.
Resolving deltas: 100% (1587/1587), done.
Checking out files: 100% (445/445), done.
```

Git has now copied the Delivery Repo from GitHub to the local machine at
C:\Users\kheaser\Delivery

Now from within VSC, select File > Open Folder
and navigate to C:\Users\kheaser\ and highlight the folder Delivery. And [Select Folder]


Now from Windows Explorer, Navigate to C:\Users\kheaser\Delivery\apps
and Shift + Rght Click and   Open Powershell/Command window here.


***
Finding out the name of the original repository you cloned from in Git
```
$ git config --get remote.origin.url
https://github.com/WhatMeWorry/Delivery.git
```


***
Once in Visual Studio Code, performed a pull from the GUI and nothing happened.
Had to go to TERMINAL and type:
```
~Delivery$ git pull
Already up-to-date
```

========================= git init versus clone =============================

I'm doing a git clone on a project following the instructions. But, do I need to do an init in the directory beforehand?


git clone is basically a combination of:

git init (create the local repository)
git remote add (add the URL to that repository)
git fetch (fetch all branches from that URL to your local repository)
git checkout (create all the files of the main branch in your working tree)
Therefore, no, you don't have to do a git init, because it is already done by git clone.

git init will create a new repository. When running git clone, what actually happens in the background is a git init, followed by git remote add origin ${URL} and then a git pull.

Typically, you only use git init if you already have code and you want to put it in a new Git repository.

===================== How to delete a Git Repository Completely =============

I created a git repository with git init. I'd like to delete it entirely and init a new one?

Git keeps all of its files in the .git directory. Just remove that one and init again.


If you can't find it, it's because it is hidden.

In Windows 7, you need to go to your folder, click on [Organize] on the top left, then click on [Folder and search options], then click on the [View] tab and click on the [Show hidden files, folders and drives] radio button.
On a Mac OS:
Open a Terminal (via Spotlight: press CMD + SPACE, [type] terminal and press Enter) and do this command: [defaults write com.apple.finder AppleShowAllFiles 1 && killall Finder].
Or you could also type cd (the space is important), drag and drop your git repo folder from Finder to the terminal window, press return, then type rm -fr .git, then return again.
On Ubuntu, in a file manager (GUI) use shortcut Ctrl + H
if in a terminal ls -al to see hidden files.


If you really want to remove all of the repository, leaving only the working directory then it should be as simple as this.

rm -rf .git
The usual provisos about rm -rf apply. Make sure you have an up to date backup and are absolutely sure that you're in the right place before running the command. etc., etc.

Note: for Visual Stuio Code, I had to delete the directory above the .git file.  (so the rm -rf .git is for a git command line environment)



======================== How to make a directory in git stay empty

Another way to make a directory stay empty (in the repository) is to create a .gitignore file inside that directory that contains four lines:

# Ignore everything in this directory
*
# Except this file
!.gitignore



======================== finding all git repositories that exist on a machine

Is there a way in which I can see all the git repositories that exist on my machine? Any command for that?

If you are in Linux or MacOS
find / -name ".git"
otherwise there is no way, they are standard directories, just use your OS file/folder find program to find .git named folders.

On Windows you could do something similar. Just search for directories named .git - which is what git uses to store its meta information.


