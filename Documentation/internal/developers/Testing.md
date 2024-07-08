# NPCore Tests
At the root of the NpCore project, you'll see two folders:
.\APPLICATION
.\TEST

These are two separate apps. The APPLICATION folder is the actual NpCore app while the TEST folder contains our test app which is automatically compiled and run on every pull request before approval.

# Microsoft Tests
Every night we run the entire MS test suite against the master branch. This is not done on every PR as it would take up too much time.

# Writing tests
Read the official recommendations by Microsoft for test codeunits first:
https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-testing-application
https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-extension-advanced-example-test

Aim to follow the GIVEN-WHEN-THEN pattern detailed in the latter article.
Aim to keep the new library codeunits and methods structured in the same way as the existing ones.
Use intellisense (ctrl+space) to pull the next object number when creating new test objects. They are all placed in the 85k area. We place them higher than 50k to keep support for testing with customer tenant extensions installed on top at a later time.

# Writing POS tests
For tests covering POS actions or core POS business codeunits, the focus is on testing the business logic, not the frontend/UI/JSON parsing.
This means, action codeunits should be written with business logic isolated into methods that can be called directly from a test.

Look at _.\TEST\POS\POSPaymentTests.Codeunit.al_ as an example of how we invoke the usual POS Session init, POS sale creation, item insert action business logic, payment action business logic and POS sale end methods without writing code that touches anything that handles JSON creation/parsing or frontend javascript.

Notice that we use a POS Mock so any request that would normally reach the frontend, such as stargate, UI updates etc. are all send to the mock codeunit instead. Unless you are writing a test specifically aimed at verifying one of these frontend routines, you can ignore the mock, but it is possible to manually subscribe to it if needed.

# Running tests while developing
A container ordered via the usual crane template will contain the test library and runner as well so you can always publish the test app to it and run your tests from it while developing. (Search for page "AL Test Tool")

# Tips and tricks
1. Remember that the new AL interface feature allows you to build modules where an entire dependency can be swapped out with a mock to isolate specific parts during testing.
As long as the dependency is covered by an interface and is injected from outside, a test codeunit can instantiate it's own mock of the interface and inject it instead.
This is how the POS mock is done. 
If this concept is foreign to you, read https://en.wikipedia.org/wiki/Inversion_of_control and search around online for these concepts as there are plenty of examples from other object oriented programming languages like C#.