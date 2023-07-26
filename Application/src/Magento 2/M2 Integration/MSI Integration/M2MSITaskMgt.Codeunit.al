codeunit 6150985 "NPR M2 MSI Task Mgt."
{
    Access = Internal;
    TableNo = "NPR Nc Task";

#if (BC17 or BC18 or BC19 or BC20)
    trigger OnRun()
    begin
        Error('Not implemented for versions lower than BC21!');
    end;
#else
    trigger OnRun()
    var
        ItemVariant: Record "Item Variant";
        TempMSIRequest: Record "NPR M2 MSI Request" temporary;
        M2IntegrationEvents: Codeunit "NPR M2 Integration Events";
        RequestArray: JsonArray;
        HasMoreRecords: Boolean;
        IsHandled: Boolean;
        VariantCodeSpecified: Boolean;
        EntityCount: Integer;
        RequestCount: Integer;
        MagentoSource: Text[50];
        MagentoSources: List of [Text[50]];
        RequestTxt: Text;
    begin
        Clear(Rec."Data Output");
        Clear(Rec.Response);

        TempMSIRequest.SetPosition(Rec."Record Position");

        if (not _ItemHelper.IsMagentoItem(TempMSIRequest."Item No.")) then
            exit;

        if (TempMSIRequest."Magento Source" = '') then
            FillSourcesArray(MagentoSources)
        else
            MagentoSources.Add(TempMSIRequest."Magento Source");

        if (MagentoSources.Count() = 0) then
            exit;

        VariantCodeSpecified := (TempMSIRequest."Variant Code" <> '');

        IsHandled := false;
        M2IntegrationEvents.CallOnBeforeFillTempMSIRequest(TempMSIRequest, VariantCodeSpecified, MagentoSources, IsHandled);
        if not IsHandled then
            foreach MagentoSource in MagentoSources do begin
                TempMSIRequest."Magento Source" := MagentoSource;

                if (not VariantCodeSpecified) then begin
                    ItemVariant.SetRange("Item No.", TempMSIRequest."Item No.");
                    ItemVariant.SetRange("NPR Blocked", false);
                    if (ItemVariant.FindSet()) then
                        repeat
                            TempMSIRequest."Variant Code" := ItemVariant.Code;
                            TempMSIRequest.Quantity := CalcStockQty(TempMSIRequest."Item No.", TempMSIRequest."Variant Code", TempMSIRequest."Magento Source");
                            TempMSIRequest.Insert();
                        until ItemVariant.Next() = 0
                    else begin
                        TempMSIRequest.Quantity := CalcStockQty(TempMSIRequest."Item No.", '', TempMSIRequest."Magento Source");
                        TempMSIRequest.Insert();
                    end;
                end else begin
                    TempMSIRequest.Quantity := CalcStockQty(TempMSIRequest."Item No.", TempMSIRequest."Variant Code", TempMSIRequest."Magento Source");
                    TempMSIRequest.Insert();
                end;
            end;

        if (not TempMSIRequest.FindSet()) then
            exit;

        HasMoreRecords := true;
        repeat
            RequestArray.Add(TempMSIRequest.SerializeToJson());
            EntityCount += 1;

            HasMoreRecords := (TempMSIRequest.Next() <> 0);

            // Magento has an unspoken limit of 20 entities in the same request
            if ((EntityCount >= 20) or (not HasMoreRecords)) then begin
                RequestCount += 1;
                PrepareRequest(RequestArray, RequestTxt);
                SendRequest(Rec, RequestCount, RequestTxt);
                EntityCount := 0;
                Clear(RequestArray);
            end;
        until (not HasMoreRecords);
    end;

    var
        _ItemHelper: Codeunit "NPR M2 Integration Item Helper";
        _HttpClient: HttpClient;
        _ClientInitialized: Boolean;
        BadApiResponseErr: Label 'Error received from the Magento API\Status Code: %1 - %2\Body: %3';

    local procedure PrepareRequest(RequestArray: JsonArray; var RequestTxt: Text)
    var
        RequestJson: JsonObject;
    begin
        RequestJson.Add('sourceItems', RequestArray);
        RequestJson.WriteTo(RequestTxt);
    end;

    local procedure SendRequest(var Task: Record "NPR Nc Task"; RequestCount: Integer; RequestTxt: Text)
    var
        InStr: InStream;
        OutStr: OutStream;
        Success: Boolean;
        ResponseTxt: Text;
        TxtBuffer: Text;
    begin
        if (Task."Data Output".HasValue()) then begin
            Task."Data Output".CreateInStream(InStr, TextEncoding::UTF8);
            InStr.Read(TxtBuffer);
        end;

        if (RequestCount > 1) then
            TxtBuffer += NewLine() + NewLine();
        TxtBuffer += StrSubstNo('Request %1', RequestCount) + NewLine();
        TxtBuffer += RequestTxt;

        Task."Data Output".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.Write(TxtBuffer);

        Task.Modify(true);
        Commit();

        Success := TrySendRequest(RequestTxt, ResponseTxt);

        Clear(TxtBuffer);
        if (Task.Response.HasValue()) then begin
            Task.Response.CreateInStream(InStr, TextEncoding::UTF8);
            InStr.Read(TxtBuffer);
        end;

        if (not Success) then
            ResponseTxt := GetLastErrorText();

        if (RequestCount > 1) then
            TxtBuffer += NewLine() + NewLine();
        TxtBuffer += StrSubstNo('Request %1', RequestCount) + NewLine();
        TxtBuffer += ResponseTxt;

        Task.Response.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.Write(TxtBuffer);

        Task.Modify(true);
        Commit();

        if (not Success) then
            Error('');
    end;

    [TryFunction]
    local procedure TrySendRequest(RequestTxt: Text; var ResponseTxt: Text)
    var
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        ResponseMsg: HttpResponseMessage;
    begin
        Content.WriteFrom(RequestTxt);
        Content.GetHeaders(ContentHeaders);
        SetHeader(ContentHeaders, 'Content-Type', 'application/json');

        InitializeHttpClient();

        _HttpClient.Post('/rest/all/V1/inventory/source-items', Content, ResponseMsg);

        if (ResponseMsg.Content.ReadAs(ResponseTxt)) then;

        if (not ResponseMsg.IsSuccessStatusCode()) then
            Error(BadApiResponseErr, ResponseMsg.HttpStatusCode(), ResponseMsg.ReasonPhrase(), ResponseTxt);
    end;

    local procedure InitializeHttpClient()
    var
        MagentoSetup: Record "NPR Magento Setup";
        ClientHeaders: HttpHeaders;
    begin
        if (_ClientInitialized) then
            exit;

        MagentoSetup.Get();
        if (MagentoSetup."Magento Url"[StrLen(MagentoSetup."Magento Url")] = '/') then
            // Really, Microsoft!? You can't statically figure out that the string length of a field minus a
            // positive integer is lower than the string length of the same field?
            // Disabling the warning...
#pragma warning disable AA0139
            MagentoSetup."Magento Url" := CopyStr(MagentoSetup."Magento Url", 1, StrLen(MagentoSetup."Magento Url") - 1);
#pragma warning restore AA0139

        _HttpClient.SetBaseAddress(MagentoSetup."Magento Url");

        ClientHeaders := _HttpClient.DefaultRequestHeaders();
        SetHeader(ClientHeaders, 'Authorization', MagentoSetup."Api Authorization");
        SetHeader(ClientHeaders, 'User-Agent', 'Microsoft-Dynamics-365-Business-Central-NP-Retail');
        SetHeader(ClientHeaders, 'Connection', 'Keep-Alive');
        SetHeader(ClientHeaders, 'Accept', 'application/json');

        _ClientInitialized := true;
    end;

    local procedure CalcStockQty(ItemNo: Code[20]; VariantFilter: Text; MagentoSource: Text[50]) Qty: Decimal
    var
        Item: Record Item;
        Location: Record Location;
        SelectionMgt: Codeunit SelectionFilterManagement;
    begin
        Location.SetRange("NPR Magento 2 Source", MagentoSource);
        if (Location.IsEmpty()) then
            exit(0);

        Item.SetLoadFields("No.", Inventory, "Qty. on Sales Order");
        Item.SetAutoCalcFields(Inventory, "Qty. on Sales Order");
        Item.SetFilter("Variant Filter", VariantFilter);
        Item.SetFilter("Location Filter", SelectionMgt.GetSelectionFilterForLocation(Location));
        Item.Get(ItemNo);
        Qty := Item.Inventory - Item."Qty. on Sales Order";
        if (Qty < 0) then
            Qty := 0;
    end;

    local procedure SetHeader(var Headers: HttpHeaders; HeaderName: Text; HeaderValue: Text)
    begin
        if (Headers.Contains(HeaderName)) then
            Headers.Remove(HeaderName);
        Headers.Add(HeaderName, HeaderValue);
    end;

    local procedure FillSourcesArray(var MagentoSources: List of [Text[50]])
    var
        Location: Record Location;
    begin
        Location.SetFilter("NPR Magento 2 Source", '<>%1', '');
        if (Location.FindSet()) then
            repeat
                if (not MagentoSources.Contains(Location."NPR Magento 2 Source")) then
                    MagentoSources.Add(Location."NPR Magento 2 Source");
            until Location.Next() = 0;
    end;

    local procedure NewLine(): Text[1]
    begin
        exit('\');
    end;
#endif
}