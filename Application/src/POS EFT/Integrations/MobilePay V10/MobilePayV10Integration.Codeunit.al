/*
   All MobilePay transactions pass through a reserved -> polling -> capture/cancel flow. We do not log polling, capture or cancel as separate transaction request.
   These are logged in the context of the original transaction, which switches status. 
   Depending on the log level, these separate request/responses are visible in the logging factbox for the original trx.
   Everything else is treated as a separate transaction request.
*/

codeunit 6014518 "NPR MobilePayV10 Integration"
{
    trigger OnRun()
    begin
    end;

    var
        Tok_INTEGRATIONTYPE: Label 'MOBILEPAY_V10', Locked = true, MaxLength = 20;
        Lbl_DESCRIPTION: Label 'MobilePay V10 Integration';
        Lbl_NO_CASHBACK: Label 'Cashback is not supported for MobilePay';
        Lbl_POS_CREATION_SUCCESS: Label 'Created POS in MobilePay backend successfully';
        Lbl_POS_DELETE_SUCCESS: Label 'Deleted POS in MobilePay backend successfully';


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    begin
        tmpEFTIntegrationType.Init();
        tmpEFTIntegrationType.Code := Tok_INTEGRATIONTYPE;
        tmpEFTIntegrationType.Description := Lbl_DESCRIPTION;
        tmpEFTIntegrationType."Codeunit ID" := Codeunit::"NPR MobilePayV10 Integration";
        tmpEFTIntegrationType.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverAuxiliaryOperations', '', false, false)]
    local procedure OnDiscoverAuxiliaryOperations(var tmpEFTAuxOperation: Record "NPR EFT Aux Operation" temporary)
    var
        mobilePayAuxRequestType: Enum "NPR MobilePayV10 Aux. Req.";
    begin
        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := Tok_INTEGRATIONTYPE;
        tmpEFTAuxOperation."Auxiliary ID" := mobilePayAuxRequestType::AuthTokenRequest.AsInteger();
        tmpEFTAuxOperation.Description := Format(mobilePayAuxRequestType::AuthTokenRequest);
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := Tok_INTEGRATIONTYPE;
        tmpEFTAuxOperation."Auxiliary ID" := mobilePayAuxRequestType::CreatePOSRequest.AsInteger();
        tmpEFTAuxOperation.Description := Format(mobilePayAuxRequestType::CreatePOSRequest);
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := Tok_INTEGRATIONTYPE;
        tmpEFTAuxOperation."Auxiliary ID" := mobilePayAuxRequestType::DeletePOSRequest.AsInteger();
        tmpEFTAuxOperation.Description := Format(mobilePayAuxRequestType::DeletePOSRequest);
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := Tok_INTEGRATIONTYPE;
        tmpEFTAuxOperation."Auxiliary ID" := mobilePayAuxRequestType::FindActivePayment.AsInteger();
        tmpEFTAuxOperation.Description := Format(mobilePayAuxRequestType::FindActivePayment);
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := Tok_INTEGRATIONTYPE;
        tmpEFTAuxOperation."Auxiliary ID" := mobilePayAuxRequestType::FindActiveRefund.AsInteger();
        tmpEFTAuxOperation.Description := Format(mobilePayAuxRequestType::FindActiveRefund);
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := Tok_INTEGRATIONTYPE;
        tmpEFTAuxOperation."Auxiliary ID" := mobilePayAuxRequestType::FindAllPayments.AsInteger();
        tmpEFTAuxOperation.Description := Format(mobilePayAuxRequestType::FindAllPayments);
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := Tok_INTEGRATIONTYPE;
        tmpEFTAuxOperation."Auxiliary ID" := mobilePayAuxRequestType::FindAllRefunds.AsInteger();
        tmpEFTAuxOperation.Description := Format(mobilePayAuxRequestType::FindAllRefunds);
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := Tok_INTEGRATIONTYPE;
        tmpEFTAuxOperation."Auxiliary ID" := mobilePayAuxRequestType::GetPaymentDetail.AsInteger();
        tmpEFTAuxOperation.Description := Format(mobilePayAuxRequestType::GetPaymentDetail);
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := Tok_INTEGRATIONTYPE;
        tmpEFTAuxOperation."Auxiliary ID" := mobilePayAuxRequestType::GetRefundDetail.AsInteger();
        tmpEFTAuxOperation.Description := Format(mobilePayAuxRequestType::GetRefundDetail);
        tmpEFTAuxOperation.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "NPR EFT Setup")
    var
        mobilePayUnitSetup: Record "NPR MobilePayV10 Unit Setup";
        mobilePayUnitSetupPage: Page "NPR MobilePayV10 Unit Setup";
    begin
        if EFTSetup."EFT Integration Type" <> Tok_INTEGRATIONTYPE then
            exit;

        EFTSetup.TestField("POS Unit No.");

        GetPOSUnitParameters(EFTsetup, mobilePayUnitSetup);
        Commit();
        mobilePayUnitSetup.SetRecFilter();
        mobilePayUnitSetupPage.SetGlobalEFTSetup(EFTSetup);
        mobilePayUnitSetupPage.SetTableView(mobilePayUnitSetup);
        mobilePayUnitSetupPage.RunModal();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationPaymentSetup', '', false, false)]
    local procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "NPR EFT Setup")
    var
        mobilePayPaymentSetup: Record "NPR MobilePayV10 Payment Setup";
    begin
        if EFTSetup."EFT Integration Type" <> Tok_INTEGRATIONTYPE then
            exit;

        GetPaymentTypeParameters(EFTSetup, mobilePayPaymentSetup);
        Commit();
        Page.RunModal(Page::"NPR MobilePayV10 Payment Setup", mobilePayPaymentSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        mobilePayUnitSetup: Record "NPR MobilePayV10 Unit Setup";
    begin
        if not EftTransactionRequest.IsType(Tok_INTEGRATIONTYPE) then
            exit;
        Handled := true;

        if (EftTransactionRequest."Cashback Amount" > 0) then
            Error(Lbl_NO_CASHBACK);

        mobilePayUnitSetup.Get(EftTransactionRequest."Register No.");
        mobilePayUnitSetup.TestField("MobilePay POS ID");
        mobilePayUnitSetup.TestField("Beacon ID");

        InitRequest(EftTransactionRequest);
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        mobilePayUnitSetup: Record "NPR MobilePayV10 Unit Setup";
    begin
        if not EftTransactionRequest.IsType(Tok_INTEGRATIONTYPE) then
            exit;
        Handled := true;

        mobilePayUnitSetup.Get(EftTransactionRequest."Register No.");
        mobilePayUnitSetup.TestField("MobilePay POS ID");
        mobilePayUnitSetup.TestField("Beacon ID");

        InitRequest(EftTransactionRequest);
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateLookupTransactionRequest', '', false, false)]
    local procedure OnCreateLookupTransactionRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(Tok_INTEGRATIONTYPE) then
            exit;
        Handled := true;

        InitRequest(EftTransactionRequest);
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateAuxRequest', '', false, false)]
    local procedure OnCreateAuxRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(Tok_INTEGRATIONTYPE) then
            exit;
        Handled := true;

        InitRequest(EftTransactionRequest);
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnSendEftDeviceRequest', '', false, false)]
    local procedure OnSendEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        EFTMobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        if not EftTransactionRequest.IsType(Tok_INTEGRATIONTYPE) then
            exit;
        Handled := true;

        EFTMobilePayProtocol.SendTrxRequest(EftTransactionRequest);
    end;

    local procedure InitRequest(var eftTrxRequest: Record "NPR EFT Transaction Request")
    var
        mobilePayPaymentSetup: record "NPR MobilePayV10 Payment Setup";
        mobilePayUnitSetup: record "NPR MobilePayV10 Unit Setup";
        eftSetup: record "NPR EFT Setup";
    begin
        eftSetup.FindSetup(eftTrxRequest."Register No.", eftTrxRequest."POS Payment Type Code");
        mobilePayPaymentSetup.Get(eftSetup."Payment Type POS");
        mobilePayUnitSetup.Get(eftSetup."POS Unit No.");

        eftTrxRequest."Hardware ID" := mobilePayUnitSetup."MobilePay POS ID";
        eftTrxRequest."Integration Version Code" := 'V10';

        case mobilePayPaymentSetup.Environment of
            mobilePayPaymentSetup.Environment::Production:
                eftTrxRequest.Mode := eftTrxRequest.Mode::Production;
            mobilePayPaymentSetup.Environment::Sandbox:
                eftTrxRequest.Mode := eftTrxRequest.Mode::"TEST Remote";
        end;
    end;

    local procedure GetPaymentTypeParameters(EFTSetup: Record "NPR EFT Setup"; var MobilePayPaymentSetupOut: Record "NPR MobilePayV10 Payment Setup")
    begin
        EFTSetup.TestField("Payment Type POS");

        if not MobilePayPaymentSetupout.Get(EFTSetup."Payment Type POS") then begin
            MobilePayPaymentSetupout.Init();
            MobilePayPaymentSetupout."Payment Type POS" := EFTSetup."Payment Type POS";
            MobilePayPaymentSetupout.Insert();
        end;
    end;

    local procedure GetPOSUnitParameters(EFTSetup: Record "NPR EFT Setup"; var MobilePayUnitSetupOut: Record "NPR MobilePayV10 Unit Setup")
    begin
        if not MobilePayUnitSetupOut.Get(EFTSetup."POS Unit No.") then begin
            MobilePayUnitSetupOut.Init();
            MobilePayUnitSetupOut."POS Unit No." := EFTSetup."POS Unit No.";
            MobilePayUnitSetupOut."Merchant POS ID" := EFTSetup."POS Unit No.";
            MobilePayUnitSetupOut.Insert();
        end;
    end;

    internal procedure HandleProtocolResponse(var eftTrxRequest: Record "NPR EFT Transaction Request")
    var
        eftInterface: Codeunit "NPR EFT Interface";
    begin
        if not eftTrxRequest.Successful then begin
            if (GuiAllowed) then begin
                //Message(eftTrxRequest."Result Display Text");   // TODO: Problems with MESSAGE (BC17 RTM issue) - what to do now?
            end else begin
                Error(eftTrxRequest."Result Display Text");
            end;
        end;
        eftInterface.EftIntegrationResponse(eftTrxRequest);
    end;

    internal procedure CreatePOS(eftSetup: Record "NPR EFT Setup")
    var
        eftTrxRequest: Record "NPR EFT Transaction Request";
        eftFramework: Codeunit "NPR EFT Framework Mgt.";
        mobilePayAuxRequest: Enum "NPR MobilePayV10 Aux. Req.";
    begin
        eftFramework.CreateAuxRequest(eftTrxRequest, eftSetup, mobilePayAuxRequest::CreatePOSRequest.AsInteger(), eftSetup."POS Unit No.", '');
        Commit();
        eftFramework.SendRequest(eftTrxRequest);
        Commit();
        eftTrxRequest.Find();
        if eftTrxRequest.Successful then
            Message(Lbl_POS_CREATION_SUCCESS);   // TODO: Problems with MESSAGE (BC17 RTM issue) - what to do now?
    end;

    internal procedure DeletePOS(eftSetup: Record "NPR EFT Setup"; var mobilePayUnitSetup: Record "NPR MobilePayV10 Unit Setup")
    var
        eftTrxRequest: Record "NPR EFT Transaction Request";
        eftFramework: Codeunit "NPR EFT Framework Mgt.";
        mobilePayAuxRequest: Enum "NPR MobilePayV10 Aux. Req.";
    begin
        eftFramework.CreateAuxRequest(eftTrxRequest, eftSetup, mobilePayAuxRequest::DeletePOSRequest.AsInteger(), eftSetup."POS Unit No.", '');
        Commit();
        eftFramework.SendRequest(eftTrxRequest);
        Commit();
        eftTrxRequest.Find();
        if eftTrxRequest.Successful then begin
            Message(Lbl_POS_DELETE_SUCCESS);       // TODO: Problems with MESSAGE (BC17 RTM issue) - what to do now?
            clear(mobilePayUnitSetup."MobilePay POS ID");
            mobilePayUnitSetup."Merchant POS ID" := mobilePayUnitSetup."POS Unit No.";
            mobilePayUnitSetup.Modify();
        end;
    end;

    internal procedure GetMobilePayStores(eftSetup: Record "NPR EFT Setup"; var MobilePayStoresBuffer: Record "NPR MobilePayV10 Store" temporary)
    var
        mobilePayStoreListRequest: Codeunit "NPR MobilePayV10 GetStoreList";
        mobilePayStoreRequest: Codeunit "NPR MobilePayV10 Get Store";
        jsonObject: JsonObject;
        jsonArray: JsonArray;
        jsonToken: JsonToken;
        jsonToken2: JsonToken;
    begin
        mobilePayStoreListRequest.Run(eftSetup);
        jsonObject.ReadFrom(mobilePayStoreListRequest.GetResponse());
        jsonObject.SelectToken('storeIds', jsonToken);
        jsonArray := jsonToken.AsArray();

        foreach jsonToken in jsonArray do begin

            MobilePayStoresBuffer.init();
            MobilePayStoresBuffer."Store ID" := jsonToken.AsValue().AsText();

            mobilePayStoreRequest.SetStoreId(MobilePayStoresBuffer."Store ID");
            mobilePayStoreRequest.Run(eftSetup);
            jsonObject.ReadFrom(mobilePayStoreRequest.GetResponse());

            if jsonObject.SelectToken('storeName', jsonToken2) then
                MobilePayStoresBuffer."Store Name" := jsonToken2.AsValue().AsText();

            if jsonObject.SelectToken('storeStreet', jsonToken2) then
                MobilePayStoresBuffer."Store Street" := jsonToken2.AsValue().AsText();

            if jsonObject.SelectToken('storeCity', jsonToken2) then
                MobilePayStoresBuffer."Store City" := jsonToken2.AsValue().AsText();

            if jsonObject.SelectToken('brandName', jsonToken2) then
                MobilePayStoresBuffer."Brand Name" := jsonToken2.AsValue().AsText();

            if jsonObject.SelectToken('merchantBrandId', jsonToken2) then
                MobilePayStoresBuffer."Merchant Brand Id" := jsonToken2.AsValue().AsText();

            if jsonObject.SelectToken('merchantLocationId', jsonToken2) then
                MobilePayStoresBuffer."Merchant Location Id" := jsonToken2.AsValue().AsText();

            MobilePayStoresBuffer.Insert();

        end;
    end;

    internal procedure LookupStore(eftSetup: Record "NPR EFT Setup"; var value: Text): Boolean
    var
        tempMobilePayStores: Record "NPR MobilePayV10 Store" temporary;
    begin
        GetMobilePayStores(eftSetup, tempMobilePayStores);

        if Page.RunModal(0, tempMobilePayStores) = Action::LookupOK then begin
            value := tempMobilePayStores."Store ID";
            exit(true);
        end;
    end;

    internal procedure LookupPOS(eftSetup: Record "NPR EFT Setup"; var mobilePayUnitSetup: Record "NPR MobilePayV10 Unit Setup"): Boolean
    var
        mobilePayPOSListRequest: Codeunit "NPR MobilePayV10 GetPOSList";
        mobilePayPOSRequest: Codeunit "NPR MobilePayV10 GetPOS";
        jsonObject: JsonObject;
        jsonArray: JsonArray;
        jsonToken: JsonToken;
        jsonToken2: JsonToken;
        tempMobilePayPOS: Record "NPR MobilePayV10 POS" temporary;
    begin
        mobilePayUnitSetup.TestField("Store ID");
        mobilePayPOSListRequest.SetFilter('storeId=' + mobilePayUnitSetup."Store ID");
        mobilePayPOSListRequest.Run(eftSetup);
        jsonObject.ReadFrom(mobilePayPOSListRequest.GetResponse());
        jsonObject.SelectToken('posIds', jsonToken);
        jsonArray := jsonToken.AsArray();

        foreach jsonToken in jsonArray do begin
            tempMobilePayPOS.init();
            tempMobilePayPOS."MobilePay POS ID" := jsonToken.AsValue().AsText();
            mobilePayPOSRequest.SetPOSId(tempMobilePayPOS."MobilePay POS ID");
            mobilePayPOSRequest.Run(eftSetup);
            jsonObject.ReadFrom(mobilePayPOSRequest.GetResponse());

            if jsonObject.SelectToken('merchantPosId', jsonToken2) then
                tempMobilePayPOS."Merchant POS ID" := jsonToken2.AsValue().AsText();

            if jsonObject.SelectToken('name', jsonToken2) then
                tempMobilePayPOS.Name := jsonToken2.AsValue().AsText();

            if jsonObject.SelectToken('beaconId', jsonToken2) then
                tempMobilePayPOS."Beacon ID" := jsonToken2.AsValue().AsText();

            tempMobilePayPOS.Insert();
        end;

        if Page.RunModal(0, tempMobilePayPOS) = Action::LookupOK then begin
            mobilePayUnitSetup."MobilePay POS ID" := tempMobilePayPOS."MobilePay POS ID";
            mobilePayUnitSetup."Beacon ID" := tempMobilePayPOS."Beacon ID";
            mobilePayUnitSetup."Merchant POS ID" := tempMobilePayPOS."Merchant POS ID";
            mobilePayUnitSetup.Modify();
            exit(true);
        end;
    end;

    internal procedure FindAndSetDefaultMobilePayV10IntegrationType(var DefaultMobilePayEftIntType: Record "NPR EFT Integration Type" temporary): Boolean
    begin
        DefaultMobilePayEftIntType.reset();
        DiscoverEftIntegrationTypes(DefaultMobilePayEftIntType);

        DefaultMobilePayEftIntType.reset();
        DefaultMobilePayEftIntType.SetRange("Codeunit ID", Codeunit::"NPR MobilePayV10 Integration");
        exit(DefaultMobilePayEftIntType.FindFirst());
    end;

    local procedure DiscoverEftIntegrationTypes(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    var
        EFTInterface: Codeunit "NPR EFT Interface";
    begin
        if tmpEFTIntegrationType.IsEmpty then begin
            EFTInterface.OnDiscoverIntegrations(tmpEFTIntegrationType);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnBeforePauseFrontEnd', '', false, false)]
    local procedure OnBeforePauseFrontEnd(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Skip: Boolean)
    begin
        if not EFTTransactionRequest.IsType(Tok_INTEGRATIONTYPE) then
            exit;

        Skip := not (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND])
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnBeforeResumeFrontEnd', '', false, false)]
    local procedure OnBeforeResumeFrontEnd(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Skip: Boolean)
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        if not EFTTransactionRequest.IsType(Tok_INTEGRATIONTYPE) then
            exit;
        if not POSSession.GetSession(POSSession, false) then
            exit;

        Skip := not (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND])
    end;

}