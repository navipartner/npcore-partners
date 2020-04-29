page 6059990 "Item Repair Action"
{
    // VRT1.20/JDH /20170106 CASE 251896 TestTool to analyse and fix Variants
    // NPR5.48/JDH /20181109 CASE 334163 Added Action Captions and object caption
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Item Repair Action';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Item Repair Action";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No.";"Item No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field("Item Ledger Entry Qty.";"Item Ledger Entry Qty.")
                {
                }
                field("No. Of tests";"No. Of tests")
                {
                }
                field("No.Of Errors";"No.Of Errors")
                {
                }
                field("Variant Action";"Variant Action")
                {
                }
                field("Variety 1 Action";"Variety 1 Action")
                {
                }
                field("Variety 2 Action";"Variety 2 Action")
                {
                }
                field("Variety 3 Action";"Variety 3 Action")
                {
                }
                field("Variety 4 Action";"Variety 4 Action")
                {
                }
                field("New Variety 1";"New Variety 1")
                {
                }
                field("New Variety 1 Table";"New Variety 1 Table")
                {
                }
                field("New Variety 1 Value";"New Variety 1 Value")
                {
                }
                field("New Variety 2";"New Variety 2")
                {
                }
                field("New Variety 2 Table";"New Variety 2 Table")
                {
                }
                field("New Variety 2 Value";"New Variety 2 Value")
                {
                }
                field("New Variety 3";"New Variety 3")
                {
                }
                field("New Variety 3 Table";"New Variety 3 Table")
                {
                }
                field("New Variety 3 Value";"New Variety 3 Value")
                {
                }
                field("New Variety 4";"New Variety 4")
                {
                }
                field("New Variety 4 Table";"New Variety 4 Table")
                {
                }
                field("New Variety 4 Value";"New Variety 4 Value")
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
                action("Execute Action (Single)")
                {
                    Caption = 'Execute Action (Single)';
                    Image = "Action";

                    trigger OnAction()
                    var
                        ItemRepair: Codeunit "Item Repair";
                    begin
                        ItemRepair.DoAction(Rec);
                    end;
                }
                action("Execute Action (Selected)")
                {
                    Caption = 'Execute Action (Selected)';
                    Image = "Action";

                    trigger OnAction()
                    var
                        ItemRepairAction2: Record "Item Repair Action";
                        ItemRepair: Codeunit "Item Repair";
                    begin
                        CurrPage.SetSelectionFilter(ItemRepairAction2);
                        ItemRepair.DoSelectedActions(ItemRepairAction2);
                    end;
                }
            }
        }
    }
}

