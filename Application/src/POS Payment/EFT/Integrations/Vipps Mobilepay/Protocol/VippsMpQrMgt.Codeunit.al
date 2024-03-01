codeunit 6184740 "NPR Vipps Mp Qr Mgt."
{
    Access = Internal;


    internal procedure CreateQRBarcodeUI()
    var
        VippsMpQrCallback: Record "NPR Vipps Mp QrCallback";
        PosUnit: Record "NPR POS Unit";
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        VippsMpSetupState: Codeunit "NPR Vipps Mp SetupState";
    begin
        VippsMpQrCallback.Init();
#pragma warning disable AA0139
        VippsMpQrCallback."Merchant Qr Id" := VippsMpUtil.RemoveCurlyBraces(CreateGuid());
#pragma warning restore AA0139
        PosUnit.Get(VippsMpSetupState.GetCurrentPosUnitNo());
        VippsMpQrCallback."Location Description" := PosUnit.Name;
        VippsMpQrCallback."Merchant Serial Number" := VippsMpSetupState.GetCurrentMsn();
        VippsMpQrCallback.Insert();
        Commit();
        if (Page.RunModal(Page::"NPR Vipps Mp QrCallback", VippsMpQrCallback) = Action::LookupCancel) then begin
            VippsMpQrCallback.Delete();
            exit;
        end;
        CreateQRBarcode(VippsMpQrCallback);
    end;

    internal procedure CreateQRBarcode(VippsMpQr: Record "NPR Vipps Mp QrCallback")
    var
        VippsMpStore: Record "NPR Vipps Mp Store";
        VippsMpQrAPI: Codeunit "NPR Vipps Mp QR API";
        JsonResponse: JsonObject;
        Token: JsonToken;
        LblCreateUpdateErr: Label 'Error when creating/updating QR: %1';
        LblFetchQrContentErr: Label 'Error when fetching the Qr Content: %1';
    begin
        VippsMpStore.Get(VippsMpQr."Merchant Serial Number");
        if (not VippsMpQrAPI.CreateOrUpdateCallbackQr(VippsMpStore, VippsMpQr."Merchant Qr Id", VippsMpQr."Location Description")) then
            Error(LblCreateUpdateErr, GetLastErrorText());
        if (not VippsMpQrAPI.GetMerchantCallBackQrInfo(VippsMpStore, VippsMpQr."Merchant Qr Id", JsonResponse)) then
            Error(LblFetchQrContentErr, GetLastErrorText());
        JsonResponse.Get('qrContent', Token);
#pragma warning disable AA0139
        VippsMpQr."Qr Content" := Token.AsValue().AsText();
#pragma warning restore AA0139
        VippsMpQr.Modify();
    end;

    internal procedure RemoveQrBarcode(VippsMpQr: Record "NPR Vipps Mp QrCallback")
    var
        VippsMpStore: Record "NPR Vipps Mp Store";
        VippsMpQrAPI: Codeunit "NPR Vipps Mp QR API";
        VippsMpSetupState: Codeunit "NPR Vipps Mp SetupState";
        LblDeleteErr: Label 'Error when deleting Qr: %1';
    begin
        if (not VippsMpStore.Get(VippsMpQr."Merchant Serial Number")) then
            VippsMpStore.Get(VippsMpSetupState.GetCurrentMsn());
        if (not VippsMpQrAPI.DeleteCallbackQr(VippsMpStore, VippsMpQr."Merchant Qr Id")) then
            Error(LblDeleteErr, GetLastErrorText());
        VippsMpQr.Delete();
    end;

    internal procedure SynchronizeQrBarcodes()
    var
        VippsMpStore: Record "NPR Vipps Mp Store";
        VippsMpQrCallback: Record "NPR Vipps Mp QrCallback";
        VippsMpQrAPI: Codeunit "NPR Vipps Mp QR API";
        JsonResponse: JsonArray;
        token: JsonToken;
        token2: JsonToken;
        FilterTxt: Text;
    begin
        while VippsMpStore.Next() <> 0 do begin
            if (not VippsMpQrAPI.GetAllMerchantCallBackQrInfo(VippsMpStore, JsonResponse)) then
                Error('');
            foreach token in JsonResponse do begin
                token.AsObject().Get('merchantQrId', token2);
                FilterTxt += '<>' + token2.AsValue().AsText() + '&';
                if (not VippsMpQrCallback.Get(token2.AsValue().AsText())) then begin
                    VippsMpQrCallback.Init();
#pragma warning disable AA0139
                    VippsMpQrCallback."Merchant Qr Id" := token2.AsValue().AsText();
                    token.AsObject().Get('locationDescription', token2);
                    VippsMpQrCallback."Location Description" := token2.AsValue().AsText();
                    token.AsObject().Get('qrContent', token2);
                    VippsMpQrCallback."Qr Content" := token2.AsValue().AsText();
                    token.AsObject().Get('merchantSerialNumber', token2);
                    VippsMpQrCallback."Merchant Serial Number" := token2.AsValue().AsText();
#pragma warning restore AA0139
                    VippsMpQrCallback.Insert();
                end;
            end;
        end;
        FilterTxt := FilterTxt.TrimEnd('&');
        VippsMpQrCallback.SetFilter("Merchant Qr Id", FilterTxt);
        VippsMpQrCallback.DeleteAll();
    end;

    internal procedure ListAll(VippsStore: Record "NPR Vipps Mp Store")
    var
        VippsMpQrAPI: Codeunit "NPR Vipps Mp QR API";
        JsonResponse: JsonArray;
        token: JsonToken;
        token2: JsonToken;
        Result: Text;
    begin
        if (not VippsMpQrAPI.GetAllMerchantCallBackQrInfo(VippsStore, JsonResponse)) then
            Error('');
        Result := '[ ';
        foreach token in JsonResponse do begin
            token.AsObject().Get('merchantQrId', token2);
            Result := Result + token2.AsValue().AsText() + ' => ';
            token.AsObject().Get('locationDescription', token2);
            Result := Result + token2.AsValue().AsText() + ', ';
        end;
        Result := Result + ' ]';
        Message(Result);
    end;

    internal procedure CreateUpdateMobilepayQrUI()
    var
        VippsMpQrCallbackPage: Page "NPR Vipps Mp QrCallback";
        VippsMpQrCallback: Record "NPR Vipps Mp QrCallback";
    begin
        VippsMpQrCallbackPage.SetMobilePaySetup();
        VippsMpQrCallbackPage.SetRecord(VippsMpQrCallback);
        if (VippsMpQrCallbackPage.RunModal() = Action::LookupCancel) then
            exit;
        CreateUpdateMobilepayQr(VippsMpQrCallback);
    end;

    internal procedure CreateUpdateMobilepayQr(QrRec: Record "NPR Vipps Mp QrCallback")
    var
        VippsMpStore: Record "NPR Vipps Mp Store";
        VippsMpQrAPI: Codeunit "NPR Vipps Mp QR API";
        JsonResponse: JsonObject;
        token: JsonToken;
        LblCreateUpdateMpQrErr: Label 'Could not create/update the old Mobilepay Qr: %1';
        LblFetchMpQrErr: Label 'Could not fetch the old Mobilepay Qr content: %1';
    begin
        VippsMpStore.Get(QrRec."Merchant Serial Number");
        if (not VippsMpQrAPI.CreateORUpdateMobilepayQr(VippsMpStore, QrRec."Merchant Qr Id", QrRec."Location Description")) then
            Error(LblCreateUpdateMpQrErr, GetLastErrorText());
        if (not VippsMpQrAPI.GetMerchantCallBackQrInfo(VippsMpStore, QrRec."Merchant Qr Id", JsonResponse)) then
            Error(LblFetchMpQrErr, GetLastErrorText());
        JsonResponse.Get('qrContent', token);
#pragma warning disable AA0139
        QrRec."Qr Content" := token.AsValue().AsText();
#pragma warning restore AA0139
        QrRec.Modify();
    end;
}