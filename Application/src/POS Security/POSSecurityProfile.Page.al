page 6014601 "NPR POS Security Profile"
{
    Extensible = False;
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
                    ExtendedDatatype = Masked;
                    ApplicationArea = NPRRetail;
                }
                field("Lock Timeout"; Rec."Lock Timeout")
                {
                    ToolTip = 'Specifies the timeout to use before a POS unit is automatically locked';
                    ApplicationArea = NPRRetail;
                }
                field("Unlock Password"; Rec."Unlock Password")
                {
                    ToolTip = 'Specifies the password for unlocking POS units';
                    ExtendedDatatype = Masked;
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
