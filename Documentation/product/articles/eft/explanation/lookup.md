# EFT lookup

In NPRetail, the EFT module supports looking up past transaction results, if the EFT integration in use supports it.
This lookup transaction request can browse through results as far back in time as the integration supports. Most of them can retrieve at least the most recently finished transaction.

If NPRetail experiences a crash or an outage on any layer (ranging from the payment terminal, local POS client or BC backend server) while an EFT transaction is active, the module prompts the POS salesperson to perform lookup of the unknown transaction result the next time they use the integration.


There are a couple of outcomes that can happen from here:

- The transaction is completed successfully with fiscal impact (the payment is performed) and we are still in the same active sale context in the POS.
NPRetail creates the missing payment line in the active sale.
- The transaction is completed successfully with fiscal impact, but we are no longer in the same active sale context.   
NP Retail prompts the salesperson about the out-of-sync payment and expects either a resume of the relevant POS sale which might be parked followed by another EFT lookup.   
If the original POS sale has been cancelled, the manual cancellation (void or refund) on the payment terminal used for the payment is required to bring the two systems back in sync.
- The transaction is completed successfully with no fiscal impact.    
We are in sync, and the salesperson is informed about it via a prompt.
- Lookup failed.   
NP Retail informs the salesperson about the failed lookup and allows more lookup attempts. 

