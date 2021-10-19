Read Microsofts latest docs on newer upgrade features in AL, i.e. comparing with a persistant upgrade tag or comparing against pre-upgrade .app version:
https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-upgrading-extensions

# Location
All upgrade codeunits should be placed inside /src/_Upgrades/

# C/SIDE Migration
For upgrades that are relevant for any customer coming from C/SIDE to AL (meaning, upgrades for old fields that existed in C/SIDE NPRetail), place them inside another nested folder: CSideMigration, i.e.:
/src/_Upgrades/CSideMigration
These upgrades are special as they will not be deleted until C/SIDE migration is done (will take years).

The upgrade routine used by hosting looks something like this:
1. Prepare new BC environment and install NPCore apps.
2. Use prepared SQL scripts to transfer all data where schema matches.
3. Invoke AL upgrades.

This means, as long as old tables that existed in C/SIDE are kept as obsolete, data will be transferred into them, from where an upgrade can deal with it as usual.

The goal is that, even if a CSIDE customer is not migrated to the .app until BC21, there is still a big chunk of upgrade codeunits ready to migrate from the obsolete CSIDE tables to AL tables.

# Controlling when to run upgrades
As noted by the MS article above, controlling when to run upgrades is important.
You might be used to a C/SIDE world where upgrades were deleted when run, after each release. But in AL we will keep them in the repo with controls on running only if version or upgrade tags matches correct condition.

# Examples
"Moving a table or field that existed all the way back to C/SIDE, to a new table in AL":
* Mark old table/field as obsolete (if table, move into obsolete folder).
* Create replacement in new table.
* Write upgrade for moving from old to new, place into path /src/_Upgrades/CSideMigration
* Add a guard against running the test more than once via "Upgrade Tags"

"Moving a table or field that only existed in AL, in earlier versions of the app":
* Same as previous example, except you also have to choice to only run your upgrade code here if the previous version is below x.x.x.x
  This can be clever to skip your upgrade code immediately even in environments without the tag, if the version is so new that it is no longer relevant.
  It will also help a colleague to know, when an upgrade is safe to delete (when every customer is on a newer build than x.x.x.x)
 

