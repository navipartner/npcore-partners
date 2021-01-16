page 6184506 "NPR EFT Verifone Paym. Param."
{
    // NPR5.53/MMV /20191204 CASE 349520 Added object

    Caption = 'EFT Verifone Payment Parameter';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Initialize Timeout Seconds field';
                }
                field("Login Timeout Seconds"; "Login Timeout Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Login Timeout Seconds field';
                }
                field("Logout Timeout Seconds"; "Logout Timeout Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Logout Timeout Seconds field';
                }
                field("Setup Test Timeout Seconds"; "Setup Test Timeout Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the GatewayTest Timeout Seconds field';
                }
                field("Trx Lookup Timeout Seconds"; "Trx Lookup Timeout Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Trx Lookup Timeout Seconds field';
                }
                field("Reconciliation Timeout Seconds"; "Reconciliation Timeout Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reconciliation Timeout Seconds field';
                }
                field("Force Abort Min. Delay Seconds"; "Force Abort Min. Delay Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Force Abort Delay Seconds field';
                }
                field("Pre Login Delay Seconds"; "Pre Login Delay Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pre Login Delay Seconds field';
                }
                field("Post Reconcile Delay Seconds"; "Post Reconcile Delay Seconds")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Reconcile Delay Seconds field';
                }
                field("Terminal Debug Mode"; "Terminal Debug Mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal Debug Mode field';
                }
            }
        }
    }

    actions
    {
    }
}

