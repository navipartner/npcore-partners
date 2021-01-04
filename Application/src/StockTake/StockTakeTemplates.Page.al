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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Item Group Filter"; "Item Group Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Group Filter field';
                }
                field("Vendor Code Filter"; "Vendor Code Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Code Filter field';
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
                field("Session Based Loading"; "Session Based Loading")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Session Based Loading field';
                }
                field("Session Based Transfer"; "Session Based Transfer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Session Based Transfer field';
                }
                field("Aggregation Level"; "Aggregation Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Aggregation Level field';
                }
                field("Data Release"; "Data Release")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Release field';
                }
                field("Transfer Action"; "Transfer Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transfer Action field';
                }
                field("Defaul Profile"; "Defaul Profile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Profile field';
                }
                field("Allow User Modification"; "Allow User Modification")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow User Modification field';
                }
                field("Items Out-of-Scope"; "Items Out-of-Scope")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Items Out-of-Scope field';
                }
                field("Items in Scope Not Counted"; "Items in Scope Not Counted")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Items in Scope Not Counted field';
                }
                field("Barcode Not Accepted"; "Barcode Not Accepted")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Barcode Not Accepted field';
                }
                field("Counting Method"; "Counting Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Counting Method field';
                }
                field("Suggested Unit Cost Source"; "Suggested Unit Cost Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Suggested Unit Cost Source field';
                }
                field("Allow Unit Cost Change"; "Allow Unit Cost Change")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Unit Cost Change field';
                }
                field("Item Journal Template Name"; "Item Journal Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Journal Template Name field';
                }
                field("Item Journal Batch Name"; "Item Journal Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Journal Batch Name field';
                }
                field("Item Journal Batch Usage"; "Item Journal Batch Usage")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Journal Batch Usage field';
                }
                field("Blocked Item"; "Blocked Item")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked Item field';
                }
                field("Suppress Not Counted"; "Suppress Not Counted")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Suppress Not Counted field';
                }
                field("Stock Take Method"; "Stock Take Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Stock Take Method field';
                }
                field("Adjustment Method"; "Adjustment Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Adjustment Method field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Card action';
            }
            action(CreateDefaultTemplates)
            {
                Caption = 'Create Default Templates';
                Image = Template;
                Promoted = true;
                PromotedIsBig = true;
                RunPageMode = View;
                ApplicationArea = All;
                ToolTip = 'Executes the Create Default Templates action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Configurations action';
            }
        }
    }
}

