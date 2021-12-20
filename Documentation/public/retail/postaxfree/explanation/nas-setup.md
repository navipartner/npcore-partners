# NAS setup

All companies that run Global Blue tax free services need three scheduled objects to run at regular intervals:

- Codeunit 6014617 - "Tax Free - GB I2 GetCountries" : Should be run every 30 days.
- Codeunit 6014615 - "Tax Free - GB I2 GetBCountries" : Should be run every 7 days.
- Codeunit 6014616 - "Tax Free - GB I2 GetBlockedIIN" : Should be run every 30 days.


This is a requirement for the solution, so NAS services must be purchased if not already available for the customer that needs Global Blue integration.
