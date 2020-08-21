page 6184508 "EFT NETS Cloud Payment Setup"
{
    // NPR5.54/MMV /20200129 CASE 364340 Created object

    Caption = 'EFT NETS Cloud Payment Setup';
    PageType = Card;
    SourceTable = "EFT NETS Cloud Payment Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("API Username"; "API Username")
                {
                    ApplicationArea = All;
                }
                field("API Password"; "API Password")
                {
                    ApplicationArea = All;
                }
                field(Environment; Environment)
                {
                    ApplicationArea = All;
                }
                field("Log Level"; "Log Level")
                {
                    ApplicationArea = All;
                }
                field("Auto Reconcile on EOD"; "Auto Reconcile on EOD")
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

