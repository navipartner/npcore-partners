page 6184507 "NPR EFT Verifone Unit Param."
{
    // NPR5.53/MMV /20191204 CASE 349520 Added object

    Caption = 'EFT Verifone Unit Parameters';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR EFT Verifone Unit Param.";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Terminal Serial Number"; Rec."Terminal Serial Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal Serial Number field';
                }
                field("Terminal LAN Address"; Rec."Terminal LAN Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal LAN Address field';
                }
                field("Terminal LAN Port"; Rec."Terminal LAN Port")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal LAN Port field';
                }
                field("Terminal Connection Mode"; Rec."Terminal Connection Mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal Connection Mode field';
                }
                field("Terminal Log Location"; Rec."Terminal Log Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal Log Location field';
                }
                field("Terminal Log Level"; Rec."Terminal Log Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal Log Level field';
                }
                field("Terminal Listening Port"; Rec."Terminal Listening Port")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal Listening Port field';
                }
                field("Terminal Connection Type"; Rec."Terminal Connection Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal Connection Type field';
                }
                field("Terminal Default Language"; Rec."Terminal Default Language")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal Default Language field';
                }
                field("Auto Close Terminal on EOD"; Rec."Auto Close Terminal on EOD")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Close Terminal on EOD field';
                }
                field("Auto Open on Transaction"; Rec."Auto Open on Transaction")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Open on Transaction field';
                }
                field("Auto Login After Reconnect"; Rec."Auto Login After Reconnect")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Login After Reconnect field';
                }
                field("Auto Reconcile on Close"; Rec."Auto Reconcile on Close")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Reconcile on Close field';
                }
            }
        }
    }

    actions
    {
    }
}

