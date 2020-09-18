page 6184506 "NPR EFT Verifone Paym. Param."
{
    // NPR5.53/MMV /20191204 CASE 349520 Added object

    Caption = 'EFT Verifone Payment Parameter';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR EFT Verifone Paym. Param.";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Initialize Timeout Seconds"; "Initialize Timeout Seconds")
                {
                    ApplicationArea = All;
                }
                field("Login Timeout Seconds"; "Login Timeout Seconds")
                {
                    ApplicationArea = All;
                }
                field("Logout Timeout Seconds"; "Logout Timeout Seconds")
                {
                    ApplicationArea = All;
                }
                field("Setup Test Timeout Seconds"; "Setup Test Timeout Seconds")
                {
                    ApplicationArea = All;
                }
                field("Trx Lookup Timeout Seconds"; "Trx Lookup Timeout Seconds")
                {
                    ApplicationArea = All;
                }
                field("Reconciliation Timeout Seconds"; "Reconciliation Timeout Seconds")
                {
                    ApplicationArea = All;
                }
                field("Force Abort Min. Delay Seconds"; "Force Abort Min. Delay Seconds")
                {
                    ApplicationArea = All;
                }
                field("Pre Login Delay Seconds"; "Pre Login Delay Seconds")
                {
                    ApplicationArea = All;
                }
                field("Post Reconcile Delay Seconds"; "Post Reconcile Delay Seconds")
                {
                    ApplicationArea = All;
                }
                field("Terminal Debug Mode"; "Terminal Debug Mode")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

