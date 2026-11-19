#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248630 "NPR API POS Sale Line"
{
    Access = Internal;

    procedure ListSaleLines(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SaleId: Text;
        SaleSystemId: Guid;
        POSSale: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
        Json: Codeunit "NPR Json Builder";
    begin
        Request.SkipCacheIfNonStickyRequest(POSSaleTableIds());

        SaleId := Request.Paths().Get(3);
        if SaleId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: saleId'));

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));

        if not POSSale.GetBySystemId(SaleSystemId) then
            exit(Response.RespondResourceNotFound());

        Json.StartArray('');
        POSSaleLine.SetRange("Register No.", POSSale."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        POSSaleLine.SetFilter("Line Type", '<>%1', POSSaleLine."Line Type"::"POS Payment");
        POSSaleLine.ReadIsolation := IsolationLevel::ReadCommitted;

        if POSSaleLine.FindSet() then
            repeat
                AddSaleLineToJson(POSSaleLine, Json);
            until POSSaleLine.Next() = 0;
        Json.EndArray();

        exit(Response.RespondOK(Json.BuildAsArray()));
    end;

    procedure GetSaleLine(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SaleId: Text;
        SaleLineId: Text;
        SaleSystemId: Guid;
        SaleLineSystemId: Guid;
        POSSale: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
        Json: Codeunit "NPR Json Builder";
    begin
        Request.SkipCacheIfNonStickyRequest(POSSaleTableIds());

        SaleId := Request.Paths().Get(3);
        SaleLineId := Request.Paths().Get(5);

        if SaleId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: saleId'));
        if SaleLineId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: saleLineId'));

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));
        if not Evaluate(SaleLineSystemId, SaleLineId) then
            exit(Response.RespondBadRequest('Invalid saleLineId format'));

        if not POSSale.GetBySystemId(SaleSystemId) then
            exit(Response.RespondResourceNotFound());

        if not POSSaleLine.GetBySystemId(SaleLineSystemId) then
            exit(Response.RespondResourceNotFound());

        if (POSSaleLine."Register No." <> POSSale."Register No.") or
           (POSSaleLine."Sales Ticket No." <> POSSale."Sales Ticket No.") then
            exit(Response.RespondResourceNotFound());

        AddSaleLineToJson(POSSaleLine, Json);

        exit(Response.RespondOK(Json.Build()));
    end;

    [CommitBehavior(CommitBehavior::Ignore)] // commit when API ends, skip explicit commits in re-used business logic
    procedure UpdateSaleLine(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SaleId: Text;
        SaleLineId: Text;
        SaleSystemId: Guid;
        SaleLineSystemId: Guid;
        Body: JsonToken;
        POSSale: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
        DeltaBuilder: Codeunit "NPR API POS Delta Builder";
        APIPOSSale: Codeunit "NPR API POS Sale";
    begin
        Request.SkipCacheIfNonStickyRequest(POSSaleTableIds());

        SaleId := Request.Paths().Get(3);
        SaleLineId := Request.Paths().Get(5);

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));
        if not Evaluate(SaleLineSystemId, SaleLineId) then
            exit(Response.RespondBadRequest('Invalid saleLineId format'));

        if not POSSale.GetBySystemId(SaleSystemId) then
            exit(Response.RespondResourceNotFound());

        if not POSSaleLine.GetBySystemId(SaleLineSystemId) then
            exit(Response.RespondResourceNotFound());

        if (POSSaleLine."Register No." <> POSSale."Register No.") or
           (POSSaleLine."Sales Ticket No." <> POSSale."Sales Ticket No.") then
            exit(Response.RespondResourceNotFound());

        if not APIPOSSale.AssertPOSUnitOpenForSale(POSSale."Register No.") then
            exit(Response.RespondBadRequest(StrSubstNo('POS Unit ''%1'' is not open for sales.', POSSale."Register No.")));

        Body := Request.BodyJson();

        APIPOSSale.ReconstructSession(SaleSystemId);
        DeltaBuilder.StartDataCollection();

        UpdateSaleLineFromJson(Body, POSSaleLine.GetPosition(false));

        exit(Response.RespondOK(DeltaBuilder.BuildDeltaResponse()));
    end;

    [CommitBehavior(CommitBehavior::Ignore)] // commit when API ends, skip explicit commits in re-used business logic
    procedure DeleteSaleLine(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SaleId: Text;
        SaleLineId: Text;
        SaleSystemId: Guid;
        SaleLineSystemId: Guid;
        POSSale: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        POSSaleLineCu: Codeunit "NPR POS Sale Line";
        DeltaBuilder: Codeunit "NPR API POS Delta Builder";
        APIPOSSale: Codeunit "NPR API POS Sale";
    begin
        Request.SkipCacheIfNonStickyRequest(POSSaleTableIds());

        SaleId := Request.Paths().Get(3);
        SaleLineId := Request.Paths().Get(5);

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));
        if not Evaluate(SaleLineSystemId, SaleLineId) then
            exit(Response.RespondBadRequest('Invalid saleLineId format'));

        if not POSSale.GetBySystemId(SaleSystemId) then
            exit(Response.RespondResourceNotFound());

        if not POSSaleLine.GetBySystemId(SaleLineSystemId) then
            exit(Response.RespondResourceNotFound());

        if (POSSaleLine."Register No." <> POSSale."Register No.") or
           (POSSaleLine."Sales Ticket No." <> POSSale."Sales Ticket No.") then
            exit(Response.RespondResourceNotFound());

        if not APIPOSSale.AssertPOSUnitOpenForSale(POSSale."Register No.") then
            exit(Response.RespondBadRequest(StrSubstNo('POS Unit ''%1'' is not open for sales.', POSSale."Register No.")));

        APIPOSSale.ReconstructSession(SaleSystemId);
        DeltaBuilder.StartDataCollection();

        POSSession.GetSaleLine(POSSaleLineCu);
        POSSaleLineCu.SetPosition(POSSaleLine.GetPosition(false));
        POSSaleLineCu.DeleteLine();

        exit(Response.RespondOK(DeltaBuilder.BuildDeltaResponse()));
    end;

    internal procedure AddSaleLineToJson(POSSaleLine: Record "NPR POS Sale Line"; var Json: Codeunit "NPR Json Builder")
    var
        NpIaItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
        ParentPOSSaleLine: Record "NPR POS Sale Line";
        NpIaSaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        Json.StartObject('')
            .AddProperty('id', Format(POSSaleLine.SystemId, 0, 4).ToLower())
            .AddProperty('sortKey', POSSaleLine."Line No.")
            .AddProperty('type', POSSaleLine."Line Type".Names.Get(POSSaleLine."Line Type".Ordinals().IndexOf(POSSaleLine."Line Type".AsInteger())))
            .AddProperty('code', POSSaleLine."No.")
            .AddProperty('variantCode', POSSaleLine."Variant Code")
            .AddProperty('description', POSSaleLine.Description)
            .AddProperty('description2', POSSaleLine."Description 2")
            .AddProperty('quantity', POSSaleLine.Quantity)
            .AddProperty('unitPrice', POSSaleLine."Unit Price")
            .AddProperty('discountPct', POSSaleLine."Discount %")
            .AddProperty('discountAmount', POSSaleLine."Discount Amount")
            .AddProperty('vatPercent', POSSaleLine."VAT %")
            .AddProperty('amountInclVat', POSSaleLine."Amount Including VAT")
            .AddProperty('amount', POSSaleLine.Amount)
            .AddProperty('unitOfMeasure', POSSaleLine."Unit of Measure Code");

        NpIaItemAddOnMgt.FilterSaleLinePOS2ItemAddOnPOSLine(POSSaleLine, NpIaSaleLinePOSAddOn);
        if NpIaSaleLinePOSAddOn.FindFirst() then begin
            Json.AddProperty('isAddon', true);
            ParentPOSSaleLine.Get(NpIaSaleLinePOSAddOn."Register No.", NpIaSaleLinePOSAddOn."Sales Ticket No.", NpIaSaleLinePOSAddOn."Sale Date", NpIaSaleLinePOSAddOn."Sale Type", NpIaSaleLinePOSAddOn."Applies-to Line No.");
            Json.AddProperty('appliesToLine', Format(ParentPOSSaleLine.SystemId, 0, 4).ToLower());
            Json.AddProperty('addonNo', NpIaSaleLinePOSAddOn."AddOn No.");
            Json.AddProperty('addonLineNo', NpIaSaleLinePOSAddOn."AddOn Line No.");
            if NpIaSaleLinePOSAddOn."Selected Option Line No." <> 0 then
                Json.AddProperty('selectedOptionLineNo', NpIaSaleLinePOSAddOn."Selected Option Line No.");
            Json.AddProperty('perUnit', NpIaSaleLinePOSAddOn."Per Unit");
        end else begin
            Json.AddProperty('isAddon', false);
        end;
        Json.EndObject();
    end;

    internal procedure ParseSaleLineFromJson(Body: JsonToken; var POSSaleLine: Record "NPR POS Sale Line"): Boolean
    var
        LineTypeText: Text;
        LineType: Enum "NPR POS Sale Line Type";
        TempText: Text;
        Barcode: Text;
        NameIndex: Integer;
    begin
        if not GetJsonText(Body, 'type', LineTypeText) then
            exit(false);

        // Handle barcode: lookup item and UoM via item reference
        if GetJsonText(Body, 'barcode', Barcode) then begin
            if not LookupItemFromBarcode(Barcode, POSSaleLine) then
                exit(false);
        end else begin
            if not GetJsonText(Body, 'code', TempText) then
                exit(false);
            POSSaleLine."No." := CopyStr(TempText, 1, MaxStrLen(POSSaleLine."No."));
        end;

        // Parse line type using enum Names/Ordinals
        NameIndex := LineType.Names.IndexOf(LineTypeText);
        if NameIndex = 0 then
            exit(false);
        POSSaleLine."Line Type" := Enum::"NPR POS Sale Line Type".FromInteger(LineType.Ordinals.Get(NameIndex));

        if POSSaleLine."Line Type" = POSSaleLine."Line Type"::"POS Payment" then
            exit(false);

        if GetJsonText(Body, 'variantCode', TempText) then
            POSSaleLine."Variant Code" := CopyStr(TempText, 1, MaxStrLen(POSSaleLine."Variant Code"));
        if GetJsonText(Body, 'description', TempText) then
            POSSaleLine.Description := CopyStr(TempText, 1, MaxStrLen(POSSaleLine.Description));
        if GetJsonText(Body, 'description2', TempText) then
            POSSaleLine."Description 2" := CopyStr(TempText, 1, MaxStrLen(POSSaleLine."Description 2"));
        if GetJsonText(Body, 'unitOfMeasure', TempText) then
            POSSaleLine."Unit of Measure Code" := CopyStr(TempText, 1, MaxStrLen(POSSaleLine."Unit of Measure Code"));

        POSSaleLine.Quantity := 1;
        if Body.AsObject().Contains('quantity') then
            POSSaleLine.Quantity := Body.AsObject().GetDecimal('quantity');

        exit(true);
    end;

    local procedure UpdateSaleLineFromJson(Body: JsonToken; LinePosition: Text)
    var
        Quantity: Decimal;
        DiscountAmount: Decimal;
        DescriptionText: Text;
        POSSession: Codeunit "NPR POS Session";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleLineRec: Record "NPR POS Sale Line";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetPosition(LinePosition);

        if GetJsonDecimal(Body, 'quantity', Quantity) then
            POSSaleLine.SetQuantity(Quantity);

        if GetJsonText(Body, 'description', DescriptionText) then
            POSSaleLine.SetDescription(CopyStr(DescriptionText, 1, 100));

        if GetJsonDecimal(Body, 'discountAmount', DiscountAmount) then begin
            POSSaleLine.GetCurrentSaleLine(POSSaleLineRec);
            POSSaleLineRec.Validate("Discount Amount", DiscountAmount);
            POSSaleLineRec.Modify(true);
            POSSaleLine.RefreshCurrent();
        end;
    end;

    internal procedure GetJsonText(Body: JsonToken; PropertyName: Text; var Value: Text): Boolean
    var
        JToken: JsonToken;
    begin
        if not Body.AsObject().Get(PropertyName, JToken) then
            exit(false);
        if JToken.IsValue() then begin
            Value := JToken.AsValue().AsText();
            exit(true);
        end;
        exit(false);
    end;

    internal procedure GetJsonDecimal(Body: JsonToken; PropertyName: Text; var Value: Decimal): Boolean
    var
        JToken: JsonToken;
    begin
        if not Body.AsObject().Get(PropertyName, JToken) then
            exit(false);
        if JToken.IsValue() then begin
            Value := JToken.AsValue().AsDecimal();
            exit(true);
        end;
        exit(false);
    end;

    local procedure LookupItemFromBarcode(Barcode: Text; var POSSaleLine: Record "NPR POS Sale Line"): Boolean
    var
        ItemReference: Record "Item Reference";
    begin
        // Lookup item reference by barcode (similar to POS insert item action)
        ItemReference.SetRange("Reference No.", Barcode);
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        if not ItemReference.FindFirst() then
            exit(false);

        POSSaleLine."No." := ItemReference."Item No.";
        POSSaleLine."Variant Code" := ItemReference."Variant Code";
        POSSaleLine."Unit of Measure Code" := ItemReference."Unit of Measure";

        exit(true);
    end;

    internal procedure POSSaleTableIds(): List of [Integer]
    var
        TableIdList: List of [Integer];
    begin
        TableIdList.Add(Database::"NPR POS Sale");
        TableIdList.Add(Database::"NPR POS Sale Line");
        exit(TableIdList);
    end;

}
#endif
