page 6014668 "Stock-Take Configuration Card"
{
    // NPR4.16/TS/20150527 CASE213313  Page Created
    // NPR5.51/TSA /20190722 CASE 359375 Added field "Keep Worksheets"

    Caption = 'Stock-Take Configuration Card';
    PageType = Card;
    SourceTable = "Stock-Take Configuration";

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
                field("Stock-Take Template Code"; "Stock-Take Template Code")
                {
                    ApplicationArea = All;
                }
                field("Inventory Calc. Date"; "Inventory Calc. Date")
                {
                    ApplicationArea = All;
                }
                field("Stock Take Method"; "Stock Take Method")
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
                group(Control6014401)
                {
                    ShowCaption = false;
                    field("Data Release"; "Data Release")
                    {
                        ApplicationArea = All;
                    }
                    field("Keep Worksheets"; "Keep Worksheets")
                    {
                        ApplicationArea = All;
                    }
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
                field("Adjustment Method"; "Adjustment Method")
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
                field("Items Out-of-Scope"; "Items Out-of-Scope")
                {
                    ApplicationArea = All;
                }
                field("Items in Scope Not Counted"; "Items in Scope Not Counted")
                {
                    ApplicationArea = All;
                }
                field("Suppress Not Counted"; "Suppress Not Counted")
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
            group(Configuration)
            {
                Caption = 'Configuration';
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = CONST(6014665),
                                  "No." = FIELD(Code);
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    var
                        NPRDimMgt: Codeunit NPRDimensionManagement;
                    begin
                    end;
                }
            }
        }
    }
}

