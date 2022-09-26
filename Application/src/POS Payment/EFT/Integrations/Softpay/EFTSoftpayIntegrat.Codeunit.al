codeunit 6059891 "NPR EFT Softpay Integrat."
{
    Access = Internal;

    trigger OnRun()
    begin
    end;

    var
        Description: Label 'MPOS Android Softpay terminal';

    procedure IntegrationType(): Code[20]
    begin
        exit('SOFTPAY');
    end;

    //Fires when Selecting "EFT Integration Type" inside EFT Setup.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    begin
        tmpEFTIntegrationType.Init();
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := Description;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR EFT Softpay Integrat.";
        tmpEFTIntegrationType."Version 2" := True;
        tmpEFTIntegrationType.Insert();
    end;
    //Fires when Selecting "POS Unit Parameter" inside EFT Setup.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "NPR EFT Setup")
    var
        Softpay: Record "NPR EFT Softpay Config";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;
        PAGE.RunModal(0, Softpay);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;
        //Fill any type specific information onto the request record before the request is fired.
        EftTransactionRequest."Reference Number Input" := EftTransactionRequest.Token;
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
        Handled := true;
    end;

    // It is sufficient to include "WorkflowName" only. It will cause the workflow to call its preparation stage
    //EftWorkflow.Add('WorkflowName', Format(Enum::"NPR POS Workflow"::SOFTPAY));
    // But by including the the hwcRequest and if the workflow supports it, we can save a roundtrip
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnPrepareRequestSend', '', false, false)]

    local procedure OnPrepareRequestSend(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Request: JsonObject; var RequestMechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text)
    var
        Enviroment: Text;
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        SoftpayConfig: Record "NPR EFT Softpay Config";
        SoftpayMerchant: Record "NPR EFT Softpay Merchant";
    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;
        Workflow := Format(Enum::"NPR POS Workflow"::SOFTPAY);
        RequestMechanism := RequestMechanism::POSWorkflow;
        SoftpayConfig.Get(EftTransactionRequest."Register No.");
        SoftpayMerchant.Get(SoftpayConfig."Merchant ID");
        Enviroment := Format(SoftpayMerchant.Environment);
        Request.Add('IntegratorID', AzureKeyVaultMgt.GetAzureKeyVaultSecret('Softpay-IntegratorID-' + Enviroment));
        Request.Add('IntegratorCredentials', AzureKeyVaultMgt.GetAzureKeyVaultSecret('Softpay-IntegratorCred-' + Enviroment));
        Request.Add('SoftpayUsername', SoftpayMerchant."Merchant ID");
        Request.Add('SoftpayPassword', SoftpayMerchant."Merchant Password");
        Request.Add('EFTEntryNo', EftTransactionRequest."Entry No.");
        Request.Add('Amount', EftTransactionRequest."Amount Input");
        Request.Add('Currency', EftTransactionRequest."Currency Code");

        case EFTTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::PAYMENT:
                begin
                    Request.Add('SoftpayAction', 'Payment');
                end;
            EftTransactionRequest."Processing Type"::REFUND:
                begin
                    Request.Add('SoftpayAction', 'Refund');
                    if (EftTransactionRequest."Amount Input" < 0) then
                        Request.Replace('Amount', -EftTransactionRequest."Amount Input");
                end;
            EftTransactionRequest."Processing Type"::LOOK_UP:
                begin
                    Request.Add('SoftpayAction', 'GetTransaction');
                    Request.Add('RequestID', EftTransactionRequest."Reference Number Output");
                end;
            /*
                ###############################################################
                # Void is supported and works, but for now we don't enable it.#
                ###############################################################
                EftTransactionRequest."Processing Type"::VOID:
                begin
                    Request.Add('SoftpayAction', 'Cancellation');
                    Request.Add('RequestID', EftTransactionRequest."Reference Number Output");
                end;*/
            else
                Message('Type %1 is not supported for softpay', Format(EftTransactionRequest."Processing Type"));
        end;
    end;

    //Fires after before lookup
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateLookupTransactionRequest', '', false, false)]
    local procedure OnCreateLookupTransactionRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        oldRecord: Record "NPR EFT Transaction Request";
    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;
        oldRecord.Get(EftTransactionRequest."Processed Entry No.");
        EftTransactionRequest."Reference Number Output" := oldRecord."Reference Number Output";
        EftTransactionRequest.Insert(true);
        Handled := True;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;
        EftTransactionRequest."Reference Number Input" := EftTransactionRequest.Token;
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
        Handled := true;
    end;

    //It works and is supported but we don't enable it for now. Might be in future that is why It is left here
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateVoidRequest', '', false, false)]
    local procedure OnCreateVoidRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;
        /*oldRecord.Get(EftTransactionRequest."Processed Entry No.");
        EftTransactionRequest."Reference Number Output" := oldRecord."Reference Number Output";
        EftTransactionRequest."Reference Number Input" := EftTransactionRequest.Token;
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest.Insert(true);
        Handled := true;*/
    end;
}