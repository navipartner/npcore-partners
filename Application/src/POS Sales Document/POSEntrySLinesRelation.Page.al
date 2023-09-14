page 6151263 "NPR POS Entry S.Lines Relation"
{
    Extensible = False;

    Caption = 'POS Entry Sale Document Lines Relation';
    PageType = List;
    SourceTable = "NPR POS Entry S.Line Relation";
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.';
                    ApplicationArea = NPRRetail;
                }
                field("Sale Document No."; Rec."Sale Document No.")
                {
                    ToolTip = 'Specifies the value of the Sale Document No. field.';
                    ApplicationArea = NPRRetail;
                }
                field("Sale Line No."; Rec."Sale Line No.")
                {
                    ToolTip = 'Specifies the value of the Sale Line No. field.';
                    ApplicationArea = NPRRetail;
                }

            }
        }
    }
}
