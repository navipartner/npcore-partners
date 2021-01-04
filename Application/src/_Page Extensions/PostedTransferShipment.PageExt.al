pageextension 6014465 "NPR Posted Transfer Shipment" extends "Posted Transfer Shipment"
{
    // NPR5.46/EMGO/20180910 CASE 324737 Added Page Actions RetailPrint and PriceLabel
    // NPR5.46/JDH /20181002 CASE 294354 Removed code on RetailPrint and PriceLabel. Made them publishers so its the same functionality all around our solution
    actions
    {
        addafter("&Navigate")
        {
            action("NPR RetailPrint")
            {
                Caption = 'Retail Print';
                Ellipsis = true;
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Executes the Retail Print action';
            }
            action("NPR PriceLabel")
            {
                Caption = 'Price Label';
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Price Label action';
            }
        }
    }

    var
        LabelLibrarySubMgt: Codeunit "NPR Label Library Sub. Mgt.";
}

