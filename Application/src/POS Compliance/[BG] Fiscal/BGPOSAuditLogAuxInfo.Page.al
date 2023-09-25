page 6151268 "NPR BG POS Audit Log Aux. Info"
{
    ApplicationArea = NPRBGFiscal;
    Caption = 'BG POS Audit Log Aux. Info';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR BG POS Audit Log Aux. Info";
    SourceTableView = sorting("Audit Entry No.") order(descending);
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Audit Entry Type"; Rec."Audit Entry Type")
                {
                    ApplicationArea = NPRBGFiscal;
                    ToolTip = 'Specifies the value of the Audit Entry Type field.';
                }
                field("Audit Entry No."; Rec."Audit Entry No.")
                {
                    ApplicationArea = NPRBGFiscal;
                    ToolTip = 'Specifies the value of the Audit Entry No. field.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRBGFiscal;
                    ToolTip = 'Specifies the value of the POS Entry record related to this record.';
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = NPRBGFiscal;
                    ToolTip = 'Specifies the entry date value.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRBGFiscal;
                    ToolTip = 'Specifies the POS store code value.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRBGFiscal;
                    ToolTip = 'Specifies the POS unit number value.';
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = NPRBGFiscal;
                    ToolTip = 'Specifies the value of the Source Document No. field.';
                }
            }
        }
    }
}
