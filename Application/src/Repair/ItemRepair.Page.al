page 6059991 "NPR Item Repair"
{
    // VRT1.20/JDH /20170106 CASE 251896 TestTool to analyse and fix Variants
    // NPR5.48/JDH /20181109 CASE 334163 Added Action Captions and object caption
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Item Repair';
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Item Repair";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Item Ledger Entry Qty."; "Item Ledger Entry Qty.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Item Ledger Entry Qty. field';
                }
                field("Item Ledger Entry Exist"; "Item Ledger Entry Exist")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Item Ledger Entry Exist field';
                }
                field("Item Ledger Entry Open"; "Item Ledger Entry Open")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Ledger Entry Open field';
                }
                field("No. Of tests"; "No. Of tests")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the No. Of tests field';
                }
                field("No.Of Errors"; "No.Of Errors")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the No.Of Errors field';
                }
                field("Errors Exists"; "Errors Exists")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Errors Exists field';
                }
                field("No. Of Item Actions"; "No. Of Item Actions")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the No. Of Item Actions field';
                }
                field("No. Of Variant Actions"; "No. Of Variant Actions")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the No. Of Variant Actions field';
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
                    Visible = ShowVariety3;
                    ToolTip = 'Specifies the value of the Variety 3 Action field';
                }
                field("Variety 4 Action"; "Variety 4 Action")
                {
                    ApplicationArea = All;
                    Visible = ShowVariety4;
                    ToolTip = 'Specifies the value of the Variety 4 Action field';
                }
                field("Variety 1 Used"; "Variety 1 Used")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 1 Used field';
                }
                field("Variety 2 Used"; "Variety 2 Used")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variety 2 Used field';
                }
                field("Variety 3 Used"; "Variety 3 Used")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = ShowVariety3;
                    ToolTip = 'Specifies the value of the Variety 3 Used field';
                }
                field("Variety 4 Used"; "Variety 4 Used")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = ShowVariety4;
                    ToolTip = 'Specifies the value of the Variety 4 Used field';
                }
                field("Blocked (Var)"; "Blocked (Var)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Blocked (Var) field';
                }
                field("Variety 1 (Item)"; "Variety 1 (Item)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 1 (Item) field';
                }
                field("Variety 1 Table (Item)"; "Variety 1 Table (Item)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 1 Table (Item) field';
                }
                field("Variety 1 (Var)"; "Variety 1 (Var)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 1 (Var) field';
                }
                field("Variety 1 Table (Var)"; "Variety 1 Table (Var)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 1 Table (Var) field';
                }
                field("Variety 1 Value (Var)"; "Variety 1 Value (Var)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 1 Value (Var) field';
                }
                field("Variety 1 Value (Var) (NEW)"; "Variety 1 Value (Var) (NEW)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 1 Value (Var) (NEW) field';
                }
                field("Variety 2 (Item)"; "Variety 2 (Item)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 2 (Item) field';
                }
                field("Variety 2 Table (Item)"; "Variety 2 Table (Item)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 2 Table (Item) field';
                }
                field("Variety 2 (Var)"; "Variety 2 (Var)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 2 (Var) field';
                }
                field("Variety 2 Table (Var)"; "Variety 2 Table (Var)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 2 Table (Var) field';
                }
                field("Variety 2 Value (Var)"; "Variety 2 Value (Var)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 2 Value (Var) field';
                }
                field("Variety 2 Value (Var) (NEW)"; "Variety 2 Value (Var) (NEW)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety 2 Value (Var) (NEW) field';
                }
                field("Variety 3 (Item)"; "Variety 3 (Item)")
                {
                    ApplicationArea = All;
                    Visible = ShowVariety3;
                    ToolTip = 'Specifies the value of the Variety 3 (Item) field';
                }
                field("Variety 3 Table (Item)"; "Variety 3 Table (Item)")
                {
                    ApplicationArea = All;
                    Visible = ShowVariety3;
                    ToolTip = 'Specifies the value of the Variety 3 Table (Item) field';
                }
                field("Variety 3 (Var)"; "Variety 3 (Var)")
                {
                    ApplicationArea = All;
                    Visible = ShowVariety3;
                    ToolTip = 'Specifies the value of the Variety 3 (Var) field';
                }
                field("Variety 3 Table (Var)"; "Variety 3 Table (Var)")
                {
                    ApplicationArea = All;
                    Visible = ShowVariety3;
                    ToolTip = 'Specifies the value of the Variety 3 Table (Var) field';
                }
                field("Variety 3 Value (Var)"; "Variety 3 Value (Var)")
                {
                    ApplicationArea = All;
                    Visible = ShowVariety3;
                    ToolTip = 'Specifies the value of the Variety 3 Value (Var) field';
                }
                field("Variety 3 Value (Var) (NEW)"; "Variety 3 Value (Var) (NEW)")
                {
                    ApplicationArea = All;
                    Visible = ShowVariety3;
                    ToolTip = 'Specifies the value of the Variety 3 Value (Var) (NEW) field';
                }
                field("Variety 4 (Item)"; "Variety 4 (Item)")
                {
                    ApplicationArea = All;
                    Visible = ShowVariety4;
                    ToolTip = 'Specifies the value of the Variety 4 (Item) field';
                }
                field("Variety 4 Table (Item)"; "Variety 4 Table (Item)")
                {
                    ApplicationArea = All;
                    Visible = ShowVariety4;
                    ToolTip = 'Specifies the value of the Variety 4 Table (Item) field';
                }
                field("Variety 4 (Var)"; "Variety 4 (Var)")
                {
                    ApplicationArea = All;
                    Visible = ShowVariety4;
                    ToolTip = 'Specifies the value of the Variety 4 (Var) field';
                }
                field("Variety 4 Table (Var)"; "Variety 4 Table (Var)")
                {
                    ApplicationArea = All;
                    Visible = ShowVariety4;
                    ToolTip = 'Specifies the value of the Variety 4 Table (Var) field';
                }
                field("Variety 4 Value (Var)"; "Variety 4 Value (Var)")
                {
                    ApplicationArea = All;
                    Visible = ShowVariety4;
                    ToolTip = 'Specifies the value of the Variety 4 Value (Var) field';
                }
                field("Variety 4 Value (Var) (NEW)"; "Variety 4 Value (Var) (NEW)")
                {
                    ApplicationArea = All;
                    Visible = ShowVariety4;
                    ToolTip = 'Specifies the value of the Variety 4 Value (Var) (NEW) field';
                }
                field("Cross Variety No."; "Cross Variety No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cross Variety No. field';
                }
                field("Variety Group"; "Variety Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety Group field';
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
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Delete Test Data action';

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
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Insert Test Data action';

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
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Test Data (All) action';

                    trigger OnAction()
                    begin
                        ItemRepair.TestAllRepairEntries;
                    end;
                }
                action("Test Data (Selection)")
                {
                    Caption = 'Test Data (Selection)';
                    Image = "Action";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Test Data (Selection) action';

                    trigger OnAction()
                    var
                        ItemRepair2: Record "NPR Item Repair";
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
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Suggest Actions (All) action';

                    trigger OnAction()
                    begin
                        ItemRepair.SuggestAllActions;
                    end;
                }
                action("Suggest Actions (Selected)")
                {
                    Caption = 'Suggest Actions (Selected)';
                    Image = Suggest;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Suggest Actions (Selected) action';

                    trigger OnAction()
                    var
                        ItemRepair2: Record "NPR Item Repair";
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Show Variety 3 action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Show Variety 4 action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Card action';

                    trigger OnAction()
                    var
                        Item: Record Item;
                    begin
                        Item.Get("Item No.");
                        PAGE.RunModal(Page::"Item Card", Item);
                    end;
                }
                action("Varient List")
                {
                    Caption = 'Varient List';
                    Image = ItemVariant;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Varient List action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Block Variant action';

                    trigger OnAction()
                    begin
                        ItemRepair.ManualSetAction(Rec, 1, 1);
                    end;
                }
                action("Delete Variant")
                {
                    Caption = 'Delete Variant';
                    Image = "Action";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Delete Variant action';

                    trigger OnAction()
                    begin
                        TestField("Item Ledger Entry Exist", false);
                        ItemRepair.ManualSetAction(Rec, 1, 2);
                    end;
                }
                action("Force New Variety Value (Var)")
                {
                    Caption = 'Force New Variety Value (Var)';
                    Image = Forecast;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Force New Variety Value (Var) action';

                    trigger OnAction()
                    begin
                        ItemRepair.SetNewVarietyValue(Rec);
                    end;
                }
                action("Block Selected Variant(s)")
                {
                    Caption = 'Block Selected Variant(s)';
                    Image = "Action";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Block Selected Variant(s) action';

                    trigger OnAction()
                    var
                        ItemRepair2: Record "NPR Item Repair";
                    begin
                        CurrPage.SetSelectionFilter(ItemRepair2);
                        ItemRepair.ManualSetActionSelected(ItemRepair2, 1, 1);
                    end;
                }
                action("Delete Selected Variant(s)")
                {
                    Caption = 'Delete Selected Variant(s)';
                    Image = "Action";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Delete Selected Variant(s) action';

                    trigger OnAction()
                    var
                        ItemRepair2: Record "NPR Item Repair";
                    begin
                        CurrPage.SetSelectionFilter(ItemRepair2);
                        ItemRepair.ManualSetActionSelected(ItemRepair2, 1, 2);
                    end;
                }
                action("Force New Variety Value(s) (Var)")
                {
                    Caption = 'Force New Variety Value(s) (Var)';
                    Image = Forecast;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Force New Variety Value(s) (Var) action';

                    trigger OnAction()
                    var
                        ItemRepair2: Record "NPR Item Repair";
                    begin
                        CurrPage.SetSelectionFilter(ItemRepair2);
                        ItemRepair.SetNewVarietyValues(ItemRepair2);
                    end;
                }
            }
        }
    }

    var
        ItemRepair: Codeunit "NPR Item Repair";
        ShowVariety3: Boolean;
        ShowVariety4: Boolean;
}

