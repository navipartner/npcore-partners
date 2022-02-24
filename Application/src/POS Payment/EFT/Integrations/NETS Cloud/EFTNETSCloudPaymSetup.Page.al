page 6184508 "NPR EFT NETS Cloud Paym. Setup"
{
    Extensible = False;
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

                    ToolTip = 'Specifies the value of the API Username field';
                    ApplicationArea = NPRRetail;
                }
                field("API Password"; Rec."API Password")
                {

                    ToolTip = 'Specifies the value of the API Password field';
                    ApplicationArea = NPRRetail;
                }
                field(Environment; Rec.Environment)
                {

                    ToolTip = 'Specifies the value of the Environment field';
                    ApplicationArea = NPRRetail;
                }
                field("Log Level"; Rec."Log Level")
                {

                    ToolTip = 'Specifies the value of the Log Level field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Reconcile on EOD"; Rec."Auto Reconcile on EOD")
                {

                    ToolTip = 'Specifies the value of the Auto Reconcile on Balancing field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

