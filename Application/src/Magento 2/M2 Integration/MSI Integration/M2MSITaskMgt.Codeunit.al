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
        RequestTxt: Text;
        ResponseTxt: Text;
        Success: Boolean;
        TempMSIRequest: Record "NPR M2 MSI Request" temporary;
        OutStr: OutStream;
    begin
        TempMSIRequest.SetPosition(Rec."Record Position");

        if (not _ItemHelper.IsMagentoItem(TempMSIRequest."Item No.")) then
            exit;

        TempMSIRequest.Quantity := CalcStockQty(TempMSIRequest."Item No.", TempMSIRequest."Variant Code", TempMSIRequest."Magento Source");

        PrepareRequest(TempMSIRequest, RequestTxt);

        Rec."Data Output".CreateOutStream(OutStr);
        OutStr.Write(RequestTxt);
        Rec.Modify(true);
        Commit();

        Success := TrySendRequest(RequestTxt, ResponseTxt);

        Clear(OutStr);
        Rec.Response.CreateOutStream(OutStr);

        if (not Success) then
            ResponseTxt := GetLastErrorText();

        OutStr.Write(ResponseTxt);
        Rec.Modify(true);
        Commit();

        if (not Success) then
            Error('');
    end;

    var
        _ItemHelper: Codeunit "NPR M2 Integration Item Helper";
        BadApiResponseErr: Label 'Error received from the Magento API\Status Code: %1 - %2\Body: %3';

    local procedure PrepareRequest(TempMSIRequest: Record "NPR M2 MSI Request" temporary; var RequestTxt: Text)
    var
        RequestArray: JsonArray;
        RequestJson: JsonObject;
    begin
        RequestArray.Add(TempMSIRequest.SerializeToJson());
        RequestJson.Add('sourceItems', RequestArray);
        RequestJson.WriteTo(RequestTxt);
    end;

    [TryFunction]
    local procedure TrySendRequest(RequestTxt: Text; var ResponseTxt: Text)
    var
        MagentoSetup: Record "NPR Magento Setup";
        ResponseMsg: HttpResponseMessage;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        Client: HttpClient;
        ClientHeaders: HttpHeaders;
    begin
        Content.WriteFrom(RequestTxt);
        Content.GetHeaders(ContentHeaders);
        SetHeader(ContentHeaders, 'Content-Type', 'application/json');

        MagentoSetup.Get();
        if (MagentoSetup."Magento Url"[StrLen(MagentoSetup."Magento Url")] = '/') then
            // Really, Microsoft!? You can't statically figure out that the string length of a field minus a
            // positive integer is lower than the string length of the same field?
            // Disabling the warning...
#pragma warning disable AA0139
            MagentoSetup."Magento Url" := CopyStr(MagentoSetup."Magento Url", 1, StrLen(MagentoSetup."Magento Url") - 1);
#pragma warning restore AA0139

        Client.SetBaseAddress(MagentoSetup."Magento Url");

        ClientHeaders := Client.DefaultRequestHeaders();
        SetHeader(ClientHeaders, 'Authorization', MagentoSetup."Api Authorization");
        SetHeader(ClientHeaders, 'User-Agent', 'Microsoft-Dynamics-365-Business-Central-NP-Retail');
        SetHeader(ClientHeaders, 'Connection', 'Keep-Alive');
        SetHeader(ClientHeaders, 'Accept', 'application/json');

        Client.Post('/rest/all/V1/inventory/source-items', Content, ResponseMsg);

        if (ResponseMsg.Content.ReadAs(ResponseTxt)) then;

        if (not ResponseMsg.IsSuccessStatusCode()) then
            Error(BadApiResponseErr, ResponseMsg.HttpStatusCode(), ResponseMsg.ReasonPhrase(), ResponseTxt);
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
#endif
}