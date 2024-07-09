# Breaking Changes

### Obsolete Tags
Use obsolete tag in 'YYYY-MM-DD' in date format as the next latest version of NP Retail at the time of obsoletion.  

### Time period
By default, we use 12 month obsolete pending periods before we can fully remove something.  
There can be exceptions to this:  
- You know 100% that something is not used. For example you might have just accidentally created a public function in a new codeunit and now you want to move it back as internal - and you can deduce that no one had a chance or a reason to consume your API yet. Note: Mark saying in a one-line comment that something is not used is not enough confirmation. You or another developer/product owner need to be 100% sure if you're going to make an exception without telemetry first.
- You have added custom telemetry via Session.LogMessage() that has allowed you to guarantee that there are no consumers of your API in the wild.  


### Pull request validation
All NPCore PRs are validated for missing ObsoleteTag with syntax 'NPRx.y' as part of our pipeline so developers cannot forget to fill it.
The pipeline allows ObsoleteTag property to be placed either directly above or below the ObsoleteState property as it uses simple regexes rather than real AL parsing.