page 6014667 "Stock-Take Template Card"
{
    // NPR4.16/TS/20150525 CASE 213313 Page Created

    Caption = 'Stock-Take Template Card';
    PageType = Card;
    SourceTable = "Stock-Take Template";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
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
                field("Counting Method"; "Counting Method")
                {
                    ApplicationArea = All;
                }
                field("Suggested Unit Cost Source"; "Suggested Unit Cost Source")
                {
                    ApplicationArea = All;
                }
                field("Transfer Action"; "Transfer Action")
                {
                    ApplicationArea = All;
                }
                field("Aggregation Level"; "Aggregation Level")
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
                field("Data Release"; "Data Release")
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
                field("Allow Unit Cost Change"; "Allow Unit Cost Change")
                {
                    ApplicationArea = All;
                }
            }
            group(Scope)
            {
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
            }
            group(Transfer)
            {
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
                field("Items Out-of-Scope"; "Items Out-of-Scope")
                {
                    ApplicationArea = All;
                }
                field("Suppress Not Counted"; "Suppress Not Counted")
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
                field("Blocked Item"; "Blocked Item")
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
            group(ActionGroup6150643)
            {
                action("Create Default Templates")
                {
                    Caption = 'Create Default Templates';
                    Ellipsis = true;
                    Image = CreateInteraction;

                    trigger OnAction()
                    begin
                        PhysInvMgr.CreateDefaultTemplates();
                    end;
                }
            }
        }
    }

    var
        PhysInvMgr: Codeunit "Stock-Take Manager";
}

