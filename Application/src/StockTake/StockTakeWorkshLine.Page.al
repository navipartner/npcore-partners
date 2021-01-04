page 6014664 "NPR StockTake Worksh. Line"
{
    AutoSplitKey = true;
    Caption = 'Stock-Take Worksheet Line';
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Stock-Take Worksheet Line";
    SourceTableView = SORTING("Stock-Take Config Code", "Worksheet Name", "Line No.")
                      ORDER(Ascending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Stock-Take Config Code"; "Stock-Take Config Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Stock-Take Conf. Code field';
                }
                field("Worksheet Name"; "Worksheet Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Worksheet Name field';
                }
                field("Transfer State"; "Transfer State")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transfer Option field';
                }
                field(Barcode; Barcode)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = BarcodeFontBold;
                    ToolTip = 'Specifies the value of the Barcode field';

                    trigger OnValidate()
                    begin
                        EvaluateFontBold();
                    end;
                }
                field("Item Translation Source"; "Item Translation Source")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Item Translation Source field';
                }
                field("Item Trans. Source Desc."; "Item Trans. Source Desc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Trans. Source Desc. field';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = ItemNoFontBold;
                    ToolTip = 'Specifies the value of the Item No. field';

                    trigger OnValidate()
                    begin
                        EvaluateFontBold();
                    end;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';

                    trigger OnValidate()
                    begin
                        EvaluateFontBold();
                    end;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Description field';
                }
                field("Variant Description"; "Variant Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Description field';
                }
                field("Qty. (Counted)"; "Qty. (Counted)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. (Counted) field';
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Cost field';
                }
                field("Date of Inventory"; "Date of Inventory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date of Inventory field';
                }
                field("Shelf  No."; "Shelf  No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shelf  No. field';
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                }
                field("Session ID"; "Session ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Session ID field';
                }
                field("Session Name"; "Session Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Session Name field';
                }
                field("Session DateTime"; "Session DateTime")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Session DateTime field';
                }
                field("Qty. (Total Counted)"; "Qty. (Total Counted)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. (Total Counted) field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = BlockedItemFontBold;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Require Variant Code"; "Require Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Require Variant Code field';
                }
                field("Item Tracking Code"; "Item Tracking Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Item Tracking Code field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Line)
            {
                Caption = 'Line';
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Dimensions action';

                    trigger OnAction()
                    begin
                        ShowLineDimensions();
                    end;
                }
                separator(Separator6150649)
                {
                }
                action("Show &Unknown Items")
                {
                    Caption = 'Show &Unknown Items';
                    Image = ShowSelected;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Show &Unknown Items action';

                    trigger OnAction()
                    begin
                        DisplayNonTranslatedItems();
                    end;
                }
                action("Show &Blocked Items")
                {
                    Caption = 'Show &Blocked Items';
                    Image = ShowSelected;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Show &Blocked Items action';

                    trigger OnAction()
                    begin
                        DisplayBlockedItems();
                    end;
                }
                action("Show Missing &Variant Codes")
                {
                    Caption = 'Show Missing &Variant Codes';
                    Image = ShowSelected;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Show Missing &Variant Codes action';

                    trigger OnAction()
                    begin
                        DisplayItemNoVariant
                    end;
                }
                action("&Show all Items")
                {
                    Caption = '&Show all Items';
                    Image = ShowSelected;
                    ApplicationArea = All;
                    ToolTip = 'Executes the &Show all Items action';

                    trigger OnAction()
                    begin
                        DisplayAllItems();
                    end;
                }
                separator(Separator6150652)
                {
                }
                action("Set Transfer Option to Ready")
                {
                    Caption = 'Set Transfer Option to Ready';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Set Transfer Option to Ready action';

                    trigger OnAction()
                    begin
                        SetTransferOptionState("Transfer State"::READY);
                    end;
                }
                action("Set Transfer Option to Ignore")
                {
                    Caption = 'Set Transfer Option to Ignore';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Set Transfer Option to Ignore action';

                    trigger OnAction()
                    begin
                        SetTransferOptionState("Transfer State"::IGNORE);
                    end;
                }
                separator(Separator6150656)
                {
                }
                action("Delete all Lines")
                {
                    Caption = 'Delete all lines';
                    Ellipsis = true;
                    Image = Delete;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Delete all lines action';

                    trigger OnAction()
                    var
                        Line: Record "NPR Stock-Take Worksheet Line";
                    begin
                        if Confirm(Text000, false) then
                            if Confirm(Text001, false) then begin
                                Line.SetRange("Stock-Take Config Code", Rec."Stock-Take Config Code");
                                Line.SetRange("Worksheet Name", "Worksheet Name");
                                Line.DeleteAll(true);
                            end;
                    end;
                }
                action("Delete lines with unknown item numbers")
                {
                    Caption = 'Delete lines with unknown item numbers';
                    Image = Delete;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Delete lines with unknown item numbers action';

                    trigger OnAction()
                    var
                        Line: Record "NPR Stock-Take Worksheet Line";
                        txtDeleteUnknown: Label 'Delete all unknown item numbers?';
                    begin
                        if not Confirm(txtDeleteUnknown) then
                            exit;
                        Line.SetRange("Stock-Take Config Code", Rec."Stock-Take Config Code");
                        Line.SetRange("Worksheet Name", "Worksheet Name");
                        Line.SetRange("Item No.", '');
                        Line.DeleteAll;
                    end;
                }
            }
            group(Item)
            {
                Caption = 'Item';
                action(Items)
                {
                    Caption = 'Items';
                    Image = Item;
                    ShortCutKey = 'Shift+F5';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Items action';

                    trigger OnAction()
                    begin
                        ShowItem;
                    end;
                }
                action("Items by Location")
                {
                    Caption = 'Items by Location';
                    Image = ItemAvailbyLoc;
                    RunObject = Page "Items by Location";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Items by Location action';
                }
                action("Item Ledger Entries")
                {
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;
                    ShortCutKey = 'Ctrl+F5';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Ledger Entries action';

                    trigger OnAction()
                    begin
                        ShowItemLedgerEntries;
                    end;
                }
                action(PhysInvEntries)
                {
                    Caption = 'Phys. Inv. Entries';
                    Image = PhysicalInventoryLedger;
                    RunObject = Page "Phys. Inventory Ledger Entries";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code");
                    ApplicationArea = All;
                    ToolTip = 'Executes the Phys. Inv. Entries action';
                }
                action("Retail Print")
                {
                    Caption = 'Retail Print';
                    Ellipsis = true;
                    Image = BinContent;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Retail Print action';

                    trigger OnAction()
                    begin
                        RetailPrint();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        EvaluateFontBold();
    end;

    var
        [InDataSet]
        BarcodeFontBold: Boolean;
        [InDataSet]
        ItemNoFontBold: Boolean;
        Text000: Label 'This function deletes all lines in all statusjournals.\Continue?';
        Text001: Label 'Are You sure?';
        [InDataSet]
        BlockedItemFontBold: Boolean;

    procedure ShowItem()
    var
        Item: Record Item;
    begin
        Item.Get("Item No.");
        PAGE.Run(0, Item);
    end;

    procedure ShowItemLedgerEntries()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetCurrentKey("Item No.");
        ItemLedgerEntry.SetRange("Item No.", "Item No.");
        ItemLedgerEntry.SetRange("Variant Code", "Variant Code");
        PAGE.Run(0, ItemLedgerEntry);
    end;

    procedure DisplayNonTranslatedItems()
    begin
        SetFilter("Item No.", '=%1', '');
    end;

    procedure DisplayBlockedItems()
    begin
        SetFilter(Blocked, '=%1', true);
    end;

    procedure DisplayItemNoVariant()
    begin
        SetFilter("Variant Code", '=%1', '');
        SetFilter("Require Variant Code", '=%1', true);
    end;

    procedure DisplayAllItems()
    begin
        SetRange("Item No.");
        SetRange(Blocked);
        SetRange("Variant Code");
        SetRange("Require Variant Code");
    end;

    local procedure ShowLineDimensions()
    begin
        ShowDimensions();
        CurrPage.Update(false);
    end;

    procedure SetFontBold(FieldNumber: Integer) SetBold: Boolean
    var
        itemVariant: Record "Item Variant";
    begin

        case FieldNumber of
            Rec.FieldNo(Barcode):
                SetBold := ("Item No." = '');
            Rec.FieldNo("Item No."):
                begin
                    SetBold := (Rec.Blocked);
                    itemVariant.SetFilter("Item No.", '=%1', Rec."Item No.");
                    SetBold := SetBold or ((Rec."Variant Code" = '') and (itemVariant.FindFirst));
                end;
            Rec.FieldNo(Blocked):
                SetBold := (Rec.Blocked);
            else
                SetBold := false;
        end;

        exit(SetBold);
    end;

    procedure SelectionCount() rCount: Integer
    begin
        exit(Count());
    end;

    local procedure SetTransferOptionState(TranferOptionState: Option)
    var
        StockTakeWorksheetLine: Record "NPR Stock-Take Worksheet Line";
    begin

        CurrPage.SetSelectionFilter(StockTakeWorksheetLine);
        StockTakeWorksheetLine.ModifyAll("Transfer State", TranferOptionState);
        CurrPage.Update(false);
    end;

    local procedure EvaluateFontBold()
    begin
        CalcFields(Blocked);
        BarcodeFontBold := SetFontBold(Rec.FieldNo(Barcode));
        ItemNoFontBold := SetFontBold(Rec.FieldNo("Item No."));
        BlockedItemFontBold := SetFontBold(Rec.FieldNo(Blocked));
    end;

    local procedure RetailPrint()
    var
        StockTakeWorksheetLine: Record "NPR Stock-Take Worksheet Line";
        StockTakeManager: Codeunit "NPR Stock-Take Manager";
    begin
        CurrPage.SetSelectionFilter(StockTakeWorksheetLine);
        StockTakeManager.RetailPrint(StockTakeWorksheetLine);
    end;
}