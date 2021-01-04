page 6184507 "NPR EFT Verifone Unit Param."
{
    // NPR5.53/MMV /20191204 CASE 349520 Added object

    Caption = 'EFT Verifone Unit Parameters';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR EFT Verifone Unit Param.";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Terminal Serial Number"; "Terminal Serial Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal Serial Number field';
                }
                field("Terminal LAN Address"; "Terminal LAN Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal LAN Address field';
                }
                field("Terminal LAN Port"; "Terminal LAN Port")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal LAN Port field';
                }
                field("Terminal Connection Mode"; "Terminal Connection Mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal Connection Mode field';
                }
                field("Terminal Log Location"; "Terminal Log Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal Log Location field';
                }
                field("Terminal Log Level"; "Terminal Log Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal Log Level field';
                }
                field("Terminal Listening Port"; "Terminal Listening Port")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal Listening Port field';
                }
                field("Terminal Connection Type"; "Terminal Connection Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal Connection Type field';
                }
                field("Terminal Default Language"; "Terminal Default Language")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal Default Language field';
                }
                field("Auto Close Terminal on EOD"; "Auto Close Terminal on EOD")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Close Terminal on EOD field';
                }
                field("Auto Open on Transaction"; "Auto Open on Transaction")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Open on Transaction field';
                }
                field("Auto Login After Reconnect"; "Auto Login After Reconnect")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Login After Reconnect field';
                }
                field("Auto Reconcile on Close"; "Auto Reconcile on Close")
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

