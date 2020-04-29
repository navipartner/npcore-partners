page 6059991 "Item Repair"
{
    // VRT1.20/JDH /20170106 CASE 251896 TestTool to analyse and fix Variants
    // NPR5.48/JDH /20181109 CASE 334163 Added Action Captions and object caption
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Item Repair';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Item Repair";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No.";"Item No.")
                {
                    Editable = false;
                }
                field("Variant Code";"Variant Code")
                {
                    Editable = false;
                }
                field(Description;Description)
                {
                    Editable = false;
                }
                field("Item Ledger Entry Qty.";"Item Ledger Entry Qty.")
                {
                    Editable = false;
                }
                field("Item Ledger Entry Exist";"Item Ledger Entry Exist")
                {
                    Editable = false;
                }
                field("Item Ledger Entry Open";"Item Ledger Entry Open")
                {
                }
                field("No. Of tests";"No. Of tests")
                {
                    Editable = false;
                }
                field("No.Of Errors";"No.Of Errors")
                {
                    Editable = false;
                }
                field("Errors Exists";"Errors Exists")
                {
                    Editable = false;
                }
                field("No. Of Item Actions";"No. Of Item Actions")
                {
                    Editable = false;
                    Enabled = false;
                }
                field("No. Of Variant Actions";"No. Of Variant Actions")
                {
                    Editable = false;
                    Enabled = false;
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
                    Visible = ShowVariety3;
                }
                field("Variety 4 Action";"Variety 4 Action")
                {
                    Visible = ShowVariety4;
                }
                field("Variety 1 Used";"Variety 1 Used")
                {
                    Editable = false;
                }
                field("Variety 2 Used";"Variety 2 Used")
                {
                    Editable = false;
                }
                field("Variety 3 Used";"Variety 3 Used")
                {
                    Editable = false;
                    Visible = ShowVariety3;
                }
                field("Variety 4 Used";"Variety 4 Used")
                {
                    Editable = false;
                    Visible = ShowVariety4;
                }
                field("Blocked (Var)";"Blocked (Var)")
                {
                    Editable = false;
                }
                field("Variety 1 (Item)";"Variety 1 (Item)")
                {
                }
                field("Variety 1 Table (Item)";"Variety 1 Table (Item)")
                {
                }
                field("Variety 1 (Var)";"Variety 1 (Var)")
                {
                }
                field("Variety 1 Table (Var)";"Variety 1 Table (Var)")
                {
                }
                field("Variety 1 Value (Var)";"Variety 1 Value (Var)")
                {
                }
                field("Variety 1 Value (Var) (NEW)";"Variety 1 Value (Var) (NEW)")
                {
                }
                field("Variety 2 (Item)";"Variety 2 (Item)")
                {
                }
                field("Variety 2 Table (Item)";"Variety 2 Table (Item)")
                {
                }
                field("Variety 2 (Var)";"Variety 2 (Var)")
                {
                }
                field("Variety 2 Table (Var)";"Variety 2 Table (Var)")
                {
                }
                field("Variety 2 Value (Var)";"Variety 2 Value (Var)")
                {
                }
                field("Variety 2 Value (Var) (NEW)";"Variety 2 Value (Var) (NEW)")
                {
                }
                field("Variety 3 (Item)";"Variety 3 (Item)")
                {
                    Visible = ShowVariety3;
                }
                field("Variety 3 Table (Item)";"Variety 3 Table (Item)")
                {
                    Visible = ShowVariety3;
                }
                field("Variety 3 (Var)";"Variety 3 (Var)")
                {
                    Visible = ShowVariety3;
                }
                field("Variety 3 Table (Var)";"Variety 3 Table (Var)")
                {
                    Visible = ShowVariety3;
                }
                field("Variety 3 Value (Var)";"Variety 3 Value (Var)")
                {
                    Visible = ShowVariety3;
                }
                field("Variety 3 Value (Var) (NEW)";"Variety 3 Value (Var) (NEW)")
                {
                    Visible = ShowVariety3;
                }
                field("Variety 4 (Item)";"Variety 4 (Item)")
                {
                    Visible = ShowVariety4;
                }
                field("Variety 4 Table (Item)";"Variety 4 Table (Item)")
                {
                    Visible = ShowVariety4;
                }
                field("Variety 4 (Var)";"Variety 4 (Var)")
                {
                    Visible = ShowVariety4;
                }
                field("Variety 4 Table (Var)";"Variety 4 Table (Var)")
                {
                    Visible = ShowVariety4;
                }
                field("Variety 4 Value (Var)";"Variety 4 Value (Var)")
                {
                    Visible = ShowVariety4;
                }
                field("Variety 4 Value (Var) (NEW)";"Variety 4 Value (Var) (NEW)")
                {
                    Visible = ShowVariety4;
                }
                field("Cross Variety No.";"Cross Variety No.")
                {
                }
                field("Variety Group";"Variety Group")
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
                action("Delete Test Data")
                {
                    Caption = 'Delete Test Data';
                    Image = Delete;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        ItemRepair.DeleteTestData;
                    end;
                }
                action("Insert Test Data")
                {
                    Caption = 'Insert Test Data';
                    Image = Add;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        ItemRepair.InsertLine;
                    end;
                }
                action("Test Data (All)")
                {
                    Caption = 'Test Data (All)';
                    Image = "Action";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        ItemRepair.TestAllRepairEntries;
                    end;
                }
                action("Test Data (Selection)")
                {
                    Caption = 'Test Data (Selection)';
                    Image = "Action";

                    trigger OnAction()
                    var
                        ItemRepair2: Record "Item Repair";
                    begin
                        CurrPage.SetSelectionFilter(ItemRepair2);
                        ItemRepair.TestSelectedRepairEntries(ItemRepair2);
                    end;
                }
                action("Suggest Actions (All)")
                {
                    Caption = 'Suggest Actions (All)';
                    Image = SuggestLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        ItemRepair.SuggestAllActions;
                    end;
                }
                action("Suggest Actions (Selected)")
                {
                    Caption = 'Suggest Actions (Selected)';
                    Image = Suggest;

                    trigger OnAction()
                    var
                        ItemRepair2: Record "Item Repair";
                    begin
                        CurrPage.SetSelectionFilter(ItemRepair2);
                        ItemRepair.SuggestSelectedActions(ItemRepair2);
                    end;
                }
            }
            group(Show)
            {
                Caption = 'Show';
                action("Show Variety 3")
                {
                    Caption = 'Show Variety 3';
                    Image = ShowSelected;

                    trigger OnAction()
                    begin
                        ShowVariety3 := not ShowVariety3;
                        CurrPage.Update;
                    end;
                }
                action("Show Variety 4")
                {
                    Caption = 'Show Variety 4';
                    Image = ShowSelected;

                    trigger OnAction()
                    begin
                        ShowVariety4 := not ShowVariety4;
                        CurrPage.Update;
                    end;
                }
                action("Item Card")
                {
                    Caption = 'Item Card';
                    Image = Card;

                    trigger OnAction()
                    var
                        Item: Record Item;
                    begin
                        Item.Get("Item No.");
                        PAGE.RunModal(6014425, Item);
                    end;
                }
                action("Varient List")
                {
                    Caption = 'Varient List';
                    Image = ItemVariant;

                    trigger OnAction()
                    var
                        ItemVariant: Record "Item Variant";
                    begin
                        ItemVariant.SetRange("Item No.", "Item No.");
                        ItemVariant.SetRange(Code, "Variant Code");
                        if ItemVariant.FindFirst then;

                        ItemVariant.SetRange(Code);
                        PAGE.RunModal(0, ItemVariant);
                    end;
                }
            }
            group("Set Actions Manual")
            {
                Caption = 'Set Actions Manual';
                action("Block Variant")
                {
                    Caption = 'Block Variant';
                    Image = "Action";

                    trigger OnAction()
                    begin
                        ItemRepair.ManualSetAction(Rec,1,1);
                    end;
                }
                action("Delete Variant")
                {
                    Caption = 'Delete Variant';
                    Image = "Action";

                    trigger OnAction()
                    begin
                        TestField("Item Ledger Entry Exist", false);
                        ItemRepair.ManualSetAction(Rec,1,2);
                    end;
                }
                action("Force New Variety Value (Var)")
                {
                    Caption = 'Force New Variety Value (Var)';
                    Image = Forecast;

                    trigger OnAction()
                    begin
                        ItemRepair.SetNewVarietyValue(Rec);
                    end;
                }
                action("Block Selected Variant(s)")
                {
                    Caption = 'Block Selected Variant(s)';
                    Image = "Action";

                    trigger OnAction()
                    var
                        ItemRepair2: Record "Item Repair";
                    begin
                        CurrPage.SetSelectionFilter(ItemRepair2);
                        ItemRepair.ManualSetActionSelected(ItemRepair2, 1, 1);
                    end;
                }
                action("Delete Selected Variant(s)")
                {
                    Caption = 'Delete Selected Variant(s)';
                    Image = "Action";

                    trigger OnAction()
                    var
                        ItemRepair2: Record "Item Repair";
                    begin
                        CurrPage.SetSelectionFilter(ItemRepair2);
                        ItemRepair.ManualSetActionSelected(ItemRepair2, 1, 2);
                    end;
                }
                action("Force New Variety Value(s) (Var)")
                {
                    Caption = 'Force New Variety Value(s) (Var)';
                    Image = Forecast;

                    trigger OnAction()
                    var
                        ItemRepair2: Record "Item Repair";
                    begin
                        CurrPage.SetSelectionFilter(ItemRepair2);
                        ItemRepair.SetNewVarietyValues(ItemRepair2);
                    end;
                }
            }
        }
    }

    var
        ItemRepair: Codeunit "Item Repair";
        ShowVariety3: Boolean;
        ShowVariety4: Boolean;
}

