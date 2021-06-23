# dragonglass-react

This repo is a bit of a black sheep here, really.

This is where majority of development (at this moment) happens, it contains most of the code (at this moment), but it is nothing but a repository of source files to be used by the root (.workspace) folder from where the build (at the moment) happens.

As you can see, there is a lot of *"at the moment"* in the previous paragraph, and that's because (at the moment) we are in the process of refactoring it.

When time is ripe, the root (.workspace) folder will simply contain webpack instructions how to build react, and this folder will become a node module of its own, with its package.json and all.

## Important

Do not add package.json in this folder. When you need to install modules for react, install them in the root. When this folder is ready to become a real module, it'll get its package.json.
