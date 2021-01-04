page 6014668 "NPR Stock-Take Config. Card"
{
    // NPR4.16/TS/20150527 CASE213313  Page Created
    // NPR5.51/TSA /20190722 CASE 359375 Added field "Keep Worksheets"

    Caption = 'Stock-Take Configuration Card';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR Stock-Take Configuration";

    layout
    {
        area(content)
        {
            group(General)
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
                field("Stock-Take Template Code"; "Stock-Take Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Stock-Take Template Code field';
                }
                field("Inventory Calc. Date"; "Inventory Calc. Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Stock-Take Calc. Date field';
                }
                field("Stock Take Method"; "Stock Take Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Stock Take Method field';
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
                field("Transfer Action"; "Transfer Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transfer Action field';
                }
                field("Aggregation Level"; "Aggregation Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Aggregation Level field';
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
                group(Control6014401)
                {
                    ShowCaption = false;
                    field("Data Release"; "Data Release")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Data Release field';
                    }
                    field("Keep Worksheets"; "Keep Worksheets")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Keep Worksheets field';
                    }
                }
                field("Allow User Modification"; "Allow User Modification")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow User Modification field';
                }
                field("Allow Unit Cost Change"; "Allow Unit Cost Change")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Unit Cost Change field';
                }
            }
            group(Scope)
            {
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
            }
            group(Transfer)
            {
                field("Adjustment Method"; "Adjustment Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Adjustment Method field';
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
                field("Suppress Not Counted"; "Suppress Not Counted")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Suppress Not Counted field';
                }
                field("Barcode Not Accepted"; "Barcode Not Accepted")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Barcode Not Accepted field';
                }
                field("Blocked Item"; "Blocked Item")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked Item field';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Dimensions action';

                    trigger OnAction()
                    var
                        NPRDimMgt: Codeunit "NPR Dimension Mgt.";
                    begin
                    end;
                }
            }
        }
    }
}

