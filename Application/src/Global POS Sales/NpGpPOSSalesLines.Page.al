page 6151169 "NPR NpGp POS Sales Lines"
{
    Caption = 'Global POS Sales Lines';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR NpGp POS Sales Line";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Store Code"; Rec."POS Store Code")
                {

                    ToolTip = 'Specifies the value of the POS Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Reference No."; Rec."Cross-Reference No.")
                {

                    ToolTip = 'Specifies the value of the Cross-Reference No. field';
                    ApplicationArea = NPRRetail;
                }
                field("BOM Item No."; Rec."BOM Item No.")
                {

                    ToolTip = 'Specifies the value of the BOM Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2"; Rec."Description 2")
                {

                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {

                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {

                    ToolTip = 'Specifies the value of the Qty. per Unit of Measure field';
                    ApplicationArea = NPRRetail;
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {

                    ToolTip = 'Specifies the value of the Quantity (Base) field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {

                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {

                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("VAT %"; Rec."VAT %")
                {

                    ToolTip = 'Specifies the value of the VAT % field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {

                    ToolTip = 'Specifies the value of the Line Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Discount Amount Excl. VAT"; Rec."Line Discount Amount Excl. VAT")
                {

                    ToolTip = 'Specifies the value of the Line Discount Amount Excl. VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Discount Amount Incl. VAT"; Rec."Line Discount Amount Incl. VAT")
                {

                    ToolTip = 'Specifies the value of the Line Discount Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Amount"; Rec."Line Amount")
                {

                    ToolTip = 'Specifies the value of the Line Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Excl. VAT"; Rec."Amount Excl. VAT")
                {

                    ToolTip = 'Specifies the value of the Amount Excl. VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Incl. VAT"; Rec."Amount Incl. VAT")
                {

                    ToolTip = 'Specifies the value of the Amount Incl. VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Dsc. Amt. Excl. VAT (LCY)"; Rec."Line Dsc. Amt. Excl. VAT (LCY)")
                {

                    ToolTip = 'Specifies the value of the Line Dsc. Amt. Excl. VAT (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Dsc. Amt. Incl. VAT (LCY)"; Rec."Line Dsc. Amt. Incl. VAT (LCY)")
                {

                    ToolTip = 'Specifies the value of the Line Dsc. Amt. Incl. VAT (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Excl. VAT (LCY)"; Rec."Amount Excl. VAT (LCY)")
                {

                    ToolTip = 'Specifies the value of the Amount Excl. VAT (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Incl. VAT (LCY)"; Rec."Amount Incl. VAT (LCY)")
                {

                    ToolTip = 'Specifies the value of the Amount Incl. VAT (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {

                    ToolTip = 'Specifies the value of the POS Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("System Id"; Rec.SystemId)
                {

                    ToolTip = 'Specifies the value of the System Id field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Detailed Global POS Sales Entries action';
                ApplicationArea = NPRRetail;
            }
            action("POS Info")
            {
                Caption = 'POS Info';
                Image = List;
                RunObject = Page "NPR NpGp POS Info POS Entry";

                ToolTip = 'Executes the POS Info action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

