# Restructuring, renaming, and keeping our change history in git

[[_TOC_]]

Changing code structure and renaming files is a part of development process. It happened in the past, it happens on daily basis, and it will keep happening in the future.

Over the past two months, we've had two major project restructurings. In the first go, Mikkel Mansa restructured objects into logical folders, and in the second go, Alen restructured everything into application and test. Both of these restructurings were absolutely necessary!

However, not both of them had the same effects. Mikkel's move operation has lost all previous file change history. Alen's move operation has retained all previous file change history.

The point of this post is not to blame or praise. Not at all! It's purely by sheer luck (or bad luck, for that matter) that Alen's restructuring retained history while Mikkel's lost it. And luck is not a good thing to rely on when talking code change history.

The point of this post is to help us always retain our file change history whenever we move or rename files around.

And for the purpose of this post (or otherwise), a move operation and a rename operation are equivalent. Moving file from one path to another path simply renames the path, and that's all there is to it.

## What is a change, from git's perspective, anyway?

Git does not know of a concept of "change". It only knows of "add" and "delete". When you change a line of code, git doesn't see it as a change in that line. Rather, it sees it as a deletion of the old line, and addition of a new line. That's how git sees it, and that's how it's logged in git. Representing that operation as an actual "change" instead of "add" + "delete" pair is what additional git tools do. But the fact that you see a change as "change" on screen does not alter the fact that git sees and treats this as "add" + "delete".

This is the at the bottom of everything.

And this applies not only to lines of code - it applies to entire files. When you rename a file, git sees it as "delete" of the file with the original name, and "add" of a new file with a new name.

Obviously, when changing lines of code, but retaining the file in place, git is able to trace all changes in code all the way back to when the file was first created. That is: when the file was first added to the repo. The fact that git does this for us allows us to drop all the unnecessary `//+NPR [321902]` kinds of comments from our code.

Now, when you rename (or move) a file, knowing that git will see it as deleting the original file and adding a new file, a legitimate question is: what happens to the file change history?

Yeah. You guessed it right. You don't have it anymore.

In short: when you change something in file `Foo.al` you'll be able to see it in the history of `Foo.al`. But when you rename `Foo.al` to `Bar.al`, observing history of `Bar.al` will show you only the fact that `Bar.al` has just been added to the repo.

Don't panic just yet!

## The history is not truly lost!

First of all, the history is not lost. Even though you don't see `Foo.al` anymore, and only see `Bar.al` from now on, git knows that there was `Foo.al` and can track its history through those commits that included it. It's just that history of `Foo.al` is technically not the history of `Bar.al`. It's only that by looking at history of `Bar.al` you won't also see the history of `Foo.al`.

Now, git is far too smart to allow this kind of blunder. Git knows that you care about file history, so when you rename a file, and then stage it, git will try to figure out if any of delete+add pairs were actual rename operations. To do so, it will compare all the deleted files to all the added files, and if it figures out that any of them are renames, it will mark the operation as a rename. Even though, technically, `Foo.al` was deleted, and `Bar.al` was added, this allows git to follow the renames (and in turn, it allows tools like Azure DevOps or GitLens to follow the renames).

But this rename detection is not 100% reliable, though. Sometimes git will correctly detect a move, and sometimes it will fail to do so. Why?

## Heuristics at work

When trying to figure out whether there are any renames, git does some heuristics. There are two lists of files: "deleted" and "added".

First, for each file in "added" list, git will check if there is the file with the same hash (git keeps track of all file hashes!). If there is a file in both lists with the same hash, git immediately sees this as a match, and will treat this as a rename. So, even though git sees `Foo.al` as deleted and `Bar.al` as added, both of them have the same hash, git shows this as a rename and is able to follow through the history. This is also blazing fast, because it only needs do compare two very short strings, and even if you have thousands of renames (like, you rename an entire subtree, say from `.\src` to `.\application\src` with 3.600 files in there) git will match all deletions to all additions in a matter of milliseconds.

Second, after this first step of heuristics are done and actual rename pairs are detected, if there are still files left in both "deleted" and "added" lists git will look into file contents to figure out if some of those file contents were changed. To do so, git will run `git diff` internally. Imagine that not only you renamed `Foo.al` into `Bar.al`, but you also changed a few lines of code in that file. Git can still detect this as a move as long as `git diff` sees that more than 50% of the file content is the same. If there is more than 50% match, git will determine that `Foo.al` was renamed to `Bar.al` even though a few lines of code have changed inside. However, this operation is far, far slower than hash comparison, especially if files are large.

And here's a catch! When you both do a bunch of renames *and* a bunch of code changes, hashes will change for a lot of those renamed files, so git will have to run `git diff` for all files where there is no has match. If there is only one added file, and one deleted file, git only needs to run `git diff` once. If there are five hundred files, there is a theoretical maximum of 250.000 `git diff` operations to run (the actual number may be smaller, because each successfully detected rename reduces the amount of remaining renames to be matched, but still - it's a metric crapload of `git diff`s to run!)

When you rename an entire subtree, like moving `.\src` into `.\application\src`, while changing content of those files, and your subtree contains 3.600 files, that's nearly 13 million `git diff`s that git would have to run to figure out if there were any actual renames there. Git won't do it. There is a limit at which git will stop trying to figure that out, and will start treating the changes as simple deletions and additions. I tried to figure out what's the limit here, and I couldn't find any official info on that. If you suspect it has something to do with the ugly VS Code warning that says *"The git repository at XXXX has too many active changes, only a subset of Git features will be enabled."* you are probably on a wrong train of thought. This is VS Code complaining, not git, so the actual cutoff point may be different.

Before I cut to the morale of the story, I want to reiterate a point: git does not, at any point, store the fact that a file (`Foo.al`) was renamed (into `Bar.al`). Inside its internal storage, the only thing git ever sees is that `Foo.al` was deleted, and `Bar.al` was added, and that's it. Various git tools (like Git Lens, or Azure DevOps when looking at individual commits) may make you believe that rename information is stored, but it actually is not. Rather, every time you look at contents of a commit, all of the heuristics I explained above are done again.

This is why, when looking at a history of a file inside DevOps, or locally using GitLens for example, the history stops at the rename point. The last history of a renamed file you can see is when it was added to the repo (as the "add" part of the rename operation pair). If DevOps figures out, again using the same heuristics, that a file might have been renamed, it will offer you the "Show rename history" option. But all this feature does is guesswork, really. There is no hard history of renames.

Now, you may think you can outsmart all of this by using `git mv` (`mv` for move, and again, move = rename). If you think git mv will do an actual move (or rename), it won't. What `git mv` is is nothing but a pair of `git rm` (for delete) and `git add` (for add), it's simply a shortcut. It's not `git mv` that marks a file as renamed, it's still the same git heuristics that will do it.

So, if you want to move 3.600 files and make sure git knows it's an actual move, rather than just a bunch of deletions and additions, running `git mv` for all of those 3.600 files will be an exercise in futility. The results will be exactly the same as simply moving the file using the file system or VS Code or whatever other way, then stage and commit those changes. If you just do 3.600 moves, git will be fast at detecting that this has been in fact 3.600 renames, rather than 3.600 deletions followed by 3.600 additions. That's because there were no changes in hashes for those 3.600 files, and git is extremely fast at figuring that part out.

Now, to the morale of the story.

## Morale of the store

Don't do move/rename at the same time you do content change! It's that simple.

When you want to restructure the repo, restructure it as one pull request. When you want to change content, change the content as a separate pull request. If you want to both restructure the repo *and* change the contents of some files for good measure, then you are bound for disaster! Depending on how many changes there are, git may see some of them as renames, but may end up actually not being able to figure this out for you when you need it.

This is the right workflow for changing structure of your repo:
1. Create a new branch
2. Do the renames/moves you intend to do ***without changing any of the file contents***
3. (Stage and) Commit the changes
4. Push the changes and create a pull request

If you want to change the file content, this is the right workflow:
1. Create a new branch
2. Change the content of files you want to change ***without changing any of file names or paths***
3. (Stage and) Commit the changes
4. Push the changes and create a pull request

This is the only way for you to be able to always follow the file change history through renames.

## What really happened with those two big restructurings?

Now, I assume Mikkel didn't know all this (I didn't know all of this before I started writing this, either!) That's why his restructuring ended up a mess, because he did a lot of file renames, moving them around the new folders. At the same time he renamed files from generic names (COD6150700.al to POSSession.al, for example), but he also changed their names to include the prefix (codeunit "POS Session" to "NPR POS Session" for example). This has resulted in hashes of all files to not match, meaning that instead of matching hashes (which would be enough for a simple move/rename operation) git now has to run full diff on a set of more than 3.600 files. That's why for Mikkel's commit (bda96a780ee8f9133dbfbf6a68be775a847441b2) git does not consistently follow the history.

At the same time, Alen suspected that simply renaming a file, that shows a deletion + addition in the Changes section in VS Code, would be a bad thing to have, losing all of the history. So he did a script which ran git mv for all of the files to move them from .\src to .\application\src. However, since he did not change any contents at this time, merely changing file paths, file hashes remained the same, and git can figure this out in a matter of milliseconds, even though there are more than 3.600 delete + addition operations. That's why for Alen's commit (ee9fbab870aed0a67f0a057f6b339c6fe6fae097) you can follow the rename history.

But, as it turns out, it's purely incidental. The only thing Mikkel did wrong was to rename and change content, while Alen only did rename (although he took far more effort at it than he should have)

Hope this helps us make sure we never lose our history again.

If you want more info on how git renaming detection works, and how to tweak it, read the official git docs:
https://git-scm.com/docs/git-diff