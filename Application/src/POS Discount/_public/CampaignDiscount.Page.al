page 6014453 "NPR Campaign Discount"
{
    Caption = 'Period Discount';
    ContextSensitiveHelpPage = 'docs/retail/discounts/how-to/period_discounts/';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR Period Discount";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies unique code for period discount';
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
                    ToolTip = 'Specifies the name for period discount';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the status of period discount';
                    ApplicationArea = NPRRetail;
                }
                field("Block Custom Disc."; Rec."Block Custom Disc.")
                {

                    ToolTip = 'Specifies if the custom discount is blocked';
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
                Image = Line;
                Visible = false;
                ObsoleteReason = 'Not used';
                ObsoleteState = Pending;
                ObsoleteTag = 'NPR23.0';

                action(Comment)
                {
                    Caption = 'Comment';
                    Image = Comment;
                    RunObject = Page "NPR Retail Comments";
                    RunPageLink = "Table ID" = CONST(6014413),
                                  "No." = FIELD(Code);
                    ToolTip = 'Executes the Comment action';
                    ApplicationArea = NPRRetail;

                    ObsoleteReason = 'Not used';
                    ObsoleteState = Pending;
                    ObsoleteTag = 'NPR23.0';
                }
                action("Item Card")
                {
                    Caption = 'Item Card';
                    Image = Item;
                    ShortCutKey = 'Shift+Ctrl+C';
                    ToolTip = 'Executes the Item Card action';
                    ApplicationArea = NPRRetail;

                    ObsoleteReason = 'Not used';
                    ObsoleteState = Pending;
                    ObsoleteTag = 'NPR23.0';

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
                        LabelManagement: Codeunit "NPR Label Management";
                    begin
                        LabelManagement.ChooseLabel(Rec);
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
                        LabelManagement: Codeunit "NPR Label Management";
                    begin
                        LabelManagement.PrintLabel(Rec, "NPR Report Selection Type"::"Price Label".AsInteger());
                    end;
                }
            }
            group("&Functions")
            {
                Caption = '&Functions';
                Image = Action;
                group("Period Discount")
                {
                    Caption = 'Period Discount';
                    Image = Transactions;
                    action("Transfer Item")
                    {
                        Caption = 'Transfer Items (Selection)';
                        Image = TransferToLines;

                        ToolTip = 'Executes the Transfer Items (Selection) action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            Item: Record Item;
                            ItemList: Page "Item List";
                        begin
                            ItemList.LookupMode := true;
                            if (ItemList.RunModal() = ACTION::LookupOK) then begin
                                ItemList.SetSelection(Item);
                                TransferToPeriod(Item);
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
                            Item: Record Item;
                            ItemCategory: Record "Item Category";
                            ItemCategories: Page "Item Categories";
                        begin
                            Clear(ItemCategories);
                            ItemCategories.LookupMode := true;
                            if ItemCategories.RunModal() = ACTION::LookupOK then begin
                                ItemCategories.GetRecord(ItemCategory);
                                Item.SetRange("Item Category Code", ItemCategory.Code);
                                Item.SetFilter("Unit Price", '<>0');
                                TransferToPeriod(Item);
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
                            Item: Record Item;
                            Vendor: Record Vendor;
                            VendorList: Page "Vendor List";
                        begin
                            VendorList.LookupMode := true;
                            if (VendorList.RunModal() = ACTION::LookupOK) then begin
                                VendorList.GetRecord(Vendor);
                                Item.SetRange("Vendor No.", Vendor."No.");
                                Item.SetFilter("Unit Price", '<>0');
                                TransferToPeriod(Item);
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
                            FromPeriodDiscountLine: Record "NPR Period Discount Line";
                            ToPeriodDiscountLine: Record "NPR Period Discount Line";
                            CampaignDiscounts: Page "NPR Campaign Discount List";
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
                                if FromPeriodDiscountLine.IsEmpty then
                                    Error(NoTransferedItemErr)
                                else begin
                                    if FromPeriodDiscountLine.FindSet() then
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
                        end;
                    }

                    action(TransferFromCustomerPriceGroup)
                    {
                        Caption = 'Transfer from Customer Price Group';
                        Image = TransferToLines;
                        ToolTip = 'Executes the Transfer from Customer Price Group action - system will create lines based on Sales Price List lines';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            PeriodDiscountManagement: Codeunit "NPR Period Discount Management";
                        begin
                            PeriodDiscountManagement.AddLinesBasedOnSalesPriceList(Rec);
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
                            Item: Record Item;
                            TransferItemsQst: Label 'Do you wish to transfer all items to this period?';
                        begin
                            Item.SetFilter("Unit Price", '<>0');
                            if Confirm(TransferItemsQst, false) then
                                TransferToPeriod(Item);
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
                        PeriodDiscount: Record "NPR Period Discount";
                        PeriodDiscountLine1: Record "NPR Period Discount Line";
                        PeriodDiscountLine: Record "NPR Period Discount Line";
                    begin
                        if Page.RunModal(Page::"NPR Campaign Discount List", PeriodDiscount) <> Action::LookupOK then
                            exit;
                        PeriodDiscountLine1.SetRange(Code, Rec.Code);
                        PeriodDiscountLine1.DeleteAll();

                        PeriodDiscountLine1.Reset();
                        PeriodDiscountLine1.SetRange(Code, PeriodDiscount.Code);
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
            action("NPR ImportFromScanner")
            {
                Caption = 'Import from scanner';
                Image = Import;
                ToolTip = 'Start importing the file from the scanner.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    InventorySetup: Record "Inventory Setup";
                    ScannerImportMgt: Codeunit "NPR Scanner Import Mgt.";
                    RecRef: RecordRef;
                begin
                    if not InventorySetup.Get() then
                        exit;

                    RecRef.GetTable(Rec);
                    ScannerImportMgt.ImportFromScanner(InventorySetup."NPR Scanner Provider", Enum::"NPR Scanner Import"::CAMPAIGNDISCOUNT, RecRef);
                end;
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

    internal procedure TransferToPeriod(var Item: Record Item)
    var
        PeriodDiscountLine: Record "NPR Period Discount Line";
        InputDialog: Page "NPR Input Dialog";
        ProgressWindow: Dialog;
        Percentage: Decimal;
        NoTransferred: Integer;
        RecNo: Integer;
        TotalRecNo: Integer;
        ItemsAlreadyIncluded: TextBuilder;
        ItemsWOutPrice: TextBuilder;
        AlreadyExistsErr: Label 'The following items already exist in the period:\%1.', Comment = '%1 - list of items';
        ZeroPriceErr: Label 'The following items have not been transferred due to missing item price:\%1.', Comment = '%1 - list of items';
        TransferItemNoErr: Label 'There are no items to transfer';
        OkMsg: Label '%1 Items have been transferred to Period %2', Comment = '%1 = No. of items, %2 = Period no.';
        EnterCostsLbl: Label 'Enter cost savings in % ';
        WindowTxt1: Label 'Processing items...\\';
        WindowTxt2: Label '@1@@@@@@@@@@@@@@@@@@@';
    begin
        if Item.IsEmpty() then
            Error(TransferItemNoErr);

        Percentage := 0;
        InputDialog.SetInput(1, Percentage, EnterCostsLbl);
        if InputDialog.RunModal() = ACTION::OK then
            InputDialog.InputDecimal(1, Percentage);
        if Percentage = 0 then
            exit;

        ProgressWindow.Open(
            WindowTxt1 +
            WindowTxt2);
        TotalRecNo := Item.Count();

        Item.FindSet();
        repeat
            case true of
                Item."Unit Price" = 0:
                    AddItemToList(Item."No.", ItemsWOutPrice);
                PeriodDiscountLine.Get(Rec.Code, Item."No."):
                    AddItemToList(Item."No.", ItemsAlreadyIncluded);
                else begin
                    PeriodDiscountLine.Init();
                    PeriodDiscountLine.Code := Rec.Code;
                    PeriodDiscountLine."Item No." := Item."No.";
                    PeriodDiscountLine."Campaign Unit Price" := (100 - Percentage) / 100 * Item."Unit Price";
                    PeriodDiscountLine."Discount %" := Percentage;
                    PeriodDiscountLine.Validate("Discount Amount", Item."Unit Price" - PeriodDiscountLine."Campaign Unit Price");
                    PeriodDiscountLine."Campaign Unit Cost" := Item."Unit Cost";
                    PeriodDiscountLine."Starting Date" := Rec."Starting Date";
                    PeriodDiscountLine."Ending Date" := Rec."Ending Date";
                    PeriodDiscountLine.Status := Rec.Status;
                    PeriodDiscountLine.Insert(true);
                    NoTransferred += 1;
                end;
            end;
            RecNo += 1;
            ProgressWindow.Update(1, Round(RecNo / TotalRecNo * 10000, 1));
        until Item.Next() = 0;

        ProgressWindow.Close();
        Message(OkMsg, NoTransferred, Rec.Code);
        if ItemsWOutPrice.Length <> 0 then
            Message(ZeroPriceErr, ItemsWOutPrice.ToText().TrimEnd('|'));
        if ItemsAlreadyIncluded.Length <> 0 then
            Message(AlreadyExistsErr, ItemsAlreadyIncluded.ToText().TrimEnd('|'));
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

    local procedure AddItemToList(ItemNo: Code[20]; var DestinationItemNoList: TextBuilder)
    begin
        if ItemNo = '' then
            exit;
        DestinationItemNoList.Append(ItemNo + '|');
    end;
}
