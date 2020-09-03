page 6014475 "NPR Retail Price Log Entries"
{
    // NPR5.40/MHA /20180316  CASE 304031 Object created

    Caption = 'Retail Price Log Entries';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Retail Price Log Entry";
    SourceTableView = SORTING("Date and Time");
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Date and Time"; "Date and Time")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Date"; Date)
                {
                    ApplicationArea = All;
                }
                field("Time"; Time)
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Change Log Entry No."; "Change Log Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
                field("Table Caption"; "Table Caption")
                {
                    ApplicationArea = All;
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                }
                field("Field Caption"; "Field Caption")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Old Value"; "Old Value")
                {
                    ApplicationArea = All;
                }
                field("New Value"; "New Value")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Update Price Log")
            {
                AccessByPermission = TableData "Change Log Entry" = R;
                Caption = 'Update Price Log';
                Image = RefreshLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    RetailPriceLogMgt: Codeunit "NPR Retail Price Log Mgt.";
                begin
                    RetailPriceLogMgt.UpdatePriceLog();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}

