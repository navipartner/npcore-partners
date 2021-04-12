page 6151168 "NPR NpGp POSSalesEntry Subpage"
{
    Caption = 'Sales Lines';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpGp POS Sales Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Item Reference No."; Rec."Cross-Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cross-Reference No. field';
                }
                field("BOM Item No."; Rec."BOM Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the BOM Item No. field';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 2 field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. per Unit of Measure field';
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity (Base) field';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT % field';
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Discount % field';
                }
                field("Line Discount Amount Excl. VAT"; Rec."Line Discount Amount Excl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Discount Amount Excl. VAT field';
                }
                field("Line Discount Amount Incl. VAT"; Rec."Line Discount Amount Incl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Discount Amount field';
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Amount field';
                }
                field("Amount Excl. VAT"; Rec."Amount Excl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Excl. VAT field';
                }
                field("Amount Incl. VAT"; Rec."Amount Incl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Incl. VAT field';
                }
                field("Line Dsc. Amt. Excl. VAT (LCY)"; Rec."Line Dsc. Amt. Excl. VAT (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Dsc. Amt. Excl. VAT (LCY) field';
                }
                field("Line Dsc. Amt. Incl. VAT (LCY)"; Rec."Line Dsc. Amt. Incl. VAT (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Dsc. Amt. Incl. VAT (LCY) field';
                }
                field("Amount Excl. VAT (LCY)"; Rec."Amount Excl. VAT (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Excl. VAT (LCY) field';
                }
                field("Amount Incl. VAT (LCY)"; Rec."Amount Incl. VAT (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Incl. VAT (LCY) field';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Retail ID"; Rec."Retail ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Retail ID field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Detailed Global POS Sales Entries")
            {
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
            }
        }
    }
}

