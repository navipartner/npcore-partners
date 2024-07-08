page 6151324 "NPR DK POS Audit Log Aux. Info"
{
    ApplicationArea = NPRDKFiscal;
    Caption = 'DK POS Audit Log Aux. Info';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR DK POS Audit Log Aux. Info";
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
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the Audit Entry Type of the transaction.';
                }
                field("Audit Entry No."; Rec."Audit Entry No.")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the Audit Entry No. of the transaction.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the POS Entry record related to the transaction.';
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the transaction date.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the POS store from which the transacion is created.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the POS unit number from which the transaction is created.';
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the Source Document Number.';
                }
            }
        }
    }
}
