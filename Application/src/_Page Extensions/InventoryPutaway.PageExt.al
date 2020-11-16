pageextension 6014479 "NPR Inventory Put-away" extends "Inventory Put-away"
{
    // NPR5.48/TS  /20181214  CASE 339845 Added Field Assigned User Id
    // NPR5.55/BHR /20200713  CASE 414268 Print Label
    layout
    {
        addafter("External Document No.2")
        {
            field("NPR Assigned User ID"; "Assigned User ID")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter("&Print")
        {
            action("NPR RetailPrint")
            {
                Caption = 'Retail Print';
                Ellipsis = true;
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    //-+NPR5.55 [414268]
                end;
            }
            action("NPR PriceLabel")
            {
                Caption = 'Price Label';
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+Ctrl+L';
                ApplicationArea = All;

                trigger OnAction()
                begin
                    //-+NPR5.55 [414268]
                end;
            }
        }
    }
}

