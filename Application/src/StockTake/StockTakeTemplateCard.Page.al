page 6014667 "NPR Stock-Take Template Card"
{
    // NPR4.16/TS/20150525 CASE 213313 Page Created

    Caption = 'Stock-Take Template Card';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR Stock-Take Template";

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
                field("Data Release"; "Data Release")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Release field';
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
                field("Suppress Not Counted"; "Suppress Not Counted")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Suppress Not Counted field';
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
            group(ActionGroup6150643)
            {
                action("Create Default Templates")
                {
                    Caption = 'Create Default Templates';
                    Ellipsis = true;
                    Image = CreateInteraction;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create Default Templates action';

                    trigger OnAction()
                    begin
                        PhysInvMgr.CreateDefaultTemplates();
                    end;
                }
            }
        }
    }

    var
        PhysInvMgr: Codeunit "NPR Stock-Take Manager";
}

