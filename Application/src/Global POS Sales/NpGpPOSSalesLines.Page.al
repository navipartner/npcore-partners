page 6151169 "NPR NpGp POS Sales Lines"
{
    Caption = 'Global POS Sales Lines';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR NpGp POS Sales Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Store Code"; "POS Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                }
                field("POS Unit No."; "POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Cross-Reference No."; "Cross-Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cross-Reference No. field';
                }
                field("BOM Item No."; "BOM Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the BOM Item No. field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 2 field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                }
                field("Qty. per Unit of Measure"; "Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. per Unit of Measure field';
                }
                field("Quantity (Base)"; "Quantity (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity (Base) field';
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("VAT %"; "VAT %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT % field';
                }
                field("Line Discount %"; "Line Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Discount % field';
                }
                field("Line Discount Amount Excl. VAT"; "Line Discount Amount Excl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Discount Amount Excl. VAT field';
                }
                field("Line Discount Amount Incl. VAT"; "Line Discount Amount Incl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Discount Amount field';
                }
                field("Line Amount"; "Line Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Amount field';
                }
                field("Amount Excl. VAT"; "Amount Excl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Excl. VAT field';
                }
                field("Amount Incl. VAT"; "Amount Incl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Incl. VAT field';
                }
                field("Line Dsc. Amt. Excl. VAT (LCY)"; "Line Dsc. Amt. Excl. VAT (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Dsc. Amt. Excl. VAT (LCY) field';
                }
                field("Line Dsc. Amt. Incl. VAT (LCY)"; "Line Dsc. Amt. Incl. VAT (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Dsc. Amt. Incl. VAT (LCY) field';
                }
                field("Amount Excl. VAT (LCY)"; "Amount Excl. VAT (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Excl. VAT (LCY) field';
                }
                field("Amount Incl. VAT (LCY)"; "Amount Incl. VAT (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Incl. VAT (LCY) field';
                }
                field("POS Entry No."; "POS Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Entry No. field';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Retail ID"; "Retail ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Retail ID field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Detailed Global POS Sales Entries")
            {
                Caption = 'Detailed Global POS Sales Entries';
                Image = List;
                RunObject = Page "NPR NpGp Det. POS S. Entries";
                RunPageLink = "POS Entry No." = FIELD("POS Entry No."),
                              "POS Sales Line No." = FIELD("Line No.");
                ShortCutKey = 'Ctrl+F7';
                ApplicationArea = All;
                ToolTip = 'Executes the Detailed Global POS Sales Entries action';
            }
            action("POS Info")
            {
                Caption = 'POS Info';
                Image = List;
                RunObject = Page "NPR NpGp POS Info POS Entry";
                ApplicationArea = All;
                ToolTip = 'Executes the POS Info action';
                //RunPageLink = "POS Entry No."=FIELD("POS Entry No."),
                //              "Sales Line No."=FIELD("Line No.");
            }
        }
    }
}

