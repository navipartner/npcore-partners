page 6059990 "NPR Item Repair Action"
{
    // VRT1.20/JDH /20170106 CASE 251896 TestTool to analyse and fix Variants
    // NPR5.48/JDH /20181109 CASE 334163 Added Action Captions and object caption
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Item Repair Action';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Item Repair Action";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Item Ledger Entry Qty."; "Item Ledger Entry Qty.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Ledger Entry Qty. field';
                }
                field("No. Of tests"; "No. Of tests")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Of tests field';
                }
                field("No.Of Errors"; "No.Of Errors")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No.Of Errors field';
                }
                field("Variant Action"; "Variant Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Action field';
                }
                field("Variety 1 Action"; "Variety 1 Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 1 Action field';
                }
                field("Variety 2 Action"; "Variety 2 Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 2 Action field';
                }
                field("Variety 3 Action"; "Variety 3 Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 3 Action field';
                }
                field("Variety 4 Action"; "Variety 4 Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 4 Action field';
                }
                field("New Variety 1"; "New Variety 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Variety 1 field';
                }
                field("New Variety 1 Table"; "New Variety 1 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Variety 1 Table field';
                }
                field("New Variety 1 Value"; "New Variety 1 Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Variety 1 Value field';
                }
                field("New Variety 2"; "New Variety 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Variety 2 field';
                }
                field("New Variety 2 Table"; "New Variety 2 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Variety 2 Table field';
                }
                field("New Variety 2 Value"; "New Variety 2 Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Variety 2 Value field';
                }
                field("New Variety 3"; "New Variety 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Variety 3 field';
                }
                field("New Variety 3 Table"; "New Variety 3 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Variety 3 Table field';
                }
                field("New Variety 3 Value"; "New Variety 3 Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Variety 3 Value field';
                }
                field("New Variety 4"; "New Variety 4")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Variety 4 field';
                }
                field("New Variety 4 Table"; "New Variety 4 Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Variety 4 Table field';
                }
                field("New Variety 4 Value"; "New Variety 4 Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Variety 4 Value field';
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
                action("Execute Action (Single)")
                {
                    Caption = 'Execute Action (Single)';
                    Image = "Action";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Execute Action (Single) action';

                    trigger OnAction()
                    var
                        ItemRepair: Codeunit "NPR Item Repair";
                    begin
                        ItemRepair.DoAction(Rec);
                    end;
                }
                action("Execute Action (Selected)")
                {
                    Caption = 'Execute Action (Selected)';
                    Image = "Action";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Execute Action (Selected) action';

                    trigger OnAction()
                    var
                        ItemRepairAction2: Record "NPR Item Repair Action";
                        ItemRepair: Codeunit "NPR Item Repair";
                    begin
                        CurrPage.SetSelectionFilter(ItemRepairAction2);
                        ItemRepair.DoSelectedActions(ItemRepairAction2);
                    end;
                }
            }
        }
    }
}

