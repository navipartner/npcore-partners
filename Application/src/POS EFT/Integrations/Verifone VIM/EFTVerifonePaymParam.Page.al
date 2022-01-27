page 6184506 "NPR EFT Verifone Paym. Param."
{
    Extensible = False;
    // NPR5.53/MMV /20191204 CASE 349520 Added object

    Caption = 'EFT Verifone Payment Parameter';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR EFT Verifone Paym. Param.";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Initialize Timeout Seconds"; Rec."Initialize Timeout Seconds")
                {

                    ToolTip = 'Specifies the value of the Initialize Timeout Seconds field';
                    ApplicationArea = NPRRetail;
                }
                field("Login Timeout Seconds"; Rec."Login Timeout Seconds")
                {

                    ToolTip = 'Specifies the value of the Login Timeout Seconds field';
                    ApplicationArea = NPRRetail;
                }
                field("Logout Timeout Seconds"; Rec."Logout Timeout Seconds")
                {

                    ToolTip = 'Specifies the value of the Logout Timeout Seconds field';
                    ApplicationArea = NPRRetail;
                }
                field("Setup Test Timeout Seconds"; Rec."Setup Test Timeout Seconds")
                {

                    ToolTip = 'Specifies the value of the GatewayTest Timeout Seconds field';
                    ApplicationArea = NPRRetail;
                }
                field("Trx Lookup Timeout Seconds"; Rec."Trx Lookup Timeout Seconds")
                {

                    ToolTip = 'Specifies the value of the Trx Lookup Timeout Seconds field';
                    ApplicationArea = NPRRetail;
                }
                field("Reconciliation Timeout Seconds"; Rec."Reconciliation Timeout Seconds")
                {

                    ToolTip = 'Specifies the value of the Reconciliation Timeout Seconds field';
                    ApplicationArea = NPRRetail;
                }
                field("Force Abort Min. Delay Seconds"; Rec."Force Abort Min. Delay Seconds")
                {

                    ToolTip = 'Specifies the value of the Force Abort Delay Seconds field';
                    ApplicationArea = NPRRetail;
                }
                field("Pre Login Delay Seconds"; Rec."Pre Login Delay Seconds")
                {

                    ToolTip = 'Specifies the value of the Pre Login Delay Seconds field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Reconcile Delay Seconds"; Rec."Post Reconcile Delay Seconds")
                {

                    ToolTip = 'Specifies the value of the Post Reconcile Delay Seconds field';
                    ApplicationArea = NPRRetail;
                }
                field("Terminal Debug Mode"; Rec."Terminal Debug Mode")
                {

                    ToolTip = 'Specifies the value of the Terminal Debug Mode field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

