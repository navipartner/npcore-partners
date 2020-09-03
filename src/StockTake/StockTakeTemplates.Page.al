page 6014666 "NPR Stock-Take Templates"
{
    // NPR4.16/TS/20150525 CASE 213313 Page Created

    Caption = 'Stock-Take Templates';
    CardPageID = "NPR Stock-Take Template Card";
    PageType = List;
    SourceTable = "NPR Stock-Take Template";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("Item Group Filter"; "Item Group Filter")
                {
                    ApplicationArea = All;
                }
                field("Vendor Code Filter"; "Vendor Code Filter")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Session Based Loading"; "Session Based Loading")
                {
                    ApplicationArea = All;
                }
                field("Session Based Transfer"; "Session Based Transfer")
                {
                    ApplicationArea = All;
                }
                field("Aggregation Level"; "Aggregation Level")
                {
                    ApplicationArea = All;
                }
                field("Data Release"; "Data Release")
                {
                    ApplicationArea = All;
                }
                field("Transfer Action"; "Transfer Action")
                {
                    ApplicationArea = All;
                }
                field("Defaul Profile"; "Defaul Profile")
                {
                    ApplicationArea = All;
                }
                field("Allow User Modification"; "Allow User Modification")
                {
                    ApplicationArea = All;
                }
                field("Items Out-of-Scope"; "Items Out-of-Scope")
                {
                    ApplicationArea = All;
                }
                field("Items in Scope Not Counted"; "Items in Scope Not Counted")
                {
                    ApplicationArea = All;
                }
                field("Barcode Not Accepted"; "Barcode Not Accepted")
                {
                    ApplicationArea = All;
                }
                field("Counting Method"; "Counting Method")
                {
                    ApplicationArea = All;
                }
                field("Suggested Unit Cost Source"; "Suggested Unit Cost Source")
                {
                    ApplicationArea = All;
                }
                field("Allow Unit Cost Change"; "Allow Unit Cost Change")
                {
                    ApplicationArea = All;
                }
                field("Item Journal Template Name"; "Item Journal Template Name")
                {
                    ApplicationArea = All;
                }
                field("Item Journal Batch Name"; "Item Journal Batch Name")
                {
                    ApplicationArea = All;
                }
                field("Item Journal Batch Usage"; "Item Journal Batch Usage")
                {
                    ApplicationArea = All;
                }
                field("Blocked Item"; "Blocked Item")
                {
                    ApplicationArea = All;
                }
                field("Suppress Not Counted"; "Suppress Not Counted")
                {
                    ApplicationArea = All;
                }
                field("Stock Take Method"; "Stock Take Method")
                {
                    ApplicationArea = All;
                }
                field("Adjustment Method"; "Adjustment Method")
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
            group(Functions)
            {
                Caption = 'Functions';
            }
            action(Card)
            {
                Caption = 'Card';
                Image = Card;
                Promoted = true;
                RunObject = Page "NPR Stock-Take Template Card";
                RunPageLink = Code = FIELD(Code);
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
                    StockTakeMgr: Codeunit "NPR Stock-Take Manager";
                begin
                    StockTakeMgr.CreateDefaultTemplates();
                end;
            }
        }
        area(navigation)
        {
            action(Configurations)
            {
                Caption = 'Configurations';
                Image = Components;
                RunObject = Page "NPR Stock-Take Configs";
                RunPageLink = "Stock-Take Template Code" = FIELD(Code);
            }
        }
    }
}

