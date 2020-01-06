page 6014472 "Retail Journal Line"
{
    // //- NE 08/07-05
    //   Rettet import tilbage til at bruge forms.
    // // RR 31-07-2008
    //   Rettet s� Alternativ Varenr tjekkes ved indtastning af varenr.
    // // NPR 190609 Sag 68963
    // Ny felter tilf�jet
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

    AutoSplitKey = true;
    Caption = 'Label Printing Subform';
    DelayedInsert = true;
    MultipleNewLines = false;
    PageType = ListPart;
    SourceTable = "Retail Journal Line";
    SourceTableView = SORTING ("No.", "Line No.");

    layout
    {
        area(content)
        {
            group(Control6014453)
            {
                ShowCaption = false;
                grid(Control6014452)
                {
                    GridLayout = Columns;
                    ShowCaption = false;
                    group("Vendor No.")
                    {
                        Caption = 'Vendor No.';
                        //The GridLayout property is only supported on controls of type Grid
                        //GridLayout = Rows;
                        field("Vendor.""No."""; Vendor."No.")
                        {
                            ShowCaption = false;

                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                if PAGE.RunModal(PAGE::"Vendor List", Vendor) = ACTION::LookupOK then begin
                                    SetRange("Vendor No.", Vendor."No.");
                                end;
                                CurrPage.Update(false);
                            end;

                            trigger OnValidate()
                            begin
                                if Vendor."No." <> '' then begin
                                    Vendor.Get(Vendor."No.");
                                    SetRange("Vendor No.", Vendor."No.");
                                end else begin
                                    Clear(Vendor);
                                    SetRange("Vendor No.");
                                end;
                                VendorNoOnAfterValidate;
                            end;
                        }
                    }
                    group("Item Group")
                    {
                        Caption = 'Item Group';
                        field("Itemgroup.""No."""; Itemgroup."No.")
                        {
                            Caption = 'Item Group';
                            ShowCaption = false;

                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                if PAGE.RunModal(PAGE::"Item Group Tree", Itemgroup) = ACTION::LookupOK then begin
                                    SetRange("Item group", Itemgroup."No.");
                                end;
                                CurrPage.Update(false);
                            end;

                            trigger OnValidate()
                            begin
                                if Itemgroup."No." <> '' then begin
                                    Itemgroup.Get(Itemgroup."No.");
                                    SetRange("Item group", Itemgroup."No.");
                                end else begin
                                    Clear(Itemgroup);
                                    SetRange("Item group");
                                end;
                                ItemgroupNoOnAfterValidate;
                            end;
                        }
                    }
                    group("Unknown Item No.")
                    {
                        Caption = 'Unknown Item No.';
                        field(ShowUnknown; ShowUnknown)
                        {
                            Caption = 'Unknown Item No.';
                            OptionCaption = 'All,Only existing items,Only unknown items';
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                case ShowUnknown of
                                    ShowUnknown::All:
                                        SetRange("Item No.");
                                    ShowUnknown::"Only existing items":
                                        SetFilter("Item No.", '<>%1', '');
                                    ShowUnknown::"Only unknown items":
                                        SetFilter("Item No.", '=%1', '');
                                end;
                                ShowUnknownOnAfterValidate;
                            end;
                        }
                    }
                    group("New Item")
                    {
                        Caption = 'New Item';
                        field(ShowNew; ShowNew)
                        {
                            Caption = 'New Item';
                            OptionCaption = 'All,Only existing items,Only new items';
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                case ShowNew of
                                    ShowNew::All:
                                        SetRange("New Item");
                                    ShowNew::"Only existing items":
                                        SetRange("New Item", false);
                                    ShowNew::"Only new items":
                                        SetRange("New Item", true);
                                end;
                                ShowNewOnAfterValidate;
                            end;
                        }
                    }
                    group("Inventory Status")
                    {
                        Caption = 'Inventory Status';
                        field(ShowInventory; ShowInventory)
                        {
                            Caption = 'Inventory Status';
                            OptionCaption = 'All,In stock,Not in stock';
                            ShowCaption = false;

                            trigger OnValidate()
                            begin
                                case ShowInventory of
                                    ShowInventory::All:
                                        SetRange(Inventory);
                                    ShowInventory::"In stock":
                                        SetFilter(Inventory, '>%1', 0);
                                    ShowInventory::"Not in stock":
                                        SetFilter(Inventory, '<=%1', 0);
                                end;
                                if Find('-') then;
                                ShowInventoryOnAfterValidate;
                            end;
                        }
                    }
                }
            }
            group(Control6014440)
            {
                ShowCaption = false;
            }
            repeater(Control6014441)
            {
                ShowCaption = false;
                field("Calculation Date"; "Calculation Date")
                {
                }
                field("Item No."; "Item No.")
                {
                    Lookup = true;
                }
                field("Quantity to Print"; "Quantity to Print")
                {
                }
                field(Print; Print)
                {
                    Caption = 'Print';

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
                }
                field("Vendor Item No."; "Vendor Item No.")
                {
                }
                field(Barcode; Barcode)
                {
                }
                field("Unit Price"; "Unit Price")
                {
                }
                field("Item.""Unit Price"""; Item."Unit Price")
                {
                    Caption = 'Unit price(Item Card)';
                    Editable = false;
                    Visible = true;
                }
                field("Last Direct Cost"; "Last Direct Cost")
                {
                }
                field("Item.""Unit Cost"""; Item."Unit Cost")
                {
                    Caption = 'Unit cost';
                    Editable = false;
                    Visible = false;
                }
                field("Profit % (new)"; "Profit % (new)")
                {
                    Visible = true;
                }
                field(Inventory; Inventory)
                {
                }
                field("Register No."; "Register No.")
                {
                }
                field("Customer Price Group"; "Customer Price Group")
                {
                }
                field("Customer Disc. Group"; "Customer Disc. Group")
                {
                }
                field("New Item No."; "New Item No.")
                {
                    Visible = false;
                }
                field("Serial No."; "Serial No.")
                {
                }
                field("Variant Code"; "Variant Code")
                {
                }
                field("Description 2"; "Description 2")
                {
                    Visible = false;
                }
                field("Base Unit of measure"; "Base Unit of measure")
                {
                    Visible = false;
                }
                field("Purch. Unit of measure"; "Purch. Unit of measure")
                {
                    Visible = false;
                }
                field("Sales Unit of measure"; "Sales Unit of measure")
                {
                    Visible = false;
                }
                field("Quantity for Discount Calc"; "Quantity for Discount Calc")
                {
                }
                field("Discount Type"; "Discount Type")
                {
                }
                field("Discount Code"; "Discount Code")
                {
                }
                field("Variant Code 2"; "Variant Code")
                {
                    Visible = false;
                }
                field("Discount Pct."; "Discount Pct.")
                {
                }
                field("Discount Price Incl. Vat"; "Discount Price Incl. Vat")
                {
                }
                field("Discount Price Excl. VAT"; "Discount Price Excl. VAT")
                {
                    Editable = false;
                }
                field("Unit List Price"; "Unit List Price")
                {
                }
                field("VAT %"; "VAT %")
                {
                    Editable = false;
                }
                field("Item group Field"; "Item group")
                {
                    Visible = false;
                }
                field(Control6014407; "Vendor No.")
                {
                    ShowCaption = false;
                    Visible = false;
                }
                field("Vendor Name"; "Vendor Name")
                {
                    Editable = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if PAGE.RunModal(PAGE::"Vendor List", Vendor) = ACTION::LookupOK then begin
                            "Vendor No." := Vendor."No.";
                            vendorName := Vendor.Name;
                            Modify(true);
                        end;
                    end;
                }
                field("Net Change"; "Net Change")
                {
                }
                field("Purchases (Qty.)"; "Purchases (Qty.)")
                {
                }
                field("Sales (Qty.)"; "Sales (Qty.)")
                {
                }
                field("Cannot edit unit price"; "Cannot edit unit price")
                {
                    Visible = false;
                }
                field("Exchange Label"; "Exchange Label")
                {

                    trigger OnValidate()
                    begin
                        //-NPR5.50 [350435]
                        CurrPage.Update;
                        //+NPR5.50 [350435]
                    end;
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
        if not Item.Get("Item No.") then
            Item.Init;

        vendorName := '';
        if Vendor.Get("Vendor No.") then
            vendorName := Vendor.Name;
        CalcFields(Inventory);
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
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Print := false;
        //-NPR5.46 [294354]
        SetupNewLine(xRec);
        //+NPR5.46 [294354]
    end;

    var
        Item: Record Item;
        Utility: Codeunit Utility;
        Vendor: Record Vendor;
        Itemgroup: Record "Item Group";
        ShowUnknown: Option All,"Only existing items","Only unknown items";
        ShowNew: Option All,"Only existing items","Only new items";
        ShowInventory: Option All,"In stock","Not in stock";
        ShowAvance: Option Alle,Positiv,Negativ;
        vendorName: Text[50];
        Print: Boolean;
        LabelLibrary: Codeunit "Label Library";
        Caption_DeletePrintedLines: Label 'Delete printed lines?';

    procedure DeleteLines()
    begin
        DeleteAll;
    end;

    procedure RoundIt(dec1: Decimal): Decimal
    begin
        exit(Utility.FormatDec2Dec(dec1, 2));
    end;

    procedure GetSelectionFilter(var Lines: Record "Retail Journal Line")
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

    local procedure VendorNoOnAfterValidate()
    begin
        CurrPage.Update(false);
    end;

    local procedure ItemgroupNoOnAfterValidate()
    begin
        CurrPage.Update(false);
    end;

    local procedure ShowUnknownOnAfterValidate()
    begin
        CurrPage.Update(false);
    end;

    local procedure ShowNewOnAfterValidate()
    begin
        CurrPage.Update(false);
    end;

    local procedure ShowInventoryOnAfterValidate()
    begin
        CurrPage.Update(false);
    end;

    local procedure ShowAvanceOnAfterValidate()
    begin
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
        RetailJnlLine: Record "Retail Journal Line";
        RecRef: RecordRef;
    begin
        LabelLibrary.PrintSelection(ReportType);

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
}

