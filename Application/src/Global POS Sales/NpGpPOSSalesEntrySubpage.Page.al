page 6151168 "NPR NpGp POSSalesEntry Subpage"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'Sales Lines';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR NpGp POS Sales Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Cross-Reference No."; "Cross-Reference No.")
                {
                    ApplicationArea = All;
                }
                field("BOM Item No."; "BOM Item No.")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Qty. per Unit of Measure"; "Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Quantity (Base)"; "Quantity (Base)")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field("VAT %"; "VAT %")
                {
                    ApplicationArea = All;
                }
                field("Line Discount %"; "Line Discount %")
                {
                    ApplicationArea = All;
                }
                field("Line Discount Amount Excl. VAT"; "Line Discount Amount Excl. VAT")
                {
                    ApplicationArea = All;
                }
                field("Line Discount Amount Incl. VAT"; "Line Discount Amount Incl. VAT")
                {
                    ApplicationArea = All;
                }
                field("Line Amount"; "Line Amount")
                {
                    ApplicationArea = All;
                }
                field("Amount Excl. VAT"; "Amount Excl. VAT")
                {
                    ApplicationArea = All;
                }
                field("Amount Incl. VAT"; "Amount Incl. VAT")
                {
                    ApplicationArea = All;
                }
                field("Line Dsc. Amt. Excl. VAT (LCY)"; "Line Dsc. Amt. Excl. VAT (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Line Dsc. Amt. Incl. VAT (LCY)"; "Line Dsc. Amt. Incl. VAT (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Amount Excl. VAT (LCY)"; "Amount Excl. VAT (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Amount Incl. VAT (LCY)"; "Amount Incl. VAT (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                }
                field("Retail ID"; "Retail ID")
                {
                    ApplicationArea = All;
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
            }
            action("POS Info")
            {
                Caption = 'POS Info';
                Image = List;
                RunObject = Page "NPR NpGp POS Info POS Entry";
                ApplicationArea = All;
                //RunPageLink = "POS Entry No."=FIELD("POS Entry No."),
                //              "Sales Line No."=FIELD("Line No.");
            }
        }
    }
}

