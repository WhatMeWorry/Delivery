
================== Git(ting) an existing GitHub Repo ==============================


Go to WhatMeWorry/Delivery or https://github.com/WhatMeWorry/Delivery

click on green "Clone or download" button and then "copy to clipboard"

At desktop, open a git command line or Visual Studio Code.  (This document assume use of VSC)

View > Integrated Terminal  (Ctrl+`)

$ pwd
/c/Users/kheaser/SomeRepo

Now cd to where you want the gitted repo to reside:

kheaser@IT-ASST-SB MINGW64 /c/Users/kheaser/Delivery (master)
$ cd ..

kheaser@IT-ASST-SB MINGW64 /c/Users/kheaser
$ pwd
/c/Users/kheaser       // Repo will now be gitted here!

type in "git clone" and right click you mouse to paste the clipboard content
type return.

$git clone https://github.com/WhatMeWorry/Delivery.git

Cloning into 'Delivery'...
remote: Counting objects: 1234, done.
remote: Total 1234 (delta 0), reused 0 (delta 0), pack-reused 1234
Receiving objects: 100% (1234/1234), 46.56 MiB | 9.21 MiB/s, done.
Resolving deltas: 100% (886/886), done.

It turns out that by default, git copied the Delivery Repo to
C:\Users\kheaser\Delivery

Within VSC, File > Open Folder
and navigate to C:\Users\kheaser\Delivery and [Select Folder]


Now from Windows Explorer, Navigate to C:\Users\kheaser\Delivery\apps
and Shift + Rght Click and   Open Powershell/Command window here.
