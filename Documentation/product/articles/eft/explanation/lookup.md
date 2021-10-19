# EFT Lookup

In NPRetail, the EFT module supports looking up past transaction results, if the specific EFT integration being used supports it.
This "Lookup" transaction request can look as far back in time as an integration supports - most support at least looking up the most recently finished transaction.

If NPRetail has experienced a crash or an outage, at any layer ranging from the payment terminal, local POS client or BC backend server while an EFT transaction was active, the module will prompt the POS salesperson to do lookup of the unknown transaction result the next time they try to use the integration.
There are a couple of outcomes that can happen from here:

1. The transaction was successfully completed with fiscal impact (=Payment was performed) and we are still in the same active sale context in the POS -> NPRetail will create the missing payment line in the active sale.
2. The transaction was successfully completed with fiscal impact but we are no longer in the same active sale context -> NPRetail will prompt the sales person about the out-of-sync payment and expect either a resume of the relevant POS sale which might be parked followed by another EFT lookup. 
If the original POS sale has been cancelled then manual cancellation (void or refund) on the payment terminal used for the payment is required to bring the two systems back in sync.
3. The transaction was successfully completed with no fiscal impact -> We are in sync, and sales person is informed about it via a prompt.
4. Lookup failed -> NPRetail will prompt the sales person about the failed lookup and any will allow more lookup attempts. 

