codeunit 6150840 "NPR EFT Planet PAX Integ"
{
    Access = Internal;

    var
        Description: Label 'Terminal integration';

    procedure IntegrationType(): Code[20]
    begin
        exit('PLANET_PAX');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    begin
        tmpEFTIntegrationType.Init();
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := Description;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR EFT Planet PAX Integ";
        tmpEFTIntegrationType."Version 2" := True;
        tmpEFTIntegrationType.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "NPR EFT Setup")
    var
        PlanetPax: Record "NPR EFT Planet PAX Config";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;
        PAGE.RunModal(0, PlanetPax);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationPaymentSetup', '', false, false)]
    local procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "NPR EFT Setup")
    var
        PlanetPaxPaymentSetup: Record "NPR EFT Planet Integ. Config";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;
        GetPaymentTypeParameters(EFTSetup, PlanetPaxPaymentSetup);
        Commit();
        PAGE.RunModal(PAGE::"NPR EFT Planet Integ. Conf.", PlanetPaxPaymentSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Output" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify();
        Handled := true;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateLookupTransactionRequest', '', false, false)]
    local procedure OnCreateLookupTransactionRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        oldRecord: Record "NPR EFT Transaction Request";
    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;
        oldRecord.Get(EftTransactionRequest."Processed Entry No.");
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest."Reference Number Output" := oldRecord."Reference Number Output";
        EftTransactionRequest.Insert(true);
        Handled := True;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Output" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify();
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateVoidRequest', '', false, false)]
    local procedure OnCreateVoidRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        oldRecord: Record "NPR EFT Transaction Request";
    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;
        oldRecord.Get(EftTransactionRequest."Processed Entry No.");
        EftTransactionRequest."Reference Number Output" := oldRecord."Reference Number Output";
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Insert(true);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnPrepareRequestSend', '', false, false)]
    local procedure OnPrepareRequestSend(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Request: JsonObject; var RequestMechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text)
    var
        EftTypeErrLabl: Label 'The EFT operation ''%1'' is not supported.';
        PlanetConfig: Record "NPR EFT Planet PAX Config";
    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;
        if (not PlanetConfig.Get(EftTransactionRequest."Register No.")) then
            exit;
        EftTransactionRequest."Hardware ID" := PlanetConfig."Terminal ID";
        Workflow := Format(Enum::"NPR POS Workflow"::PLANET_PAX);


        if (EftTransactionRequest."Processing Type" in [
            EftTransactionRequest."Processing Type"::PAYMENT,
            EftTransactionRequest."Processing Type"::REFUND]) then begin

            RequestMechanism := RequestMechanism::POSWorkflow;
            Request.Add('EFTEntryNo', EftTransactionRequest."Entry No.");
            Request.Add('EFTReqType', Format(EftTransactionRequest."Processing Type"));
            Request.Add('formattedAmount', Format(EFTTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>'));
            exit;
        end;
        if (EftTransactionRequest."Processing Type" in [
            EftTransactionRequest."Processing Type"::LOOK_UP,
            EftTransactionRequest."Processing Type"::VOID]) then begin

            RequestMechanism := RequestMechanism::Synchronous;
            exit;
        end;
        Error(EftTypeErrLabl);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnSendRequestSynchronously', '', false, false)]
    local procedure OnSendRequestSynchronously(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        Protocol: Codeunit "NPR 3cXml Protocol";
        LogCU: Codeunit "NPR EFT Planet PAX Logger";
        EftInterface: Codeunit "NPR EFT Interface";
        Config: Record "NPR EFT Planet PAX Config";
        LogLvl: Enum "NPR EFT Planet Pax Log Lvl";
        Request: Text;
        Response: Text;
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        if (EftTransactionRequest."Processing Type" in [
            EftTransactionRequest."Processing Type"::LOOK_UP,
            EftTransactionRequest."Processing Type"::VOID]) then begin
            Config.Get(EftTransactionRequest."Register No.");
            Request := Protocol.PreparePlanetPaxEftRequest(EftTransactionRequest);
            LogCU.Log(LogLvl::Verbose, EftTransactionRequest, 'Request', Request);
            if (not Protocol.SendRequest(Config."Url Endpoint", Request, Response)) then begin
                LogCU.Log(LogLvl::Error, EftTransactionRequest, 'SendRequestFailed', Response);
            end else begin
                LogCU.Log(LogLvl::Verbose, EftTransactionRequest, 'ResponseReceived', Response);
            end;

            Protocol.HandleEftResponse(Response, EftTransactionRequest);
            if (not EftTransactionRequest.Successful) then begin
                if (EftTransactionRequest."Result Description" = '') then
                    Message(EftTransactionRequest."Client Error")
                else
                    Message(EftTransactionRequest."Result Description");
            end;
            EftInterface.EftIntegrationResponse(EftTransactionRequest);
            Handled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnAfterFinancialCommit', '', false, false)]
    local procedure OnAfterFinancialCommit(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        if not Codeunit.Run(Codeunit::"NPR EFT Try Print Receipt", EftTransactionRequest) then
            Message(GetLastErrorText);
        Commit();
    end;

    internal procedure GetPaymentTypeParameters(EFTSetup: Record "NPR EFT Setup"; var EFTPaymentConfig: Record "NPR EFT Planet Integ. Config")
    begin
        EFTSetup.TestField("Payment Type POS");

        if not EFTPaymentConfig.Get(EFTSetup."Payment Type POS") then begin
            EFTPaymentConfig.Init();
            EFTPaymentConfig."Payment Type POS" := EFTSetup."Payment Type POS";
            EFTPaymentConfig."Log Level" := Enum::"NPR EFT Planet Pax Log Lvl"::Error;
            EFTPaymentConfig.Insert();
        end;
    end;
}