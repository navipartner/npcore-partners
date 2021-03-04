page 6014490 "NPR Retail Journal Header"
{
    Caption = 'Retail Journal';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Retail Journal Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Control6150616)
                {
                    ShowCaption = false;
                    field("No."; "No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Code field';
                       
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Description field';
                    }
                }
                group(Control6150619)
                {
                    ShowCaption = false;
                    field("Date of creation"; "Date of creation")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Date field';
                    }
                    field("Salesperson Code"; "Salesperson Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Salesperson field';
                    }
                    field("Location Code"; "Location Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Location Code field';

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    field("Register No."; "Register No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the POS Unit No. field';
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
                }
            }
            group(Dimensions)
            {
                Caption = 'Dimensions';
                group(Control6150625)
                {
                    ShowCaption = false;
                    field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    }
                    field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    }
                }
            }
            group("Line Filters")
            {
                Caption = 'Line Filters';
                grid(Control6014422)
                {
                    GridLayout = Columns;
                    ShowCaption = false;
                    group("Vendor No.")
                    {
                        Caption = 'Vendor No.';
                        //The GridLayout property is only supported on controls of type Grid
                        //GridLayout = Rows;
                        field(VendorFilter; VendorFilter)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            TableRelation = Vendor;
                            ToolTip = 'Specifies the value of the VendorFilter field';

                            trigger OnValidate()
                            begin
                                //-NPR5.53 [374290]
                                VendorFilter := UpperCase(VendorFilter);
                                SetLineFilters();
                                //+NPR5.53 [374290]
                            end;
                        }
                    }
                    group("Item Group")
                    {
                        Caption = 'Item Group';
                        field(ItemGroupFilter; ItemGroupFilter)
                        {
                            ApplicationArea = All;
                            Caption = 'Item Group';
                            ShowCaption = false;
                            TableRelation = "NPR Item Group";
                            ToolTip = 'Specifies the value of the Item Group field';

                            trigger OnValidate()
                            begin
                                //-NPR5.53 [374290]
                                ItemGroupFilter := UpperCase(ItemGroupFilter);
                                SetLineFilters();
                                //+NPR5.53 [374290]
                            end;
                        }
                    }
                    group("Unknown Item No.")
                    {
                        Caption = 'Unknown Item No.';
                        field(ShowUnknown; ShowUnknown)
                        {
                            ApplicationArea = All;
                            Caption = 'Unknown Item No.';
                            OptionCaption = 'All,Only existing items,Only unknown items';
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Unknown Item No. field';

                            trigger OnValidate()
                            begin
                                //-NPR5.53 [374290]
                                SetLineFilters();
                                //+NPR5.53 [374290]
                            end;
                        }
                    }
                    group("New Item")
                    {
                        Caption = 'New Item';
                        field(ShowNew; ShowNew)
                        {
                            ApplicationArea = All;
                            Caption = 'New Item';
                            OptionCaption = 'All,Only existing items,Only new items';
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the New Item field';

                            trigger OnValidate()
                            begin
                                //-NPR5.53 [374290]
                                SetLineFilters();
                                //+NPR5.53 [374290]
                            end;
                        }
                    }
                    group("Inventory Status")
                    {
                        Caption = 'Inventory Status';
                        field(ShowInventory; ShowInventory)
                        {
                            ApplicationArea = All;
                            Caption = 'Inventory Status';
                            OptionCaption = 'All,In stock,Not in stock';
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Inventory Status field';

                            trigger OnValidate()
                            begin
                                //-NPR5.53 [374290]
                                SetLineFilters();
                                //+NPR5.53 [374290]
                            end;
                        }
                    }
                }
            }
            part(SubLine; "NPR Retail Journal Line")
            {
                SubPageLink = "No." = FIELD("No."),
                              "Location Filter" = FIELD("Location Code");
                SubPageView = SORTING("No.", "Line No.");
                ApplicationArea = All;
            }
        }
        area(factboxes)
        {
            part(Control6150641; "Item Invoicing FactBox")
            {
                Provider = SubLine;
                SubPageLink = "No." = FIELD("Item No.");
                ApplicationArea = All;
            }
            part(Control6150645; "NPR NP Attributes FactBox")
            {
                Provider = SubLine;
                SubPageLink = "No." = FIELD("Item No.");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Print)
            {
                Caption = '&Print';
                action("Shelf Label")
                {
                    Caption = 'Shelf Label';
                    Image = BinContent;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Shelf Label action';

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                    begin
                        CurrPage.SubLine.PAGE.PrintSelection(ReportSelectionRetail."Report Type"::"Shelf Label");
                    end;
                }
                action("Price Label")
                {
                    Caption = 'Price Label';
                    Image = BinLedger;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ShortCutKey = 'Ctrl+Alt+L';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Price Label action';

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                    begin
                        CurrPage.SubLine.PAGE.PrintSelection(ReportSelectionRetail."Report Type"::"Price Label");
                    end;
                }
                action("Sign Print")
                {
                    Caption = 'Sign Print';
                    Image = Bin;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sign Print action';

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                    begin
                        CurrPage.SubLine.PAGE.PrintSelection(ReportSelectionRetail."Report Type"::Sign);
                    end;
                }
                action(InvertSelection)
                {
                    Caption = 'Invert selection';
                    Image = Change;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Invert selection action';

                    trigger OnAction()
                    begin
                        CurrPage.SubLine.PAGE.InvertSelection;
                    end;
                }
                action("Set Print Qty to Inventory")
                {
                    Caption = 'Set Print Qty to Inventory';
                    Image = AddAction;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Set Print Qty to Inventory action';

                    trigger OnAction()
                    begin
                        //-NPR5.46 [294354]
                        SetPrintQuantityByInventory;
                        //+NPR5.46 [294354]
                    end;
                }
                separator(Separator6014407)
                {
                }
                action(List)
                {
                    Caption = 'List';
                    Image = "Report";
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ApplicationArea = All;
                    ToolTip = 'Executes the List action';

                    trigger OnAction()
                    begin
                        //-NPR5.53 [375557]
                        CurrPage.SubLine.PAGE.SetSkipConfirm(true);
                        CurrPage.SubLine.PAGE.PrintSelection(REPORT::"NPR Retail Journal List");
                        //+NPR5.53 [375557]
                    end;
                }
            }
            group(Texts)
            {
                Caption = 'Texts';
                action(GetFormItemCard)
                {
                    Caption = 'Get from Item Card';
                    Image = Card;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Get from Item Card action';

                    trigger OnAction()
                    var
                        "Retail Journal Line": Record "NPR Retail Journal Line";
                        item: Record Item;
                    begin

                        //CurrForm.SubLine.FORM.getSelectionFilter("Retail Journal Line");
                        CurrPage.SubLine.PAGE.GetSelectionFilter("Retail Journal Line");
                        if "Retail Journal Line".Find('-') then
                            repeat
                                if item.Get("Retail Journal Line"."Item No.") then begin
                                    "Retail Journal Line".Validate(Description, item.Description);
                                    "Retail Journal Line".Validate("Description 2", item."Description 2");
                                    "Retail Journal Line".Modify(true);
                                end;
                            until "Retail Journal Line".Next = 0;
                    end;
                }
            }
            group("Import From")
            {
                Caption = 'Import From';
                action(ImportFromItems)
                {
                    Caption = 'Items';
                    Image = ItemLines;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Items action';

                    trigger OnAction()
                    var
                        RetJnlImportItems: Report "NPR Ret. Jnl. - Import Items";
                    begin
                        RetJnlImportItems.SetJournal("No.");
                        RetJnlImportItems.RunModal;
                    end;
                }
                action(ImportFromPeriodDiscount)
                {
                    Caption = 'Period Discounts';
                    Image = PeriodEntries;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Period Discounts action';

                    trigger OnAction()
                    var
                        RetailJournalCode: Codeunit "NPR Retail Journal Code";
                    begin
                        //-NPR5.46 [294354]
                        // RetailJournalHeader := Rec;
                        // RetailJournalHeader.SETRECFILTER;
                        // RetJnlImpPerDisc.SETTABLEVIEW(RetailJournalHeader);
                        // RetJnlImpPerDisc.RUNMODAL;
                        // CLEAR(RetJnlImpPerDisc);
                        RetailJournalCode.Campaign2RetailJnl('', "No.");
                        CurrPage.Update(true);
                        //+NPR5.46 [294354]
                    end;
                }
                action(ImportFromMixedDiscount)
                {
                    Caption = 'Mixed Discounts';
                    Enabled = false;
                    Image = Discount;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Mixed Discounts action';

                    trigger OnAction()
                    begin
                        //-NPR5.46 [294354]
                        // RetailJournalHeader := Rec;
                        // RetailJournalHeader.SETRECFILTER;
                        // RetJnlImpMixDisc.SETTABLEVIEW(RetailJournalHeader);
                        // RetJnlImpMixDisc.RUNMODAL;
                        // CLEAR(RetJnlImpMixDisc);
                        //+NPR5.46 [294354]
                    end;
                }
                action(ImportFromTransferOrder)
                {
                    Caption = 'Transfer Order';
                    Image = PeriodEntries;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Transfer Order action';

                    trigger OnAction()
                    var
                        RetailJournalCode: Codeunit "NPR Retail Journal Code";
                    begin
                        //-NPR5.46 [294354]
                        RetailJournalCode.TransferOrder2RetailJnl('', "No.");
                        CurrPage.Update(true);
                        //+NPR5.46 [294354]
                    end;
                }
                action(ImportFromTransferShipment)
                {
                    Caption = 'Transfer Shipment';
                    Image = PeriodEntries;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Transfer Shipment action';

                    trigger OnAction()
                    var
                        RetailJournalCode: Codeunit "NPR Retail Journal Code";
                    begin
                        //-NPR5.46 [294354]
                        RetailJournalCode.TransferShipment2RetailJnl('', "No.");
                        CurrPage.Update(true);
                        //+NPR5.46 [294354]
                    end;
                }
                action(ImportFromTransferReceipt)
                {
                    Caption = 'Transfer Receipt';
                    Image = PeriodEntries;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Transfer Receipt action';

                    trigger OnAction()
                    var
                        RetailJournalCode: Codeunit "NPR Retail Journal Code";
                    begin
                        //-NPR5.46 [294354]
                        RetailJournalCode.TransferReceipt2RetailJnl('', "No.");
                        CurrPage.Update(true);
                        //+NPR5.46 [294354]
                    end;
                }
                action(ImportFromPriceLog)
                {
                    Caption = 'Retail Price Log';
                    Image = ImportLog;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Retail Price Log action';

                    trigger OnAction()
                    var
                        RetailPriceLogMgt: Codeunit "NPR Retail Price Log Mgt.";
                    begin
                        //-NPR5.40 [304031]
                        RetailPriceLogMgt.RetailJnlImportFromPriceLog(Rec);
                        CurrPage.Update(false);
                        //+NPR5.40 [304031]
                    end;
                }
            }
            group("Export to")
            {
                Caption = 'Export to ';
                action(ExportToItemCard)
                {
                    Caption = 'Export to Item Card';
                    Enabled = false;
                    Image = Card;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Export to Item Card action';

                    trigger OnAction()
                    begin
                        //-NPR5.46 [294354]
                        //CurrPage.SubLine.PAGE.GetSelectionFilter(RetailJournalLine);
                        //RetailJournalCode.ExportToItems(RetailJournalLine);
                        //+NPR5.46 [294354]
                    end;
                }
                action(ExportToOtherRetailJournal)
                {
                    Caption = 'Other Retail Journal';
                    Image = Journal;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Other Retail Journal action';

                    trigger OnAction()
                    var
                        RetailJournalLine: Record "NPR Retail Journal Line";
                    begin
                        CurrPage.SubLine.PAGE.GetSelectionFilter(RetailJournalLine);
                        RetailJournalCode.ExportToRetailJournal(RetailJournalLine);
                    end;
                }
                action(ExportToPeriodDisount)
                {
                    Caption = 'Period Discount';
                    Image = Campaign;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Period Discount action';

                    trigger OnAction()
                    var
                        RetailJournalLine: Record "NPR Retail Journal Line";
                    begin
                        CurrPage.SubLine.PAGE.GetSelectionFilter(RetailJournalLine);
                        RetailJournalCode.ExportToPeriodDiscount(RetailJournalLine);
                    end;
                }
                action(ExportToItemJournal)
                {
                    Caption = 'Item Journal';
                    Image = ItemLines;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Journal action';

                    trigger OnAction()
                    var
                        RetailJournalLine: Record "NPR Retail Journal Line";
                    begin
                        CurrPage.SubLine.PAGE.GetSelectionFilter(RetailJournalLine);
                        RetailJournalCode.ExportToItemJournal(RetailJournalLine);
                    end;
                }
                action(ExportToRequisitionWorksheet)
                {
                    Caption = 'Requisition Worksheet';
                    Image = Worksheet;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Requisition Worksheet action';

                    trigger OnAction()
                    var
                        RetailJournalLine: Record "NPR Retail Journal Line";
                    begin
                        CurrPage.SubLine.PAGE.GetSelectionFilter(RetailJournalLine);
                        RetailJournalCode.ExportToPurchaseJournal(RetailJournalLine);
                    end;
                }
                action(ExportToFile)
                {
                    Caption = 'File';
                    Image = MakeDiskette;
                    ApplicationArea = All;
                    ToolTip = 'Executes the File action';

                    trigger OnAction()
                    var
                        RetailJournalLine: Record "NPR Retail Journal Line";
                    begin
                        CurrPage.SubLine.PAGE.GetSelectionFilter(RetailJournalLine);
                        RetailJournalCode.ExportToFile(RetailJournalLine);
                    end;
                }
            }
            group(Function)
            {
                Caption = 'Function';
                action("Find Item")
                {
                    Caption = 'Find Item';
                    Image = Find;
                    ShortCutKey = 'Ctrl+F';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Find Item action';

                    trigger OnAction()
                    var
                        item1: Record Item;
                    begin
                        if PAGE.RunModal(PAGE::"Item List", item1) = ACTION::LookupOK then
                            CurrPage.SubLine.PAGE.SetItemFilter(item1."No.")
                        else
                            CurrPage.SubLine.PAGE.SetItemFilter('');
                    end;
                }
                action("Item Card")
                {
                    Caption = 'Item Card';
                    Image = Card;
                    ShortCutKey = 'Shift+F5';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Card action';

                    trigger OnAction()
                    var
                        ItemCard: Page "Item Card";
                        "Retail Journal Line": Record "NPR Retail Journal Line";
                        Item: Record Item;
                    begin

                        //CurrForm.SubLine.FORM.GETRECORD("Retail Journal Line");
                        CurrPage.SubLine.PAGE.GetRecord("Retail Journal Line");
                        Clear(ItemCard);
                        Item.Reset;
                        Item.SetRange("No.", "Retail Journal Line"."Item No.");
                        Item.Find('-');
                        ItemCard.SetRecord(Item);
                        ItemCard.RunModal;
                    end;
                }
                action("Validate Lines")
                {
                    Caption = 'Validate Lines';
                    Image = CheckList;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Validate Lines action';

                    trigger OnAction()
                    var
                        jnlLines: Record "NPR Retail Journal Line";
                        d: Dialog;
                        i: Integer;
                        n: Integer;
                        t001: Label 'Validating...';
                        t002: Label '@1@@@@@@@@@@';
                    begin

                        //CurrForm.SubLine.FORM.getSelectionFilter(jnlLines);
                        CurrPage.SubLine.PAGE.GetSelectionFilter(jnlLines);
                        d.Open(t001 + '\' + t002);

                        i := 0;

                        if jnlLines.Find('-') then begin
                            n := jnlLines.Count;
                            repeat
                                d.Update(1, Round(i / n * 10000, 1, '>'));
                                if jnlLines."Item No." = '' then
                                    jnlLines."Item No." := jnlLines.Barcode;
                                jnlLines.Validate("Item No.");
                                jnlLines.Modify(true);
                                i += 1;
                            until jnlLines.Next = 0;
                        end;
                        d.Close;
                    end;
                }
                action("Change Price on Selected Items")
                {
                    Caption = 'Change Price on Selected Items';
                    Image = PriceAdjustment;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Change Price on Selected Items action';
                }
            }
            group(Create)
            {
                Caption = 'Create';
                separator(Separator6150644)
                {
                }
                action("Update Count Code/Type")
                {
                    Caption = 'Update Count Code/Type';
                    Image = Discount;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Update Count Code/Type action';

                    trigger OnAction()
                    begin
                        UpdateDiscount(Rec);
                    end;
                }
            }
        }
        area(navigation)
        {
            action(PriceLog)
            {
                Caption = 'Retail Price Log Entries';
                Image = Log;
                RunObject = Page "NPR Retail Price Log Entries";
                ApplicationArea = All;
                ToolTip = 'Executes the Retail Price Log Entries action';
            }
        }
    }

    trigger OnOpenPage()
    begin
        //-NPR5.53 [374290]
        IsWebClient := not (CurrentClientType in [CLIENTTYPE::Windows, CLIENTTYPE::Desktop]);
        //+NPR5.53 [374290]
    end;

    var
        Text001: Label 'Discount Code and Type updated successfully';
        RetailJournalCode: Codeunit "NPR Retail Journal Code";
        VendorFilter: Text;
        ItemGroupFilter: Text;
        ShowUnknown: Option All,"Only existing items","Only unknown items";
        ShowNew: Option All,"Only existing items","Only new items";
        ShowInventory: Option All,"In stock","Not in stock";
        IsWebClient: Boolean;

    procedure UpdateDiscount(RetailJournalHeader: Record "NPR Retail Journal Header")
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        MixDiscountLine: Record "NPR Mixed Discount Line";
        MixDiscount: Record "NPR Mixed Discount";
    begin
        RetailJournalLine.Reset;
        RetailJournalLine.SetFilter(RetailJournalLine."No.", RetailJournalHeader."No.");
        //-NPR5.31 [262904]
        //IF RetailJournalLine.FINDFIRST THEN REPEAT
        if not RetailJournalLine.IsEmpty then begin
            RetailJournalLine.FindSet;
            repeat
                //+NPR5.31 [262904]
                PeriodDiscountLine.Reset;
                PeriodDiscountLine.SetFilter(PeriodDiscountLine."Starting Date", '<=%1', RetailJournalHeader."Date of creation");
                PeriodDiscountLine.SetFilter(PeriodDiscountLine."Ending Date", '>=%1', RetailJournalHeader."Date of creation");
                PeriodDiscountLine.SetFilter(PeriodDiscountLine."Item No.", RetailJournalLine."Item No.");

                if PeriodDiscountLine.FindFirst then begin
                    RetailJournalLine."Discount Code" := PeriodDiscountLine.Code;
                    RetailJournalLine."Discount Type" := RetailJournalLine."Discount Type"::Campaign;
                end else begin
                    MixDiscountLine.Reset;
                    MixDiscountLine.SetFilter(MixDiscountLine."No.", RetailJournalLine."Item No.");
                    //-NPR5.31 [262904]
                    //IF MixDiscountLine.FINDFIRST THEN REPEAT
                    //  MixDiscount.RESET;
                    MixDiscountLine.SetRange("Disc. Grouping Type", MixDiscountLine."Disc. Grouping Type"::Item);
                    if MixDiscountLine.FindFirst then begin
                        //+NPR5.31 [262904]
                        if MixDiscount.Get(MixDiscountLine.Code) and
                            ((MixDiscount."Starting date" <= RetailJournalHeader."Date of creation") and
                            (MixDiscount."Ending date" >= RetailJournalHeader."Date of creation")) then begin
                            RetailJournalLine."Discount Code" := MixDiscountLine.Code;
                            RetailJournalLine."Discount Type" := RetailJournalLine."Discount Type"::Mix;
                            //-NPR5.31 [262904]
                            //    MixDiscountLine.FINDLAST;
                            //  END;
                            //UNTIL MixDiscountLine.NEXT = 0;
                        end;
                    end;
                    //+NPR5.31 [262904]
                end;
                RetailJournalLine.Modify;
            until RetailJournalLine.Next = 0;
            //-NPR5.31 [262904]
        end;
        //+NPR5.31 [262904]
        Message(Text001);
    end;

    local procedure SetLineFilters()
    begin
        //-NPR5.53 [374290]
        CurrPage.SubLine.PAGE.SetLineFilters(VendorFilter, ItemGroupFilter, ShowUnknown, ShowNew, ShowInventory);
        //+NPR5.53 [374290]
    end;
}

