page 6014490 "Retail Journal Header"
{
    // NPR70.00.01.01/MH/20140819  Removed WEBRETAIL functionality: Removed Menu Item; Function --> Generate Report and Mail.
    // NPR4.14/TS/20150218 CASE 206013 Added Missing Code in Function Import From ->Scanner
    // NPR4.14/TS/20150218 CASE 221050 Change Caption Item Card to Export Til Item Card
    // NPR4.15/TS/20151013 CASE 224751 Added NpAttribute Factbox
    // NPR4.16/JDH/20151016 CASE 225285 Removed Action ImportFromExternaldatabase - Not used any more
    // NPR4.18/MMV/20151210 CASE 229221 Unify how label printing of lines are handled.
    //                                  Disabled actions "Shelf Label" & "Sign" since they are not used currently. Should be rewritten if needed.
    // NPR5.22/MMV/20160420 CASE 237743 Updated references to label library CU.
    //                                  Reenabled & refactored action "Shelf Label".
    // NPR5.23/MMV/20160510 CASE 240211 Changed "Shelf Label" to work via print selection buffer.
    //                                  Renabled "Sign" action and refactored to work via print selection buffer.
    // NPR5.23/JDH /20160513 CASE 240916 Deleted old VariaX Matrix Action
    // NPR5.30/TS  /20170206 CASE 265531 Correct Action Caption
    // NPR5.30/MMV /20170221 CASE 266517 Renamed label action caption.
    // NPR5.31/MHA /20170110 CASE 262904 Added filter on MixDiscountLine."Disc. Grouping Type"::Item in UpdateDiscount()
    // NPR5.36/MMV /20170919 CASE 290792 Deleted action "Check Barcodes".
    // NPR5.37/MMV /20171024 CASE 294148 Promoted print actions for tablet (POS) use.
    // NPR5.40/MHA /20180316 CASE 304031 Added Action ImportFromPriceLog and PriceLog
    // NPR5.46/JDH /20180926 CASE 294354 Action Export to Item Card removed. Its replaced by Item Worksheet. Recoded some import and export actions, and added a few new fields
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action
    // NPR5.48/TS  /20180104 CASE 338609 Added Shortcut Ctrl+Alt+L to Price Label
    // NPR5.49/ZESO/20190214 CASE 334538 Reworked Function for Sales Return

    Caption = 'Retail Journal';
    PageType = Card;
    SourceTable = "Retail Journal Header";

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
                    field("No.";"No.")
                    {

                        trigger OnAssistEdit()
                        begin
                            if AssistEdit(xRec) then
                              CurrPage.Update;
                        end;
                    }
                    field(Description;Description)
                    {
                        Importance = Promoted;
                    }
                }
                group(Control6150619)
                {
                    ShowCaption = false;
                    field("Date of creation";"Date of creation")
                    {
                    }
                    field("Salesperson Code";"Salesperson Code")
                    {
                    }
                    field("Location Code";"Location Code")
                    {

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    field("Register No.";"Register No.")
                    {
                    }
                    field("Customer Price Group";"Customer Price Group")
                    {
                    }
                    field("Customer Disc. Group";"Customer Disc. Group")
                    {
                    }
                }
            }
            group(Dimensions)
            {
                Caption = 'Dimensions';
                group(Control6150625)
                {
                    ShowCaption = false;
                    field("Shortcut Dimension 1 Code";"Shortcut Dimension 1 Code")
                    {
                    }
                    field("Shortcut Dimension 2 Code";"Shortcut Dimension 2 Code")
                    {
                    }
                }
            }
            part(SubLine;"Retail Journal Line")
            {
                SubPageLink = "No."=FIELD("No."),
                              "Location Filter"=FIELD("Location Code");
                SubPageView = SORTING("No.","Line No.");
            }
        }
        area(factboxes)
        {
            part(Control6150641;"Item Invoicing FactBox")
            {
                Provider = SubLine;
                SubPageLink = "No."=FIELD("Item No.");
            }
            part(Control6150645;"NP Attributes FactBox")
            {
                Provider = SubLine;
                SubPageLink = "No."=FIELD("Item No.");
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
                    PromotedCategory = "Report";

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "Report Selection Retail";
                    begin
                        CurrPage.SubLine.PAGE.PrintSelection(ReportSelectionRetail."Report Type"::"Shelf Label");
                    end;
                }
                action("Price Label")
                {
                    Caption = 'Price Label';
                    Image = BinLedger;
                    Promoted = true;
                    PromotedCategory = "Report";
                    ShortCutKey = 'Ctrl+Alt+L';

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "Report Selection Retail";
                    begin
                        CurrPage.SubLine.PAGE.PrintSelection(ReportSelectionRetail."Report Type"::"Price Label");
                    end;
                }
                action("Sign Print")
                {
                    Caption = 'Sign Print';
                    Image = Bin;
                    Promoted = true;
                    PromotedCategory = "Report";

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "Report Selection Retail";
                    begin
                        CurrPage.SubLine.PAGE.PrintSelection(ReportSelectionRetail."Report Type"::Sign);
                    end;
                }
                action(InvertSelection)
                {
                    Caption = 'Invert selection';
                    Image = Change;
                    Promoted = true;
                    PromotedCategory = "Report";

                    trigger OnAction()
                    begin
                        CurrPage.SubLine.PAGE.InvertSelection;
                    end;
                }
                action("Set Print Qty to Inventory")
                {
                    Caption = 'Set Print Qty to Inventory';
                    Image = AddAction;

                    trigger OnAction()
                    begin
                        //-NPR5.46 [294354]
                        SetPrintQuantityByInventory;
                        //+NPR5.46 [294354]
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

                    trigger OnAction()
                    var
                        "Retail Journal Line": Record "Retail Journal Line";
                        item: Record Item;
                    begin

                        //CurrForm.SubLine.FORM.getSelectionFilter("Retail Journal Line");
                        CurrPage.SubLine.PAGE.GetSelectionFilter("Retail Journal Line");
                        if "Retail Journal Line".Find('-') then repeat
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

                    trigger OnAction()
                    var
                        RetJnlImportItems: Report "Ret. Jnl. - Import Items";
                    begin
                        RetJnlImportItems.SetJournal("No.");
                        RetJnlImportItems.RunModal;
                    end;
                }
                action(ImportFromScanner)
                {
                    Caption = 'Scanner';
                    Image = MiniForm;

                    trigger OnAction()
                    var
                        LabelPrintLine: Record "Retail Journal Line";
                        Scanner: Codeunit "Scanner - Functions";
                    begin
                        //-NPR4.14
                        CurrPage.SubLine.PAGE.GetRecord(LabelPrintLine);
                        //+NPR4.14
                        Scanner.initRetailJournal( Rec );
                    end;
                }
                action(ImportFromPeriodDiscount)
                {
                    Caption = 'Period Discounts';
                    Image = PeriodEntries;

                    trigger OnAction()
                    var
                        RetailJournalCode: Codeunit "Retail Journal Code";
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
                action(ImportFromReturnSales)
                {
                    Caption = 'Return Sales';
                    Enabled = false;
                    Image = ReturnReceipt;
                    Visible = false;

                    trigger OnAction()
                    begin
                        //-NPR5.46 [294354]
                        // RetailJournalHeader.GET("No.");
                        // RetailJournalHeader.SETRECFILTER;
                        // REPORT.RUNMODAL(REPORT::"Ret. Jnl. - Imp. Return Sales", TRUE, FALSE, RetailJournalHeader);
                        //+NPR5.46 [294354]


                        //-NPR5.49 [334538]
                        RetailJournalCode.SalesReturn2RetailJnl("No.");
                        //-NPR5.49 [334538]
                    end;
                }
                action(ImportFromTransferOrder)
                {
                    Caption = 'Transfer Order';
                    Image = PeriodEntries;

                    trigger OnAction()
                    var
                        RetailJournalCode: Codeunit "Retail Journal Code";
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

                    trigger OnAction()
                    var
                        RetailJournalCode: Codeunit "Retail Journal Code";
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

                    trigger OnAction()
                    var
                        RetailJournalCode: Codeunit "Retail Journal Code";
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

                    trigger OnAction()
                    var
                        RetailPriceLogMgt: Codeunit "Retail Price Log Mgt.";
                    begin
                        //-NPR5.40 [304031]
                        RetailPriceLogMgt.RetailJnlImportFromPriceLog(Rec);
                        CurrPage.Update(false);
                        //+NPR5.40 [304031]
                    end;
                }
            }
            group("Export to ")
            {
                Caption = 'Export to ';
                action(ExportToItemCard)
                {
                    Caption = 'Export to Item Card';
                    Enabled = false;
                    Image = Card;
                    Visible = false;

                    trigger OnAction()
                    begin
                        //-NPR5.46 [294354]
                        //CurrPage.SubLine.PAGE.GetSelectionFilter(RetailJournalLine);
                        //RetailJournalCode.ExportToItems(RetailJournalLine);
                        //+NPR5.46 [294354]
                    end;
                }
                action(ExportToScanner)
                {
                    Caption = 'Scanner';
                    Image = MiniForm;

                    trigger OnAction()
                    var
                        RetailJournalLine: Record "Retail Journal Line";
                        ScannerFunctions: Codeunit "Scanner - Functions";
                    begin
                        CurrPage.SubLine.PAGE.GetSelectionFilter(RetailJournalLine);
                        ScannerFunctions.GoSend(RetailJournalLine)
                    end;
                }
                action(ExportToOtherRetailJournal)
                {
                    Caption = 'Other Retail Journal';
                    Image = Journal;

                    trigger OnAction()
                    var
                        RetailJournalLine: Record "Retail Journal Line";
                    begin
                        CurrPage.SubLine.PAGE.GetSelectionFilter(RetailJournalLine);
                        RetailJournalCode.ExportToRetailJournal(RetailJournalLine);
                    end;
                }
                action(ExportToPeriodDisount)
                {
                    Caption = 'Period Discount';
                    Image = Campaign;

                    trigger OnAction()
                    var
                        RetailJournalLine: Record "Retail Journal Line";
                    begin
                        CurrPage.SubLine.PAGE.GetSelectionFilter(RetailJournalLine);
                        RetailJournalCode.ExportToPeriodDiscount(RetailJournalLine);
                    end;
                }
                action(ExportToItemJournal)
                {
                    Caption = 'Item Journal';
                    Image = ItemLines;

                    trigger OnAction()
                    var
                        RetailJournalLine: Record "Retail Journal Line";
                    begin
                        CurrPage.SubLine.PAGE.GetSelectionFilter(RetailJournalLine);
                        RetailJournalCode.ExportToItemJournal(RetailJournalLine);
                    end;
                }
                action(ExportToRequisitionWorksheet)
                {
                    Caption = 'Requisition Worksheet';
                    Image = Worksheet;

                    trigger OnAction()
                    var
                        RetailJournalLine: Record "Retail Journal Line";
                    begin
                        CurrPage.SubLine.PAGE.GetSelectionFilter(RetailJournalLine);
                        RetailJournalCode.ExportToPurchaseJournal(RetailJournalLine);
                    end;
                }
                action(ExportToFile)
                {
                    Caption = 'File';
                    Image = MakeDiskette;

                    trigger OnAction()
                    var
                        RetailJournalLine: Record "Retail Journal Line";
                    begin
                        CurrPage.SubLine.PAGE.GetSelectionFilter(RetailJournalLine);
                        RetailJournalCode.ExportToFile(RetailJournalLine);
                    end;
                }
            }
            group("Function")
            {
                Caption = 'Function';
                action("Find Item")
                {
                    Caption = 'Find Item';
                    Image = Find;
                    ShortCutKey = 'Ctrl+F';

                    trigger OnAction()
                    var
                        item1: Record Item;
                    begin
                        if PAGE.RunModal(PAGE::"Item List",item1)=ACTION::LookupOK then
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

                    trigger OnAction()
                    var
                        ItemCard: Page "Retail Item Card";
                        "Retail Journal Line": Record "Retail Journal Line";
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

                    trigger OnAction()
                    var
                        jnlLines: Record "Retail Journal Line";
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
                            d.Update(1, Round(i/n*10000,1, '>'));
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
                RunObject = Page "Retail Price Log Entries";
            }
        }
    }

    var
        Text001: Label 'Discount Code and Type updated successfully';
        RetailJournalCode: Codeunit "Retail Journal Code";

    procedure UpdateDiscount(RetailJournalHeader: Record "Retail Journal Header")
    var
        RetailJournalLine: Record "Retail Journal Line";
        PeriodDiscountLine: Record "Period Discount Line";
        MixDiscountLine: Record "Mixed Discount Line";
        MixDiscount: Record "Mixed Discount";
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
            PeriodDiscountLine.SetFilter(PeriodDiscountLine."Item No.",RetailJournalLine."Item No.");

            if PeriodDiscountLine.FindFirst then begin
              RetailJournalLine."Discount Code" := PeriodDiscountLine.Code;
              RetailJournalLine."Discount Type" := RetailJournalLine."Discount Type"::Campaign;
            end else begin
              MixDiscountLine.Reset;
              MixDiscountLine.SetFilter(MixDiscountLine."No.",RetailJournalLine."Item No.");
              //-NPR5.31 [262904]
              //IF MixDiscountLine.FINDFIRST THEN REPEAT
              //  MixDiscount.RESET;
              MixDiscountLine.SetRange("Disc. Grouping Type",MixDiscountLine."Disc. Grouping Type"::Item);
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
}

