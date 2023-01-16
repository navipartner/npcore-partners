# Reflect.run

For integration testing our point of sale control addin, we use https://reflect.run

This app contains helper logic to make our integration testing better, for example an API procedure that is invoked by reflect.run to reset state in BC before running the nightly test suite.
Also print subscribers that make the printed jobs pop-up in messages that we can do validation on via reflect.runs tooling.

Feel free to extend as needed.