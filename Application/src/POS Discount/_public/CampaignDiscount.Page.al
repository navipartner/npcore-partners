page 6014453 "NPR Campaign Discount"
{
    Caption = 'Period Discount';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR Period Discount";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Created Date"; Rec."Created Date")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Created Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {

                    Caption = 'Last Changed';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Changed field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Block Custom Disc."; Rec."Block Custom Disc.")
                {

                    ToolTip = 'Specifies the value of the Block Custom Discount field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Conditions)
            {
                Caption = 'Conditions';
                field("Starting date 2"; Rec."Starting Date")
                {

                    Importance = Promoted;
                    Lookup = false;
                    ToolTip = 'Specifies the value of the Starting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending date 2"; Rec."Ending Date")
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Closing Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Time"; Rec."Starting Time")
                {

                    ToolTip = 'Specifies the value of the Starting Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Time"; Rec."Ending Time")
                {

                    ToolTip = 'Specifies the value of the Closing Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Period Type"; Rec."Period Type")
                {

                    ToolTip = 'Specifies the value of the Period Type field';
                    ApplicationArea = NPRRetail;
                }
                group(Period)
                {
                    Caption = 'Period';
                    Visible = (Rec."Period Type" = 1);
                    field("Period Description"; Rec."Period Description")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Period Description field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Monday; Rec.Monday)
                    {

                        ToolTip = 'Specifies the value of the Monday field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Tuesday; Rec.Tuesday)
                    {

                        ToolTip = 'Specifies the value of the Tuesday field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Wednesday; Rec.Wednesday)
                    {

                        ToolTip = 'Specifies the value of the Wednesday field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Thursday; Rec.Thursday)
                    {

                        ToolTip = 'Specifies the value of the Thursday field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Friday; Rec.Friday)
                    {

                        ToolTip = 'Specifies the value of the Friday field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Saturday; Rec.Saturday)
                    {

                        ToolTip = 'Specifies the value of the Saturday field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Sunday; Rec.Sunday)
                    {

                        ToolTip = 'Specifies the value of the Sunday field';
                        ApplicationArea = NPRRetail;
                    }
                }
                field("Customer Disc. Group Filter"; Rec."Customer Disc. Group Filter")
                {

                    ToolTip = 'Specifies the value of the Customer Disc. Group Filter field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        FilterAssist(Rec.FieldNo("Customer Disc. Group Filter"));
                    end;
                }
            }
            part(SubForm; "NPR Campaign Discount Lines")
            {
                SubPageLink = Code = Field(Code);
                Visible = SubFormVisible;
                ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Comment action';
                    ApplicationArea = NPRRetail;
                }
                action("Item Card")
                {
                    Caption = 'Item Card';
                    Image = Item;
                    ShortCutKey = 'Shift+Ctrl+C';

                    ToolTip = 'Executes the Item Card action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Retail Print action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        LabelLibrary: Codeunit "NPR Label Library";
                    begin
                        LabelLibrary.ChooseLabel(Rec);
                    end;
                }
                action(PriceLabel)
                {
                    Caption = 'Price Label';
                    Image = BinContent;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the Price Label action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
                        LabelLibrary: Codeunit "NPR Label Library";
                    begin
                        LabelLibrary.PrintLabel(Rec, ReportSelectionRetail."Report Type"::"Price Label");
                    end;
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

                        ToolTip = 'Executes the Transfer Item action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            ErrUnitPrice: Label 'Item no. %1 does not have any salesprice';
                            ItemList: Page "Item List";
                        begin
                            Clear(ItemList);
                            ItemList.LookupMode := true;
                            if (ItemList.RunModal() = ACTION::LookupOK) then begin
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

                        ToolTip = 'Executes the Transfer from Item Category action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            ItemCategory: Record "Item Category";
                            ItemCategories: Page "Item Categories";
                        begin
                            Clear(ItemCategories);
                            ItemCategories.LookupMode := true;
                            if (ItemCategories.RunModal() = ACTION::LookupOK) then begin
                                Item.Reset();
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

                        ToolTip = 'Executes the Transfer from Vendor action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            Vendor: Record Vendor;
                            VendorList: Page "Vendor List";
                        begin
                            Clear(VendorList);
                            VendorList.LookupMode := true;
                            if (VendorList.RunModal() = ACTION::LookupOK) then begin
                                VendorList.GetRecord(Vendor);
                                Item.Reset();
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

                        ToolTip = 'Executes the Transfer from Period Discount action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            FromPeriodDiscount: Record "NPR Period Discount";
                            CampaignDiscounts: Page "NPR Campaign Discount List";
                            FromPeriodDiscountLine: Record "NPR Period Discount Line";
                            ToPeriodDiscountLine: Record "NPR Period Discount Line";
                            NoTransferedItemErr: Label 'There are no items to transfer';
                            ItemAlreadyExistErr: Label 'Item No. %1 already exists in the period', Comment = '%1 = Item No.';
                            OkMsg: Label '%1 Items has been transferred to Period %2', Comment = '%1 = Number of Items, %2 = Period';
                        begin
                            FromPeriodDiscount.SetFilter(Code, '<>%1', Rec.Code);
                            CampaignDiscounts.LookupMode := true;
                            CampaignDiscounts.Editable := false;
                            CampaignDiscounts.SetTableView(FromPeriodDiscount);
                            if CampaignDiscounts.RunModal() = ACTION::LookupOK then begin
                                CampaignDiscounts.GetRecord(FromPeriodDiscount);
                                FromPeriodDiscountLine.SetRange(Code, FromPeriodDiscount.Code);
                                if not FromPeriodDiscountLine.FindSet() then
                                    Error(NoTransferedItemErr)
                                else
                                    repeat
                                        if ToPeriodDiscountLine.Get(Rec.Code, FromPeriodDiscountLine."Item No.", FromPeriodDiscountLine."Variant Code") then
                                            Message(ItemAlreadyExistErr, FromPeriodDiscountLine."Item No.")
                                        else begin
                                            ToPeriodDiscountLine.Init();
                                            ToPeriodDiscountLine := FromPeriodDiscountLine;
                                            ToPeriodDiscountLine.Code := Rec.Code;
                                            ToPeriodDiscountLine.Insert(true);
                                        end;
                                    until FromPeriodDiscountLine.Next() = 0;
                                Message(OkMsg, FromPeriodDiscountLine.Count, Rec.Code);
                            end;
                        end;
                    }
                    action("Transfer all Items")
                    {
                        Caption = 'Transfer all Items';
                        Image = TransferToLines;

                        ToolTip = 'Executes the Transfer all Items action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            MsgOkCancel: Label 'Do you wish to transfer all items to this period?';
                        begin
                            Item.Reset();
                            Item.SetFilter("Unit Price", '<>0');
                            if DIALOG.Confirm(MsgOkCancel, false) then
                                TransferToPeriod();
                        end;
                    }
                }
                action("Send to Retail Journal")
                {
                    Caption = 'Send to Retail Journal';
                    Image = SendTo;

                    ToolTip = 'Executes the Send to Retail Journal action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        RetailJournalCode: Codeunit "NPR Retail Journal Code";
                    begin
                        RetailJournalCode.Campaign2RetailJnl(Rec.Code, '');
                    end;
                }
                action("Copy Campaign Discount")
                {
                    Caption = 'Copy Campaign Discount';
                    Image = CopyDocument;

                    ToolTip = 'Executes the Copy Campaign Discount action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        PeriodDiscount1: Record "NPR Period Discount";
                        PeriodDiscountLine1: Record "NPR Period Discount Line";
                        PeriodDiscountLine: Record "NPR Period Discount Line";
                    begin
                        if Page.RunModal(Page::"NPR Campaign Discount List", PeriodDiscount1) <> Action::LookupOK then
                            exit;
                        PeriodDiscountLine1.Reset();
                        PeriodDiscountLine1.SetRange(Code, Rec.Code);
                        PeriodDiscountLine1.DeleteAll();

                        PeriodDiscountLine1.Reset();
                        PeriodDiscountLine1.SetRange(Code, PeriodDiscount1.Code);
                        if PeriodDiscountLine1.FindSet() then
                            repeat
                                PeriodDiscountLine.Init();
                                PeriodDiscountLine.TransferFields(PeriodDiscountLine1);
                                PeriodDiscountLine.Code := Rec.Code;
                                PeriodDiscountLine.Insert(true);
                            until PeriodDiscountLine1.Next() = 0;
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

                ToolTip = 'Executes the Inventory Campaign Stat. action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnInit()
    begin
        SubFormVisible := true;
    end;

    trigger OnOpenPage()
    var
        PeriodDiscount: Record "NPR Period Discount";
    begin
        if not PeriodDiscount.Find('-') then begin
            SubFormVisible := false;
            SubFormVisible := true;
        end;
    end;

    var
        Text10600000: Label 'Enter cost savings in % ';
        Item: Record Item;
        [InDataSet]
        SubFormVisible: Boolean;

    internal procedure TransferToPeriod()
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
        if InputDialog.RunModal() = ACTION::OK then
            InputDialog.InputDecimal(1, Percentage);

        if Percentage = 0 then
            exit;
        repeat
            if PeriodDiscountLine.Get(Rec.Code, Item."No.") then
                Message(ErrorNo2, Item."No.")
            else begin
                PeriodDiscountLine.Init();
                PeriodDiscountLine.Code := Rec.Code;
                PeriodDiscountLine."Item No." := Item."No.";
                PeriodDiscountLine."Campaign Unit Price" := (100 - Percentage) / 100 * Item."Unit Price";
                PeriodDiscountLine."Discount %" := Percentage;
                PeriodDiscountLine.Validate("Discount Amount", Item."Unit Price" - PeriodDiscountLine."Campaign Unit Price");
                PeriodDiscountLine."Campaign Unit Cost" := Item."Unit Cost";
                PeriodDiscountLine.Description := Item.Description;
                PeriodDiscountLine."Unit Price Incl. VAT" := true;
                PeriodDiscountLine."Starting Date" := Rec."Starting Date";
                PeriodDiscountLine."Ending Date" := Rec."Ending Date";
                PeriodDiscountLine.Status := Rec.Status;
                PeriodDiscountLine.Insert(true);
            end;
        until Item.Next() = 0;
        Message(OkMsg, Item.Count, Rec.Code);
    end;

    local procedure GetFieldCaption(CaptionFieldNo: Integer) Caption: Text
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.GetTable(Rec);
        FieldRef := RecRef.Field(CaptionFieldNo);
        Caption := FieldRef.Caption;
        exit(Caption);
    end;

    local procedure GetPrimaryKeyValue(var RecRef: RecordRef): Text
    var
        FieldRef: FieldRef;
        KeyRef: KeyRef;
    begin
        KeyRef := RecRef.KeyIndex(1);
        FieldRef := KeyRef.FieldIndex(KeyRef.FieldCount);
        exit(FieldRef.Value);
    end;

    local procedure FilterAssist(AssistFieldNo: Integer)
    var
        RecRef: RecordRef;
        Caption: Text;
    begin
        if not SetFiltersOnRecRef(AssistFieldNo, RecRef) then
            exit;

        Caption := GetFieldCaption(AssistFieldNo);
        if not RunDynamicRequestPage(Caption, RecRef) then
            exit;

        UpdateFiltersOnCurrRec(AssistFieldNo, RecRef);
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
        EntityID := CopyStr(Caption, 1, 20);
        if not RequestPageParametersHelper.BuildDynamicRequestPage(FilterPageBuilder, EntityID, RecRef.Number) then
            exit(false);

        FilterPageBuilder.SetView(RecRef.Caption, RecRef.GetView());
        FilterPageBuilder.PageCaption := Caption;
        if not FilterPageBuilder.RunModal() then
            exit(false);

        ReturnFilters := RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder, EntityID, RecRef.Number);

        RecRef.Reset();
        if ReturnFilters <> '' then begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText(ReturnFilters);
            if not RequestPageParametersHelper.ConvertParametersToFilters(RecRef, TempBlob) then
                exit;
        end;

        exit(true);
    end;

    local procedure SetFiltersOnRecRef(FilterFieldNo: Integer; var RecRef: RecordRef): Boolean
    var
        CustomerDiscountGroup: Record "Customer Discount Group";
    begin
        case FilterFieldNo of
            Rec.FieldNo("Customer Disc. Group Filter"):
                begin
                    CustomerDiscountGroup.SetFilter(Code, Rec."Customer Disc. Group Filter");
                    RecRef.GetTable(CustomerDiscountGroup);
                    exit(true);
                end;
        end;

        exit(false);
    end;

    local procedure UpdateFiltersOnCurrRec(FilterFieldNo: Integer; RecRef: RecordRef)
    var
        CurrRecRef: RecordRef;
        CurrFieldRef: FieldRef;
        PrimaryKeyFilter: Text;
    begin
        CurrRecRef.GetTable(Rec);
        CurrFieldRef := CurrRecRef.Field(FilterFieldNo);

        if RecRef.IsEmpty() then begin
            CurrFieldRef.Value := '';
            CurrRecRef.SetTable(Rec);
            exit;
        end;

        RecRef.FindSet();
        PrimaryKeyFilter := GetPrimaryKeyValue(RecRef);
        while RecRef.Next() <> 0 do
            PrimaryKeyFilter += '|' + GetPrimaryKeyValue(RecRef);

        CurrFieldRef.Value := CopyStr(PrimaryKeyFilter, 1, CurrFieldRef.Length);
        CurrRecRef.SetTable(Rec);
    end;
}
