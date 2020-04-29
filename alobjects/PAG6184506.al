page 6184506 "EFT Verifone Payment Parameter"
{
    // NPR5.53/MMV /20191204 CASE 349520 Added object

    Caption = 'EFT Verifone Payment Parameter';
    PageType = Card;
    SourceTable = "EFT Verifone Payment Parameter";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Initialize Timeout Seconds";"Initialize Timeout Seconds")
                {
                }
                field("Login Timeout Seconds";"Login Timeout Seconds")
                {
                }
                field("Logout Timeout Seconds";"Logout Timeout Seconds")
                {
                }
                field("Setup Test Timeout Seconds";"Setup Test Timeout Seconds")
                {
                }
                field("Trx Lookup Timeout Seconds";"Trx Lookup Timeout Seconds")
                {
                }
                field("Reconciliation Timeout Seconds";"Reconciliation Timeout Seconds")
                {
                }
                field("Force Abort Min. Delay Seconds";"Force Abort Min. Delay Seconds")
                {
                }
                field("Pre Login Delay Seconds";"Pre Login Delay Seconds")
                {
                }
                field("Post Reconcile Delay Seconds";"Post Reconcile Delay Seconds")
                {
                }
                field("Terminal Debug Mode";"Terminal Debug Mode")
                {
                }
            }
        }
    }

    actions
    {
    }
}

