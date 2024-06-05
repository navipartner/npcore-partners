page 6184664 "NPR POS Entry Waiter Pad Links"
{
    Extensible = False;
    Caption = 'POS Entry - Waiter Pad Links';
    Editable = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR POS Entry Waiter Pad Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ToolTip = 'Specifies the POS entry number the link is created for.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Entry Sales Line No."; Rec."POS Entry Sales Line No.")
                {
                    ToolTip = 'Specifies the POS entry sales line number the link is created for.';
                    ApplicationArea = NPRRetail;
                }
                field("Waiter Pad No."; Rec."Waiter Pad No.")
                {
                    ToolTip = 'Specifies the waiter pad number the link is created for.';
                    ApplicationArea = NPRRetail;
                }
                field("Waiter Pad Line No."; Rec."Waiter Pad Line No.")
                {
                    ToolTip = 'Specifies the waiter pad line number the link is created for.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
