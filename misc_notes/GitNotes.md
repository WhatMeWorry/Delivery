

Requirements:

Two main goals are to have a zero cost of entry and to be universally available. The following programs are free and generally open source as well; Additionally, all are available for the big three platforms: Linx, MacOS, and Windows. 

Git needs to be installed on you machine.
If not, go to https://git-scm.com/download and download and install it.

A D Language compiler needs to be installed. We will be using a LLVM-based D compiler called LDC whhich is a portable, stand-alone, binary, compiler.  
If not, go to https://github.com/ldc-developers/ldc/releases and download and install it.

Visual Studio Code needs to be installed.
If not, go to https://code.visualstudio.com/download and download and install it.

DUB, the D package registry, needs to be installed.
If not, go to https://code.dlang.org/download and download and install it.


================== Git(ting) an existing GitHub Repo ==============================


Go to WhatMeWorry/Delivery or https://github.com/WhatMeWorry/Delivery

Then click on the green **[Clone or download]** button and select the "copy to clipboard" icon

Now open the Visual Studio Code application.

At the drop down menus of VSC select:
**View > Integrated Terminal**  (Ctrl+`)

Just to get ones bearing and to verify that terminal works, type in the command **pwd**

```
kheaser@IT-ASST-SB MINGW64 ~
$ pwd
/c/Users/kheaser
```

We re going to put all of our local copies of Github repositories under user kheaser which we are conviently already at. You are not required to use this convention, but place them wherever you want.  


In the Visual Studio Code terminal, type **git clone** and right click your mouse to paste the clipboard content from above.
Hit Enter and you shoul see something like the following:

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

Git has now copied the Delivery Repository from GitHub website to your local machine at
C:\Users\kheaser\Delivery

Or if customization is desired, you can clone to an arbitrarily named path/folder with git clone <repo> <directory>

'''
$git clone https://github.com/WhatMeWorry/Delivery.git  C:\Users\kheaser\path\to\my\repos\LocalDelivery
Cloning into '.\path\to\MyDelivery'...
remote: Enumerating objects: 27, done.
```
 

Now from within VSC, select **File > Open Folder**
and navigate to **C:\Users\kheaser\\** and highlight the folder **Delivery**. Click on **[Select Folder]**

You should now see all the files associated with the Delivery repo within VSC.

Let's leave VSC for now and open Windows Explorer. Navigate to **C:\Users\kheaser\Delivery\\** (or wherever you placed it)
and **Shift + Rght Click** on the **apps** folder and select **open powershell/command window here**


Running The D/OpenGL examples
----------------------------------

Open a Powershell/Command Window or Terminal and navigate to
C:\Users\\*user\*\Delivery\apps>























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



======================
Delete the .git directory in the root-directory of your repository if you only want to delete the git-related information (branches, versions).

If you want to delete everything (git-data, code, etc), just delete the whole directory.

$ rm -rf .git
Or to delete .gitignore and .gitmodules if any (via @aragaer):

$ rm -rf .git*
Then from the same ex-repository folder, to see if hidden folder .git is still there:

$ ls -lah

kheaser@IT-ASST MINGW64 ~/Delivery
$ ls -al
total 78
drwxr-xr-x 1 kheaser 1049089     0 Mar  7 16:54  ./
drwxr-xr-x 1 kheaser 1049089     0 Mar  7 09:11  ../
-rw-r--r-- 1 kheaser 1049089   720 Feb 11 16:45  .gitignore
drwxr-xr-x 1 kheaser 1049089     0 Feb 11 16:45  .vscode/
drwxr-xr-x 1 kheaser 1049089     0 Feb 11 16:45  apps/
-rw-r--r-- 1 kheaser 1049089    22 Feb 11 16:45  index.html
drwxr-xr-x 1 kheaser 1049089     0 Feb 11 16:45  linux/
drwxr-xr-x 1 kheaser 1049089     0 Feb 11 16:45  macos/
drwxr-xr-x 1 kheaser 1049089     0 Mar  4 15:41  misc_notes/
-rw-r--r-- 1 kheaser 1049089    81 Feb 11 16:45  README.md
-rw-r--r-- 1 kheaser 1049089 28495 Feb 11 16:45 'Untitled picture.png'
drwxr-xr-x 1 kheaser 1049089     0 Mar  4 16:19  windows/

kheaser@IT-ASST MINGW64 ~/Delivery
$ rm -rf .git*

kheaser@IT-ASST MINGW64 ~/Delivery
$ l s-alh
bash: l: command not found

kheaser@IT-ASST MINGW64 ~/Delivery
$ ls -alh
total 74K
drwxr-xr-x 1 kheaser 1049089   0 Mar  7 16:55  ./
drwxr-xr-x 1 kheaser 1049089   0 Mar  7 09:11  ../
drwxr-xr-x 1 kheaser 1049089   0 Feb 11 16:45  .vscode/
drwxr-xr-x 1 kheaser 1049089   0 Feb 11 16:45  apps/
-rw-r--r-- 1 kheaser 1049089  22 Feb 11 16:45  index.html
drwxr-xr-x 1 kheaser 1049089   0 Feb 11 16:45  linux/
drwxr-xr-x 1 kheaser 1049089   0 Feb 11 16:45  macos/
drwxr-xr-x 1 kheaser 1049089   0 Mar  4 15:41  misc_notes/
-rw-r--r-- 1 kheaser 1049089  81 Feb 11 16:45  README.md
-rw-r--r-- 1 kheaser 1049089 28K Feb 11 16:45 'Untitled picture.png'
drwxr-xr-x 1 kheaser 1049089   0 Mar  4 16:19  windows/

kheaser@IT-ASST MINGW64 ~/Delivery
$ rm -rf .
rm: refusing to remove '.' or '..' directory: skipping '.'

kheaser@IT-ASST MINGW64 ~/Delivery
$ ls
 apps/   index.html   linux/   macos/   misc_notes/   README.md  'Untitled picture.png'   windows/

kheaser@IT-ASST MINGW64 ~/Delivery
$ cd ..

kheaser@IT-ASST MINGW64 ~
$ rm -rf Delivery
rm: cannot remove 'Delivery': Device or resource busy

kheaser@IT-ASST MINGW64 ~
$ cd Delivery

kheaser@IT-ASST MINGW64 ~/Delivery
$ ls -alh
total 12K
drwxr-xr-x 1 kheaser 1049089 0 Mar  7 16:57 ./
drwxr-xr-x 1 kheaser 1049089 0 Mar  7 09:11 ../

kheaser@IT-ASST MINGW64 ~/Delivery

=====================================================================================================================



