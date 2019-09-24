page 6151169 "NpGp POS Sales Lines"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'Global POS Sales Lines';
    Editable = false;
    PageType = List;
    SourceTable = "NpGp POS Sales Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Store Code";"POS Store Code")
                {
                }
                field("POS Unit No.";"POS Unit No.")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field(Type;Type)
                {
                }
                field("No.";"No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field("Cross-Reference No.";"Cross-Reference No.")
                {
                }
                field("BOM Item No.";"BOM Item No.")
                {
                }
                field("Location Code";"Location Code")
                {
                }
                field(Description;Description)
                {
                }
                field("Description 2";"Description 2")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                }
                field("Qty. per Unit of Measure";"Qty. per Unit of Measure")
                {
                }
                field("Quantity (Base)";"Quantity (Base)")
                {
                }
                field("Unit Price";"Unit Price")
                {
                }
                field("Currency Code";"Currency Code")
                {
                }
                field("VAT %";"VAT %")
                {
                }
                field("Line Discount %";"Line Discount %")
                {
                }
                field("Line Discount Amount Excl. VAT";"Line Discount Amount Excl. VAT")
                {
                }
                field("Line Discount Amount Incl. VAT";"Line Discount Amount Incl. VAT")
                {
                }
                field("Line Amount";"Line Amount")
                {
                }
                field("Amount Excl. VAT";"Amount Excl. VAT")
                {
                }
                field("Amount Incl. VAT";"Amount Incl. VAT")
                {
                }
                field("Line Dsc. Amt. Excl. VAT (LCY)";"Line Dsc. Amt. Excl. VAT (LCY)")
                {
                }
                field("Line Dsc. Amt. Incl. VAT (LCY)";"Line Dsc. Amt. Incl. VAT (LCY)")
                {
                }
                field("Amount Excl. VAT (LCY)";"Amount Excl. VAT (LCY)")
                {
                }
                field("Amount Incl. VAT (LCY)";"Amount Incl. VAT (LCY)")
                {
                }
                field("POS Entry No.";"POS Entry No.")
                {
                }
                field("Line No.";"Line No.")
                {
                }
                field("Retail ID";"Retail ID")
                {
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
                RunObject = Page "NpGp Detailed POS S. Entries";
                RunPageLink = "POS Entry No."=FIELD("POS Entry No."),
                              "POS Sales Line No."=FIELD("Line No.");
                ShortCutKey = 'Ctrl+F7';
            }
            action("POS Info")
            {
                Caption = 'POS Info';
                Image = List;
                RunObject = Page "NpGp POS Info POS Entry";
                //RunPageLink = "POS Entry No."=FIELD("POS Entry No."),
                //              "Sales Line No."=FIELD("Line No.");
            }
        }
    }
}

