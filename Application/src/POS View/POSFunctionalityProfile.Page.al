page 6151286 "NPR POS Functionality Profile"
{
    PageType = Card;
    SourceTable = "NPR POS Functionality Profile";
    UsageCategory = None;
    Caption = 'POS Functionality Profile';
    Extensible = false;
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR27.0';
    ObsoleteReason = 'New parameter SelectCustReq and SelectMemberReq in POS Action Login created, use this instead.';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the unique code of the POS functionality profile.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the short description of the functionality profile.';
                    ApplicationArea = NPRRetail;
                }
                field("Require Select Member"; Rec."Require Select Member")
                {
                    ToolTip = 'Require Select Member After POS Login';
                    ApplicationArea = NPRRetail;
                }
                field("Require Select Customer"; Rec."Require Select Customer")
                {
                    ToolTip = 'Require Select Customer After POS Login';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}