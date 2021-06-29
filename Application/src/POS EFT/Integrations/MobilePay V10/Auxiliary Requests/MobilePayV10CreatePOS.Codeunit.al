codeunit 6014478 "NPR MobilePayV10 CreatePOS"
{
    // POST  /v10/pointofsales
    TableNo = "NPR EFT Transaction Request";

    var
        _request: text;
        _response: text;
        _responseHttpCode: Integer;
        QR_BEACON_EMPTY_Err: Label '%1 must not be empty unless used in QR-only mode. Scan the box ID into the field.';

    trigger OnRun()
    begin
        clear(_request);
        clear(_response);
        clear(_responseHttpCode);
        SendRequest(Rec);
    end;

    internal procedure GetRequestResponse(): text
    begin
        exit(StrSubstNo('==Request==\%1\\==Response==\(%2)\%3', _request, _responseHttpCode, _response));
    end;

    local procedure SendRequest(var eftTrxRequest: Record "NPR EFT Transaction Request")
    var
        reqMessage: HttpRequestMessage;
        httpClient: HttpClient;
        respMessage: HttpResponseMessage;
        headers: HttpHeaders;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
        eftSetup: Record "NPR EFT Setup";
        jsonRequest: JsonObject;
        mobilePayUnitSetup: Record "NPR MobilePayV10 Unit Setup";
        posUnit: Record "NPR POS Unit";
        beaconTypes: JsonArray;
        httpRequestHelper: Codeunit "NPR HttpRequest Helper";
    begin
        eftSetup.FindSetup(eftTrxRequest."Register No.", eftTrxRequest."Original POS Payment Type Code");
        mobilePayUnitSetup.Get(eftSetup."POS Unit No.");
        posUnit.Get(eftSetup."POS Unit No.");

        reqMessage.GetHeaders(headers);
        mobilePayProtocol.SetGenericHeaders(eftSetup, reqMessage, httpRequestHelper, headers);
        httpRequestHelper.SetHeader('x-mobilepay-idempotency-key', Format(eftTrxRequest."Entry No."));

        jsonRequest.Add('merchantPosId', mobilepayUnitSetup."Merchant PoS ID");
        jsonRequest.Add('storeId', mobilePayUnitSetup."Store ID");
        jsonRequest.Add('name', posUnit.Name);

        // Beacons types
        beaconTypes.Add('QR');
        if mobilePayUnitSetup."Only QR" then begin
            // Nothing here!
        end else begin
            // Could be (or should be a Bluetooth) device otherwise "QR only" is recommended to use.
            // Bluetooth approach is to support legacy, new MobilePay subscriptions will be QR only as the
            // physical devices are not provided anymore.
            if mobilePayUnitSetup."Beacon ID" = '' then begin
                // It's mandatory for Bluetooth devices.
                error(QR_BEACON_EMPTY_Err, mobilePayUnitSetup.FieldCaption("Beacon ID"))
            end;
            beaconTypes.Add('Bluetooth');
        end;
        jsonRequest.Add('supportedBeaconTypes', beaconTypes);

        // Beacon ID
        if mobilePayUnitSetup."Beacon ID" = '' then begin
            // Supposing we are in QR only mode without QR being preassigned, let's generate a new one.
            // This is useful especially for MPOS units which can render whatever code and don't depend
            // on any physical QR sticker or even device.
            mobilePayUnitSetup."Beacon ID" := Format(CreateGuid()).TrimStart('{').TrimEnd('}').ToLower();
            mobilePayUnitSetup.Modify();
        end;
        jsonRequest.Add('beaconId', mobilePayUnitSetup."Beacon ID");

        jsonRequest.WriteTo(_request);
        reqMessage.Content.WriteFrom(_request);
        reqMessage.Content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');
        reqMessage.Method := 'POST';
        reqMessage.SetRequestUri(mobilePayProtocol.GetURL(eftSetup) + '/pos/v10/pointofsales');

        mobilePayProtocol.SendAndPreHandleTheRequest(httpClient, reqMessage, respMessage, httpRequestHelper);

        _responseHttpCode := respMessage.HttpStatusCode;
        respMessage.Content.ReadAs(_response);

        ParseResponse(reqMessage, respMessage, eftTrxRequest, mobilePayUnitSetup);

    end;

    local procedure ParseResponse(var reqMessage: HttpRequestMessage; respMessage: HttpResponseMessage; var eftTrxRequest: Record "NPR EFT Transaction Request"; mobilePayUnitSetup: Record "NPR MobilePayV10 Unit Setup")
    var
        jsonToken: JsonToken;
        jsonResponse: JsonObject;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayProtocol.PreHandlerTheResponse(reqMessage, respMessage, jsonResponse, true, '');

        jsonResponse.SelectToken('posId', jsonToken);
        mobilePayUnitSetup."MobilePay POS ID" := jsonToken.AsValue().AsText();
        mobilePayUnitSetup.Modify();

        eftTrxRequest."External Result Known" := true;
        eftTrxRequest.Successful := true;
        eftTrxRequest.Modify();
    end;
}