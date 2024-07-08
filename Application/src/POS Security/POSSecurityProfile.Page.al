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
                    ToolTip = 'Specifies unique code for POS security profile';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the name of POS security profile';
                    ApplicationArea = NPRRetail;
                }
                field("Password on Unblock Discount"; Rec."Password on Unblock Discount")
                {
                    ToolTip = 'Specifies the Administrator Password value.';
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
                field("POS Buttons Refresh Time"; Rec."POS Buttons Refresh Time")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the time interval of how often POS buttons data will be refreshed';
                }
            }
        }
    }
}
