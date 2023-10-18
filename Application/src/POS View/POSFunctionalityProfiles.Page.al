page 6151287 "NPR POS Functionality Profiles"
{
    PageType = List;
    SourceTable = "NPR POS Functionality Profile";
    CardPageID = "NPR POS Functionality Profile";
    Caption = 'POS Functionality Profiles';
    Extensible = false;
    Editable = false;
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR27.0';
    ObsoleteReason = 'New parameter SelectCustReq and SelectMemberReq in POS Action Login created, use this instead.';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
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