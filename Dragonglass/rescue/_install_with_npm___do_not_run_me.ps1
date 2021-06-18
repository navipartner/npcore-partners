# Seriously, don't run this script!
# 
# This script is intended to be run only if for whatever crazy reason anyone ever wants to switch back
# to npm world. Which noone shouldn't do unless completely out of their mind.
# 
# This script goes through individual package directories, runs npm install to wire up all the modules and
# prep the tsc compilation, and then does it in the root to wire up all packages together.
#
# Run this package only if you are completely crazy and think that your life will be easier with vanilla
# npm. It won't. Good luck.

cd ../packages/dragonglass-core
npm install
cd ../dragonglass-transcendence
npm install
cd ../dragonglass-front-end-async
npm install
cd ../dragonglass-workflows
npm install
cd ../..
npm install
