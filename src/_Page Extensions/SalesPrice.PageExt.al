pageextension 6014475 "NPR Sales Price" extends "Sales Prices"
{
    // VRT1.00/JDH/20150304 CASE 201022 Show Variety Matrix
    // NPR5.22/TJ/20160411 CASE 238601 Moved code from Variety function to NPR Event Subscriber codeunit
    // NPR5.31/JDH /20170502 CASE 271133 Image added + action promoted
    actions
    {
        addafter(ClearFilter)
        {
            group("NPR Variants")
            {
                Caption = 'Variants';
            }
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+Alt+V';
                ApplicationArea=All;
            }
        }
    }
}

