codeunit 6184624 "NPR API POS Sale Line V2"
{
    Access = Internal;

    var
        _APIPOSSaleLine: Codeunit "NPR API POS Sale Line";

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
        DiscountManagement: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        SaleLineId: Guid;
        AddonsArray: JsonToken;
    begin
        Request.SkipCacheIfNonStickyRequest(_APIPOSSaleLine.POSSaleTableIds());

        SaleId := Request.Paths().Get(3);
        if SaleId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: saleId'));

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));

        if not POSSaleRec.GetBySystemId(SaleSystemId) then
            exit(Response.RespondResourceNotFound());

        if not APIPOSSale.AssertPOSUnitOpenForSale(POSSaleRec."Register No.") then
            exit(Response.RespondBadRequest(StrSubstNo('POS Unit ''%1'' is not open for sales.', POSSaleRec."Register No.")));

        if not Evaluate(SaleLineId, Request.Paths().Get(5)) then
            exit(Response.RespondBadRequest('Invalid saleLineId format'));

        Body := Request.BodyJson();

        APIPOSSale.ReconstructSession(SaleSystemId);
        DeltaBuilder.StartDataCollection();
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(TempPOSSaleLine);

        if not _APIPOSSaleLine.ParseSaleLineFromJson(Body, TempPOSSaleLine) then
            exit(Response.RespondBadRequest('Invalid sale line data'));

        TempPOSSaleLine.SystemId := SaleLineId;

        POSSaleLine.SetUseCustomSystemId(true);
        if not POSSaleLine.InsertLine(TempPOSSaleLine, true) then
            exit(Response.RespondBadRequest('Failed to insert sale line'));

        POSSaleLine.GetCurrentSaleLine(CreatedLine);
        if Body.AsObject().Get('addons', AddonsArray) and AddonsArray.IsArray() then begin
            ProcessAddonsArray(AddonsArray, CreatedLine);
            DiscountManagement.RecalculateAllSaleLinePOS(POSSaleRec);
        end;
        InsertMissingMandatoryAddons(CreatedLine, POSSession);

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
        DiscountManagement: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        ParentLineIdText: Text;
    begin
        Request.SkipCacheIfNonStickyRequest(_APIPOSSaleLine.POSSaleTableIds());

        SaleId := Request.Paths().Get(3);
        AddonLineId := Request.Paths().Get(5);

        if not Evaluate(SaleSystemId, SaleId) then
            exit(Response.RespondBadRequest('Invalid saleId format'));
        if not Evaluate(AddonLineSystemId, AddonLineId) then
            exit(Response.RespondBadRequest('Invalid addonLineId format'));

        if not POSSaleRec.GetBySystemId(SaleSystemId) then
            exit(Response.RespondResourceNotFound());

        if not APIPOSSale.AssertPOSUnitOpenForSale(POSSaleRec."Register No.") then
            exit(Response.RespondBadRequest(StrSubstNo('POS Unit ''%1'' is not open for sales.', POSSaleRec."Register No.")));

        Body := Request.BodyJson();

        if not _APIPOSSaleLine.GetJsonText(Body, 'parentLineId', ParentLineIdText) then
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
        DiscountManagement.OnAfterInsertSaleLinePOS(CreatedLine);

        exit(Response.RespondCreated(DeltaBuilder.BuildDeltaResponse()));
    end;

    local procedure InsertAddonLineFromApi(AddonJson: JsonToken; ParentLine: Record "NPR POS Sale Line"; var CreatedLine: Record "NPR POS Sale Line")
    var
        AddonId: Text;
        AddonLineSystemId: Guid;
    begin
        if not _APIPOSSaleLine.GetJsonText(AddonJson, 'lineId', AddonId) then
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

        if not _APIPOSSaleLine.GetJsonText(AddonJson, 'addonNo', AddonNo) then
            Error('missing addon number');
        if not _APIPOSSaleLine.GetJsonText(AddonJson, 'addonLineNo', AddonLineNoText) then
            Error('missing addon line number');
        Evaluate(AddonLineNo, AddonLineNoText);

        Quantity := 1;
        if _APIPOSSaleLine.GetJsonDecimal(AddonJson, 'quantity', Quantity) then;

        if _APIPOSSaleLine.GetJsonText(AddonJson, 'selectedOptionLineNo', SelectedOptionLineNoText) then
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
            // Mandatory on a Select line only requires a choice; the chosen line stays deletable
            TempItemAddOnLine.Mandatory := false;
            if ItemAddOnLineOpt.Quantity <> 0 then
                TempItemAddOnLine.Quantity := ItemAddOnLineOpt.Quantity;
        end else
            SelectedOptionLineNo := 0;

        if TempItemAddOnLine."Fixed Quantity" then begin
            if TempItemAddOnLine.Quantity <> Quantity then
                Error('Invalid addon quantity. Addon quantity is fixed to %1', TempItemAddOnLine.Quantity);
        end;

        TempItemAddOnLine.Quantity := Quantity;
        if TempItemAddOnLine."Per Unit" and (TempItemAddOnLine."Fixed Quantity" or (not TempItemAddOnLine.Mandatory)) and
           (ParentLine."Quantity (Base)" <> 0)
        then
            TempItemAddOnLine.Quantity := Round(Quantity * ParentLine."Quantity (Base)", 0.00001);
        TempItemAddOnLine.Modify();

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(POSSaleRec);
        POSSession.GetSaleLine(POSSaleLine);
        if ItemAddOnLine.Mandatory and (ItemAddOnLine.Type = ItemAddOnLine.Type::Quantity) then
            ItemAddOnMgt.RemoveAttachedPOSAddOnLine(POSSaleRec, POSSaleLine, ParentLine."Line No.", TempItemAddOnLine);
        POSSaleLine.SetPosition(ParentLine.GetPosition());

        if not ItemAddOnMgt.InsertPOSAddOnLine(TempItemAddOnLine, POSSaleRec, POSSaleLine, ParentLine."Line No.", CreatedLine, AddonSaleLineId, SelectedOptionLineNo) then
            Error('Inserting POS addon line failed');
    end;

    local procedure InsertMissingMandatoryAddons(ParentLine: Record "NPR POS Sale Line"; POSSession: Codeunit "NPR POS Session")
    var
        Item: Record Item;
        ItemAddOn: Record "NPR NpIa Item AddOn";
        ItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
    begin
        if ParentLine."Line Type" <> ParentLine."Line Type"::Item then
            exit;
        if not Item.Get(ParentLine."No.") then
            exit;
        if Item."NPR Item AddOn No." = '' then
            exit;
        if not ItemAddOn.Get(Item."NPR Item AddOn No.") then
            exit;
        if not ItemAddOn.Enabled then
            exit;

        ItemAddOnMgt.InsertMissingMandatoryPOSAddOnLines(ItemAddOn, POSSession, ParentLine);
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
