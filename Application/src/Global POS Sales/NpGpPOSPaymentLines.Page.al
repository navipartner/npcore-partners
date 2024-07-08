page 6150810 "NPR NpGp POS Payment Lines"
{
    Caption = 'Global POS Payment Lines';
    PageType = List;
    SourceTable = "NPR NpGp POS Payment Line";
    UsageCategory = None;
    Editable = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {
                    ToolTip = 'Specifies the value of the POS Payment Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Amount"; Rec."Payment Amount")
                {
                    ToolTip = 'Specifies the value of the Payment Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ToolTip = 'Specifies the value of the Amount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ToolTip = 'Specifies the value of the POS Entry No. field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            action(POSSalesEntryCard)
            {
                Caption = 'POS Entry Card';
                Image = Card;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = page "NPR NpGp POS Sales Entry Card";
                RunPageLink = "Entry No." = field("POS Entry No.");
                ToolTip = 'Opens the Sales Entry Card with the full sale';
                ApplicationArea = NPRRetail;
            }
        }
    }
}
