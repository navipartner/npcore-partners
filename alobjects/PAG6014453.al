page 6014453 "Campaign Discount"
{
    // 001:  NPK-Henrik Ohm, 21-01-2003
    //       Medtage ikke varer med salgspris = 0.  Er tilf�jet p� ALLE punkter under dropdownknap funktioner undtagen UDSKRIV
    // //-NPR3.0e ved Simon 2005.08.02
    //   Oversaettelser
    // 
    // //-NPR3.0f ved Anders 2006.08.14
    //   Tilf�jet funktion til kopiering af rabat til alle andre regnskaber
    // 
    // //-NPR 280509 Ny menupunkt under funktion Sag 70115
    // Send to Retail Journal
    // 
    // 
    // NPR4.002.004, 01-06-10, MH - Added Function, UpdateStatus(). It corrects the status depending on "Closing date" and "Closing Time"
    //                         (Job 87927).
    // NPR4.002.004, 21-10-10, RR - Updated function to print Shelf Fronts
    // NPR4.14/BHR/20150812 CASE 220174 Added name to action
    // NPR4.14/TS/20150818 CASE 220973 Removed Starting Date and End Date
    // NPR4.14/MH/20150818  CASE 220972 Deleted deprecated Web field "Internet Campaign"
    // NPR5.27/TJ/20160926 CASE 248282 Removed fields Order Deadline, Week Of Delivery, Valuation and Campaign Ref.
    // NPR5.30/TS  /20170206  CASE 265535 Removed Action List
    // NPR5.30/BHR /20170223  CASE 265244 Copy Discount Functionality
    // NPR5.33/MHA /20170605  CASE 278733 Replaced Location and Global Dims "Customer Disc. Group Filter"
    // NPR5.36/TJ  /20170809  CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                    Removed unused variables/functions
    // NPR5.38/AP  /20171102  CASE 295330 Deleted function UpdateStatus()
    // NPR5.38/TS  /20171211  CASE 299279 Added Report Lager Kampagnestat
    // NPR5.38/TS  /20171213  CASE 299281 Added Field Comment
    // NPR5.39/JLK /20180207  CASE 304016 Corrected issue on printing shelf label
    // NPR5.42/MHA /20180521  CASE 315554 Added Period Fields to enable Weekly Condition
    // NPR5.45/TS  /20180803  CASE 308194 Removed Quantity Sold and Turnover
    // NPR5.46/JDH /20180928 CASE 294354  Added Retail Print Actions, and removed the old ones
    // NPR5.53/ALPO/20191029 CASE 369115 New control added: "Block Custom Disc."

    Caption = 'Period Discount';
    PageType = Card;
    SourceTable = "Period Discount";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Code)
                {

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field(Description; Description)
                {
                    Importance = Promoted;
                }
                field("Created Date"; "Created Date")
                {
                    Editable = false;
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    Caption = 'Last Changed';
                    Editable = false;
                }
                field(Status; Status)
                {
                }
                field("Block Custom Disc."; "Block Custom Disc.")
                {
                }
                field(Control6014404; Comment)
                {
                    ShowCaption = false;
                }
            }
            group(Conditions)
            {
                Caption = 'Conditions';
                field("Starting date 2"; "Starting Date")
                {
                    Importance = Promoted;
                    Lookup = false;
                }
                field("Ending date 2"; "Ending Date")
                {
                    Importance = Promoted;
                }
                field("Starting Time"; "Starting Time")
                {
                }
                field("Ending Time"; "Ending Time")
                {
                }
                field("Period Type"; "Period Type")
                {
                }
                group(Period)
                {
                    Caption = 'Period';
                    Visible = ("Period Type" = 1);
                    field("Period Description"; "Period Description")
                    {
                        Editable = false;
                    }
                    field(Monday; Monday)
                    {
                    }
                    field(Tuesday; Tuesday)
                    {
                    }
                    field(Wednesday; Wednesday)
                    {
                    }
                    field(Thursday; Thursday)
                    {
                    }
                    field(Friday; Friday)
                    {
                    }
                    field(Saturday; Saturday)
                    {
                    }
                    field(Sunday; Sunday)
                    {
                    }
                }
                field("Customer Disc. Group Filter"; "Customer Disc. Group Filter")
                {

                    trigger OnAssistEdit()
                    begin
                        //-NPR5.33 [278733]
                        FilterAssist(FieldNo("Customer Disc. Group Filter"));
                        //+NPR5.33 [278733]
                    end;
                }
            }
            part(SubForm; "Campaign Discount Lines")
            {
                SubPageLink = Code = FIELD(Code);
                Visible = SubFormVisible;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(DimBtn)
            {
                Caption = 'D&imension';
                Image = Dimensions;
                Visible = DimBtnVisible;
                action("Default Dimensions")
                {
                    Caption = 'Default Dimensions';
                    Image = DefaultDimension;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    var
                        NPRDimMgt: Codeunit NPRDimensionManagement;
                    begin
                        RetailSetup.Get;
                        if RetailSetup."Use Adv. dimensions" then
                            NPRDimMgt.OpenFormDefaultDimensions(DATABASE::"Period Discount", Code);
                    end;
                }
            }
            group("Lin&e")
            {
                Caption = 'Lin&e';
                action(Comment)
                {
                    Caption = 'Comment';
                    Image = Comment;
                    RunObject = Page "Retail Comments";
                    RunPageLink = "Table ID" = CONST(6014413),
                                  "No." = FIELD(Code);
                }
                action("Item Card")
                {
                    Caption = 'Item Card';
                    Image = Item;
                    ShortCutKey = 'Shift+Ctrl+C';

                    trigger OnAction()
                    var
                        Item2: Record Item;
                        PeriodDiscountLine: Record "Period Discount Line";
                    begin
                        CurrPage.SubForm.PAGE.GetRecord(PeriodDiscountLine);
                        Item2.SetRange("No.", PeriodDiscountLine."Item No.");
                        PAGE.Run(6014425, Item2, Item2."No.");
                    end;
                }
            }
            group("&Print")
            {
                Caption = '&Print';
                Image = Print;
                action(RetailPrint)
                {
                    Caption = 'Retail Print';
                    Ellipsis = true;
                    Image = BinContent;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                }
                action(PriceLabel)
                {
                    Caption = 'Price Label';
                    Image = BinContent;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                }
            }
            group("&Functions")
            {
                Caption = '&Functions';
                group("Period Discount")
                {
                    Caption = 'Period Discount';
                    Image = Transactions;
                    action("Transfer Item")
                    {
                        Caption = 'Transfer Item';
                        Image = TransferToLines;

                        trigger OnAction()
                        var
                            ErrUnitPrice: Label 'Item no. %1 does not have any salesprice';
                            ItemList: Page "Item List";
                        begin
                            Clear(ItemList);
                            ItemList.LookupMode := true;
                            if (ItemList.RunModal = ACTION::LookupOK) then begin
                                ItemList.GetRecord(Item);
                                Item.SetRange("No.", Item."No.");
                                Item.Find('-');
                                if Item."Unit Price" = 0 then
                                    Error(ErrUnitPrice, Item."No.");
                                TransferToPeriod();
                            end;
                        end;
                    }
                    action("Transfer from Item Group")
                    {
                        Caption = 'Transfer from Item Group';
                        Image = TransferToLines;

                        trigger OnAction()
                        var
                            ItemGroup: Record "Item Group";
                            ItemGroupTree: Page "Item Group Tree";
                        begin
                            Clear(ItemGroupTree);
                            ItemGroupTree.LookupMode := true;
                            if (ItemGroupTree.RunModal = ACTION::LookupOK) then begin
                                Item.Reset;
                                ItemGroupTree.GetRecord(ItemGroup);
                                Item.SetRange("Item Group", ItemGroup."No.");
                                Item.SetFilter("Unit Price", '<>0');
                                TransferToPeriod();
                            end;
                        end;
                    }
                    action("Transfer from Vendor")
                    {
                        Caption = 'Transfer from Vendor';
                        Image = TransferToLines;

                        trigger OnAction()
                        var
                            Vendor: Record Vendor;
                            VendorList: Page "Vendor List";
                        begin
                            Clear(VendorList);
                            VendorList.LookupMode := true;
                            if (VendorList.RunModal = ACTION::LookupOK) then begin
                                VendorList.GetRecord(Vendor);
                                Item.Reset;
                                Item.SetRange("Vendor No.", Vendor."No.");
                                Item.SetFilter("Unit Price", '<>0');
                                TransferToPeriod();
                            end;
                        end;
                    }
                    action("Transfer from Period Discount")
                    {
                        Caption = 'Transfer from Period Discount';
                        Image = TransferToLines;
                    }
                    action("Transfer all Items")
                    {
                        Caption = 'Transfer all Items';
                        Image = TransferToLines;

                        trigger OnAction()
                        var
                            MsgOkCancel: Label 'Do you wish to transfer all items to this period?';
                        begin
                            Item.Reset;
                            Item.SetFilter("Unit Price", '<>0');
                            if DIALOG.Confirm(MsgOkCancel, false) then
                                TransferToPeriod();
                        end;
                    }
                }
                separator(Separator1160330004)
                {
                }
                action("&Read from scanner")
                {
                    Caption = '&Read from scanner';
                    Image = "Action";

                    trigger OnAction()
                    var
                        ScannerFunctions: Codeunit "Scanner - Functions";
                    begin
                        ScannerFunctions.initCampaignDiscount(Rec);
                    end;
                }
                action("Copy to all companies")
                {
                    Caption = 'Copy to all companies';
                    Image = Copy;

                    trigger OnAction()
                    begin
                        SetRange(Code, Code);
                        REPORT.RunModal(6060100, false, false, Rec);
                        SetRange(Code);
                    end;
                }
                separator(Separator1160330020)
                {
                }
                action("Send to Retail Journal")
                {
                    Caption = 'Send to Retail Journal';
                    Image = SendTo;

                    trigger OnAction()
                    var
                        RetailJournalCode: Codeunit "Retail Journal Code";
                    begin
                        //-NPR5.46 [294354]
                        // IF PAGE.RUNMODAL(PAGE::"Retail Journal List","Retail Journal Header") <> ACTION::LookupOK THEN
                        //  EXIT;
                        // PeriodDiscountLineRec.SETRANGE(Code,Code);
                        // IF PeriodDiscountLineRec.FIND('-') THEN
                        //  REPEAT
                        //    RetailJournalLine.RESET;
                        //    RetailJournalLine.SETRANGE("No.","Retail Journal Header"."No.");
                        //    IF RetailJournalLine.FIND('+') THEN
                        //      tempInt := RetailJournalLine."Line No." + 10000
                        //    ELSE
                        //      tempInt := 10000;
                        //    tempAntal := PeriodDiscountLineRec.COUNT;
                        //
                        //    RetailJournalLine."No." := "Retail Journal Header"."No.";
                        //    RetailJournalLine."Line No." := tempInt;
                        //    RetailJournalLine.VALIDATE("Item No.",PeriodDiscountLineRec."Item No.");
                        //    RetailJournalLine."Variant Code" := PeriodDiscountLineRec."Variant Code";
                        //    RetailJournalLine."Discount Type" := 1;
                        //    RetailJournalLine."Discount Unit Price" := PeriodDiscountLineRec."Unit Price";
                        //    RetailJournalLine."Discount Price Incl. Vat" := PeriodDiscountLineRec."Campaign Unit Price";
                        //    RetailJournalLine."Discount Code" := PeriodDiscountLineRec.Code;
                        //    RetailJournalLine.INSERT(TRUE);
                        //  UNTIL PeriodDiscountLineRec.NEXT = 0;
                        // MESSAGE(txt001,tempAntal);

                        RetailJournalCode.Campaign2RetailJnl(Code, '');
                        //+NPR5.46 [294354]
                    end;
                }
                action("Copy Campaign Discount")
                {
                    Caption = 'Copy Campaign Discount';
                    Image = CopyDocument;

                    trigger OnAction()
                    var
                        PeriodDiscount1: Record "Period Discount";
                        PeriodDiscountLine1: Record "Period Discount Line";
                        PeriodDiscountLine: Record "Period Discount Line";
                    begin
                        //-NPR5.30 [265244]
                        if PAGE.RunModal(PAGE::"Campaign Discount List", PeriodDiscount1) <> ACTION::LookupOK then
                            exit;
                        PeriodDiscountLine1.Reset;
                        PeriodDiscountLine1.SetRange(Code, Code);
                        PeriodDiscountLine1.DeleteAll;

                        PeriodDiscountLine1.Reset;
                        PeriodDiscountLine1.SetRange(Code, PeriodDiscount1.Code);
                        if PeriodDiscountLine1.FindSet then
                            repeat
                                PeriodDiscountLine.Init;
                                PeriodDiscountLine.TransferFields(PeriodDiscountLine1);
                                PeriodDiscountLine.Code := Code;
                                PeriodDiscountLine.Insert(true);
                            until PeriodDiscountLine1.Next = 0;

                        //+NPR5.30 [265244]
                    end;
                }
            }
        }
        area(reporting)
        {
            action("Inventory Campaign Stat.")
            {
                Caption = 'Inventory Campaign Stat.';
                Image = "Report";
                RunObject = Report "Inventory Campaign Stat.";
            }
        }
    }

    trigger OnInit()
    begin
        DimBtnVisible := true;
        GlobDim2Visible := true;
        GlobDim1Visible := true;
        SubFormVisible := true;
    end;

    trigger OnOpenPage()
    var
        PeriodDiscount: Record "Period Discount";
    begin
        //-NPR5.38 [295330]
        //UpdateStatus();
        //+NPR5.38 [295330]
        if not PeriodDiscount.Find('-') then begin
            SubFormVisible := false;
            SubFormVisible := true;
        end;
    end;

    var
        Text10600000: Label 'Enter cost savings in % ';
        RetailSetup: Record "Retail Setup";
        Item: Record Item;
        ReportSelectionRetail: Record "Report Selection Retail";
        PeriodDiscountLineGlobal: Record "Period Discount Line";
        PeriodDiscountLineRec: Record "Period Discount Line";
        TxtDoYouWantToCopyLoc: Label 'Do you want to copy the campaign to the following locations :';
        TxtDoYouWantToCopyDim1: Label 'Do you want to copy the campaign to the following department code :';
        [InDataSet]
        SubFormVisible: Boolean;
        [InDataSet]
        GlobDim1Visible: Boolean;
        [InDataSet]
        GlobDim2Visible: Boolean;
        [InDataSet]
        DimBtnVisible: Boolean;

    procedure TransferToPeriod()
    var
        PeriodDiscountLine: Record "Period Discount Line";
        InputDialog: Page "Input Dialog";
        CampaignDiscountList: Page "Campaign Discount List";
        Percentage: Decimal;
        ErrorNo1: Label 'There are no items to transfer';
        ErrorNo2: Label 'Item No. %1 already exists in the period';
        OkMsg: Label '%1 Items has been transferred to Period %2';
    begin
        if not Item.Find('-') then
            Error(ErrorNo1);
        Clear(CampaignDiscountList);
        Percentage := 0;

        InputDialog.SetInput(1, Percentage, Text10600000);
        if InputDialog.RunModal = ACTION::OK then
            InputDialog.InputDecimal(1, Percentage);

        if Percentage = 0 then
            exit;
        repeat
            if PeriodDiscountLine.Get(Code, Item."No.") then
                Message(ErrorNo2, Item."No.")
            else begin
                PeriodDiscountLine.Init;
                PeriodDiscountLine.Code := Code;
                PeriodDiscountLine."Item No." := Item."No.";
                PeriodDiscountLine."Campaign Unit Price" := (100 - Percentage) / 100 * Item."Unit Price";
                PeriodDiscountLine."Discount %" := Percentage;
                PeriodDiscountLine.Validate("Discount Amount", Item."Unit Price" - PeriodDiscountLine."Campaign Unit Price");
                PeriodDiscountLine."Campaign Unit Cost" := Item."Unit Cost";
                PeriodDiscountLine.Description := Item.Description;
                PeriodDiscountLine."Unit Price Incl. VAT" := true;
                PeriodDiscountLine."Starting Date" := "Starting Date";
                PeriodDiscountLine."Ending Date" := "Ending Date";
                PeriodDiscountLine.Status := Status;
                // Periodelinie.VALIDATE("Unit price", Vare."Unit Price");
                PeriodDiscountLine.Insert(true);
            end;
        until Item.Next = 0;
        Message(OkMsg, Item.Count, Code);
    end;

    procedure PrintEANLabel()
    var
        RetailFormCode: Codeunit "Retail Form Code";
    begin
        //PrintEANLabel()
        CurrPage.SubForm.PAGE.GetCurrLine(PeriodDiscountLineGlobal);
        Item.Get(PeriodDiscountLineGlobal."Item No.");
        RetailFormCode.PrintLabelItemCard(Item, true, 0, true);
    end;

    procedure TransferToRetailJournalLine()
    var
        RetailJournalLine: Record "Retail Journal Line";
        NextLineNo: Integer;
        FirstLineNo: Integer;
        PeriodDiscountLine2: Record "Period Discount Line";
    begin
        if RetailJournalLine.Find('+') then;
        if RetailJournalLine."Line No." <> 0 then
            NextLineNo := RetailJournalLine."Line No." + 1
        else
            NextLineNo := 1;
        FirstLineNo := NextLineNo;

        PeriodDiscountLine2.SetRange(Code, Code);
        if PeriodDiscountLine2.Find('-') then
            repeat
                RetailJournalLine.Init();
                RetailJournalLine.Validate("Line No.", NextLineNo);
                RetailJournalLine.Validate("Item No.", PeriodDiscountLine2."Item No.");
                RetailJournalLine.Insert();
                RetailJournalLine.Validate(RetailJournalLine."Quantity to Print", 1);
                RetailJournalLine.Validate("Discount Price Incl. Vat", PeriodDiscountLine2."Campaign Unit Price");
                RetailJournalLine.Validate("Last Direct Cost", PeriodDiscountLine2."Unit Cost Purchase");
                RetailJournalLine.Modify();
                NextLineNo += 1;
            until PeriodDiscountLine2.Next = 0;

        Commit();

        Clear(RetailJournalLine);
        RetailJournalLine.SetRange("Line No.", FirstLineNo, NextLineNo);
        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Shelf Label");
        ReportSelectionRetail.SetFilter("Report ID", '<>0');
        ReportSelectionRetail.Find('-');
        repeat
            REPORT.RunModal(ReportSelectionRetail."Report ID", true, false, RetailJournalLine);
        until ReportSelectionRetail.Next = 0;
    end;

    procedure CopyCampaignsToLocations()
    var
        PeriodDiscount: Record "Period Discount";
        PeriodDiscountLine: Record "Period Discount Line";
        Location: Record Location;
        RetailList: Record "Retail List";
        RetailListPage: Page "Retail List";
        CampaignCode: Code[20];
        Counter: Integer;
        LocationsString: Text[1024];
    begin
        Clear(RetailList);
        if RetailList.Count > 0 then
            RetailList.DeleteAll;
        Counter := 1;
        if "Location Code" <> '' then
            Location.SetFilter(Code, '<>%1', "Location Code");
        if Location.Find('-') then
            repeat
                RetailList.Init;
                RetailList.Number := Counter;
                RetailList.Choice := Location.Code;
                RetailList.Insert;
                Counter := Counter + 1;
            until Location.Next = 0;
        Commit;

        Clear(RetailListPage);
        if ACTION::LookupOK = RetailListPage.RunModal then begin
            Error('Getselection filter ISSUE');
            //retailListForm.getSelectionFilter(retailListRec);
            //retailListRec.MARKEDONLY(TRUE);
            if RetailList.Find('-') then
                repeat
                    LocationsString := LocationsString + CopyStr(RetailList.Choice, 1, StrLen(RetailList.Choice)) + ',';
                until RetailList.Next = 0;

            LocationsString := CopyStr(LocationsString, 1, StrLen(LocationsString) - 1);
            if Confirm(TxtDoYouWantToCopyLoc + LocationsString + ' ?') then begin
                if RetailList.Find('-') then
                    repeat
                        if Location.Get(RetailList.Choice) then
                            Clear(PeriodDiscount);
                        PeriodDiscount.Init;
                        PeriodDiscount.Copy(Rec);
                        if StrPos(PeriodDiscount.Code, '_') > 0 then
                            CampaignCode := CopyStr(PeriodDiscount.Code, 1, StrPos(PeriodDiscount.Code, '_') - 1)
                        else
                            CampaignCode := PeriodDiscount.Code;
                        CampaignCode := CampaignCode + '_' + Location.Code;
                        PeriodDiscount.Code := CampaignCode;
                        PeriodDiscount."Location Code" := Location.Code;
                        PeriodDiscount.Insert(true);
                        PeriodDiscount."Global Dimension 1 Code" := "Global Dimension 1 Code";
                        PeriodDiscount."Global Dimension 2 Code" := "Global Dimension 2 Code";
                        PeriodDiscount.Modify(true);
                        CurrPage.SubForm.PAGE.GetCurrLine(PeriodDiscountLineGlobal);
                        PeriodDiscountLineGlobal.SetRange(Code, Code);
                        if PeriodDiscountLineGlobal.Find('-') then
                            repeat
                                Clear(PeriodDiscountLine);
                                PeriodDiscountLine.Init;
                                PeriodDiscountLine.Copy(PeriodDiscountLineGlobal);
                                PeriodDiscountLine.Code := CampaignCode;
                                PeriodDiscountLine.Insert(true);
                            until PeriodDiscountLineGlobal.Next = 0;
                        PeriodDiscountLineGlobal.SetRange(Code);
                    until RetailList.Next = 0;

            end;
        end;

        RetailList.ClearMarks;
        RetailList.Reset;
        RetailList.DeleteAll;
        Commit;
    end;

    procedure CopyCampaignsToGlobalDim1()
    var
        PeriodDiscount: Record "Period Discount";
        PeriodDiscountLine: Record "Period Discount Line";
        DimensionValue: Record "Dimension Value";
        RetailList: Record "Retail List";
        RetailListPage: Page "Retail List";
        CampaignCode: Code[20];
        Counter: Integer;
        LocationsString: Text[1024];
    begin
        Clear(RetailList);
        if RetailList.Count > 0 then
            RetailList.DeleteAll;
        Counter := 1;
        DimensionValue.SetRange("Global Dimension No.", 1);
        if "Global Dimension 1 Code" <> '' then
            DimensionValue.SetFilter(Code, '<>%1', "Global Dimension 1 Code");
        if DimensionValue.Find('-') then
            repeat
                RetailList.Init;
                RetailList.Number := Counter;
                RetailList.Choice := DimensionValue.Code;
                RetailList.Insert;
                Counter := Counter + 1;
            until DimensionValue.Next = 0;
        Commit;

        Clear(RetailListPage);
        if ACTION::LookupOK = RetailListPage.RunModal then begin
            Error('Getselection filter ISSUE');
            // retailListForm.getSelectionFilter(retailListRec);
            if RetailList.Find('-') then
                repeat
                    LocationsString := LocationsString + CopyStr(RetailList.Choice, 1, StrLen(RetailList.Choice)) + ',';
                until RetailList.Next = 0;

            LocationsString := CopyStr(LocationsString, 1, StrLen(LocationsString) - 1);
            if Confirm(TxtDoYouWantToCopyDim1 + LocationsString + ' ?') then begin
                if RetailList.Find('-') then
                    repeat
                        DimensionValue.SetCurrentKey(Code, "Global Dimension No.");
                        DimensionValue.SetRange(Code, RetailList.Choice);
                        DimensionValue.SetRange("Global Dimension No.", 1);
                        if DimensionValue.Find('-') then
                            Clear(PeriodDiscount);
                        PeriodDiscount.Init;
                        PeriodDiscount.Copy(Rec);
                        if StrPos(PeriodDiscount.Code, '_') > 0 then
                            CampaignCode := CopyStr(PeriodDiscount.Code, 1, StrPos(PeriodDiscount.Code, '_') - 1)
                        else
                            CampaignCode := PeriodDiscount.Code;
                        CampaignCode := CampaignCode + '_' + DimensionValue.Code;
                        PeriodDiscount.Code := CampaignCode;
                        PeriodDiscount."Location Code" := '';
                        PeriodDiscount.Insert(true);
                        PeriodDiscount."Global Dimension 1 Code" := DimensionValue.Code;
                        PeriodDiscount.Modify(true);
                        CurrPage.SubForm.PAGE.GetCurrLine(PeriodDiscountLineGlobal);
                        PeriodDiscountLineGlobal.SetRange(Code, Code);
                        if PeriodDiscountLineGlobal.Find('-') then
                            repeat
                                Clear(PeriodDiscountLine);
                                PeriodDiscountLine.Init;
                                PeriodDiscountLine.Copy(PeriodDiscountLineGlobal);
                                PeriodDiscountLine.Code := CampaignCode;
                                PeriodDiscountLine.Insert(true);
                            until PeriodDiscountLineGlobal.Next = 0;
                        PeriodDiscountLineGlobal.SetRange(Code);
                    until RetailList.Next = 0;

            end;
        end;

        RetailList.ClearMarks;
        RetailList.Reset;
        RetailList.DeleteAll;
        Commit;
    end;

    local procedure GetFieldCaption(CaptionFieldNo: Integer) Caption: Text
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        //-NPR5.31 [263093]
        RecRef.GetTable(Rec);
        FieldRef := RecRef.Field(CaptionFieldNo);
        Caption := FieldRef.Caption;
        exit(Caption);
        //+NPR5.31 [263093]
    end;

    local procedure GetPrimaryKeyValue(var RecRef: RecordRef): Text
    var
        FieldRef: FieldRef;
        KeyRef: KeyRef;
    begin
        //-NPR5.31 [263093]
        KeyRef := RecRef.KeyIndex(1);
        FieldRef := KeyRef.FieldIndex(KeyRef.FieldCount);
        exit(FieldRef.Value);
        //+NPR5.31 [263093]
    end;

    local procedure FilterAssist(AssistFieldNo: Integer)
    var
        RecRef: RecordRef;
        Caption: Text;
    begin
        //-NPR5.33 [278733]
        if not SetFiltersOnRecRef(AssistFieldNo, RecRef) then
            exit;
        Caption := GetFieldCaption(AssistFieldNo);
        if not RunDynamicRequestPage(Caption, RecRef) then
            exit;

        UpdateFiltersOnCurrRec(AssistFieldNo, RecRef);
        //+NPR5.33 [278733]
    end;

    local procedure RunDynamicRequestPage(Caption: Text; var RecRef: RecordRef): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
        OutStream: OutStream;
        ReturnFilters: Text;
        EntityID: Code[20];
    begin
        //-NPR5.33 [278733]
        EntityID := CopyStr(Caption, 1, 20);
        if not RequestPageParametersHelper.BuildDynamicRequestPage(FilterPageBuilder, EntityID, RecRef.Number) then
            exit(false);
        FilterPageBuilder.SetView(RecRef.Caption, RecRef.GetView);
        FilterPageBuilder.PageCaption := Caption;
        if not FilterPageBuilder.RunModal then
            exit(false);

        ReturnFilters := RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder, EntityID, RecRef.Number);

        RecRef.Reset;
        if ReturnFilters <> '' then begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText(ReturnFilters);
            if not RequestPageParametersHelper.ConvertParametersToFilters(RecRef, TempBlob) then
                exit;
        end;

        exit(true);
        //+NPR5.33 [278733]
    end;

    local procedure SetFiltersOnRecRef(FilterFieldNo: Integer; var RecRef: RecordRef): Boolean
    var
        CustomerDiscountGroup: Record "Customer Discount Group";
    begin
        //-NPR5.33 [278733]
        case FilterFieldNo of
            FieldNo("Customer Disc. Group Filter"):
                begin
                    CustomerDiscountGroup.SetFilter(Code, "Customer Disc. Group Filter");
                    RecRef.GetTable(CustomerDiscountGroup);
                    exit(true);
                end;
        end;

        exit(false);
        //+NPR5.33 [278733]
    end;

    local procedure UpdateFiltersOnCurrRec(FilterFieldNo: Integer; RecRef: RecordRef)
    var
        CurrRecRef: RecordRef;
        CurrFieldRef: FieldRef;
        PrimaryKeyFilter: Text;
    begin
        //-NPR5.33 [278733]
        CurrRecRef.GetTable(Rec);
        CurrFieldRef := CurrRecRef.Field(FilterFieldNo);

        if RecRef.IsEmpty then begin
            CurrFieldRef.Value := '';
            CurrRecRef.SetTable(Rec);
            exit;
        end;

        RecRef.FindSet;
        PrimaryKeyFilter := GetPrimaryKeyValue(RecRef);
        while RecRef.Next <> 0 do
            PrimaryKeyFilter += '|' + GetPrimaryKeyValue(RecRef);

        CurrFieldRef.Value := CopyStr(PrimaryKeyFilter, 1, CurrFieldRef.Length);
        CurrRecRef.SetTable(Rec);
        //+NPR5.33 [278733]
    end;
}

