page 6014472 "NPR Retail Journal Line"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Retail Journal Line";
    SourceTableView = SORTING("No.", "Line No.");

    layout
    {
        area(content)
        {
            repeater(Control6014441)
            {
                ShowCaption = false;
                field(ItemNo; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Clear(Item);
                        TryToGetItem(Rec."Item No.");
                    end;
                }
                field("Calculation Date"; Rec."Calculation Date")
                {
                    ToolTip = 'Specifies the value of the Calculation Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Quantity to Print"; Rec."Quantity to Print")
                {

                    ToolTip = 'Specifies the value of the Quantity to Print field';
                    ApplicationArea = NPRRetail;
                }
                field(Print; Print)
                {
                    Caption = 'Print';
                    ToolTip = 'Specifies the value of the Print field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    var
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        LabelLibrary.ToggleLine(RecRef);
                    end;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor Item No."; Rec."Vend Item No.")
                {

                    ToolTip = 'Specifies the value of the Vendor Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Barcode; Rec.Barcode)
                {

                    ToolTip = 'Specifies the value of the Barcode field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {

                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field(ItemUnitPrice; Item."Unit Price")
                {

                    Caption = 'Unit price(Item Card)';
                    Editable = false;
                    Visible = true;
                    ToolTip = 'Specifies the value of the Unit price(Item Card) field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Direct Cost"; Rec."Last Direct Cost")
                {

                    ToolTip = 'Specifies the value of the Last Direct Cost field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Cost"; Item."Unit Cost")
                {

                    Caption = 'Unit cost';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Unit cost field';
                    ApplicationArea = NPRRetail;
                }
                field("Profit % (new)"; Rec."Profit % (new)")
                {

                    Visible = true;
                    ToolTip = 'Specifies the value of the Profit % (new) field';
                    ApplicationArea = NPRRetail;
                }
                field(Inventory; Rec.Inventory)
                {

                    ToolTip = 'Specifies the value of the Inventory field';
                    ApplicationArea = NPRRetail;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved to the NPR Retail Jnl. Line FactBox';
                    Visible = false;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Price Group"; Rec."Customer Price Group")
                {

                    ToolTip = 'Specifies the value of the Customer Price Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Disc. Group"; Rec."Customer Disc. Group")
                {

                    ToolTip = 'Specifies the value of the Customer Disc. Group field';
                    ApplicationArea = NPRRetail;
                }
                field("New Item No."; Rec."New Item No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the New Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Serial No."; Rec."Serial No.")
                {

                    ToolTip = 'Specifies the value of the Serial No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2"; Rec."Description 2")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Base Unit of measure"; Rec."Base Unit of measure")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Base Unit of measure field';
                    ApplicationArea = NPRRetail;
                }
                field("Purch. Unit of measure"; Rec."Purch. Unit of measure")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Purch. Unit of measure field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Unit of measure"; Rec."Sales Unit of measure")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Sales Unit of measure field';
                    ApplicationArea = NPRRetail;
                }
                field("Quantity for Discount Calc"; Rec."Quantity for Discount Calc")
                {

                    ToolTip = 'Specifies the value of the Quantity for Discount Calculation field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Type"; Rec."Discount Type")
                {

                    ToolTip = 'Specifies the value of the Discount Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Code"; Rec."Discount Code")
                {

                    ToolTip = 'Specifies the value of the Discount Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code 2"; Rec."Variant Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Pct."; Rec."Discount Pct.")
                {

                    ToolTip = 'Specifies the value of the Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Price Incl. Vat"; Rec."Discount Price Incl. Vat")
                {

                    ToolTip = 'Specifies the value of the Discount Price Incl. Vat field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Price Excl. VAT"; Rec."Discount Price Excl. VAT")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Discount Price Excl. VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit List Price"; Rec."Unit List Price")
                {

                    ToolTip = 'Specifies the value of the Unit List Price field';
                    ApplicationArea = NPRRetail;
                }
                field("VAT %"; Rec."VAT %")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the VAT % field';
                    ApplicationArea = NPRRetail;
                }
                field("Item group Field"; Rec."Item group")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Item group field';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor No."; Rec."Vendor No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Vendor No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor Name"; Rec."Vend Name")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Vendor Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Net Change"; Rec."Net Change")
                {

                    ToolTip = 'Specifies the value of the Net Change field';
                    ApplicationArea = NPRRetail;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved to the NPR Retail Jnl. Line FactBox';
                    Visible = false;
                }
                field("Purchases (Qty.)"; Rec."Purchases (Qty.)")
                {

                    ToolTip = 'Specifies the value of the Purchases (Qty.) field';
                    ApplicationArea = NPRRetail;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved to the NPR Retail Jnl. Line FactBox';
                    Visible = false;
                }
                field("Sales (Qty.)"; Rec."Sales (Qty.)")
                {

                    ToolTip = 'Specifies the value of the Sales (Qty.) field';
                    ApplicationArea = NPRRetail;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved to the NPR Retail Jnl. Line FactBox';
                    Visible = false;
                }
                field("Cannot edit unit price"; Rec."Cannot edit unit price")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Can''t edit unit price field';
                    ApplicationArea = NPRRetail;
                }
                field("Exchange Label"; Rec."Exchange Label")
                {

                    ToolTip = 'Specifies the value of the Exchange Label field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        //-NPR5.50 [350435]
                        CurrPage.Update();
                        //+NPR5.50 [350435]
                    end;
                }
                field("RFID Tag Value"; Rec."RFID Tag Value")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the RFID Tag Value field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        RecRef: RecordRef;
    begin
        if not TryToGetItem(Rec."Item No.") then
            Item.Init();
        Rec.calcProfit();
        RecRef.GetTable(Rec);
        Print := LabelLibrary.SelectionContains(RecRef);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        if LabelLibrary.SelectionContains(RecRef) then
            LabelLibrary.ToggleLine(RecRef);
        Clear(Item);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(Item);
        Print := false;
        Rec.SetupNewLine(xRec);
    end;

    trigger OnOpenPage()
    begin
        IsWebClient := not (CurrentClientType in [CLIENTTYPE::Windows, CLIENTTYPE::Desktop]);
    end;

    var
        Item: Record Item;
        Print: Boolean;
        LabelLibrary: Codeunit "NPR Label Library";
        Caption_DeletePrintedLines: Label 'Delete printed lines?';
        SkipConfirm: Boolean;
        IsWebClient: Boolean;

    procedure GetSelectionFilter(var Lines: Record "NPR Retail Journal Line")
    var
        t001: Label 'No lines chosen!\Select using mouse or keyboard';
        t002: Label 'Only one item chosen. Continue?';
    begin
        CurrPage.SetSelectionFilter(Lines);

        if not Lines.FindFirst() then
            Error(t001);

        if Lines.Count() = 1 then
            if not Confirm(t002, true) then Error('');
    end;

    internal procedure SetItemFilter(ItemNo: Code[20])
    begin
        if ItemNo = '' then
            Rec.SetRange("Item No.")
        else
            Rec.SetRange("Item No.", ItemNo);

        CurrPage.Update(false);
    end;

    internal procedure InvertSelection()
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        LabelLibrary.InvertAllLines(RecRef);
        CurrPage.Update(false);
    end;

    procedure PrintSelection(ReportType: Integer)
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
        TempRetailJnlLine: Record "NPR Retail Journal Line" temporary;
        RecRef: RecordRef;
    begin
        if IsWebClient then begin
            RetailJnlLine.SetView(Rec.GetView());
            CurrPage.SetSelectionFilter(RetailJnlLine);
            if RetailJnlLine.FindSet() then begin
                TempRetailJnlLine.SetView(RetailJnlLine.GetView());
                repeat
                    TempRetailJnlLine.Init();
                    TempRetailJnlLine := RetailJnlLine;
                    TempRetailJnlLine.Insert();
                until RetailJnlLine.Next() = 0;
            end;
            LabelLibrary.SetSelectionBuffer(TempRetailJnlLine);
        end;

        LabelLibrary.PrintSelection(ReportType);

        If SkipConfirm then
            exit;

        if Confirm(Caption_DeletePrintedLines) then begin
            RetailJnlLine.SetRange("No.", Rec."No.");
            if RetailJnlLine.FindSet() then
                repeat
                    RecRef.GetTable(RetailJnlLine);
                    if LabelLibrary.SelectionContains(RecRef) then
                        RetailJnlLine.Delete(true);
                    RecRef.Close();
                until RetailJnlLine.Next() = 0;
        end;
    end;

    internal procedure SetSkipConfirm(SkipConfirmHere: Boolean)
    begin
        SkipConfirm := SkipConfirmHere;
    end;

    internal procedure SetLineFilters(VendorFilter: Text; ItemGroupFilter: Text; ShowUnknown: Option All,"Only existing items","Only unknown items"; ShowNew: Option All,"Only existing items","Only new items"; ShowInventory: Option All,"In stock","Not in stock")
    begin
        Rec.FilterGroup(40);
        Rec.SetFilter("Vendor No.", VendorFilter);
        Rec.SetFilter("Item group", ItemGroupFilter);

        case ShowUnknown of
            ShowUnknown::All:
                begin
                    Rec.SetRange("Item No.");
                end;
            ShowUnknown::"Only existing items":
                begin
                    Rec.SetFilter("Item No.", '<>%1', '');
                end;
            ShowUnknown::"Only unknown items":
                begin
                    Rec.SetFilter("Item No.", '=%1', '');
                end;
        end;

        case ShowNew of
            ShowNew::All:
                begin
                    Rec.SetRange("New Item");
                end;
            ShowNew::"Only existing items":
                begin
                    Rec.SetRange("New Item", false);
                end;
            ShowNew::"Only new items":
                begin
                    Rec.SetRange("New Item", true);
                end;
        end;

        case ShowInventory of
            ShowInventory::All:
                begin
                    Rec.SetRange(Inventory);
                end;
            ShowInventory::"In stock":
                begin
                    Rec.SetFilter(Inventory, '>%1', 0);
                end;
            ShowInventory::"Not in stock":
                begin
                    Rec.SetFilter(Inventory, '<=%1', 0);
                end;
        end;

        Rec.FilterGroup(0);
        CurrPage.Update(false);
    end;

    local procedure TryToGetItem(ItemNo: Code[20]): Boolean
    begin
        Item.SetLoadFields("Unit Cost", "Unit Price");
        exit(Item.Get(ItemNo));
    end;
}

