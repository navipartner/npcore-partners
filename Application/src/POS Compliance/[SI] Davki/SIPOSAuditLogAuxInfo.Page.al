page 6150768 "NPR SI POS Audit Log Aux. Info"
{
    ApplicationArea = NPRSIFiscal;
    Caption = 'SI POS Audit Log Aux. Info';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR SI POS Audit Log Aux. Info";
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
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Audit Entry Type field.';
                }
                field("Audit Entry No."; Rec."Audit Entry No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Audit Entry No. field.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the POS Entry record related to this record.';
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the entry date value.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the POS store code value.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the POS unit number value.';
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the value of the Source Document No. field.';
                }
            }
        }
    }
}
