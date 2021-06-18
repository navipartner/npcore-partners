# Rescue directory

This directory contains some maintenance files. Most likely you won't need them, but in case you do...

## When things go wrong...

... and they do go wrong in this business, don't they? So, imagine this unlikely situation: *something happened*, and your packages are out of sync, modules don't install or fail to install, compilation doesn't work any more, there is a mess of trial and error remnants in `package.json`s around the system, and things generally don't look good.

Not that hard to imagine, is it? 😁

Anyway, something goes wrong, this is what you do:

```powershell
# Run this from root

cd rescue
.\_clean.ps1

cd ..
pnpm multi install
```

That's it, seriously.

## Individual scripts in this directory

If you want to know what the scripts in this directory do, here's an all-you-need-to-know-about-them reference.

## _clean.ps1

Removes node_modules, dist, and package-lock.json from the root and all package subdirectories.

## _install_with_npm___do_not_run_me.ps1

Runs `npm install` in all package subdirectories in the correct logical order, and then runs it in the root.

You probably absolutely don't want to run this one.


