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
        EftTransactionRequest."Card Number" := CopyStr(format(JToken.AsValue().AsText()), 1, MaxStrLen(EftTransactionRequest."Card Number"));

        Request.Get('CardHolder', JToken);
        EftTransactionRequest."Card Name" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Card Name"));

        Request.Get('ApprovalCode', JToken);
        EftTransactionRequest."Authorisation Number" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Authorisation Number"));

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'AllowVoidEFTRequestOnPaymentLineDelete', '', false, false)]
    local procedure OnIsCancelAllowed(SaleLinePOS: Record "NPR POS Sale Line"; var Handled: Boolean; var IsAllowed: Boolean)
    var
        EFTSetup: Record "NPR EFT Setup";
    begin
        if Handled then
            exit;

        if not EFTSetup.Get(SaleLinePOS."No.", SaleLinePOS."Register No.") then
            if not EFTSetup.Get(SaleLinePOS."No.", '') then
                EFTSetup.Init();

        Handled := EFTSetup."EFT Integration Type" = IntegrationType();

        if (Handled) then
            IsAllowed := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateVoidEFTRequestOnPaymentLineDelete', '', false, false)]
    local procedure OnCreateVoidEFTRequst(var SaleLinePOS: Record "NPR POS Sale Line"; var Handled: Boolean)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if Handled then
            exit;

        EFTTransactionRequest.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        EFTTransactionRequest.SetRange("Sales Line No.", SaleLinePOS."Line No.");
        EFTTransactionRequest.SetRange(Reversed, false);
        if EFTTransactionRequest.FindFirst() then begin
            if (not EftTransactionRequest.IsType(IntegrationType())) then
                exit;
            CreateVoidRequest(EFTTransactionRequest);
            SetPaymentLineToZero(SaleLinePOS);
            Handled := true;
        end;
    end;

    procedure CreateVoidRequest(EftTransactionRequestToVoid: Record "NPR EFT Transaction Request")
    var
        OriginalEftTransactionRequest: Record "NPR EFT Transaction Request";
        DescriptionLbl: Label 'Manual Void of %1';
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        ConfirmVoidLbl: Label 'Cannot delete externally approved electronic funds transfer. Do you want to void of the original transaction instead?';
    begin
        if not Confirm(ConfirmVoidLbl) then
            exit;

        EftTransactionRequest.Init();
        EftTransactionRequest."Entry No." := 0;
        EftTransactionRequest."Integration Type" := EftTransactionRequestToVoid."Integration Type";
        EftTransactionRequest."POS Payment Type Code" := EftTransactionRequestToVoid."POS Payment Type Code";
        EftTransactionRequest."Original POS Payment Type Code" := EftTransactionRequestToVoid."Original POS Payment Type Code";
        EftTransactionRequest."Register No." := EftTransactionRequestToVoid."Register No.";
        EftTransactionRequest."Sales Ticket No." := EftTransactionRequestToVoid."Sales Ticket No.";
        EftTransactionRequest."Sales ID" := EftTransactionRequestToVoid."Sales ID";
        EftTransactionRequest."User ID" := CopyStr(UserId, 1, MaxStrLen(EftTransactionRequest."User ID"));
        EftTransactionRequest.Started := CurrentDateTime();
        EftTransactionRequest.Token := CreateGuid();

        OriginalEftTransactionRequest := EftTransactionRequestToVoid;
        if OriginalEftTransactionRequest."Processing Type" = OriginalEftTransactionRequest."Processing Type"::LOOK_UP then
            OriginalEftTransactionRequest.Get(OriginalEftTransactionRequest."Processed Entry No.");
        OriginalEftTransactionRequest.TestField("Integration Type", EftTransactionRequest."Integration Type");

        if not (OriginalEftTransactionRequest."Processing Type" in
            [OriginalEftTransactionRequest."Processing Type"::PAYMENT,
             OriginalEftTransactionRequest."Processing Type"::REFUND])
        then
            OriginalEftTransactionRequest.FieldError("Processing Type");

        if (not OriginalEftTransactionRequest.Successful) and (OriginalEftTransactionRequest.Recovered) then
            OriginalEftTransactionRequest.Get(OriginalEftTransactionRequest."Recovered by Entry No.");

        EftTransactionRequest."Currency Code" := OriginalEftTransactionRequest."Currency Code";
        EftTransactionRequest."Amount Input" := -OriginalEftTransactionRequest."Result Amount";
        EftTransactionRequest."Amount Output" := -OriginalEftTransactionRequest."Amount Output";
        EftTransactionRequest."Result Amount" := -OriginalEftTransactionRequest."Result Amount";
        EftTransactionRequest."Tip Amount" := OriginalEftTransactionRequest."Tip Amount";
        EftTransactionRequest."Fee Amount" := OriginalEftTransactionRequest."Fee Amount";
        EftTransactionRequest."POS Description" := CopyStr(StrSubstNo(DescriptionLbl, OriginalEftTransactionRequest."POS Description"), 1, MaxStrLen(EftTransactionRequest."POS Description"));
        EftTransactionRequest."Card Name" := OriginalEftTransactionRequest."Card Name";
        EftTransactionRequest."Card Number" := OriginalEftTransactionRequest."Card Number";
        EftTransactionRequest."Processing Type" := EftTransactionRequest."Processing Type"::VOID;
        EftTransactionRequest."Processed Entry No." := EftTransactionRequestToVoid."Entry No.";
        EftTransactionRequest."External Result Known" := true;
        EftTransactionRequest.Recoverable := false;
        EftTransactionRequest.Successful := true;
        EFTTransactionRequest.Finished := CurrentDateTime;
        EFTTransactionRequest."Result Processed" := true;
        if (EftTransactionRequest."Result Amount" <> 0) and (EftTransactionRequest.Successful) then
            EftTransactionRequest."Financial Impact" := true;
        EftTransactionRequest."Sales Line No." := OriginalEftTransactionRequest."Sales Line No.";
        EftTransactionRequest."Sales Line ID" := OriginalEftTransactionRequest."Sales Line ID";
        EftTransactionRequest.Insert(true);

        MarkAsReversed(OriginalEftTransactionRequest, EftTransactionRequest."Entry No.");
    end;

    local procedure MarkAsReversed(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; ReversedByEntryNo: Integer)
    begin
        if EFTTransactionRequest.Reversed then
            exit;

        EFTTransactionRequest.Reversed := true;
        EFTTransactionRequest."Reversed by Entry No." := ReversedByEntryNo;
        EFTTransactionRequest.Modify();
    end;

    local procedure SetPaymentLineToZero(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        SaleLinePOS.Validate("Amount Including VAT", 0);
        SaleLinePOS.Validate(Amount, 0);
        SaleLinePOS.Validate("Currency Amount", 0);
        SaleLinePOS.Modify();
    end;

}
