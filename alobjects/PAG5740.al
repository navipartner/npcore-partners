pageextension 6014457 pageextension6014457 extends "Transfer Order" 
{
    // NPR4.04/TS/20150218 CASE 206013 Added Function Read from Scanner
    // NPR4.18/TS/20151109 CASE 222241 Added Action Import From Text
    // NPR5.22/TJ/20160414 CASE 238601 Moved code from funcions Read From Scanner and Import From Text to NPR Event Subscriber codeunit
    // NPR5.27/MMV /20161024 CASE 256178 Added support for retail prints.
    // NPR5.30/TJ  /20170202 CASE 262533 Removed actions Labels and Invert selection. Instead added actions Retail Print and Price Label
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
            }
            action(PriceLabel)
            {
                Caption = 'Price Label';
                Image = BinContent;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            }
        }
        addfirst("F&unctions")
        {
            action("Import From Scanner File")
            {
                Caption = 'Import From Scanner File';
                Image = Import;
                Promoted = true;
            }
        }
        addafter("Get Bin Content")
        {
            action("&Read from scanner")
            {
                Caption = '&Read from scanner';
                Promoted = true;
                PromotedCategory = Process;
            }
        }
    }
}

