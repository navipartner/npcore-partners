#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185041 "NPR TicketingCatalogAgent"
{
    Access = Internal;

    internal procedure GetCatalog(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        StoreCode: Code[32];
        ItemNumber: Code[20];
    begin
        StoreCode := '';
        ItemNumber := '';
        if (Request.Paths().Count() = 3) then
            StoreCode := CopyStr(Request.Paths().Get(3), 1, MaxStrLen(StoreCode));

        if (Request.QueryParams().ContainsKey('itemNumber')) then
            ItemNumber := CopyStr(UpperCase(Request.QueryParams().Get('itemNumber')), 1, MaxStrLen(ItemNumber));

        exit(GetCatalog(StoreCode, ItemNumber));
    end;

    internal procedure GetCatalog(StoreCode: Code[32]; ItemNumber: Code[20]) Response: Codeunit "NPR API Response"
    var
        ResponseJson: Codeunit "NPR JSON Builder";
        EnumEncoder: Codeunit "NPR TicketingApiTranslations";

        TempCatalogItems: Record "Item Variant" temporary;
        TicketDescriptionBuffer: Record "NPR TM TempTicketDescription";
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
        GeneralLedgerSetup: Record "General Ledger Setup";

        UnitPrice: Decimal;
        UnitPriceIncludesVat: Boolean;
        UnitPriceVatPercentage: Decimal;
    begin
        if (not PrepareCatalogItemList(StoreCode, ItemNumber, TempCatalogItems, TicketDescriptionBuffer, CopyStr(StoreCode, 1, 10))) then
            exit(Response.RespondResourceNotFound('No items found in the catalog.'));

        GeneralLedgerSetup.Get();

        TempCatalogItems.Reset();
        TempCatalogItems.SetCurrentKey("Item No.", Code);
        TempCatalogItems.FindSet();

        ResponseJson.AddProperty('storeCode', StoreCode).
            StartArray('items');

        repeat
            Item.Get(TempCatalogItems."Item No.");
            TicketType.Get(Item."NPR Ticket Type");

            if (not CalculatePrice(TempCatalogItems."Item No.", TempCatalogItems.Code, UnitPrice, UnitPriceIncludesVat, UnitPriceVatPercentage)) then begin
                UnitPrice := Item."Unit Price";
                UnitPriceIncludesVat := Item."Price Includes VAT";
                UnitPriceVatPercentage := 0;
            end;

            TicketDescriptionBuffer.Get(TempCatalogItems."Item No.", TempCatalogItems.Code, '');

            ResponseJson.StartObject()
                .AddProperty('itemNumber', TempCatalogItems."Item No.")
                .AddObject(ItemReferenceDTO(ResponseJson, 'itemReferences', TempCatalogItems."Item No.", TempCatalogItems.Code))
                .StartObject('recommendedPrice')
                    .AddProperty('unitPrice', UnitPrice)
                    .AddProperty('unitPriceIncludesVat', UnitPriceIncludesVat)
                    .AddProperty('vatPct', UnitPriceVatPercentage)
                    .AddProperty('currencyCode', GeneralLedgerSetup."LCY Code")
                .EndObject()
                .StartObject('ticketType')
                    .AddProperty('code', Item."NPR Ticket Type")
                    .AddProperty('description', TicketType.Description)
                    .AddProperty('category', TicketType.Category)
                    .AddProperty('kind', EnumEncoder.EncodeTicketTypeAdmissionKind(TicketType."Admission Registration"))
                .EndObject()
                .StartObject('description')
                    .AddObject(AddPropertyNotNull(ResponseJson, 'title', TicketDescriptionBuffer.Title))
                    .AddObject(AddPropertyNotNull(ResponseJson, 'subtitle', TicketDescriptionBuffer.Subtitle))
                    .AddObject(AddPropertyNotNull(ResponseJson, 'name', TicketDescriptionBuffer.Name))
                    .AddObject(AddPropertyNotNull(ResponseJson, 'description', TicketDescriptionBuffer.Description))
                    .AddObject(AddPropertyNotNull(ResponseJson, 'fullDescription', TicketDescriptionBuffer.FullDescription))
                .EndObject()
                .AddArray(AdmissionDetailsDTO(ResponseJson, 'contents', TempCatalogItems."Item No.", TempCatalogItems.Code, TicketDescriptionBuffer))
            .EndObject();

        until (TempCatalogItems.Next() = 0);

        ResponseJson.EndArray();
        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    local procedure ItemReferenceDTO(var ResponseJson: Codeunit "NPR JSON Builder"; ArrayName: Text; ItemNo: Code[20]; VariantCode: Code[10]): Codeunit "NPR JSON Builder";
    var
        ItemReference: Record "Item Reference";
    begin

        if (VariantCode <> '') then
            ResponseJson.AddProperty('variantCode', VariantCode);

        ItemReference.SetFilter("Item No.", '=%1', ItemNo);
        if (VariantCode <> '') then
            ItemReference.SetFilter("Variant Code", '=%1', VariantCode);
        ItemReference.SetFilter("Reference Type", '=%1', ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetFilter("Starting Date", '=%1|<=%2', 0D, Today());
        ItemReference.SetFilter("Ending Date", '=%1|>=%2', 0D, Today());

        if (ItemReference.FindSet()) then begin
            ResponseJson.StartArray(ArrayName);
            repeat
                ResponseJson.StartObject()
                    .AddProperty('referenceNumber', ItemReference."Reference No.")
                    .AddProperty('description', ItemReference.Description)
                    .EndObject();
            until (ItemReference.Next() = 0);
            ResponseJson.EndArray();
        end;

        exit(ResponseJson);
    end;

    local procedure AdmissionDetailsDTO(var ResponseJson: Codeunit "NPR JSON Builder"; ArrayName: Text; ItemNumber: Code[20]; VariantCode: Code[10]; var TicketDescriptionBuffer: Record "NPR TM TempTicketDescription"): Codeunit "NPR JSON Builder";
    var
        TicketBom: Record "NPR TM Ticket Admission Bom";
        Admission: Record "NPR TM Admission";
        EnumEncoder: Codeunit "NPR TicketingApiTranslations";
    begin
        ResponseJson.StartArray(ArrayName);

        TicketBom.SetFilter("Item No.", '=%1', ItemNumber);
        TicketBom.SetFilter("Variant Code", '=%1', VariantCode);
        TicketBom.FindSet();
        repeat
            Admission.Get(TicketBom."Admission Code");
            TicketDescriptionBuffer.Get(ItemNumber, VariantCode, TicketBom."Admission Code");

            ResponseJson.StartObject()
                .AddProperty('code', TicketBom."Admission Code")
                .AddProperty('default', TicketBom.Default)
                .AddProperty('included', EnumEncoder.EncodeInclusion(TicketBom."Admission Inclusion"))
                .AddProperty('capacityControl', EnumEncoder.EncodeCapacity(Admission."Capacity Control"))
                .AddProperty('scheduleSelection', EnumEncoder.EncodeScheduleSelection(TicketBom."Ticket Schedule Selection", Admission."Default Schedule"))
                .AddProperty('maxCapacity', Admission."Max Capacity Per Sch. Entry")
                .StartObject('description')
                    .AddObject(AddPropertyNotNull(ResponseJson, 'title', TicketDescriptionBuffer.Title))
                    .AddObject(AddPropertyNotNull(ResponseJson, 'subtitle', TicketDescriptionBuffer.Subtitle))
                    .AddObject(AddPropertyNotNull(ResponseJson, 'name', TicketDescriptionBuffer.Name))
                    .AddObject(AddPropertyNotNull(ResponseJson, 'description', TicketDescriptionBuffer.Description))
                    .AddObject(AddPropertyNotNull(ResponseJson, 'fullDescription', TicketDescriptionBuffer.FullDescription))
                .EndObject()
            .EndObject();

        until (TicketBom.Next() = 0);

        ResponseJson.EndArray();
        exit(ResponseJson);
    end;

    local procedure AddPropertyNotNull(var ResponseJson: Codeunit "NPR JSON Builder"; PropertyName: Text; PropertyValue: Text): Codeunit "NPR JSON Builder"
    begin
        if (PropertyValue <> '') then
            ResponseJson.AddProperty(PropertyName, PropertyValue);
        exit(ResponseJson);
    end;

    internal procedure GetCatalogItemDescription(StoreCode: Code[32]; ItemNumber: Code[20]; var TicketDescriptionBuffer: Record "NPR TM TempTicketDescription"; LanguageCode: Code[10]): Boolean
    var
        TempCatalogItems: Record "Item Variant" temporary;
    begin
        exit(PrepareCatalogItemList(StoreCode, ItemNumber, TempCatalogItems, TicketDescriptionBuffer, LanguageCode));
    end;

    local procedure PrepareCatalogItemList(StoreCode: Code[32]; ItemNumber: Code[20]; var TempCatalogItems: Record "Item Variant" temporary; var TicketDescriptionBuffer: Record "NPR TM TempTicketDescription"; LanguageCode: Code[10]): Boolean
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
    begin

        // Find all ticket items and expand the list with variants
        Item.SetFilter("NPR Ticket Type", '<>%1', '');
        Item.SetFilter(Blocked, '=%1', false);
        if (ItemNumber <> '') then
            Item.SetFilter("No.", '=%1', ItemNumber);

        if (not Item.FindSet()) then
            exit(false);

        repeat
            TempCatalogItems."Item No." := Item."No.";

            ItemVariant.SetFilter("Item No.", '=%1', Item."No.");
            if (ItemVariant.FindSet()) then begin
                repeat
                    TempCatalogItems.Code := ItemVariant.Code;
                    if (TempCatalogItems.Insert()) then;
                until (ItemVariant.Next() = 0);
            end else begin
                TempCatalogItems.Code := '';
                if (TempCatalogItems.Insert()) then;
            end;
        until (Item.Next() = 0);

        // Remove item variants that are not in the ticket bom
        TempCatalogItems.Reset();
        if (TempCatalogItems.FindSet()) then begin
            repeat
                TicketBOM.SetFilter("Item No.", '=%1', TempCatalogItems."Item No.");
                TicketBOM.SetFilter("Variant Code", '=%1', TempCatalogItems.Code);
                if (TicketBOM.IsEmpty()) then
                    TempCatalogItems.Delete();
            until (TempCatalogItems.Next() = 0);
        end;

        // Extract descriptions for the items
        TempCatalogItems.Reset();
        if (TempCatalogItems.FindSet()) then begin
            repeat
                TicketDescriptionBuffer.SetKeyAndDescription(TempCatalogItems."Item No.", TempCatalogItems.Code, '', StoreCode, LanguageCode);
                TicketDescriptionBuffer.AdmissionCode := '';
                if (not TicketDescriptionBuffer.Insert()) then; // IgnoreDuplicates

            until (TempCatalogItems.Next() = 0);
        end;

        // Extract descriptions for the dynamic ticket items
        TicketBOM.Reset();
        if (ItemNumber <> '') then
            TicketBOM.SetFilter("Item No.", '=%1', ItemNumber);

        if (TicketBOM.FindSet()) then begin
            repeat
                TicketDescriptionBuffer.SetKeyAndDescription(TicketBOM."Item No.", TicketBOM."Variant Code", TicketBOM."Admission Code", StoreCode, LanguageCode);

                if (Admission.Get(TicketBOM."Admission Code")) then
                    if (Admission."Additional Experience Item No." <> '') then
                        TicketDescriptionBuffer.SetDescription(Admission."Additional Experience Item No.", '', TicketBOM."Admission Code", StoreCode, LanguageCode);
                if (TicketDescriptionBuffer.Insert()) then; // IgnoreDuplicates
            until (TicketBOM.Next() = 0);
        end;

        exit(TempCatalogItems.Count() > 0);

    end;

    local procedure CalculatePrice(ItemNumber: Code[20]; VariantCode: Code[10]; var UnitPrice: Decimal; var UnitPriceIncludesVat: Boolean; var UnitPriceVatPercentage: Decimal): Boolean
    var
        AdmCapacityPriceBuffer: Record "NPR TM AdmCapacityPriceBuffer";
        TicketBom: Record "NPR TM Ticket Admission Bom";
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        LocalDateTime: DateTime;
    begin

        TicketBom.SetFilter("Item No.", '=%1', ItemNumber);
        TicketBom.SetFilter("Variant Code", '=%1', VariantCode);
        TicketBom.SetFilter("Default", '=%1', true);
        if (not TicketBom.FindFirst()) then
            exit(false);

        LocalDateTime := TimeHelper.GetLocalTimeAtAdmission(TicketBom."Admission Code");

        AdmCapacityPriceBuffer.Init();
        AdmCapacityPriceBuffer.EntryNo := 1;
        AdmCapacityPriceBuffer.ItemNumber := ItemNumber;
        AdmCapacityPriceBuffer.VariantCode := VariantCode;
        AdmCapacityPriceBuffer.AdmissionCode := TicketBom."Admission Code";
        AdmCapacityPriceBuffer.ReferenceDate := DT2Date(LocalDateTime);
        AdmCapacityPriceBuffer.DefaultAdmission := TicketBom.Default;
        AdmCapacityPriceBuffer.AdmissionInclusion := TicketBom."Admission Inclusion";
        AdmCapacityPriceBuffer.Quantity := 1;

        if (TicketBom."Admission Inclusion" = TicketBom."Admission Inclusion"::REQUIRED) then
            if (TicketBom.Default) then
                TicketPrice.CalculateErpPrice(AdmCapacityPriceBuffer);

        UnitPrice := AdmCapacityPriceBuffer.UnitPrice;
        UnitPriceIncludesVat := AdmCapacityPriceBuffer.UnitPriceIncludesVat;
        UnitPriceVatPercentage := AdmCapacityPriceBuffer.UnitPriceVatPercentage;
        exit(true);

    end;

}
#endif