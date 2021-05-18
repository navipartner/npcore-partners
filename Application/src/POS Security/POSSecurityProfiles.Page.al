page 6014600 "NPR POS Security Profiles"
{
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Security Profile";
    Caption = 'NPR POS Security Profiles';
    Editable = false;
    CardPAgeID = "NPR POS Security Profile";
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Password on Unblock Discount"; Rec."Password on Unblock Discount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Administrator Password field';
                }
            }
        }
    }
}