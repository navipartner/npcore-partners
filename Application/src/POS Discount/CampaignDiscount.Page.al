page 6014453 "NPR Campaign Discount"
{
    Caption = 'Period Discount';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Period Discount";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Created Date"; "Created Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Created Date field';
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = All;
                    Caption = 'Last Changed';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Changed field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Block Custom Disc."; "Block Custom Disc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Block Custom Discount field';
                }
            }
            group(Conditions)
            {
                Caption = 'Conditions';
                field("Starting date 2"; "Starting Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Lookup = false;
                    ToolTip = 'Specifies the value of the Starting Date field';
                }
                field("Ending date 2"; "Ending Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Closing Date field';
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Time field';
                }
                field("Ending Time"; "Ending Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closing Time field';
                }
                field("Period Type"; "Period Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Type field';
                }
                group(Period)
                {
                    Caption = 'Period';
                    Visible = ("Period Type" = 1);
                    field("Period Description"; "Period Description")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Period Description field';
                    }
                    field(Monday; Monday)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Monday field';
                    }
                    field(Tuesday; Tuesday)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Tuesday field';
                    }
                    field(Wednesday; Wednesday)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Wednesday field';
                    }
                    field(Thursday; Thursday)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Thursday field';
                    }
                    field(Friday; Friday)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Friday field';
                    }
                    field(Saturday; Saturday)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Saturday field';
                    }
                    field(Sunday; Sunday)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sunday field';
                    }
                }
                field("Customer Disc. Group Filter"; "Customer Disc. Group Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Disc. Group Filter field';

                    trigger OnAssistEdit()
                    begin
                        //-NPR5.33 [278733]
                        FilterAssist(FieldNo("Customer Disc. Group Filter"));
                        //+NPR5.33 [278733]
                    end;
                }
            }
            part(SubForm; "NPR Campaign Discount Lines")
            {
                SubPageLink = Code = FIELD(Code);
                Visible = SubFormVisible;
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("Lin&e")
            {
                Caption = 'Lin&e';
                action(Comment)
                {
                    Caption = 'Comment';
                    Image = Comment;
                    RunObject = Page "NPR Retail Comments";
                    RunPageLink = "Table ID" = CONST(6014413),
                                  "No." = FIELD(Code);
                    ApplicationArea = All;
                    ToolTip = 'Executes the Comment action';
                }
                action("Item Card")
                {
                    Caption = 'Item Card';
                    Image = Item;
                    ShortCutKey = 'Shift+Ctrl+C';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Card action';

                    trigger OnAction()
                    var
                        Item2: Record Item;
                        PeriodDiscountLine: Record "NPR Period Discount Line";
                    begin
                        CurrPage.SubForm.PAGE.GetRecord(PeriodDiscountLine);
                        Item2.SetRange("No.", PeriodDiscountLine."Item No.");
                        PAGE.Run(Page::"Item Card", Item2, Item2."No.");
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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Retail Print action';
                }
                action(PriceLabel)
                {
                    Caption = 'Price Label';
                    Image = BinContent;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Price Label action';
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
                        ApplicationArea = All;
                        ToolTip = 'Executes the Transfer Item action';

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
                    action("Transfer from Item Category")
                    {
                        Caption = 'Transfer from Item Category';
                        Image = TransferToLines;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Transfer from Item Category action';

                        trigger OnAction()
                        var
                            ItemCategory: Record "Item Category";
                            ItemCategories: Page "Item Categories";
                        begin
                            Clear(ItemCategories);
                            ItemCategories.LookupMode := true;
                            if (ItemCategories.RunModal = ACTION::LookupOK) then begin
                                Item.Reset;
                                ItemCategories.GetRecord(ItemCategory);
                                Item.SetRange("Item Category Code", ItemCategory.Code);
                                Item.SetFilter("Unit Price", '<>0');
                                TransferToPeriod();
                            end;
                        end;
                    }
                    action("Transfer from Vendor")
                    {
                        Caption = 'Transfer from Vendor';
                        Image = TransferToLines;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Transfer from Vendor action';

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
                        ApplicationArea = All;
                        ToolTip = 'Executes the Transfer from Period Discount action';
                    }
                    action("Transfer all Items")
                    {
                        Caption = 'Transfer all Items';
                        Image = TransferToLines;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Transfer all Items action';

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
                action("Copy to all companies")
                {
                    Caption = 'Copy to all companies';
                    Image = Copy;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Copy to all companies action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send to Retail Journal action';

                    trigger OnAction()
                    var
                        RetailJournalCode: Codeunit "NPR Retail Journal Code";
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Copy Campaign Discount action';

                    trigger OnAction()
                    var
                        PeriodDiscount1: Record "NPR Period Discount";
                        PeriodDiscountLine1: Record "NPR Period Discount Line";
                        PeriodDiscountLine: Record "NPR Period Discount Line";
                    begin
                        //-NPR5.30 [265244]
                        if PAGE.RunModal(PAGE::"NPR Campaign Discount List", PeriodDiscount1) <> ACTION::LookupOK then
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
                RunObject = Report "NPR Inventory Campaign Stat.";
                ApplicationArea = All;
                ToolTip = 'Executes the Inventory Campaign Stat. action';
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
        PeriodDiscount: Record "NPR Period Discount";
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
        Item: Record Item;
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        PeriodDiscountLineGlobal: Record "NPR Period Discount Line";
        PeriodDiscountLineRec: Record "NPR Period Discount Line";
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
        PeriodDiscountLine: Record "NPR Period Discount Line";
        InputDialog: Page "NPR Input Dialog";
        CampaignDiscountList: Page "NPR Campaign Discount List";
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

