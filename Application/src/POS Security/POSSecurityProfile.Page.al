page 6014601 "NPR POS Security Profile"
{
    Caption = 'NPR POS Security Profile';
    PageType = Card;
    SourceTable = "NPR POS Security Profile";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
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
                    ExtendedDatatype = Masked;
                }
            }
        }
    }


}
