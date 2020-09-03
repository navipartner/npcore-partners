page 6184507 "NPR EFT Verifone Unit Param."
{
    // NPR5.53/MMV /20191204 CASE 349520 Added object

    Caption = 'EFT Verifone Unit Parameters';
    PageType = Card;
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
                }
                field("Terminal LAN Address"; "Terminal LAN Address")
                {
                    ApplicationArea = All;
                }
                field("Terminal LAN Port"; "Terminal LAN Port")
                {
                    ApplicationArea = All;
                }
                field("Terminal Connection Mode"; "Terminal Connection Mode")
                {
                    ApplicationArea = All;
                }
                field("Terminal Log Location"; "Terminal Log Location")
                {
                    ApplicationArea = All;
                }
                field("Terminal Log Level"; "Terminal Log Level")
                {
                    ApplicationArea = All;
                }
                field("Terminal Listening Port"; "Terminal Listening Port")
                {
                    ApplicationArea = All;
                }
                field("Terminal Connection Type"; "Terminal Connection Type")
                {
                    ApplicationArea = All;
                }
                field("Terminal Default Language"; "Terminal Default Language")
                {
                    ApplicationArea = All;
                }
                field("Auto Close Terminal on EOD"; "Auto Close Terminal on EOD")
                {
                    ApplicationArea = All;
                }
                field("Auto Open on Transaction"; "Auto Open on Transaction")
                {
                    ApplicationArea = All;
                }
                field("Auto Login After Reconnect"; "Auto Login After Reconnect")
                {
                    ApplicationArea = All;
                }
                field("Auto Reconcile on Close"; "Auto Reconcile on Close")
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

