

Assuming we have an open git repoistory created and opened in Visual Studio Code.

Any files which are modified or created will increment a blue cirle counter next to the fork icon.

Clicking on the Fork Icon will open a pane with file entries. Modified files will have a M next to
it whereas new files will have a U.  M stands for "Modified" whereas U is for "Untracked"

Double clicking on the files will pull up two versions of the file. A before file and an after file
will all the changes highlighted.  Green highlights mean lines where added while red lines means the
line was removed.

After you are satisfied with the changes you can move then from "Working" to "Staged Index" by
clicking on the three dots  . . .  which appear on the left pane header and then select  "Stage all changes"
The tree node will change name from CHANGES to STAGED CHANGES

After all the staged files are good, they can then by "committed" by 
clicking on the three dots . . .  which appear on the left pane header and the select "Commit All"
a comment message dialogue will open that prompts the user for a description of the commit.
This will transition the files from "Staged Index" to the local repository.
The tree node will return to from STAGED CHANGES to and empty CHANGES.  It is empty because all the files
are now residing in the local repo in a committed state.

If your local repository is good and you want to move the changes into the remote (github) repo,
click on the three dots . . .  which appear on the left pane header and then select "Push"

After this, you should be able to see the new changes in you github repo from your browser.


To Pull the Remote Repository to you local repo on your desktop,
click on the Repo name in the left pane and then click on the Synchronize changes icon in the bottom left
of the window.  It is a two white circular arrows on a field of blue.




