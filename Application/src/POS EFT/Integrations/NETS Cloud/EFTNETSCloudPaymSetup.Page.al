page 6184508 "NPR EFT NETS Cloud Paym. Setup"
{
    Caption = 'EFT NETS Cloud Payment Setup';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR EFT NETS Cloud Paym. Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("API Username"; "API Username")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the API Username field';
                }
                field("API Password"; "API Password")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the API Password field';
                }
                field(Environment; Environment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Environment field';
                }
                field("Log Level"; "Log Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Level field';
                }
                field("Auto Reconcile on EOD"; "Auto Reconcile on EOD")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Reconcile on Balancing field';
                }
            }
        }
    }

    actions
    {
    }
}

