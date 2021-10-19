# Prerelease flow
- **Prerelease will error out if not run from default branch (master)!**
- Prerelease build triggers automatically on Pull Request merged into master branch.
- Find latest release branch (eg. 5.55) and create version having minor component increased by one 1700.**6**.0.0 (LatestReleaseTag calculated).
- Find latest prerelease tag, having minor component of the build (1700.**6**.0.100) and increase revision by one: 1700.**6**.0.101 (PrereleaseRevisionCounter). Prerelease counter starts with 1 and is specific for a MajorVersion, meaning we will have different revision numbers fro 1700 and 1800 major versions.

- Foreach major version flag deined in common pipeline template:
     - Compile a different .app for each json entry with versioning logic:
	MajorVersionFromPipelineTemplate.LatestReleaseTag+1.0.PrereleaseRevisionCounter

NOTE: app.json in the master branch can be left on a good default i.e. 9999.9999.9999.9999 so you are always on higher version when developing.
**app.json is entirely ignored by pipeline.**

# Release flow
- **Release will error out if not run from a branch inside /releases folder (/releases/5.56)!**
- Find latest release tag for a version specified in release branch name (eg. releases/**5.55**) and create version having revision component increased by one 1700.5.55.**10001** (LatestReleaseTag calculated). Prerelease counter starts with 10000 and is specific for a MajorVersion, meaning we will have different revision numbers fro 1700 and 1800 major versions.

 - Run release pipeline by hand, which outputs one .app per compilation entry in the nuget feed i.e.
   1700.1.0.0, 1705.1.0.0, 1800.1.0.0
   
Versioning logic:   	MajorVersionFromPipelineTemplate.MinorFromReleaseBranchName.BuildFromReleaseBranchName.ReleaseRevisionCounter
**app.json is entirely ignored by pipeline.**

# Hotfix flow
 - branch from last release branch, name branch with intended version i.e. releases/5.55. 
 - Locally cherry pick from master commit IDs
 - Run release pipeline by hand, which outputs one .app per compilation entry in the nuget feeds i.e.
   1700.1.1.0, 1705.1.1.0, 1800.1.1.0
 - Specific NuGet packages are created for each major version (NaviPartner.NPCore.BC[majorVersion] => NaviPartner.NPCore.BC1700, NaviPartner.NPCore.BC1800)
   
**Versioning logic is identical to the Release flow versioning logic.**

# Nuget feed example
Example of nuget feed with above approach, chronologically on empty project (top to bottom):

1700.1.0.00001-prerelease
1700.1.0.00002-prerelease
1700.1.0.00003-prerelease
1700.1.0.00004-prerelease
1700.1.0.00005-prerelease
1700.1.0.10000 (this is a release)
1700.1.1.10000 (this hotfix could have been created much later but sorts here in feed which is correct as it MUST have less features/fixes than latest 2.0prerelease)
1700.2.0.00001-prerelease
1700.2.0.00002-prerelease
1700.2.0.00003-prerelease
1700.2.0.00004-prerelease
1700.2.0.00005-prerelease
1700.2.0.10000 (this is a release)

# Notes
- Internally, we'll refer to NPRetail versions as "Version 3, hotfix 2" when talking about which version a customer is running on, as we strive to keep all core functionality equal between supported major BC versions.
- PrereleaseRevisionCounter starts at .00001 while ReleaseRevisionCounter starts at .10000. This means it will be obvious if a release build is deployed based on the fourth number.
- When picking a NPRetail version from the feed, use highest possible (but lower or same) major version number for the platform, i.e. if you use 1708 platform, pick 1705.
- There will be some major releases by Microsoft (hopefully), with zero breaking changes towards NPRetail, for these we do not have to add a new compilation output,
  e.g. if BC19 works with BC18 NPCore, leave it as-is.
- BC17.5 was used as an example of an EMERGENCY where BC17.5 contains a fix we urgently need in the baseapp and it also contains breaking changes we need to compile around.
  During normal operations, we do not add eagerly add compilation flags for cumulative updates, we just wait <6 months until next major BC release.

# Compiler preprocessing config example (configured in the main build template):
```yaml
  - name: BC17
    containerImageName: npretail.azurecr.io/np/dynamicsnav:17.0.16993.0-w1
    artifactUrl: ''
    endpointName: npretail_ACR
    serverInstanceName: BC
    licenseSecureFileName: 'DEV_BC OP 17.flf'
    
    majorVersion: 1700    
    appJsonValues: 
    -  platform: '17.0.0.0'
    -  application: '17.0.0.0'
    -  preprocessorSymbols: '@(''BC17'')'

  - name: BC17.5
    containerImageName: npretail.azurecr.io/np/dynamicsnav:17.5.20469.20605-w1
    artifactUrl: ''
    endpointName: npretail_ACR
    serverInstanceName: BC
    licenseSecureFileName: 'DEV_BC OP 17.flf'
    
    majorVersion: 1750    
    appJsonValues: 
    -  platform: '17.5.0.0'
    -  application: '17.5.0.0'
    -  preprocessorSymbols: '@(''BC17'',''BC17.5'')'

  - name: BC18
    containerImageName: npretail.azurecr.io/np/dynamicsnav:18.0.23013.23795-w1
    artifactUrl: ''
    endpointName: npretail_ACR
    serverInstanceName: BC
    licenseSecureFileName: 'DEV_BC OP 18.flf'

    majorVersion: 1800
    appJsonValues:
    -  platform: '18.0.0.0'
    -  application: '18.0.0.0'
    -  preprocessorSymbols: '@(''BC18'')'
```


# Compiler preprocessing usage examples
NOTE: BC17.5 compilation still happens with BC17 flag so when the examples below use target "BC17" they cover 17.x etc.


1. Code should compile in BC17 but not in higher major versions (i.e. support was removed in later versions):
```
#if BC17
// AL code for BC17 here
#endif
```

2. Code should compile into anything higher than BC17 (feature was added in later versions): 
```
#if BC17
// Do nothing
#else
// AL Code using a feature that was added in BC18 and forward.
#endif
```

3. Code should compile a little differently for BC17.5 (emergency for a cumulative update):
```
# if BC17.5
// AL code only for BC17.5
#endif
# if BC17 
// AL code for both BC17 and BC17.5
#endif
```