page 6184507 "EFT Verifone Unit Parameters"
{
    // NPR5.53/MMV /20191204 CASE 349520 Added object

    Caption = 'EFT Verifone Unit Parameters';
    PageType = Card;
    SourceTable = "EFT Verifone Unit Parameter";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Terminal Serial Number";"Terminal Serial Number")
                {
                }
                field("Terminal LAN Address";"Terminal LAN Address")
                {
                }
                field("Terminal LAN Port";"Terminal LAN Port")
                {
                }
                field("Terminal Connection Mode";"Terminal Connection Mode")
                {
                }
                field("Terminal Log Location";"Terminal Log Location")
                {
                }
                field("Terminal Log Level";"Terminal Log Level")
                {
                }
                field("Terminal Listening Port";"Terminal Listening Port")
                {
                }
                field("Terminal Connection Type";"Terminal Connection Type")
                {
                }
                field("Terminal Default Language";"Terminal Default Language")
                {
                }
                field("Auto Close Terminal on EOD";"Auto Close Terminal on EOD")
                {
                }
                field("Auto Open on Transaction";"Auto Open on Transaction")
                {
                }
                field("Auto Login After Reconnect";"Auto Login After Reconnect")
                {
                }
                field("Auto Reconcile on Close";"Auto Reconcile on Close")
                {
                }
            }
        }
    }

    actions
    {
    }
}

