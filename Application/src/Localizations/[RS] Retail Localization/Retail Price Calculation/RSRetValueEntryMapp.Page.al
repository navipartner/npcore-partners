page 6184587 "NPR RS Ret. Value Entry Mapp."
{
    ApplicationArea = NPRRSRLocal;
    Caption = 'RS Retail Value Entry Mappings';
    PageType = List;
    SourceTable = "NPR RS Ret. Value Entry Mapp.";
    UsageCategory = Lists;
    Editable = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("Item Ledger Entry Type"; Rec."Item Ledger Entry Type")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Item Ledger Entry Type field.';
                }
                field("Item Ledger Entry No."; Rec."Item Ledger Entry No.")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Item Ledger Entry No. field.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Location Code field.';
                }
                field("Retail Calculation"; Rec."Retail Calculation")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Retail Calculation field.';
                }
                field(Nivelation; Rec.Nivelation)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Nivelation field.';
                }
                field("COGS Correction"; Rec."COGS Correction")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the COGS Correction field.';
                }
                field("Standard Correction"; Rec."Standard Correction")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Standard Correction field.';
                }
                field(Open; Rec.Open)
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Open field.';
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = NPRRSRLocal;
                    ToolTip = 'Specifies the value of the Remaining Quantity field.';
                }
            }
        }
    }
}