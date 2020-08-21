page 6014664 "Stock-Take Worksheet Line"
{
    // NPR4.16/TS/20150525 CASE 213313 Page Created
    // NPR4.16/TSA20150715 CASE 213313 Adopted dimensions
    // NPR5.46/TSA /20181001 CASE 329899 Added Retail Print
    // TM1.39/TSA /20181102 CASE 334585 A control of type 'FlowFilter' is not allowed in a parent control of type 'Repeater'
    // NPR5.51/RA  /20190617 CASE 355055 Added field "Item Tracking Code"

    AutoSplitKey = true;
    Caption = 'Stock-Take Worksheet Line';
    PageType = ListPart;
    SourceTable = "Stock-Take Worksheet Line";
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
                }
                field("Worksheet Name"; "Worksheet Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Transfer State"; "Transfer State")
                {
                    ApplicationArea = All;
                }
                field(Barcode; Barcode)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = BarcodeFontBold;

                    trigger OnValidate()
                    begin
                        EvaluateFontBold();
                    end;
                }
                field("Item Translation Source"; "Item Translation Source")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Item Trans. Source Desc."; "Item Trans. Source Desc.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = ItemNoFontBold;

                    trigger OnValidate()
                    begin
                        EvaluateFontBold();
                    end;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        EvaluateFontBold();
                    end;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = All;
                }
                field("Variant Description"; "Variant Description")
                {
                    ApplicationArea = All;
                }
                field("Qty. (Counted)"; "Qty. (Counted)")
                {
                    ApplicationArea = All;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = All;
                }
                field("Date of Inventory"; "Date of Inventory")
                {
                    ApplicationArea = All;
                }
                field("Shelf  No."; "Shelf  No.")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Session ID"; "Session ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Session Name"; "Session Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Session DateTime"; "Session DateTime")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Qty. (Total Counted)"; "Qty. (Total Counted)")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = BlockedItemFontBold;
                }
                field("Require Variant Code"; "Require Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Item Tracking Code"; "Item Tracking Code")
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
            group(Line)
            {
                Caption = 'Line';
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        ShowDimensions();
                    end;
                }
                separator(Separator6150649)
                {
                }
                action("Show &Unknown Items")
                {
                    Caption = 'Show &Unknown Items';
                    Image = ShowSelected;

                    trigger OnAction()
                    begin
                        DisplayNonTranslatedItems();
                    end;
                }
                action("Show &Blocked Items")
                {
                    Caption = 'Show &Blocked Items';
                    Image = ShowSelected;

                    trigger OnAction()
                    begin
                        DisplayBlockedItems();
                    end;
                }
                action("Show Missing &Variant Codes")
                {
                    Caption = 'Show Missing &Variant Codes';
                    Image = ShowSelected;

                    trigger OnAction()
                    begin
                        DisplayItemNoVariant
                    end;
                }
                action("&Show all Items")
                {
                    Caption = '&Show all Items';
                    Image = ShowSelected;

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

                    trigger OnAction()
                    begin
                        SetTransferOptionState("Transfer State"::READY);
                    end;
                }
                action("Set Transfer Option to Ignore")
                {
                    Caption = 'Set Transfer Option to Ignore';

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

                    trigger OnAction()
                    var
                        Line: Record "Stock-Take Worksheet Line";
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

                    trigger OnAction()
                    var
                        Line: Record "Stock-Take Worksheet Line";
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
                }
                action("Item Ledger Entries")
                {
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;
                    ShortCutKey = 'Ctrl+F5';

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
                }
                action("Retail Print")
                {
                    Caption = 'Retail Print';
                    Ellipsis = true;
                    Image = BinContent;

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

    procedure ShowDimensions()
    begin
        //-NPR4.16
        ShowDimensions();
        CurrPage.Update(false);

        // JournalLineDimension.FILTERGROUP (2);
        // JournalLineDimension.SETFILTER ("Table ID", '=%1', DATABASE::"Stock-Take Worksheet Line");
        // JournalLineDimension.SETFILTER ("Journal Template Name", '=%1', "Stock-Take Config Code");
        // JournalLineDimension.SETFILTER ("Journal Batch Name", '=%1', "Worksheet Name");
        // JournalLineDimension.SETFILTER ("Journal Line No.", '=%1', "Line No.");
        // JournalLineDimension.FILTERGROUP (0);
        //
        // PAGE.SETTABLEVIEW (JournalLineDimension);
        // PAGE.RUNMODAL
        //+NPR4.16
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
        StockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
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
        StockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
        StockTakeManager: Codeunit "Stock-Take Manager";
    begin

        //-NPR5.46 [329899]
        CurrPage.SetSelectionFilter(StockTakeWorksheetLine);
        StockTakeManager.RetailPrint(StockTakeWorksheetLine);
        //+NPR5.46 [329899]
    end;
}

