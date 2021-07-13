page 6014600 "NPR POS Security Profiles"
{
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Security Profile";
    Caption = 'NPR POS Security Profiles';
    Editable = false;
    CardPAgeID = "NPR POS Security Profile";
    ApplicationArea = NPRRetail;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Password on Unblock Discount"; Rec."Password on Unblock Discount")
                {

                    ToolTip = 'Specifies the value of the Administrator Password field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}