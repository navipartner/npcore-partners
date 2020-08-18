pageextension 6014479 pageextension6014479 extends "Inventory Put-away" 
{
    // NPR5.48/TS  /20181214  CASE 339845 Added Field Assigned User Id
    // NPR5.55/BHR /20200713  CASE 414268 Print Label
    layout
    {
        addafter("External Document No.2")
        {
            field("Assigned User ID";"Assigned User ID")
            {
            }
        }
    }
    actions
    {
        addafter("&Print")
        {
            action(RetailPrint)
            {
                Caption = 'Retail Print';
                Ellipsis = true;
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    //-+NPR5.55 [414268]
                end;
            }
            action(PriceLabel)
            {
                Caption = 'Price Label';
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+Ctrl+L';

                trigger OnAction()
                begin
                    //-+NPR5.55 [414268]
                end;
            }
        }
    }
}

