codeunit 6184478 "EFT Gift Card Mgt."
{
    // NPR5.51/MMV /20190626 CASE 359385 Created object
    // NPR5.53/MMV /20191203 CASE 349520 Only recover to payment line when original trx was unsuccessful. This should logically be implied but added safeguard against integration specific bugs.
    // NPR5.53/MMV /20200114 CASE 375525 Return EntryNo from StartGiftCardLoadTransaction
    // NPR5.54/MMV /20200302 CASE 364340 Merged functionality into "EFT Payment Mgt." for code reuse.


    trigger OnRun()
    begin
    end;
}

