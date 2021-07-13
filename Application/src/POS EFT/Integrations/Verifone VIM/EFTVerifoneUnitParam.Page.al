page 6184507 "NPR EFT Verifone Unit Param."
{
    // NPR5.53/MMV /20191204 CASE 349520 Added object

    Caption = 'EFT Verifone Unit Parameters';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR EFT Verifone Unit Param.";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Terminal Serial Number"; Rec."Terminal Serial Number")
                {

                    ToolTip = 'Specifies the value of the Terminal Serial Number field';
                    ApplicationArea = NPRRetail;
                }
                field("Terminal LAN Address"; Rec."Terminal LAN Address")
                {

                    ToolTip = 'Specifies the value of the Terminal LAN Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Terminal LAN Port"; Rec."Terminal LAN Port")
                {

                    ToolTip = 'Specifies the value of the Terminal LAN Port field';
                    ApplicationArea = NPRRetail;
                }
                field("Terminal Connection Mode"; Rec."Terminal Connection Mode")
                {

                    ToolTip = 'Specifies the value of the Terminal Connection Mode field';
                    ApplicationArea = NPRRetail;
                }
                field("Terminal Log Location"; Rec."Terminal Log Location")
                {

                    ToolTip = 'Specifies the value of the Terminal Log Location field';
                    ApplicationArea = NPRRetail;
                }
                field("Terminal Log Level"; Rec."Terminal Log Level")
                {

                    ToolTip = 'Specifies the value of the Terminal Log Level field';
                    ApplicationArea = NPRRetail;
                }
                field("Terminal Listening Port"; Rec."Terminal Listening Port")
                {

                    ToolTip = 'Specifies the value of the Terminal Listening Port field';
                    ApplicationArea = NPRRetail;
                }
                field("Terminal Connection Type"; Rec."Terminal Connection Type")
                {

                    ToolTip = 'Specifies the value of the Terminal Connection Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Terminal Default Language"; Rec."Terminal Default Language")
                {

                    ToolTip = 'Specifies the value of the Terminal Default Language field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Close Terminal on EOD"; Rec."Auto Close Terminal on EOD")
                {

                    ToolTip = 'Specifies the value of the Auto Close Terminal on EOD field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Open on Transaction"; Rec."Auto Open on Transaction")
                {

                    ToolTip = 'Specifies the value of the Auto Open on Transaction field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Login After Reconnect"; Rec."Auto Login After Reconnect")
                {

                    ToolTip = 'Specifies the value of the Auto Login After Reconnect field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Reconcile on Close"; Rec."Auto Reconcile on Close")
                {

                    ToolTip = 'Specifies the value of the Auto Reconcile on Close field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

