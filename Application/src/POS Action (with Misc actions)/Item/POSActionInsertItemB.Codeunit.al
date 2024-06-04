codeunit 6059854 "NPR POS Action: Insert Item B"
{
    Access = Internal;

    var
        _BaseLineNo: Integer;
        _SkipCalcDiscount: Boolean;

    procedure GetItem(var Item: Record Item; var ItemReference: Record "Item Reference"; ItemIdentifier: Text; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin)
    var
        ItemSearchErrLbl: Label 'Could not find a matching item for input %1';
        SentryScope: Codeunit "NPR Sentry Scope";
        SentryActionSpan: Codeunit "NPR Sentry Span";
        SentryGetItemSpan: Codeunit "NPR Sentry Span";
    begin
        SentryScope.TryGetActiveSpan(SentryActionSpan);
        SentryActionSpan.StartChildSpan('bc.workflow.ITEM.get', 'bc.workflow.ITEM.get', SentryGetItemSpan);

        if not Item.AreFieldsLoaded(GTIN) then
            Item.AddLoadFields(GTIN);

        Clear(ItemReference);
        case ItemIdentifierType of
            ItemIdentifierType::ItemNo:
                Item.Get(ItemIdentifier);
            ItemIdentifierType::ItemCrossReference:
                begin
                    ItemReference.SetCurrentKey("Reference Type", "Reference No.");
                    ItemReference.SetRange("Reference No.", CopyStr(ItemIdentifier, 1, MaxStrLen(ItemReference."Reference No.")));
                    ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
                    ItemReference.SetLoadFields("Item No.", "Variant Code", "Unit of Measure", "Reference No.", "Reference Type");
                    if not (ItemReference.Find('-') and (ItemReference.Next() = 0)) then
                        if PAGE.RunModal(0, ItemReference) <> ACTION::LookupOK then
                            Error('');

                    Item.Get(ItemReference."Item No.");
                end;

            ItemIdentifierType::ItemSearch:
                if GetItemFromItemSearch(ItemIdentifier) then
                    Item.Get(ItemIdentifier)
                else
                    Error(ItemSearchErrLbl, ItemIdentifier);

            ItemIdentifierType::SerialNoItemCrossReference:
                begin
                    ItemReference.SetCurrentKey("Reference Type", "Reference No.");
                    ItemReference.SetRange("Reference No.", CopyStr(ItemIdentifier, 1, MaxStrLen(ItemReference."Reference No.")));
                    ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"NPR Retail Serial No.");
                    ItemReference.SetLoadFields("Item No.", "Variant Code", "Unit of Measure", "Reference No.", "Reference Type");
                    if not (ItemReference.Find('-') and (ItemReference.Next() = 0)) then
                        if PAGE.RunModal(0, ItemReference) <> ACTION::LookupOK then
                            Error('');

                    Item.Get(ItemReference."Item No.");
                end;
            ItemIdentifierType::ItemGtin:
                begin
                    Item.SetRange(GTIN, ItemIdentifier);
                    Item.FindFirst();
                end;
        end;
        ItemReference."Item No." := Item."No.";

        SentryGetItemSpan.Finish();
    end;

    procedure AddItemLine(ItemNo: Code[20]; ItemQuantity: Decimal; UnitPrice: Decimal; CustomDescription: Text; CustomDescription2: Text; InputSerial: Text; InputLot: Text)
    var
        POSSession: Codeunit "NPR POS Session";
        FrontEnd: Codeunit "NPR POS Front End Management";
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin;
    begin
        POSSession.GetFrontEnd(FrontEnd);
        Item.Get(ItemNo);
        AddItemLine(Item, ItemReference, ItemIdentifierType::ItemNo, ItemQuantity, UnitPrice, CustomDescription, CustomDescription2, InputSerial, POSSession, FrontEnd, InputLot);
    end;

    procedure AddItemLine(Item: Record Item; ItemReference: Record "Item Reference"; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin; ItemQuantity: Decimal; UnitPrice: Decimal; CustomDescription: Text; CustomDescription2: Text; InputSerial: Text; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; BenefitItem: Boolean; TotalDiscountCode: Code[20]; TotalDiscountStepAmount: Decimal; benefitListCode: Code[20]; InputLot: Text)
    begin
        AddItemLine(Item, ItemReference, ItemIdentifierType::ItemNo, ItemQuantity, '', UnitPrice, CustomDescription, CustomDescription2, InputSerial, POSSession, FrontEnd, BenefitItem, TotalDiscountCode, TotalDiscountStepAmount, benefitListCode, InputLot);
    end;

    procedure AddItemLine(Item: Record Item; ItemReference: Record "Item Reference"; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin; ItemQuantity: Decimal; UnitOfMeasure: Code[10]; UnitPrice: Decimal; CustomDescription: Text; CustomDescription2: Text; InputSerial: Text; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; BenefitItem: Boolean; TotalDiscountCode: Code[20]; TotalDiscountStepAmount: Decimal; benefitListCode: Code[20]; InputLot: Text)
    var
        Line: Record "NPR POS Sale Line";
        SaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if ItemQuantity = 0 then
            ItemQuantity := 1;

        Line."Line Type" := Line."Line Type"::Item;
        Line.Quantity := ItemQuantity;

        case ItemIdentifierType of
            ItemIdentifierType::ItemSearch,
            ItemIdentifierType::ItemNo,
            ItemIdentifierType::ItemGtin:
                begin
                    Line."No." := Item."No.";
                    Line."Variant Code" := ItemReference."Variant Code";
                end;

            ItemIdentifierType::ItemCrossReference:
                begin
                    Line."No." := ItemReference."Item No.";
                    Line."Variant Code" := ItemReference."Variant Code";
                    Line."Unit of Measure Code" := ItemReference."Unit of Measure";
                    if (ItemReference."Reference Type" = ItemReference."Reference Type"::"NPR Retail Serial No.") then
                        Line."Serial No. not Created" := ItemReference."Reference No.";
                end;

            ItemIdentifierType::SerialNoItemCrossReference:
                begin

                    SaleLinePOS.Reset();
                    SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
                    SaleLinePOS.SetRange("Serial No. not Created", ItemReference."Reference No.");
                    if not SaleLinePOS.IsEmpty then
                        exit;

                    Line."No." := ItemReference."Item No.";
                    Line."Variant Code" := ItemReference."Variant Code";
                    Line."Unit of Measure Code" := ItemReference."Unit of Measure";
                    if (ItemReference."Reference Type" = ItemReference."Reference Type"::"NPR Retail Serial No.") then
                        Line."Serial No. not Created" := ItemReference."Reference No.";
                end;
        end;

        if InputSerial <> '' then
            Line.Validate("Serial No.", InputSerial);

        if InputLot <> '' then
            Line.Validate("Lot No.", InputLot);

        if CustomDescription <> '' then
            Line.Description := CopyStr(CustomDescription, 1, MaxStrLen(Line.Description));

        if CustomDescription2 <> '' then
            Line."Description 2" := CopyStr(CustomDescription2, 1, MaxStrLen(Line."Description 2"));

        if UnitOfMeasure <> '' then
            Line."Unit of Measure Code" := UnitOfMeasure;

        Line."Unit Price" := UnitPrice;
        Line."Benefit Item" := BenefitItem;
        Line."Total Discount Code" := TotalDiscountCode;
        Line."Total Discount Step" := TotalDiscountStepAmount;
        Line."Benefit List Code" := benefitListCode;

        if (Line."Line Type" = Line."Line Type"::Item) then
            Line."Initial Group Sale Price" := UnitPrice;

        Line.SetSkipCalcDiscount(GetSkipCalcDiscount());

        POSSession.GetSaleLine(SaleLine);
        SaleLine.InsertLine(Line, false);
        AddAccessories(Item, SaleLine);
        AutoExplodeBOM(Item, SaleLine);
        _BaseLineNo := Line."Line No.";
    end;

    procedure GetSkipCalcDiscount(): Boolean
    begin
        exit(_SkipCalcDiscount);
    end;

    procedure SetSkipCalcDiscount(SkipCalcDiscount: Boolean)
    begin
        _SkipCalcDiscount := SkipCalcDiscount;
    end;

    procedure AddItemLine(Item: Record Item; ItemReference: Record "Item Reference"; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin; ItemQuantity: Decimal; UnitPrice: Decimal; CustomDescription: Text; CustomDescription2: Text; InputSerial: Text; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; InputLot: Text)
    begin
        AddItemLine(Item, ItemReference, ItemIdentifierType, ItemQuantity, '', UnitPrice, CustomDescription, CustomDescription2, InputSerial, POSSession, FrontEnd, false, '', 0, '', InputLot);
    end;

    procedure AddItemLine(Item: Record Item; ItemReference: Record "Item Reference"; ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin; ItemQuantity: Decimal; UnitOfMeasure: Code[10]; UnitPrice: Decimal; CustomDescription: Text; CustomDescription2: Text; InputSerial: Text; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; InputLot: Text)
    begin
        AddItemLine(Item, ItemReference, ItemIdentifierType, ItemQuantity, UnitOfMeasure, UnitPrice, CustomDescription, CustomDescription2, InputSerial, POSSession, FrontEnd, false, '', 0, '', InputLot);
    end;

    procedure GetLineNo(): Integer;
    begin
        exit(_BaseLineNo)
    end;

    local procedure AutoExplodeBOM(Item: Record Item; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        Level: Integer;
    begin
        if not Item."NPR Explode BOM auto" then
            exit;
        Item.CalcFields("Assembly BOM");
        if not Item."Assembly BOM" then
            exit;

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS.Validate("Line Type", SaleLinePOS."Line Type"::"BOM List");
        SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::"BOM List";
        SaleLinePOS."Discount Code" := SaleLinePOS."No.";
        SaleLinePOS."Unit Price" := 0;
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        SaleLinePOS.Modify(true);

        SaleLinePOS.ExplodeBOM(SaleLinePOS."No.", 0, 0, Level, 0, 0);
    end;

    local procedure AddAccessories(Item: Record Item; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        AccessorySparePart: Record "NPR Accessory/Spare Part";
    begin
        // This is an adoption of the original function UdpakTilbeh?r in 6014418
        AccessorySparePart.SetRange(Type, AccessorySparePart.Type::Accessory);
        AccessorySparePart.SetRange(Code, Item."No.");
        AccessorySparePart.SetRange("Add Extra Line Automatically", true);
        if (AccessorySparePart.IsEmpty()) then begin
            // Item Group Accessory
            AccessorySparePart.SetRange(Code, Item."Item Category Code");
            if (not AccessorySparePart.IsEmpty()) then
                AddAccessoryForItem(Item, true, POSSaleLine);
        end else
            AddAccessoryForItem(Item, false, POSSaleLine);
    end;

    local procedure AddAccessoryForItem(Item: Record Item; GroupAccessory: Boolean; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        MainSaleLinePOS: Record "NPR POS Sale Line";
        AccessorySaleLinePOS: Record "NPR POS Sale Line";
        AccessorySparePart: Record "NPR Accessory/Spare Part";
    begin
        AccessorySparePart.SetRange(Type, AccessorySparePart.Type::Accessory);
        AccessorySparePart.SetRange(Code, Item."No.");
        if (not AccessorySparePart.FindSet()) then
            exit;

        POSSaleLine.GetCurrentSaleLine(MainSaleLinePOS);

        repeat
            POSSaleLine.GetNewSaleLine(AccessorySaleLinePOS);

            AccessorySaleLinePOS.Accessory := true;
            AccessorySaleLinePOS."Main Item No." := Item."No.";
            AccessorySaleLinePOS."Item group accessory" := GroupAccessory;
            if (GroupAccessory) then
                AccessorySaleLinePOS."Accessories Item Group No." := Item."Item Category Code";

            AccessorySaleLinePOS.Validate("No.", AccessorySparePart."Item No.");

            // This is not support unless we add a commit at this point
            if (AccessorySparePart."Quantity in Dialogue") then
                Error('The possibility to specify quantity per accessory line in a dialogue has been discontinued.');

            if (AccessorySparePart."Per unit") then
                AccessorySaleLinePOS.Validate(Quantity, AccessorySparePart.Quantity * MainSaleLinePOS.Quantity)
            else
                AccessorySaleLinePOS.Validate(Quantity, AccessorySparePart.Quantity);

            if AccessorySparePart."Use Alt. Price" and not AccessorySparePart."Show Discount" then begin
                AccessorySaleLinePOS."Manual Item Sales Price" := true;
                AccessorySaleLinePOS."Unit Price" := AccessorySparePart."Alt. Price";
            end else
                AccessorySaleLinePOS."Unit Price" := 0;  //Allow for default price retrieval routine to kick in

            POSSaleLine.InsertLine(AccessorySaleLinePOS);

            if AccessorySparePart."Use Alt. Price" and AccessorySparePart."Show Discount" then begin
                POSSaleLine.ConvertPriceToVAT(
                  Item."Price Includes VAT", Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group",
                  AccessorySaleLinePOS, AccessorySparePart."Alt. Price");
                if not AccessorySaleLinePOS."Price Includes VAT" then
                    AccessorySparePart."Alt. Price" := AccessorySparePart."Alt. Price" * (1 + (AccessorySaleLinePOS."VAT %" / 100));
                AccessorySaleLinePOS.Validate("Amount Including VAT", AccessorySparePart."Alt. Price" * AccessorySaleLinePOS.Quantity);
            end;

            AccessorySaleLinePOS."Item group accessory" := GroupAccessory;
            if (GroupAccessory) then
                AccessorySaleLinePOS."Accessories Item Group No." := Item."Item Category Code";

            AccessorySaleLinePOS.Accessory := true;
            AccessorySaleLinePOS."Main Item No." := Item."No.";
            AccessorySaleLinePOS."Main Line No." := MainSaleLinePOS."Line No.";

            AccessorySaleLinePOS.Modify();
            POSSaleLine.RefreshCurrent();
        until (AccessorySparePart.Next() = 0);

    end;

    [Obsolete('Replaced by function ItemRequiresSerialNo in codeunit NPR POS Tracking Utils', 'NPR23.0')]
    procedure ItemRequiresSerialNumberOnSale(Item: Record Item; var UseSpecificTracking: Boolean): Boolean
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        //Global
        if Item."Item Tracking Code" = '' then
            exit(false);
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then
            exit(false);
        UseSpecificTracking := ItemTrackingCode."SN Specific Tracking";
        exit(ItemTrackingCode."SN Sales Outbound Tracking");
    end;

    [Obsolete('Replaced by function SerialNumberCanBeUsedByItem in codeunit NPR POS Tracking Utils', 'NPR23.0')]
    procedure SerialNumberCanBeUsedForItem(var ItemRef: Record "Item Reference"; SerialNumber: Code[50]; var UserInformationErrorWarning: Text; SerialSelectionFromList: Boolean) CanBeUsed: Boolean
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ItemLedgerEntry: Record "Item Ledger Entry";
        SaleLinePOS: Record "NPR POS Sale Line";
        "Sale POS": Record "NPR POS Sale";
        TextActiveSaved: Text;
        WrongSerialOnILELbl: Label 'Serial number %1 for item %2 - %3 can not be used since it can not be found as received.', Comment = '%1 = Serial Number, %2 = Item No., %3 = Item Description';
        WrongSerialOnSLPLbl: Label 'Serial number %1 for item %2 - %3 can not be used since it is already on %4 sale %5 on register %6.', Comment = '%1 = Serial Number, %2 = Item No., %3 = Item Description, %4 = Sale, %5 = sales Ticket No, %6 = Register No.';
        ActiveLbl: Label 'active';
        WrongSerial_InstrLbl: Label ' \Press OK to re-enter serial number now. \Press Cancel to enter serial number later.\';
    begin
        if not Item.Get(ItemRef."Item No.") then
            exit(false);
        if Item."Item Tracking Code" = '' then
            exit(false);
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then
            exit(false);

        UserInformationErrorWarning := '';

        if not ItemTrackingCode."SN Specific Tracking" then begin
            CanBeUsed := true;
        end else begin
            ItemLedgerEntry.Reset();
            ItemLedgerEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Lot No.", "Serial No.");
            ItemLedgerEntry.SetRange(Open, true);
            ItemLedgerEntry.SetRange(Positive, true);
            ItemLedgerEntry.SetRange("Serial No.", SerialNumber);
            ItemLedgerEntry.SetRange("Item No.", ItemRef."Item No.");
            ItemLedgerEntry.SetRange("Lot No.", '');
            if ItemRef."Variant Code" <> '' then
                ItemLedgerEntry.SetRange("Variant Code", ItemRef."Variant Code");
            if not ItemLedgerEntry.FindSet() then begin
                CanBeUsed := false;
                UserInformationErrorWarning := StrSubstNo(WrongSerialOnILELbl, SerialNumber, Item."No.", Item.Description);  //NPR5.55 [398263]
            end else begin
                CanBeUsed := true;
            end;

            //Check if serial number exists in saved/active pos sale line
            //TO DO: check pos saved sales?
            if CanBeUsed then begin
                SaleLinePOS.Reset();
                SaleLinePOS.SetCurrentKey("Serial No.");
                SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
                SaleLinePOS.SetRange("No.", ItemRef."Item No.");
                SaleLinePOS.SetRange("Serial No.", SerialNumber);
                repeat
                    SaleLinePOS.SetRange("Variant Code", ItemLedgerEntry."Variant Code");
                    CanBeUsed := SaleLinePOS.IsEmpty();
                    if CanBeUsed then
                        ItemRef."Variant Code" := ItemLedgerEntry."Variant Code";
                until (ItemLedgerEntry.Next() = 0) or CanBeUsed;

                if not CanBeUsed then begin
                    //Create user information message
                    SaleLinePOS.FindFirst();
                    "Sale POS".Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.");
                    TextActiveSaved := ActiveLbl;
                    UserInformationErrorWarning := StrSubstNo(WrongSerialOnSLPLbl, SerialNumber, Item."No.", Item.Description, TextActiveSaved, SaleLinePOS."Sales Ticket No.", SaleLinePOS."Register No.");  //NPR5.55 [398263]
                end;
            end;
            if (UserInformationErrorWarning <> '') and not SerialSelectionFromList then
                UserInformationErrorWarning := UserInformationErrorWarning + WrongSerial_InstrLbl;
        end;

        exit(CanBeUsed);
    end;

    [Obsolete('Replaced by function SelectSerialNoFromList in codeunit NPR POS Tracking Utils', 'NPR23.0')]
    procedure SelectSerialNoFromList(var ItemRef: Record "Item Reference"; LocationCode: Code[10]; var SerialNo: Text)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.Init();
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
        SaleLinePOS."No." := ItemRef."Item No.";
        SaleLinePOS."Variant Code" := ItemRef."Variant Code";
        SaleLinePOS."Location Code" := LocationCode;
        SaleLinePOS.Quantity := 1;
        if SaleLinePOS.SerialNoLookup2() then begin
            SerialNo := SaleLinePOS."Serial No.";
            ItemRef."Variant Code" := SaleLinePOS."Variant Code";
        end;
    end;

    procedure GetItemFromItemSearch(var ItemIdentifierString: Text): Boolean
    var
        Item: Record Item;
        ItemList: Page "Item List";
        LookupOk: Boolean;
        POSActionPublishers: Codeunit "NPR POS Action Publishers";
        ItemFound: Boolean;
        Handled: Boolean;
    begin
        POSActionPublishers.OnBeforeGetItemFromItemSearch(ItemIdentifierString, ItemFound, Handled);

        if Handled then
            exit(ItemFound);

        SetItemSearchFilter(ItemIdentifierString, Item, true);
        if not Item.FindFirst() then
            exit(false);

        ItemIdentifierString := Item."No.";
        Item.FindLast();
        if ItemIdentifierString = Item."No." then
            exit(true);

        ItemList.Editable(true);
        ItemList.LookupMode(true);
        ItemList.SetTableView(Item);
        LookupOk := ItemList.RunModal() = ACTION::LookupOK;
        if LookupOk then
            ItemList.GetRecord(Item);

        if LookupOk then begin
            ItemIdentifierString := Item."No.";
            exit(true);
        end;
    end;

    procedure SetItemSearchFilter(ItemIdentifierString: Text; var Item: Record Item; IncludeBlockedFilter: Boolean)
    var
        SearchFilter: Text;
        SearchString: Text;
        SearchFilterLbl: Label '=%1', Locked = true;
    begin
        Clear(Item);

        SearchString := CopyStr(ItemIdentifierString, 1, MaxStrLen(Item."Search Description"));
        SearchString := UpperCase(SearchString);
        SearchFilter := SearchString + '*';
        if ItemIdentifierString = '' then
            SearchFilter := StrSubstNo(SearchFilterLbl, '');

        Item.SetCurrentKey("Search Description");
        Item.SetFilter("Search Description", SearchFilter);
        if IncludeBlockedFilter then
            Item.SetRange(Blocked, false);
        Item.SetLoadFields("No.");
    end;

    internal procedure GetBOMComponentLines(SaleLinePOS: Record "NPR POS Sale Line"; var BOMComponentSaleLinePOS: Record "NPR POS Sale Line")
    begin
        BOMComponentSaleLinePOS.SetRange("Register No.", SaleLinePOS."Register No.");
        BOMComponentSaleLinePOS.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        BOMComponentSaleLinePOS.SetRange("Serial No.", '');
        BOMComponentSaleLinePOS.SetRange("Parent BOM Item No.", SaleLinePOS."No.");
        BOMComponentSaleLinePOS.SetRange("Parent BOM Line No.", SaleLinePOS."Line No.");
        BOMComponentSaleLinePOS.SetFilter("Line Type", '%1|%2', BOMComponentSaleLinePOS."Line Type"::Item, BOMComponentSaleLinePOS."Line Type"::"BOM List");
    end;

    internal procedure AssingSerialNo(var SaleLinePOS: Record "NPR POS Sale Line"; var SerialNoInput: Text[50]; SerialSelectionFromList: Boolean; POSStore: Record "NPR POS Store")
    var
        POSTrackingUtils: Codeunit "NPR POS Tracking Utils";
    begin
        POSTrackingUtils.ValidateSerialNo(SaleLinePOS."No.", SaleLinePOS."Variant Code", SerialNoInput, SerialSelectionFromList, POSStore);

        SaleLinePOS.Validate("Serial No.", SerialNoInput);
        SaleLinePOS.Modify(true);
    end;

    internal procedure AssignLotNo(var SaleLinePOS: Record "NPR POS Sale Line"; LotNoInput: Text[50]; POSStore: Record "NPR POS Store")
    var
        POSTrackingUtils: Codeunit "NPR POS Tracking Utils";
    begin
        POSTrackingUtils.ValidateLotNo(SaleLinePOS."No.", SaleLinePOS."Variant Code", LotNoInput, POSStore);

        SaleLinePOS.Validate("Lot No.", LotNoInput);
        SaleLinePOS.Modify(true);
    end;

    internal procedure GetItemAdditionalInformationRequirements(ItemNo: Code[20]; var RequiresSerialNoInput: Boolean; var RequiresSpecificSerialNo: Boolean; var RequiresUnitPriceInput: Boolean; var RequiresLotNoInput: Boolean; var RequiresSpecificLotNo: Boolean)
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("No.", "NPR Group sale", "Assembly BOM", "NPR Explode BOM auto", "Item Tracking Code");
        Item.SetAutoCalcFields("Assembly BOM");
        if not Item.Get(ItemNo) then
            Clear(Item);

        GetItemAdditionalInformationRequirements(Item, RequiresSerialNoInput, RequiresSpecificSerialNo, requiresUnitPriceInput, RequiresLotNoInput, RequiresSpecificLotNo);
    end;

    internal procedure GetItemAdditionalInformationRequirements(var Item: Record Item; var RequiresSerialNoInput: Boolean; var RequiresSpecificSerialNo: Boolean; var RequiresUnitPriceInput: Boolean; var RequiresLotNoInput: Boolean; var RequiresSpecificLotNo: Boolean);
    var
        POSTrackingUtils: Codeunit "NPR POS Tracking Utils";
    begin
        RequiresUnitPriceInput := Item."NPR Group sale";

        if not (Item."Assembly BOM" and Item."NPR Explode BOM auto") then
            POSTrackingUtils.ItemRequiresLotNoSerialNo(Item, RequiresSpecificSerialNo, RequiresSpecificLotNo, RequiresSerialNoInput, RequiresLotNoInput)

    end;

    internal procedure CheckItemRequiresAdditionalInformationInput(RequiresSerialNoInput: Boolean; RequiresUnitPriceInput: Boolean; GetSerialNoFromList: Boolean; UsePresetUnitPrice: Boolean; RequiresSpecificSerialNo: Boolean; var RequiresUnitPriceInputPrompt: Boolean; var RequiresSerialNoInputPrompt: Boolean; var ItemRequiresAdditionalInformationInput: Boolean; var RequiresLotNoInputPrompt: Boolean; RequiresLotNoInput: Boolean; RequiresSpecificLotNo: Boolean; SelectSerialNoListEmptyInput: Boolean; InputSerial: Text)
    begin
        RequiresSerialNoInputPrompt := RequiresSerialNoInput and ((GetSerialNoFromList and not RequiresSpecificSerialNo) or (GetSerialNoFromList and SelectSerialNoListEmptyInput and (InputSerial = '')) or not GetSerialNoFromList);
        RequiresUnitPriceInputPrompt := RequiresUnitPriceInput and not UsePresetUnitPrice;
        RequiresLotNoInputPrompt := RequiresLotNoInput or RequiresSpecificLotNo;
        ItemRequiresAdditionalInformationInput := RequiresUnitPriceInputPrompt or RequiresSerialNoInputPrompt or RequiresLotNoInputPrompt;
    end;

    internal procedure CheckBOMComponentsNeedLotNoSerialInput(Item: Record Item; var RequiresLotNoInput: Boolean; var RequiresSerialNoInput: Boolean)
    var
        BOMComponent: Record "BOM Component";
        BOMComponentITem: Record Item;
        POSTrackingUtils: Codeunit "NPR POS Tracking Utils";
        RequiresSpecificLotNo: Boolean;
        RequiresSpecificlSerialNo: Boolean;
    begin
        if not Item."Assembly BOM" then
            exit;

        if not Item."NPR Explode BOM auto" then
            exit;

        BOMComponent.Reset();
        BOMComponent.SetLoadFields(Type, "Parent Item No.", "No.");
        BOMComponent.SetRange(Type, BOMComponent.Type::Item);
        BOMComponent.SetRange("Parent Item No.", Item."No.");
        if not BOMComponent.FindSet(false) then
            exit;

        repeat
            BOMComponentITem.SetLoadFields("Item Tracking Code", "No.");
            If BOMComponentITem.Get(BOMComponent."No.") then
                POSTrackingUtils.ItemRequiresLotNoSerialNo(BOMComponentITem, RequiresSpecificlSerialNo, RequiresSpecificLotNo, RequiresSerialNoInput, RequiresLotNoInput);
        until (BOMComponent.Next() = 0) or (RequiresLotNoInput and RequiresSerialNoInput);

    end;

    internal procedure AddBenefitItems(SalePOS: Record "NPR POS Sale"; var TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Item: Record Item;
        TempItemReference: Record "Item Reference" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
        POSSession: Codeunit "NPR POS Session";
        UnitPrice: Decimal;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin;
    begin
        TempNPRTotalDiscBenItemBuffer.Reset();
        TempNPRTotalDiscBenItemBuffer.SetFilter(Quantity, '<>0');
        if not TempNPRTotalDiscBenItemBuffer.FindSet(false) then
            exit;

        repeat
            if not Item.Get(TempNPRTotalDiscBenItemBuffer."Item No.") then
                Clear(Item);

            if not GeneralLedgerSetup.Get() then
                Clear(GeneralLedgerSetup);

            UnitPrice := TempNPRTotalDiscBenItemBuffer."Unit Price";
            if not SalePOS."Prices Including VAT" then begin

                if not VATPostingSetup.Get(SalePOS."VAT Bus. Posting Group", Item."VAT Prod. Posting Group") then
                    Clear(VATPostingSetup);

                UnitPrice := NPRTotalDiscountManagement.CalcAmountWithoutVAT(UnitPrice, VATPostingSetup."VAT %", GeneralLedgerSetup."Amount Rounding Precision");
            end;
            TempItemReference."Item No." := TempNPRTotalDiscBenItemBuffer."Item No.";
            TempItemReference."Variant Code" := TempNPRTotalDiscBenItemBuffer."Variant Code";

            AddItemLine(Item, TempItemReference, ItemIdentifierType::ItemNo, TempNPRTotalDiscBenItemBuffer.Quantity, UnitPrice, '', '', '', POSSession, FrontEnd, true, TempNPRTotalDiscBenItemBuffer."Total Discount Code", TempNPRTotalDiscBenItemBuffer."Total Discount Step", TempNPRTotalDiscBenItemBuffer."Benefit List Code", '');
        until TempNPRTotalDiscBenItemBuffer.Next() = 0;
    end;
}
