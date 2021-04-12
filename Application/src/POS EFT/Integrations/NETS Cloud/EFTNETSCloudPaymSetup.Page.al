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
                field("API Username"; Rec."API Username")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the API Username field';
                }
                field("API Password"; Rec."API Password")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the API Password field';
                }
                field(Environment; Rec.Environment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Environment field';
                }
                field("Log Level"; Rec."Log Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Level field';
                }
                field("Auto Reconcile on EOD"; Rec."Auto Reconcile on EOD")
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

