page 6184886 "NPR NP Pay POS Payment Setups"
{
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    Extensible = false;
    InsertAllowed = false;
    Editable = false;
    SourceTable = "NPR NP Pay POS Payment Setup";
    CardPageId = "NPR NP Pay POS Payment Setup";
    Caption = 'NP Pay POS Payment Setup';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Code';
                    ToolTip = 'Specifies the code for this NP Pay POS Payment Setup.';
                }
                field("Merchant Account"; Rec."Merchant Account")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Merchant Account';
                    ToolTip = 'Specifies which Merchant Account should be used for the payment setup.';
                }
            }
        }
    }
}