# This script cleans all npm and tsc artifacts in all subdirectories.
# It will get rid of all node_modules and dist directories, and package-lock.json files in the root and all
# of this monorepo's package directories.
#
# Run this package when you want to get a clean slate, perhaps when you want to test that changes you did
# to the repo will be easy to git clone and get started on a fresh machine or in a fresh dev environment.

Remove-Item ./../node_modules -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item ./../packages/dragonglass-core/node_modules -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item ./../packages/dragonglass-transcendence/node_modules -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item ./../packages/dragonglass-front-end-async/node_modules -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item ./../packages/dragonglass-workflows/node_modules -Force -Recurse -ErrorAction SilentlyContinue

Remove-Item ./../packages/dragonglass-core/dist -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item ./../packages/dragonglass-transcendence/dist -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item ./../packages/dragonglass-front-end-async/dist -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item ./../packages/dragonglass-workflows/dist -Force -Recurse -ErrorAction SilentlyContinue

Remove-Item ./../packages/dragonglass-core/package-lock.json -Force -ErrorAction SilentlyContinue
Remove-Item ./../packages/dragonglass-transcendence/package-lock.json -Force -ErrorAction SilentlyContinue
Remove-Item ./../packages/dragonglass-front-end-async/package-lock.json -Force -ErrorAction SilentlyContinue
Remove-Item ./../packages/dragonglass-workflows/package-lock.json -Force -ErrorAction SilentlyContinue
Remove-Item ./../package-lock.json -Force -ErrorAction SilentlyContinue
