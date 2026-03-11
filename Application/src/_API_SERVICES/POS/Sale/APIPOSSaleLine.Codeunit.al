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
    procedure CreateSaleLine(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SaleId: Text;
        SaleSystemId: Guid;
        Body: JsonToken;
        POSSaleRec: Record "NPR POS Sale";
        TempPOSSaleLine: Record "NPR POS Sale Line" temporary;
        CreatedLine: Record "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        APIPOSSale: Codeunit "NPR API POS Sale";
        DeltaBuilder: Codeunit "NPR API POS Delta Builder";
        SaleLineId: Guid;
        AddonsArray: JsonToken;
    begin
        Request.SkipCacheIfNonStickyRequest(POSSaleTableIds());

        SaleId := Request.Paths().Get(3);
        if SaleId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: saleId'));

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));

        if not POSSaleRec.GetBySystemId(SaleSystemId) then
            exit(Response.RespondResourceNotFound());

        if not Evaluate(SaleLineId, Request.Paths().Get(5)) then
            exit(Response.RespondBadRequest('Invalid saleLineId format'));

        Body := Request.BodyJson();

        APIPOSSale.ReconstructSession(SaleSystemId);
        DeltaBuilder.StartDataCollection();
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(TempPOSSaleLine);

        if not ParseSaleLineFromJson(Body, TempPOSSaleLine) then
            exit(Response.RespondBadRequest('Invalid sale line data'));

        TempPOSSaleLine.SystemId := SaleLineId;

        POSSaleLine.SetUseCustomSystemId(true);
        if not POSSaleLine.InsertLine(TempPOSSaleLine, true) then
            exit(Response.RespondBadRequest('Failed to insert sale line'));

        if Body.AsObject().Get('addons', AddonsArray) and AddonsArray.IsArray() then begin
            POSSaleLine.GetCurrentSaleLine(CreatedLine);
            ProcessAddonsArray(AddonsArray, CreatedLine);
        end;

        exit(Response.RespondCreated(DeltaBuilder.BuildDeltaResponse()));
    end;

    [CommitBehavior(CommitBehavior::Ignore)] // commit when API ends, skip explicit commits in re-used business logic
    procedure CreateSaleLineAddon(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SaleId: Text;
        AddonLineId: Text;
        SaleSystemId: Guid;
        AddonLineSystemId: Guid;
        Body: JsonToken;
        POSSaleRec: Record "NPR POS Sale";
        ParentLineSystemId: Guid;
        ParentLine: Record "NPR POS Sale Line";
        CreatedLine: Record "NPR POS Sale Line";
        APIPOSSale: Codeunit "NPR API POS Sale";
        DeltaBuilder: Codeunit "NPR API POS Delta Builder";
        ParentLineIdText: Text;
    begin
        Request.SkipCacheIfNonStickyRequest(POSSaleTableIds());

        SaleId := Request.Paths().Get(3);
        AddonLineId := Request.Paths().Get(5);

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));
        if not Evaluate(AddonLineSystemId, AddonLineId) then
            exit(Response.RespondBadRequest('Invalid addonLineId format'));

        if not POSSaleRec.GetBySystemId(SaleSystemId) then
            exit(Response.RespondResourceNotFound());

        Body := Request.BodyJson();

        if not GetJsonText(Body, 'parentLineId', ParentLineIdText) then
            exit(Response.RespondBadRequest('Missing required field: parentLineId'));
        if not Evaluate(ParentLineSystemId, ParentLineIdText) then
            exit(Response.RespondBadRequest('Invalid parentLineId format'));

        if not ParentLine.GetBySystemId(ParentLineSystemId) then
            exit(Response.RespondBadRequest('Parent line not found'));

        if (ParentLine."Register No." <> POSSaleRec."Register No.") or
           (ParentLine."Sales Ticket No." <> POSSaleRec."Sales Ticket No.") then
            exit(Response.RespondBadRequest('Parent line does not belong to this sale'));

        if ParentLine."Line Type" <> ParentLine."Line Type"::Item then
            exit(Response.RespondBadRequest('Parent line must be an Item'));

        APIPOSSale.ReconstructSession(SaleSystemId);
        DeltaBuilder.StartDataCollection();

        InsertAddonLineFromApi(Body, ParentLine, CreatedLine);

        exit(Response.RespondCreated(DeltaBuilder.BuildDeltaResponse()));
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
        end else begin
            Json.AddProperty('isAddon', false);
        end;
        Json.EndObject();
    end;

    local procedure ParseSaleLineFromJson(Body: JsonToken; var POSSaleLine: Record "NPR POS Sale Line"): Boolean
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

    local procedure GetJsonText(Body: JsonToken; PropertyName: Text; var Value: Text): Boolean
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

    local procedure GetJsonDecimal(Body: JsonToken; PropertyName: Text; var Value: Decimal): Boolean
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

    local procedure POSSaleTableIds(): List of [Integer]
    var
        TableIdList: List of [Integer];
    begin
        TableIdList.Add(Database::"NPR POS Sale");
        TableIdList.Add(Database::"NPR POS Sale Line");
        exit(TableIdList);
    end;

    local procedure InsertAddonLineFromApi(AddonJson: JsonToken; ParentLine: Record "NPR POS Sale Line"; var CreatedLine: Record "NPR POS Sale Line")
    var
        AddonId: Text;
        AddonLineSystemId: Guid;
    begin
        if not GetJsonText(AddonJson, 'lineId', AddonId) then
            Error('missing addon id');
        if not Evaluate(AddonLineSystemId, AddonId) then
            Error('missing addon id');

        InsertAddonLineFromApi(AddonJson, ParentLine, CreatedLine, AddonLineSystemId);
    end;

    local procedure InsertAddonLineFromApi(AddonJson: JsonToken; ParentLine: Record "NPR POS Sale Line"; var CreatedLine: Record "NPR POS Sale Line"; AddonSaleLineId: Guid)
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        ItemAddOnLineOpt: Record "NPR NpIa ItemAddOn Line Opt.";
        TempItemAddOnLine: Record "NPR NpIa Item AddOn Line" temporary;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleRec: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        ItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
        AddonNo: Text;
        AddonLineNo: Integer;
        Quantity: Decimal;
        SelectedOptionLineNo: Integer;
        AddonLineNoText: Text;
        SelectedOptionLineNoText: Text;
    begin

        if not GetJsonText(AddonJson, 'addonNo', AddonNo) then
            Error('missing addon number');
        if not GetJsonText(AddonJson, 'addonLineNo', AddonLineNoText) then
            Error('missing addon line number');
        Evaluate(AddonLineNo, AddonLineNoText);

        Quantity := 1;
        if GetJsonDecimal(AddonJson, 'quantity', Quantity) then;

        if GetJsonText(AddonJson, 'selectedOptionLineNo', SelectedOptionLineNoText) then
            Evaluate(SelectedOptionLineNo, SelectedOptionLineNoText);

        ItemAddOn.Get(AddonNo);
        if not ItemAddOn.Enabled then
            Error('Item Addon is disabled');
        ItemAddOnLine.Get(AddonNo, AddonLineNo);
        ItemAddonLine.SetRecFilter();

        ItemAddOnMgt.CopyItemAddOnLinesToTemp(ItemAddOnLine, TempItemAddOnLine, true);

        if ItemAddOnLine.Type = ItemAddOnLine.Type::Select then begin
            if SelectedOptionLineNo = 0 then
                Error('Missing item addon selection');

            ItemAddOnLineOpt.Get(AddonNo, AddonLineNo, SelectedOptionLineNo);

            TempItemAddOnLine."Item No." := ItemAddOnLineOpt."Item No.";
            TempItemAddOnLine."Variant Code" := ItemAddOnLineOpt."Variant Code";
            TempItemAddOnLine.Description := ItemAddOnLineOpt.Description;
            TempItemAddOnLine."Description 2" := ItemAddOnLineOpt."Description 2";
            TempItemAddOnLine."Unit Price" := ItemAddOnLineOpt."Unit Price";
            TempItemAddOnLine."Use Unit Price" := ItemAddOnLineOpt."Use Unit Price";
            TempItemAddOnLine."Discount %" := ItemAddOnLineOpt."Discount %";
            TempItemAddOnLine."Fixed Quantity" := ItemAddOnLineOpt."Fixed Quantity";
            TempItemAddOnLine."Per Unit" := ItemAddOnLineOpt."Per Unit";
            if ItemAddOnLineOpt.Quantity <> 0 then
                TempItemAddOnLine.Quantity := ItemAddOnLineOpt.Quantity;
        end;

        if TempItemAddOnLine."Fixed Quantity" then begin
            if TempItemAddOnLine.Quantity <> Quantity then
                Error('Invalid addon quantity. Addon quantity is fixed to %1', TempItemAddOnLine.Quantity);
        end;

        TempItemAddOnLine.Quantity := Quantity;
        TempItemAddOnLine.Modify();

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(POSSaleRec);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetPosition(ParentLine.GetPosition());

        if not ItemAddOnMgt.InsertPOSAddOnLine(TempItemAddOnLine, POSSaleRec, POSSaleLine, ParentLine."Line No.", CreatedLine, AddonSaleLineId) then
            Error('Inserting POS addon line failed');
    end;

    local procedure ProcessAddonsArray(AddonsArray: JsonToken; ParentLine: Record "NPR POS Sale Line")
    var
        AddonToken: JsonToken;
        CreatedLine: Record "NPR POS Sale Line";
        i: Integer;
    begin
        for i := 0 to AddonsArray.AsArray().Count() - 1 do begin
            AddonsArray.AsArray().Get(i, AddonToken);
            InsertAddonLineFromApi(AddonToken, ParentLine, CreatedLine)
        end;
    end;
}
#endif
