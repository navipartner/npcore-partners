page 6014666 "Stock-Take Templates"
{
    // NPR4.16/TS/20150525 CASE 213313 Page Created

    Caption = 'Stock-Take Templates';
    CardPageID = "Stock-Take Template Card";
    PageType = List;
    SourceTable = "Stock-Take Template";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Location Code";"Location Code")
                {
                }
                field("Item Group Filter";"Item Group Filter")
                {
                }
                field("Vendor Code Filter";"Vendor Code Filter")
                {
                }
                field("Global Dimension 1 Code";"Global Dimension 1 Code")
                {
                }
                field("Global Dimension 2 Code";"Global Dimension 2 Code")
                {
                }
                field("Session Based Loading";"Session Based Loading")
                {
                }
                field("Session Based Transfer";"Session Based Transfer")
                {
                }
                field("Aggregation Level";"Aggregation Level")
                {
                }
                field("Data Release";"Data Release")
                {
                }
                field("Transfer Action";"Transfer Action")
                {
                }
                field("Defaul Profile";"Defaul Profile")
                {
                }
                field("Allow User Modification";"Allow User Modification")
                {
                }
                field("Items Out-of-Scope";"Items Out-of-Scope")
                {
                }
                field("Items in Scope Not Counted";"Items in Scope Not Counted")
                {
                }
                field("Barcode Not Accepted";"Barcode Not Accepted")
                {
                }
                field("Counting Method";"Counting Method")
                {
                }
                field("Suggested Unit Cost Source";"Suggested Unit Cost Source")
                {
                }
                field("Allow Unit Cost Change";"Allow Unit Cost Change")
                {
                }
                field("Item Journal Template Name";"Item Journal Template Name")
                {
                }
                field("Item Journal Batch Name";"Item Journal Batch Name")
                {
                }
                field("Item Journal Batch Usage";"Item Journal Batch Usage")
                {
                }
                field("Blocked Item";"Blocked Item")
                {
                }
                field("Suppress Not Counted";"Suppress Not Counted")
                {
                }
                field("Stock Take Method";"Stock Take Method")
                {
                }
                field("Adjustment Method";"Adjustment Method")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Functions';
            }
            action(Card)
            {
                Caption = 'Card';
                Image = Card;
                Promoted = true;
                RunObject = Page "Stock-Take Template Card";
                RunPageLink = Code=FIELD(Code);
                ShortCutKey = 'Shift+F5';
            }
            action(CreateDefaultTemplates)
            {
                Caption = 'Create Default Templates';
                Image = Template;
                Promoted = true;
                PromotedIsBig = true;
                RunPageMode = View;

                trigger OnAction()
                var
                    StockTakeMgr: Codeunit "Stock-Take Manager";
                begin
                    StockTakeMgr.CreateDefaultTemplates ();
                end;
            }
        }
        area(navigation)
        {
            action(Configurations)
            {
                Caption = 'Configurations';
                Image = Components;
                RunObject = Page "Stock-Take Configurations";
                RunPageLink = "Stock-Take Template Code"=FIELD(Code);
            }
        }
    }
}

