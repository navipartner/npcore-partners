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
                field("API Username";"API Username")
                {
                }
                field("API Password";"API Password")
                {
                }
                field(Environment;Environment)
                {
                }
                field("Log Level";"Log Level")
                {
                }
                field("Auto Reconcile on EOD";"Auto Reconcile on EOD")
                {
                }
            }
        }
    }

    actions
    {
    }
}

