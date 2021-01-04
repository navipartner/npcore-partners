page 6014472 "NPR Retail Journal Line"
{
    // //- NE 08/07-05
    //   Rettet import tilbage til at bruge forms.
    // // RR 31-07-2008
    //   Rettet så Alternativ Varenr tjekkes ved indtastning af varenr.
    // // NPR 190609 Sag 68963
    // Ny felter tilf¢jet
    // 50020     StartDate
    // 50021     CustomerPriceGroupcode
    // 
    // VRT1.00/JDH/20150305  CASE 201022 colour of Price field is formatted from new price tables
    // NPR4.16/BHR/20151106 CASE 226777 set size of variable VendorName from 30 to 50 caracters
    // NPR4.18/MMV/20160105 CASE 229221 Unify how label printing of lines are handled.
    // NPR5.22/MMV/20160420 CASE 237743 Updated references to label library CU.
    // NPR5.23/JDH /20160516 CASE 240916 Removed old references to VariaX
    // NPR5.29/MMV /20161122 CASE 259110 Removed CurrPage.UPDATE() on Print Validate
    // NPR5.34/MMV /20170719 CASE 282048 Delete prompt after all print operations.
    // NPR5.41/TS  /20180105 CASE 300893 Restored Group Property
    // NPR5.45/BHR /20180829 CASE 326412 Added fields Vat % and Unit Price excl. Vat
    // NPR5.46/JDH /20180926 CASE 294354 Removed Field "Update". it has been discontinued. "Show Avance" discontinued as well
    // NPR5.47/BHR /20181018 CASE 331700 Add the field 85 "Unit List price"
    // NPR5.49/BHR /20190220 CASE 344000 Added the field Inventory, "Net Change","Purchases (Qty.)","Sales (Qty.)"
    // NPR5.49/TJ  /20190307 CASE 345733 New control Exchange Label
    // NPR5.50/ALST/20190408 CASE 350435 page update added
    // NPR5.52/YAHA/20190609 CASE 367384 Field Re positioning
    // NPR5.53/TJ  /20191119 CASE 375557 New function SetSkipConfirm
    // NPR5.53/MHA /20191121 CASE 374290 Moved filter fields to Main Page
    // NPR5.54/SARA/20200316 CASE 395769 Re activate button 'Invert Selection'
    // NPR5.55/MMV /20200708 CASE 407265 Added field "RFID Tag Value"

    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Retail Journal Line";
    SourceTableView = SORTING("No.", "Line No.");

    layout
    {
        area(content)
        {
            repeater(Control6014441)
            {
                ShowCaption = false;
                field(ItemNo; ItemNo)
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                    Lookup = true;
                    TableRelation = Item;
                    ToolTip = 'Specifies the value of the Item No. field';

                    trigger OnValidate()
                    begin
                        //-NPR5.53 [374290]
                        Validate("Item No.", ItemNo);
                        Clear(Item);
                        if Item.Get(ItemNo) then;
                        //+NPR5.53 [374290]
                    end;
                }
                field("Calculation Date"; "Calculation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Calculation Date field';
                }
                field("Quantity to Print"; "Quantity to Print")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity to Print field';
                }
                field(Print; Print)
                {
                    ApplicationArea = All;
                    Caption = 'Print';
                    ToolTip = 'Specifies the value of the Print field';

                    trigger OnValidate()
                    var
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        LabelLibrary.ToggleLine(RecRef);
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Vendor Item No."; "Vendor Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Item No. field';
                }
                field(Barcode; Barcode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Barcode field';
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Item.""Unit Price"""; Item."Unit Price")
                {
                    ApplicationArea = All;
                    Caption = 'Unit price(Item Card)';
                    Editable = false;
                    Visible = true;
                    ToolTip = 'Specifies the value of the Unit price(Item Card) field';
                }
                field("Last Direct Cost"; "Last Direct Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Direct Cost field';
                }
                field("Item.""Unit Cost"""; Item."Unit Cost")
                {
                    ApplicationArea = All;
                    Caption = 'Unit cost';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Unit cost field';
                }
                field("Profit % (new)"; "Profit % (new)")
                {
                    ApplicationArea = All;
                    Visible = true;
                    ToolTip = 'Specifies the value of the Profit % (new) field';
                }
                field(Inventory; Inventory)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inventory field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("Customer Price Group"; "Customer Price Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Price Group field';
                }
                field("Customer Disc. Group"; "Customer Disc. Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Disc. Group field';
                }
                field("New Item No."; "New Item No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the New Item No. field';
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serial No. field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 2 field';
                }
                field("Base Unit of measure"; "Base Unit of measure")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Base Unit of measure field';
                }
                field("Purch. Unit of measure"; "Purch. Unit of measure")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Purch. Unit of measure field';
                }
                field("Sales Unit of measure"; "Sales Unit of measure")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sales Unit of measure field';
                }
                field("Quantity for Discount Calc"; "Quantity for Discount Calc")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity for Discount Calculation field';
                }
                field("Discount Type"; "Discount Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Type field';
                }
                field("Discount Code"; "Discount Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Code field';
                }
                field("Variant Code 2"; "Variant Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Discount Pct."; "Discount Pct.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount % field';
                }
                field("Discount Price Incl. Vat"; "Discount Price Incl. Vat")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Price Incl. Vat field';
                }
                field("Discount Price Excl. VAT"; "Discount Price Excl. VAT")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Discount Price Excl. VAT field';
                }
                field("Unit List Price"; "Unit List Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit List Price field';
                }
                field("VAT %"; "VAT %")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the VAT % field';
                }
                field("Item group Field"; "Item group")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Item group field';
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Vendor No. field';
                }
                field("Vendor Name"; "Vendor Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Vendor Name field';
                }
                field("Net Change"; "Net Change")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Net Change field';
                }
                field("Purchases (Qty.)"; "Purchases (Qty.)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchases (Qty.) field';
                }
                field("Sales (Qty.)"; "Sales (Qty.)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales (Qty.) field';
                }
                field("Cannot edit unit price"; "Cannot edit unit price")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Can''t edit unit price field';
                }
                field("Exchange Label"; "Exchange Label")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Exchange Label field';

                    trigger OnValidate()
                    begin
                        //-NPR5.50 [350435]
                        CurrPage.Update;
                        //+NPR5.50 [350435]
                    end;
                }
                field("RFID Tag Value"; "RFID Tag Value")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the RFID Tag Value field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        Vendor: Record Vendor;
        RecRef: RecordRef;
    begin
        //-NPR5.53 [374290]
        ItemNo := "Item No.";
        //+NPR5.53 [374290]
        if not Item.Get("Item No.") then
            Item.Init;
        calcProfit;

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

        ItemNo := '';
        Clear(Item);
        //+NPR5.53 [374290]
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //-NPR5.53 [374290]
        ItemNo := '';
        Clear(Item);
        //+NPR5.53 [374290]
        Print := false;
        //-NPR5.46 [294354]
        SetupNewLine(xRec);
        //+NPR5.46 [294354]
    end;

    trigger OnOpenPage()
    begin
        //-NPR5.53 [374290]
        IsWebClient := not (CurrentClientType in [CLIENTTYPE::Windows, CLIENTTYPE::Desktop]);
        //+NPR5.53 [374290]
    end;

    var
        Item: Record Item;
        Print: Boolean;
        LabelLibrary: Codeunit "NPR Label Library";
        Caption_DeletePrintedLines: Label 'Delete printed lines?';
        SkipConfirm: Boolean;
        IsWebClient: Boolean;
        ItemNo: Text;

    procedure DeleteLines()
    begin
        DeleteAll;
    end;

    procedure RoundIt(dec1: Decimal): Decimal
    var
        Utility: Codeunit "NPR Utility";
    begin
        exit(Utility.FormatDec2Dec(dec1, 2));
    end;

    procedure GetSelectionFilter(var Lines: Record "NPR Retail Journal Line")
    var
        t001: Label 'No lines chosen!\Select using mouse or keyboard';
        t002: Label 'Only one item chosen. Continue?';
    begin
        CurrPage.SetSelectionFilter(Lines);

        if not Lines.FindFirst then
            Error(t001);

        if Lines.Count = 1 then
            if not Confirm(t002, true) then Error('');
    end;

    procedure SetItemFilter(ItemNo1: Code[20])
    begin
        if ItemNo1 = '' then
            SetRange("Item No.")
        else
            SetRange("Item No.", ItemNo1);

        CurrPage.Update(false);
    end;

    procedure InvertSelection()
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
        //-NPR5.53 [374290]
        if IsWebClient then begin
            CurrPage.SetSelectionFilter(RetailJnlLine);
            if RetailJnlLine.FindSet then
                repeat
                    TempRetailJnlLine.Init;
                    TempRetailJnlLine := RetailJnlLine;
                    TempRetailJnlLine.Insert;
                until RetailJnlLine.Next = 0;
            LabelLibrary.SetSelectionBuffer(TempRetailJnlLine);
        end;
        //+NPR5.53 [374290]

        LabelLibrary.PrintSelection(ReportType);

        //-NPR5.53 [375557]
        if SkipConfirm then
            exit;
        //+NPR5.53 [375557]
        //-NPR5.34 [282048]
        if Confirm(Caption_DeletePrintedLines) then begin
            RetailJnlLine.SetRange("No.", "No.");
            if RetailJnlLine.FindSet then
                repeat
                    RecRef.GetTable(RetailJnlLine);
                    if LabelLibrary.SelectionContains(RecRef) then
                        RetailJnlLine.Delete(true);
                    RecRef.Close;
                until RetailJnlLine.Next = 0;
        end;
        //+NPR5.34 [282048]
    end;

    procedure SetSkipConfirm(SkipConfirmHere: Boolean)
    begin
        //-NPR5.53 [375557]
        SkipConfirm := SkipConfirmHere;
        //+NPR5.53 [375557]
    end;

    procedure SetLineFilters(VendorFilter: Text; ItemGroupFilter: Text; ShowUnknown: Option All,"Only existing items","Only unknown items"; ShowNew: Option All,"Only existing items","Only new items"; ShowInventory: Option All,"In stock","Not in stock")
    begin
        //-NPR5.53 [374290]
        FilterGroup(40);
        SetFilter("Vendor No.", VendorFilter);
        SetFilter("Item group", ItemGroupFilter);

        case ShowUnknown of
            ShowUnknown::All:
                begin
                    SetRange("Item No.");
                end;
            ShowUnknown::"Only existing items":
                begin
                    SetFilter("Item No.", '<>%1', '');
                end;
            ShowUnknown::"Only unknown items":
                begin
                    SetFilter("Item No.", '=%1', '');
                end;
        end;

        case ShowNew of
            ShowNew::All:
                begin
                    SetRange("New Item");
                end;
            ShowNew::"Only existing items":
                begin
                    SetRange("New Item", false);
                end;
            ShowNew::"Only new items":
                begin
                    SetRange("New Item", true);
                end;
        end;

        case ShowInventory of
            ShowInventory::All:
                begin
                    SetRange(Inventory);
                end;
            ShowInventory::"In stock":
                begin
                    SetFilter(Inventory, '>%1', 0);
                end;
            ShowInventory::"Not in stock":
                begin
                    SetFilter(Inventory, '<=%1', 0);
                end;
        end;

        FilterGroup(0);
        CurrPage.Update(false);
        //+NPR5.53 [374290]
    end;
}

