codeunit 6184630 "NPR EFT Ext. Terminal Integ."
{
    Access = Internal;

    trigger OnRun()
    begin
    end;

    procedure IntegrationType(): Code[20]
    begin
        exit('EXTERNAL_TERMINAL');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    var
        DescriptionLbl: Label 'External non-integrated Terminal';
    begin
        tmpEFTIntegrationType.Init();
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := DescriptionLbl;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR EFT Ext. Terminal Integ.";
        tmpEFTIntegrationType."Version 2" := true;
        tmpEFTIntegrationType.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationPaymentSetup', '', false, false)]
    local procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "NPR EFT Setup")
    var
        EFTExtTermPaymSetup: Record "NPR EFT Ext. Term. Paym. Setup";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        GetPaymentTypeParameters(EFTSetup, EFTExtTermPaymSetup);
        Commit();
        PAGE.RunModal(PAGE::"NPR EFT Ext. Term. Paym. Setup", EFTExtTermPaymSetup);
    end;

    local procedure GetPaymentTypeParameters(EFTSetup: Record "NPR EFT Setup"; var EFTExtTermPaymSetupOut: Record "NPR EFT Ext. Term. Paym. Setup")
    begin
        EFTSetup.TestField("Payment Type POS");

        if not EFTExtTermPaymSetupOut.Get(EFTSetup."Payment Type POS") then begin
            EFTExtTermPaymSetupOut.Init();
            EFTExtTermPaymSetupOut."Payment Type POS" := EFTSetup."Payment Type POS";
            EFTExtTermPaymSetupOut.Insert();
        end;
    end;

    internal procedure GetCardDigitsParameter(EFTSetupIn: Record "NPR EFT Setup"): Boolean
    var
        EFTExtTermPaymSetup: Record "NPR EFT Ext. Term. Paym. Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTExtTermPaymSetup);
        exit(EFTExtTermPaymSetup."Enable Card Digits Popup");
    end;

    internal procedure GetCardholderParameter(EFTSetupIn: Record "NPR EFT Setup"): Boolean
    var
        EFTExtTermPaymSetup: Record "NPR EFT Ext. Term. Paym. Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTExtTermPaymSetup);
        exit(EFTExtTermPaymSetup."Enable Cardholder Popup");
    end;

    internal procedure GetApprovalCodeParameter(EFTSetupIn: Record "NPR EFT Setup"): Boolean
    var
        EFTExtTermPaymSetup: Record "NPR EFT Ext. Term. Paym. Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTExtTermPaymSetup);
        exit(EFTExtTermPaymSetup."Enable Approval Code Popup");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        ZeroAmountErr: Label 'Cannot start EFT Request for zero amount';
    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;
        Handled := true;
        if EftTransactionRequest."Amount Input" = 0 then
            Error(ZeroAmountErr);

        EftTransactionRequest."Transaction Date" := Today();
        EftTransactionRequest."Transaction Time" := Time;
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Insert(true);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;
        Handled := true;
        EftTransactionRequest."Transaction Date" := Today();
        EftTransactionRequest."Transaction Time" := Time;
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnAfterFinancialCommit', '', false, false)]
    local procedure OnAfterFinancialCommit(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;

        EftTransactionRequest.PrintReceipts(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnPrepareRequestSend', '', false, false)]
    local procedure OnCreateHwcEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Request: JsonObject; var RequestMechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text)

    begin
        if (not EftTransactionRequest.IsType(IntegrationType())) then
            exit;

        CreateHwcEftDeviceRequest(EftTransactionRequest, Request, RequestMechanism, Workflow);
    end;

    procedure CreateHwcEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; Request: JsonObject; var RequestMechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text)
    begin
        InitGeneralRequest(EftTransactionRequest, Request, RequestMechanism, Workflow);

        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::REFUND,
            EftTransactionRequest."Processing Type"::PAYMENT:
                PaymentTransaction(EftTransactionRequest, Request);
        end;
    end;

    local procedure InitGeneralRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; Request: JsonObject; var RequestMechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text)
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTExtTerminalInteg: Codeunit "NPR EFT Ext. Terminal Integ.";
    begin
        RequestMechanism := RequestMechanism::POSWorkflow;
        Workflow := Format(Enum::"NPR POS Workflow"::EFT_EXT_TERMNL);

        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EftTransactionRequest."POS Payment Type Code");

        Request.Add('PaymentType', EftTransactionRequest."POS Payment Type Code");
        Request.add('PromptCardDigits', EFTExtTerminalInteg.GetCardDigitsParameter(EFTSetup));
        Request.add('PromptCardHolder', EFTExtTerminalInteg.GetCardholderParameter(EFTSetup));
        Request.add('PromptApprovalCode', EFTExtTerminalInteg.GetApprovalCodeParameter(EFTSetup));
        Request.add('CardDigits', 0);
        Request.add('CardHolder', '');
        Request.add('ApprovalCode', '');
    end;

    local procedure PaymentTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request"; Request: JsonObject)
    begin
        Request.Add('Type', 'Transaction');
        Request.Add('EntryNo', EFTTransactionRequest."Entry No.");
        Request.Add('ReceiptNo', EFTTransactionRequest."Sales Ticket No.");
        Request.Add('AmountIn', Round(EftTransactionRequest."Amount Input"));
        Request.Add('SalesId', EFTTransactionRequest."Sales ID");
        Request.Add('CurrencyCode', EFTTransactionRequest."Currency Code");
    end;

    internal procedure HandleResponse(Request: JsonObject; Result: JsonObject; Context: Codeunit "NPR POS JSON Helper") EntryNo: Integer
    var
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        JToken: JsonToken;
        ApprovedLbl: Label 'OK';
    begin
        Request.Get('EntryNo', JToken);
        EftTransactionRequest.Get(JToken.AsValue().AsInteger());
        EftTransactionRequest.Successful := true;
        EftTransactionRequest."External Result Known" := true;

        ValidateParameters(EftTransactionRequest, Request);

        EftTransactionRequest."POS Description" := StrSubstNo('%1 %2', format(EftTransactionRequest."Processing Type"), EftTransactionRequest."POS Payment Type Code");
        EFTTransactionRequest."Result Description" := ApprovedLbl;
        EFTTransactionRequest."Result Display Text" := ApprovedLbl;

        EftTransactionRequest."Amount output" := EftTransactionRequest."Amount Input";
        case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::PAYMENT,
            EFTTransactionRequest."Processing Type"::REFUND:
                EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
        end;
        EftTransactionRequest.Modify();

        exit(EftTransactionRequest."Entry No.");
    end;

    local procedure ValidateParameters(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Request: JsonObject)
    var
        JToken: JsonToken;
    begin
        Request.Get('CardDigits', JToken);
        EftTransactionRequest."Card Number" := copystr(format(JToken.AsValue().AsInteger()), 1, MaxStrLen(EftTransactionRequest."Card Number"));

        Request.Get('CardHolder', JToken);
        EftTransactionRequest."Card Name" := copystr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Card Name"));

        Request.Get('ApprovalCode', JToken);
        EftTransactionRequest."Authorisation Number" := copystr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Authorisation Number"));

    end;

}
