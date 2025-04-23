﻿codeunit 6184473 "NPR EFT Transaction Mgt."
{
    Access = Internal;
    // Public API for EFT operations.


    var
        ERROR_SESSION: Label 'Critical Error: Session object could not be retrieved by EFT Framework';
        CAPTION_RECOVER_PROMPT: Label 'The last %1 transaction on this register never completed successfully.\Do you want to attempt recovery of the below transaction now?\(This is strongly recommended)\\From Sales Ticket No.: %2\Type: %3\Amount: %4 %5\External Ref. No.: %6';
        CAPTION_RECOVER_FAIL_HARD: Label 'LOOKUP UNKNOWN:\%1 lookup request failed. Check the connection and try again.';
        CAPTION_RECOVER_FAIL_SOFT: Label 'LOOKUP UNKNOWN:\Cannot lookup %1 result for transaction entry no. %2';
        CAPTION_RECOVER_SYNC_ZERO: Label 'LOOKUP SUCCESS:\Recovered transaction result:\(ZERO AMOUNT - NO MONEY WAS TRANSFERRED)\\%1\From Sales Ticket No.: %2\Type: %3\Amount: %4 %5\External Ref. No.: %6';
        CAPTION_RECOVER_EARLIER: Label 'LOOKUP SUCCESS:\%1 transaction result has already been recovered by an earlier lookup request (Entry No. %2):\\From Sales Ticket No.: %3\Type: %4\Recovered Amount: %5 %6\External Ref. No.: %7';
        CAPTION_RECOVER_SAVE: Label 'LOOKUP SUCCESS:\A lost transaction result from the current sale was recovered and re-created as payment line:\\%1\Sales Ticket No.: %2\Type: %3\Amount: %4 %5\External Ref. No.: %6';
        CAPTION_RECOVER_WARN: Label 'LOOKUP WARNING:\A transaction result from an earlier sale was recovered. The recovered amount is out of sync with what the system recorded initially.\We recommend checking the sale details manually in %3 and reversing the transaction if necessary.\\%1\From Sales Ticket No.: %2\Type: %5\Amount: %6 %7\External Ref. No.: %8\Entry No. %4';
        CAPTION_RECOVER_WARN_STRONG: Label 'LOOKUP WARNING:\A transaction result from an earlier sale that never ended correctly was recovered. If the sale was cancelled this transaction should be reversed.\\%1\From Sales Ticket No.: %2\Type: %4\Amount: %5 %6\External Ref. No.: %7\Entry No. %3';
        RESULT_KNOWN: Label 'LOOKUP SUCCESS:\%1 transaction result is already known:\\From Sales Ticket No.: %2\Type: %3\Successful: %4\Amount: %5 %6\External Ref. No.: %7';
        ALREADY_VOID: Label '%1, %2 %3 has already been voided';
        RESULT_UNKNOWN: Label 'Cannot void a transaction with unknown result. Perform a lookup first to recover the lost result and try again.';
        SALE_NOT_FOUND: Label 'Could not find sale linked with trx. It needs to be either finished or active in the current POS sale before a void operation is allowed.';
        QUOTE_OUT_OF_SYNC: Label 'LOOKUP WARNING:\Transaction result is out of sync, but cannot be recreated unless %1 %2 is loaded first. Please load that sale and lookup transaction again!';
        MISSING_ORIGINAL: Label 'LOOKUP WARNING:\A transaction result was recovered but the original sale connected to it, is missing.If the sale was cancelled the transaction should be reversed.\\%1\From Sales Ticket No.: %2\Type: %3\Amount: %4 %5\External Ref. No.: %6';


    procedure PreparePayment(EFTSetup: Record "NPR EFT Setup"; Amount: Decimal; CurrencyCode: Code[10]; SalePOS: Record "NPR POS Sale"; var IntegrationRequest: JsonObject; var Mechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text): Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionRequestToRecover: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
    begin
        if PerformRecoveryInstead(SalePOS, EFTSetup."EFT Integration Type", EFTTransactionRequestToRecover) then begin
            EFTFrameworkMgt.CreateLookupTransactionRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", EFTTransactionRequestToRecover."Entry No.");
        end else begin
            if (Amount >= 0) then
                EFTFrameworkMgt.CreatePaymentOfGoodsRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", CurrencyCode, Amount)
            else
                EFTFrameworkMgt.CreateRefundRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", CurrencyCode, Abs(Amount), 0);
        end;

        EFTFrameworkMgt.PrepareRequestSend(EFTTransactionRequest, IntegrationRequest, Mechanism, Workflow);
        Commit(); // Save the request record data regardless of any later errors when invoking.

        exit(EFTTransactionRequest."Entry No.");
    end;

    procedure PrepareVoid(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; RequestEntryNoToVoid: Integer; IsManualVoid: Boolean; var IntegrationRequest: JsonObject; var Mechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text): Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequestToRecover: Record "NPR EFT Transaction Request";
    begin
        CheckIfTrxCanBeVoided(RequestEntryNoToVoid, SalePOS);

        if PerformRecoveryInstead(SalePOS, EFTSetup."EFT Integration Type", EFTTransactionRequestToRecover) then begin
            EFTFrameworkMgt.CreateLookupTransactionRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", EFTTransactionRequestToRecover."Entry No.");
        end else begin
            EFTFrameworkMgt.CreateVoidRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", RequestEntryNoToVoid, IsManualVoid);
        end;

        EFTFrameworkMgt.PrepareRequestSend(EFTTransactionRequest, IntegrationRequest, Mechanism, Workflow);
        Commit(); // Save the request record data regardless of any later errors when invoking.

        exit(EFTTransactionRequest."Entry No.");
    end;

    procedure PrepareReferencedRefund(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; CurrencyCode: Code[10]; AmountToRefund: Decimal; OriginalRequestEntryNo: Integer; var IntegrationRequest: JsonObject; var Mechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text): Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequestToRecover: Record "NPR EFT Transaction Request";
    begin

        if PerformRecoveryInstead(SalePOS, EFTSetup."EFT Integration Type", EFTTransactionRequestToRecover) then begin
            EFTFrameworkMgt.CreateLookupTransactionRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", EFTTransactionRequestToRecover."Entry No.");
        end else begin
            EFTFrameworkMgt.CreateRefundRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", CurrencyCode, Abs(AmountToRefund), OriginalRequestEntryNo);
        end;

        EFTFrameworkMgt.PrepareRequestSend(EFTTransactionRequest, IntegrationRequest, Mechanism, Workflow);
        Commit(); // Save the request record data regardless of any later errors when invoking.

        exit(EFTTransactionRequest."Entry No.");
    end;

    procedure PrepareLookup(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; EntryNoToLookup: Integer; var IntegrationRequest: JsonObject; var Mechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text): Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        CheckIfTrxResultAlreadyKnown(EntryNoToLookup);

        EFTFrameworkMgt.CreateLookupTransactionRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", EntryNoToLookup);
        EFTFrameworkMgt.PrepareRequestSend(EFTTransactionRequest, IntegrationRequest, Mechanism, Workflow);
        Commit(); // Save the request record data regardless of any later errors when invoking.

        exit(EFTTransactionRequest."Entry No.");
    end;

    procedure PrepareBeginWorkshift(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var IntegrationRequest: JsonObject; var Mechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text): Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTFrameworkMgt.CreateBeginWorkshiftRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.");
        EFTFrameworkMgt.PrepareRequestSend(EFTTransactionRequest, IntegrationRequest, Mechanism, Workflow);
        Commit(); // Save the request record data regardless of any later errors when invoking.

        exit(EFTTransactionRequest."Entry No.");
    end;

    procedure PrepareEndWorkshift(EFTSetup: Record "NPR EFT Setup"; RegisterNo: Code[10]; SalesTicketNo: Code[20]; var IntegrationRequest: JsonObject; var Mechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text): Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTFrameworkMgt.CreateEndWorkshiftRequest(EFTTransactionRequest, EFTSetup, RegisterNo, SalesTicketNo);
        EFTFrameworkMgt.PrepareRequestSend(EFTTransactionRequest, IntegrationRequest, Mechanism, Workflow);
        Commit(); // Save the request record data regardless of any later errors when invoking.

        exit(EFTTransactionRequest."Entry No.");
    end;

    procedure PrepareEndWorkshift(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var IntegrationRequest: JsonObject; var Mechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text): Integer
    begin
        exit(PrepareEndWorkshift(EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", IntegrationRequest, Mechanism, Workflow));
    end;

    procedure PrepareAuxOperation(EFTSetup: Record "NPR EFT Setup"; POSUnitNo: Code[10]; SalesReceiptNo: Code[20]; AuxFunction: Integer; var IntegrationRequest: JsonObject; var Mechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text): Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTFrameworkMgt.CreateAuxRequest(EFTTransactionRequest, EFTSetup, AuxFunction, POSUnitNo, SalesReceiptNo);
        EFTFrameworkMgt.PrepareRequestSend(EFTTransactionRequest, IntegrationRequest, Mechanism, Workflow);
        Commit(); // Save the request record data regardless of any later errors when invoking.

        exit(EFTTransactionRequest."Entry No.");
    end;

    procedure PrepareVerifySetup(EFTSetup: Record "NPR EFT Setup"; POSUnitNo: Code[10]; SalesReceiptNo: Code[20]; var IntegrationRequest: JsonObject; var Mechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text): Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTFrameworkMgt.CreateVerifySetupRequest(EFTTransactionRequest, EFTSetup, POSUnitNo, SalesReceiptNo);
        EFTFrameworkMgt.PrepareRequestSend(EFTTransactionRequest, IntegrationRequest, Mechanism, Workflow);
        Commit(); // Save the request record data regardless of any later errors when invoking.

        exit(EFTTransactionRequest."Entry No.");
    end;

    procedure PrepareGiftCardLoad(EFTSetup: Record "NPR EFT Setup"; Amount: Decimal; CurrencyCode: Code[10]; POSUnitNo: Code[10]; SalesReceiptNo: Code[20]; var IntegrationRequest: JsonObject; var Mechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text): Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTFrameworkMgt.CreateGiftcardLoadRequest(EFTTransactionRequest, EFTSetup, POSUnitNo, SalesReceiptNo, CurrencyCode, Amount);
        EFTFrameworkMgt.PrepareRequestSend(EFTTransactionRequest, IntegrationRequest, Mechanism, Workflow);
        Commit(); // Save the request record data regardless of any later errors when invoking.

        exit(EFTTransactionRequest."Entry No.");
    end;

    procedure SendRequestIfSynchronous(EntryNo: Integer; var Request: JsonObject; var Mechanism: Enum "NPR EFT Request Mechanism")
    var
        EFTInterface: Codeunit "NPR EFT Interface";
        Handled: Boolean;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if Mechanism <> Mechanism::Synchronous then
            exit;

        EFTTransactionRequest.Get(EntryNo);

        EFTInterface.OnSendRequestSynchronously(EFTTransactionRequest, Handled);
        if not Handled then
            Error('EFT Integration %1 is not subscribing to OnSendRequestSynchronously correctly.', EFTTransactionRequest."Integration Type");
    end;

    [Obsolete('Pending Removal due to move to a new function GetEFTReceiptText because this one supports only one sucesfull EFT Transaction, not all of them.', '2024-03-28')]
    procedure GetEFTReceiptText(SalesTicketNo: Code[20]; ReceiptNo: Integer): Text
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTReceipt: Record "NPR EFT Receipt";
        EFTReceiptText: Text;
        NewLine: Text;
    begin
        EFTTransactionRequest.SetRange("Sales Ticket No.", SalesTicketNo);
        EFTTransactionRequest.SetRange(Successful, true);

        if not EFTTransactionRequest.FindFirst() then
            exit;

        NewLine[1] := 13; // CR
        NewLine[2] := 10; // LF

        EFTReceipt.SetRange("EFT Trans. Request Entry No.", EFTTransactionRequest."Entry No.");
        EFTReceipt.SetRange("Receipt No.", ReceiptNo);

        if EFTReceipt.FindSet() then
            repeat
                EFTReceiptText += EFTReceipt.Text + Format(NewLine);
            until EFTReceipt.Next() = 0;
        exit(EFTReceiptText);
    end;

    procedure GetEFTReceiptText(SalesTicketNo: Code[20]): Text
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTReceipt: Record "NPR EFT Receipt";
        EFTReceiptText: Text;
        NewLine: Text;
    begin
        NewLine[1] := 13; // CR
        NewLine[2] := 10; // LF
        EFTTransactionRequest.SetRange("Sales Ticket No.", SalesTicketNo);
        if EFTTransactionRequest.FindSet() then
            repeat
                EFTReceipt.SetRange("EFT Trans. Request Entry No.", EFTTransactionRequest."Entry No.");
                if EFTReceipt.FindSet() then
                    repeat
                        EFTReceiptText += EFTReceipt.Text + Format(NewLine);
                    until EFTReceipt.Next() = 0;
            until EFTTransactionRequest.Next() = 0;
        exit(EFTReceiptText);
    end;

    procedure GetEFTExternalCustomerId(SalesTicketNo: Code[20]; RegisterNo: Code[10]; Started: DateTime; DTDifference: Integer; ExternalCustomerIdProvider: Text[50]): Text[50]
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.SetRange("Sales Ticket No.", SalesTicketNo);
        EFTTransactionRequest.SetRange("Register No.", RegisterNo);
        EFTTransactionRequest.SetFilter(Started, '%1..%2', Started, Started + DTDifference);
        EFTTransactionRequest.SetFilter("External Customer ID", '<>%1', '');
        EFTTransactionRequest.SetRange("External Customer ID Provider", ExternalCustomerIdProvider);
        if EFTTransactionRequest.FindFirst() then
            exit(EFTTransactionRequest."External Customer ID");
    end;

    #region Response Handlers
    procedure HandleGenericWorkflowResponse(EftTrxRequest: Record "NPR EFT Transaction Request"; IntegrationRequest: JsonObject; IntegrationResponse: JsonObject; Result: JsonObject)
    var
        EftInterface: Codeunit "NPR EFT Interface";
        EftFramework: Codeunit "NPR EFT Framework Mgt.";
        Handled: Boolean;
        JToken: JsonToken;
        NotHandled: Label 'Hardware Connector response from %1 %2 is not handled.';
    begin
        EftInterface.OnGenericWorkflowResponse(EftTrxRequest, IntegrationRequest, IntegrationResponse, Result, Handled);
        if (not Handled) then
            Error(NotHandled, EftTrxRequest."Integration Type", EftTrxRequest."Processing Type");

        IntegrationRequest.Get('EntryNo', JToken);
        EftTrxRequest.Find('='); //Refresh
        EftFramework.EftIntegrationResponseReceived(EftTrxRequest);
    end;

    procedure HandleIntegrationResponse(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
    begin
        if not POSSession.IsInitialized() then
            Error(ERROR_SESSION);
        POSSession.GetFrontEnd(POSFrontEnd);

        LockTimeout(false);

        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::REFUND,
          EftTransactionRequest."Processing Type"::PAYMENT:
                EftPaymentResponseReceived(EftTransactionRequest, POSFrontEnd, POSSession);
            EftTransactionRequest."Processing Type"::VOID:
                EftVoidResponseReceived(EftTransactionRequest, POSFrontEnd, POSSession);
            EftTransactionRequest."Processing Type"::LOOK_UP:
                EftLookupResponseReceived(EftTransactionRequest, POSFrontEnd, POSSession);

            EftTransactionRequest."Processing Type"::GIFTCARD_LOAD:
                GiftCardLoadResponseReceived(EftTransactionRequest, POSFrontEnd, POSSession);
        end;
    end;

    local procedure EftPaymentResponseReceived(EftTransactionRequest: Record "NPR EFT Transaction Request"; POSFrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        EFTInterface: Codeunit "NPR EFT Interface";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
    begin
        SetFinancialImpact(EftTransactionRequest);
        InsertPaymentLine(POSSession, EftTransactionRequest);

        HandleSurcharge(POSSession, EftTransactionRequest);
        HandleTip(POSSession, EftTransactionRequest);

        MarkOriginalTransactionAsReversed(EftTransactionRequest);
        Commit(); // This commit should handle both the sale line(s) insertion and trx record "Result Processed" := true in the same transaction. On failure, lookup of trx result is needed.
        EFTInterface.OnAfterFinancialCommit(EftTransactionRequest);

        if EftTransactionRequest.Successful then begin
            if not ConfirmEftPayment(EftTransactionRequest) then
                exit; //Don't resume front end straight away as a subscriber indicated the transaction might need to be annulled now, for example due to signature decline
        end;
        EFTFrameworkMgt.ResumeFrontEndAfterEFTRequest(EftTransactionRequest, POSFrontEnd);
    end;

    local procedure EftLookupResponseReceived(EftTransactionRequest: Record "NPR EFT Transaction Request"; POSFrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        OriginalEftTransactionRequest: Record "NPR EFT Transaction Request";
        FinancialRecovery: Boolean;
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        OriginalEftTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");

        case true of
            LookupError(EftTransactionRequest):
                ;
            LookupFailure(EftTransactionRequest, OriginalEftTransactionRequest):
                ;
            LookupInSyncNoFinancialImpact(EftTransactionRequest, OriginalEftTransactionRequest):
                ;
            LookupOutOfSyncAndSaleIsCurrent(EftTransactionRequest, OriginalEftTransactionRequest):
                FinancialRecovery := true;
            LookupOutOfSyncAndSaleIsParked(EftTransactionRequest, OriginalEftTransactionRequest):
                ;
            LookupOutOfSyncAndSaleIsFinished(EftTransactionRequest, OriginalEftTransactionRequest):
                ;
            LookupOutOfSyncAndSaleIsOnAnotherUnit(EftTransactionRequest, OriginalEftTransactionRequest):
                ;
            else
                LookupOutOfSyncAndSaleIsLost(EftTransactionRequest, OriginalEftTransactionRequest);
        end;

        if FinancialRecovery then begin
            case OriginalEftTransactionRequest."Processing Type" of
                OriginalEftTransactionRequest."Processing Type"::VOID:
                    EftVoidResponseReceived(EftTransactionRequest, POSFrontEnd, POSSession);
                OriginalEftTransactionRequest."Processing Type"::REFUND,
              OriginalEftTransactionRequest."Processing Type"::PAYMENT:
                    EftPaymentResponseReceived(EftTransactionRequest, POSFrontEnd, POSSession);
                OriginalEftTransactionRequest."Processing Type"::GIFTCARD_LOAD:
                    GiftCardLoadResponseReceived(EftTransactionRequest, POSFrontEnd, POSSession);
            end;
        end else begin
            EFTFrameworkMgt.ResumeFrontEndAfterEFTRequest(EftTransactionRequest, POSFrontEnd);
        end;
    end;

    local procedure EftVoidResponseReceived(EftTransactionRequest: Record "NPR EFT Transaction Request"; POSFrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        OriginalEftTransactionRequest: Record "NPR EFT Transaction Request";
        EFTInterface: Codeunit "NPR EFT Interface";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
    begin
        EFTFrameworkMgt.ResumeFrontEndAfterEFTRequest(EftTransactionRequest, POSFrontEnd);

        if not EftTransactionRequest.Successful then
            exit;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SetFinancialImpact(EftTransactionRequest);

        if EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::LOOK_UP then begin
            OriginalEftTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");
            OriginalEftTransactionRequest.TestField("Processing Type", OriginalEftTransactionRequest."Processing Type"::VOID);
            OriginalEftTransactionRequest.Get(OriginalEftTransactionRequest."Processed Entry No.");
        end else
            OriginalEftTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");

        MarkAsReversed(OriginalEftTransactionRequest, EftTransactionRequest."Entry No.");


        case OriginalEftTransactionRequest."Processing Type" of
            OriginalEftTransactionRequest."Processing Type"::PAYMENT,
          OriginalEftTransactionRequest."Processing Type"::REFUND:
                InsertPaymentLine(POSSession, EftTransactionRequest);

            OriginalEftTransactionRequest."Processing Type"::GIFTCARD_LOAD:
                InsertSaleVoucherLine(POSSession, EftTransactionRequest);
        end;
        HandleSurcharge(POSSession, EftTransactionRequest);
        HandleTip(POSSession, EftTransactionRequest);

        Commit();
        EFTInterface.OnAfterFinancialCommit(EftTransactionRequest);
        POSSession.RequestRefreshData();
    end;
    #endregion

    #region Aux

    local procedure InsertPaymentLine(POSSession: Codeunit "NPR POS Session"; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSLine: Record "NPR POS Sale Line";
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetPaymentLine(POSLine);

        POSLine."No." := EFTTransactionRequest."POS Payment Type Code";
        POSLine."EFT Approved" := EFTTransactionRequest.Successful;
        POSLine.Description := CopyStr(EFTTransactionRequest."POS Description", 1, MaxStrLen(POSLine.Description));
        POSLine.Reference := CopyStr(EFTTransactionRequest."Reference Number Output", 1, MaxStrLen(POSLine.Reference));

        // Card metadata
        POSLine."EFT Card Number" := EFTTransactionRequest."Card Number";
        POSLine."EFT Card Name" := EFTTransactionRequest."Card Name";
        POSLine."EFT Card Application ID" := EFTTransactionRequest."Card Application ID";
        POSLine."EFT Card Expiry Month" := EFTTransactionRequest."Card Expiry Month";
        POSLine."EFT Card Expiry Year" := EFTTransactionRequest."Card Expiry Year";
        POSLine."EFT Payment Brand" := EFTTransactionRequest."Payment Brand";
        POSLine."EFT Payment Account Reference" := EFTTransactionRequest."Payment Account Reference";
        POSLine."EFT Shopper Country" := EFTTransactionRequest."Shopper Country";

        if POSLine."EFT Approved" then begin
            POSLine."Amount Including VAT" := EFTTransactionRequest."Result Amount";
            POSLine."Currency Amount" := POSLine."Amount Including VAT";
        end;

        POSPaymentLine.InsertPaymentLine(POSLine, 0);
        POSPaymentLine.GetCurrentPaymentLine(POSLine);

        EFTTransactionRequest."Sales Line No." := POSLine."Line No.";
        EFTTransactionRequest."Sales Line ID" := POSLine.SystemId;
        EFTTransactionRequest.Modify();
    end;

    local procedure HandleSurcharge(POSSession: Codeunit "NPR POS Session"; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        OriginalProcessingType: Integer;
        POSPaymentMethod: Record "NPR POS Payment Method";
        EFTSetup: Record "NPR EFT Setup";
    begin
        if not EFTTransactionRequest.Successful then
            exit;
        if EFTTransactionRequest."Fee Amount" = 0 then
            exit;

        OriginalProcessingType := EFTTransactionRequest."Processing Type";
        if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::LOOK_UP then begin
            OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
            OriginalProcessingType := OriginalEFTTransactionRequest."Processing Type";
        end;


        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if EFTSetup.UseAccountPostingForServices() then begin
            POSPaymentMethod.Get(EFTTransactionRequest."Original POS Payment Type Code");
            POSPaymentMethod.TestField("EFT Surcharge Account No.");

            case OriginalProcessingType of
                EFTTransactionRequest."Processing Type"::PAYMENT:
                    EFTTransactionRequest."Fee Line ID" := InsertAccountLine(POSSession, POSPaymentMethod."EFT Surcharge Account No.", EFTTransactionRequest."Fee Amount", '');
                EFTTransactionRequest."Processing Type"::REFUND,
                EFTTransactionRequest."Processing Type"::VOID:
                    EFTTransactionRequest."Fee Line ID" := InsertAccountLine(POSSession, POSPaymentMethod."EFT Surcharge Account No.", EFTTransactionRequest."Fee Amount" * -1, ' - ' + Format(EFTTransactionRequest."Processing Type"));
            end;
        end else begin
            POSPaymentMethod.Get(EFTTransactionRequest."POS Payment Type Code");
            POSPaymentMethod.TestField("EFT Surcharge Service Item No.");

            case OriginalProcessingType of
                EFTTransactionRequest."Processing Type"::PAYMENT:
                    EFTTransactionRequest."Fee Line ID" := InsertServiceItemLine(POSSession, POSPaymentMethod."EFT Surcharge Service Item No.", EFTTransactionRequest."Fee Amount", '', 1);
                EFTTransactionRequest."Processing Type"::REFUND,
                EFTTransactionRequest."Processing Type"::VOID:
                    EFTTransactionRequest."Fee Line ID" := InsertServiceItemLine(POSSession, POSPaymentMethod."EFT Surcharge Service Item No.", EFTTransactionRequest."Fee Amount", ' - ' + Format(EFTTransactionRequest."Processing Type"), -1);
            end;
        end;

        EFTTransactionRequest.Modify();
    end;

    local procedure HandleTip(POSSession: Codeunit "NPR POS Session"; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        OriginalProcessingType: Integer;
        EFTSetup: Record "NPR EFT Setup";
    begin
        if not EFTTransactionRequest.Successful then
            exit;
        if EFTTransactionRequest."Tip Amount" = 0 then
            exit;

        OriginalProcessingType := EFTTransactionRequest."Processing Type";
        if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::LOOK_UP then begin
            OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
            OriginalProcessingType := OriginalEFTTransactionRequest."Processing Type";
        end;


        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if EFTSetup.UseAccountPostingForServices() then begin
            POSPaymentMethod.Get(EFTTransactionRequest."Original POS Payment Type Code");
            POSPaymentMethod.TestField("EFT Tip Account No.");

            case OriginalProcessingType of
                EFTTransactionRequest."Processing Type"::PAYMENT:
                    EFTTransactionRequest."Tip Line ID" := InsertAccountLine(POSSession, POSPaymentMethod."EFT Tip Account No.", EFTTransactionRequest."Tip Amount", '');
                EFTTransactionRequest."Processing Type"::REFUND,
                EFTTransactionRequest."Processing Type"::VOID:
                    EFTTransactionRequest."Tip Line ID" := InsertAccountLine(POSSession, POSPaymentMethod."EFT Tip Account No.", EFTTransactionRequest."Tip Amount" * -1, ' - ' + Format(EFTTransactionRequest."Processing Type"));
            end;
        end else begin
            POSPaymentMethod.Get(EFTTransactionRequest."POS Payment Type Code");
            POSPaymentMethod.TestField("EFT Tip Service Item No.");

            case OriginalProcessingType of
                EFTTransactionRequest."Processing Type"::PAYMENT:
                    EFTTransactionRequest."Tip Line ID" := InsertServiceItemLine(POSSession, POSPaymentMethod."EFT Tip Service Item No.", EFTTransactionRequest."Tip Amount", '', 1);
                EFTTransactionRequest."Processing Type"::REFUND,
                EFTTransactionRequest."Processing Type"::VOID:
                    EFTTransactionRequest."Tip Line ID" := InsertServiceItemLine(POSSession, POSPaymentMethod."EFT Tip Service Item No.", EFTTransactionRequest."Tip Amount", ' - ' + Format(EFTTransactionRequest."Processing Type"), -1);
            end;
        end;

        EFTTransactionRequest.Modify();
    end;

    local procedure InsertServiceItemLine(POSSession: Codeunit "NPR POS Session"; ItemNo: Text; Amount: Decimal; DescriptionPostFix: Text; Qty: Integer): Guid
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Item.TestField(Type, Item.Type::Service);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS.Validate("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.Validate("No.", ItemNo);
        SaleLinePOS.Validate(Quantity, Qty);
        SaleLinePOS.Validate("Unit Price", Amount);
        if DescriptionPostFix <> '' then begin
            SaleLinePOS.Description := CopyStr(SaleLinePOS.Description + DescriptionPostFix, 1, MaxStrLen(SaleLinePOS.Description));
        end;
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
        exit(SaleLinePOS.SystemId);
    end;

    local procedure InsertAccountLine(POSSession: Codeunit "NPR POS Session"; AccountNo: Text; Amount: Decimal; DescriptionPostFix: Text): Guid
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        GLAccount: Record "G/L Account";
    begin
        if Amount = 0 then
            exit;

        GLAccount.Get(AccountNo);
        GLAccount.TestField("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.TestField("Direct Posting", true);

        POSSession.GetSaleLine(POSSaleLine);

        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::"GL Payment";
        SaleLinePOS.Quantity := 1;
        SaleLinePOS.Validate("No.", AccountNo);
        SaleLinePOS."Amount Including VAT" := Amount;
        SaleLinePOS."Unit Price" := Amount;
        if DescriptionPostFix <> '' then begin
            SaleLinePOS.Description := CopyStr(SaleLinePOS.Description + DescriptionPostFix, 1, MaxStrLen(SaleLinePOS.Description));
        end;

        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
        exit(SaleLinePOS.SystemId);
    end;

    local procedure GiftCardLoadResponseReceived(EftTransactionRequest: Record "NPR EFT Transaction Request"; POSFrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        EFTInterface: Codeunit "NPR EFT Interface";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
    begin

        SetFinancialImpact(EftTransactionRequest);
        InsertSaleVoucherLine(POSSession, EftTransactionRequest);
        Commit(); // This commit should handle both the sale line insertion and EFT transaction record result modification in one transaction to prevent synchronization issues.
        EFTInterface.OnAfterFinancialCommit(EftTransactionRequest);
        EFTFrameworkMgt.ResumeFrontEndAfterEFTRequest(EftTransactionRequest, POSFrontEnd);
    end;

    local procedure InsertSaleVoucherLine(POSSession: Codeunit "NPR POS Session"; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LineAmount: Decimal;
    begin

        if not EFTTransactionRequest.Successful then
            exit;
        if EFTTransactionRequest."Result Amount" = 0 then
            exit;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);

        POSPaymentMethod.Get(EFTTransactionRequest."Original POS Payment Type Code");

        LineAmount := EFTTransactionRequest."Result Amount" * -1;

        SaleLinePOS.Validate("Line Type", SaleLinePOS."Line Type"::"Issue Voucher");
        SaleLinePOS.Validate("No.", GetPOSPostingSetupAccountNo(POSSession, EFTTransactionRequest."Original POS Payment Type Code"));
        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS."EFT Approved" := EFTTransactionRequest.Successful;
        SaleLinePOS.Description := CopyStr(SaleLinePOS.Description + ' - ' + EFTTransactionRequest."Card Number", 1, MaxStrLen(SaleLinePOS.Description));
        SaleLinePOS.Reference := CopyStr(EFTTransactionRequest."Reference Number Output", 1, MaxStrLen(SaleLinePOS.Reference));
        SaleLinePOS.Validate("Unit Price", LineAmount);
        SaleLinePOS.Validate("Amount Including VAT", LineAmount);
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, true);

        EFTTransactionRequest."Sales Line No." := SaleLinePOS."Line No.";
        EFTTransactionRequest."Sales Line ID" := SaleLinePOS.SystemId;
        EFTTransactionRequest.Modify();
    end;

    local procedure PerformRecoveryInstead(SalePOS: Record "NPR POS Sale"; IntegrationType: Text; var EFTTransactionRequestToRecover: Record "NPR EFT Transaction Request"): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        EFTInterface: Codeunit "NPR EFT Interface";
        Skip: Boolean;
    begin
        EFTTransactionRequestToRecover.SetRange("Register No.", SalePOS."Register No.");
        EFTTransactionRequestToRecover.SetRange("Integration Type", IntegrationType);

        EFTTransactionRequestToRecover.SetFilter("Processing Type", '%1|%2|%3|%4', EFTTransactionRequestToRecover."Processing Type"::PAYMENT, EFTTransactionRequestToRecover."Processing Type"::REFUND, EFTTransactionRequestToRecover."Processing Type"::VOID, EFTTransactionRequestToRecover."Processing Type"::GIFTCARD_LOAD);

        if not EFTTransactionRequestToRecover.FindLast() then
            exit(false);

        if not EFTTransactionRequestToRecover.Recoverable then
            exit(false);

        if EFTTransactionRequestToRecover.Recovered then
            exit(false);

        if (EFTTransactionRequestToRecover."External Result Known" and (EFTTransactionRequestToRecover.Finished <> 0DT)) then
            exit(false);


        if EFTTransactionRequestToRecover."Self Service" then
            exit(false);

        EFTInterface.OnBeforeLookupPrompt(EFTTransactionRequestToRecover, Skip);
        if Skip then
            exit(false);

        if (POSUnit.Get(SalePOS."Register No.")) then
            if (POSUnit."POS Type" = POSUnit."POS Type"::UNATTENDED) then
                exit(false);

        exit(Confirm(CAPTION_RECOVER_PROMPT, true, EFTTransactionRequestToRecover."Integration Type", EFTTransactionRequestToRecover."Sales Ticket No.", EFTTransactionRequestToRecover."Processing Type", EFTTransactionRequestToRecover."Amount Input", EFTTransactionRequestToRecover."Currency Code", EFTTransactionRequestToRecover."Reference Number Output"));
    end;

    local procedure ConfirmEftPayment(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        EFTIntegration: Codeunit "NPR EFT Framework Mgt.";
        Annul: Boolean;
    begin
        EFTIntegration.ConfirmAfterPayment(EFTTransactionRequest, Annul);
        exit(not Annul);
    end;

    local procedure SaleSuccessful(SystemID: Guid): Boolean
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetRange(SystemId, SystemID);
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        exit(not POSEntry.IsEmpty());
    end;

    local procedure MarkOriginalTransactionAsReversed(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        OriginalEftTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not EFTTransactionRequest.Successful then
            exit;

        if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::REFUND then
            if GetInitialRequest(EFTTransactionRequest."Processed Entry No.", OriginalEftTransactionRequest) then
                MarkAsReversed(OriginalEftTransactionRequest, EFTTransactionRequest."Entry No.");

        if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::LOOK_UP then
            if GetInitialRequest(EFTTransactionRequest."Processed Entry No.", OriginalEftTransactionRequest) then
                if OriginalEftTransactionRequest."Processing Type" = OriginalEftTransactionRequest."Processing Type"::REFUND then
                    if GetInitialRequest(OriginalEftTransactionRequest."Processed Entry No.", OriginalEftTransactionRequest) then
                        MarkAsReversed(OriginalEftTransactionRequest, EFTTransactionRequest."Entry No.");
    end;

    local procedure MarkAsReversed(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; ReversedByEntryNo: Integer)
    begin
        if EFTTransactionRequest.Reversed then
            exit;

        EFTTransactionRequest.Reversed := true;
        EFTTransactionRequest."Reversed by Entry No." := ReversedByEntryNo;
        EFTTransactionRequest.Modify();
    end;

    local procedure MarkAsRecovered(var OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if OriginalEFTTransactionRequest.Recovered then
            exit;

        OriginalEFTTransactionRequest.Recovered := true;
        OriginalEFTTransactionRequest."Recovered by Entry No." := EFTTransactionRequest."Entry No.";
        OriginalEFTTransactionRequest.Modify();
    end;

    local procedure GetInitialRequest(InitializedByEntryNo: Integer; var EFTTransactionRequestOut: Record "NPR EFT Transaction Request"): Boolean
    begin
        if InitializedByEntryNo = 0 then
            exit(false);
        exit(EFTTransactionRequestOut.Get(InitializedByEntryNo));
    end;

    local procedure SetFinancialImpact(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if (not EftTransactionRequest."Financial Impact") then
            if (EftTransactionRequest."Result Amount" <> 0) and (EftTransactionRequest.Successful) then begin
                EftTransactionRequest."Financial Impact" := true;
                EftTransactionRequest.Modify();
            end;
    end;

    local procedure CheckIfTrxResultAlreadyKnown(EntryNo: Integer)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        RecoveredEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin

        EFTTransactionRequest.Get(EntryNo);

        if EFTTransactionRequest.Recovered then begin
            RecoveredEFTTransactionRequest.Get(EFTTransactionRequest."Recovered by Entry No.");
            Error(CAPTION_RECOVER_EARLIER,
              EFTTransactionRequest."Integration Type",
              RecoveredEFTTransactionRequest."Entry No.",
              EFTTransactionRequest."Sales Ticket No.",
              Format(EFTTransactionRequest."Processing Type"),
              RecoveredEFTTransactionRequest."Result Amount",
              RecoveredEFTTransactionRequest."Currency Code",
              RecoveredEFTTransactionRequest."Reference Number Output");
        end;

        if EFTTransactionRequest."External Result Known" and (EFTTransactionRequest.Finished <> 0DT) then begin
            Error(RESULT_KNOWN,
              EFTTransactionRequest."Integration Type",
              EFTTransactionRequest."Sales Ticket No.",
              Format(EFTTransactionRequest."Processing Type"),
              EFTTransactionRequest.Successful,
              EFTTransactionRequest."Result Amount",
              EFTTransactionRequest."Currency Code",
              EFTTransactionRequest."Reference Number Output");
        end;

    end;

    local procedure CheckIfTrxCanBeVoided(EntryNo: Integer; SalePOS: Record "NPR POS Sale")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Get(EntryNo);

        if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::LOOK_UP then begin
            EFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
        end;

        if (EFTTransactionRequest.Reversed) then begin
            Error(ALREADY_VOID, EFTTransactionRequest.TableCaption, EFTTransactionRequest.FieldCaption("Entry No."), EFTTransactionRequest."Entry No.");
        end;

        if not ((EFTTransactionRequest."External Result Known" and (EFTTransactionRequest.Finished <> 0DT)) or EFTTransactionRequest.Recovered) then begin
            Error(RESULT_UNKNOWN);
        end;

        if EFTTransactionRequest.Recovered then begin
            EFTTransactionRequest.Get(EFTTransactionRequest."Recovered by Entry No.");
        end;

        if (not SaleSuccessful(EFTTransactionRequest."Sales ID")) and (EFTTransactionRequest."Sales ID" <> SalePOS.SystemId) then begin
            Error(SALE_NOT_FOUND);
        end;
    end;

    local procedure LookupError(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin
        if ((EFTTransactionRequest.Finished = 0DT) or (not EFTTransactionRequest."External Result Known")) then begin
            Message(CAPTION_RECOVER_FAIL_HARD, EFTTransactionRequest."Integration Type");
            exit(true);
        end;
    end;

    local procedure LookupFailure(EFTTransactionRequest: Record "NPR EFT Transaction Request"; OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin
        if (not EFTTransactionRequest.Successful) then begin
            Message(CAPTION_RECOVER_FAIL_SOFT, EFTTransactionRequest."Integration Type", OriginalEFTTransactionRequest."Entry No.");
            exit(true);
        end;
    end;

    local procedure LookupInSyncNoFinancialImpact(EFTTransactionRequest: Record "NPR EFT Transaction Request"; OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin
        if (OriginalEFTTransactionRequest."Result Amount" = EFTTransactionRequest."Result Amount") and (EFTTransactionRequest."Result Amount" = 0) then begin
            MarkAsRecovered(OriginalEFTTransactionRequest, EFTTransactionRequest);
            Message(CAPTION_RECOVER_SYNC_ZERO,
              EFTTransactionRequest."Integration Type",
              OriginalEFTTransactionRequest."Sales Ticket No.",
              Format(OriginalEFTTransactionRequest."Processing Type"),
              EFTTransactionRequest."Result Amount",
              EFTTransactionRequest."Currency Code",
              EFTTransactionRequest."Reference Number Output");

            exit(true);
        end;
    end;

    local procedure LookupOutOfSyncAndSaleIsCurrent(EFTTransactionRequest: Record "NPR EFT Transaction Request"; OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin
        if (EFTTransactionRequest."Sales ID" = OriginalEFTTransactionRequest."Sales ID") and (EFTTransactionRequest."Result Amount" <> 0) then begin
            MarkAsRecovered(OriginalEFTTransactionRequest, EFTTransactionRequest);
            Message(CAPTION_RECOVER_SAVE,
              EFTTransactionRequest."Integration Type",
              OriginalEFTTransactionRequest."Sales Ticket No.",
              Format(OriginalEFTTransactionRequest."Processing Type"),
              EFTTransactionRequest."Result Amount",
              EFTTransactionRequest."Currency Code",
              EFTTransactionRequest."Reference Number Output");

            exit(true);
        end;
    end;

    local procedure LookupOutOfSyncAndSaleIsParked(EFTTransactionRequest: Record "NPR EFT Transaction Request"; OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
    begin
        if (EFTTransactionRequest."Result Amount" <> 0) then begin
            POSQuoteEntry.SetRange(SystemId, OriginalEFTTransactionRequest."Sales ID");
            if (not POSQuoteEntry.IsEmpty) then begin
                Message(QUOTE_OUT_OF_SYNC, POSQuoteEntry.TableCaption, POSQuoteEntry."Sales Ticket No.");
                exit(true);
            end;
        end;
    end;

    local procedure LookupOutOfSyncAndSaleIsFinished(EFTTransactionRequest: Record "NPR EFT Transaction Request"; OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        POSEntry: Record "NPR POS Entry";
    begin
        if (EFTTransactionRequest."Result Amount" <> 0) then begin
            if (SaleSuccessful(OriginalEFTTransactionRequest."Sales ID")) then begin
                Message(CAPTION_RECOVER_WARN,
                  EFTTransactionRequest."Integration Type",
                  OriginalEFTTransactionRequest."Sales Ticket No.",
                  POSEntry.TableCaption,
                  OriginalEFTTransactionRequest."Entry No.",
                  Format(OriginalEFTTransactionRequest."Processing Type"),
                  EFTTransactionRequest."Result Amount",
                  EFTTransactionRequest."Currency Code",
                  EFTTransactionRequest."Reference Number Output");
                exit(true);
            end;
        end;
    end;

    local procedure LookupOutOfSyncAndSaleIsOnAnotherUnit(EFTTransactionRequest: Record "NPR EFT Transaction Request"; OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        SalePOS: Record "NPR POS Sale";
    begin
        if (EFTTransactionRequest."Result Amount" <> 0) and (EFTTransactionRequest."Sales ID" <> OriginalEFTTransactionRequest."Sales ID") then begin
            if SalePOS.GetBySystemId(OriginalEFTTransactionRequest."Sales ID") then begin
                Message(CAPTION_RECOVER_WARN_STRONG,
                  EFTTransactionRequest."Integration Type",
                  OriginalEFTTransactionRequest."Sales Ticket No.",
                  OriginalEFTTransactionRequest."Entry No.",
                  Format(OriginalEFTTransactionRequest."Processing Type"),
                  EFTTransactionRequest."Result Amount",
                  EFTTransactionRequest."Currency Code",
                  EFTTransactionRequest."Reference Number Output");
                exit(true);
            end;
        end;
    end;

    local procedure LookupOutOfSyncAndSaleIsLost(EFTTransactionRequest: Record "NPR EFT Transaction Request"; OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin
        Message(MISSING_ORIGINAL,
          EFTTransactionRequest."Integration Type",
          OriginalEFTTransactionRequest."Sales Ticket No.",
          Format(OriginalEFTTransactionRequest."Processing Type"),
          EFTTransactionRequest."Result Amount",
          EFTTransactionRequest."Currency Code",
          EFTTransactionRequest."Reference Number Output");
    end;

    procedure GetPOSPostingSetupAccountNo(var POSSession: Codeunit "NPR POS Session"; PaymentMethodCode: Code[20]): Code[20]
    var
        SalePOS: Record "NPR POS Sale";
        POSPostingSetup: Record "NPR POS Posting Setup";
        POSSale: Codeunit "NPR POS Sale";
        NoPOSPostingSetupFound: Label '%1 for %2 %3 and %4 %5 with %6 %7 not found.', Comment = '%1 = POSPostingSetup.TableCaption(), %2 = POSPostingSetup.FieldCaption("POS Store Code"), %3 = SalePOS."POS Store Code", %4 = POSPostingSetup.FieldCaption("POS Payment Method Code"),%5 = PaymentMethodCode, %6 = POSPostingSetup.FieldCaption("Account Type") %7=  POSPostingSetup."Account Type"::"G/L Account"';
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSPostingSetup.Reset();
        POSPostingSetup.SetRange("POS Store Code", SalePOS."POS Store Code");
        POSPostingSetup.SetRange("POS Payment Method Code", PaymentMethodCode);
        POSPostingSetup.SetRange("Account Type", POSPostingSetup."Account Type"::"G/L Account");
        if POSPostingSetup.FindFirst() then
            exit(POSPostingSetup."Account No.")
        else begin
            POSPostingSetup.SetRange("POS Store Code");
            if POSPostingSetup.FindFirst() then
                exit(POSPostingSetup."Account No.")
            else
                Error(NoPOSPostingSetupFound, POSPostingSetup.TableCaption(), POSPostingSetup.FieldCaption("POS Store Code"), SalePOS."POS Store Code", POSPostingSetup.FieldCaption("POS Payment Method Code"), PaymentMethodCode, POSPostingSetup.FieldCaption("Account Type"), POSPostingSetup."Account Type"::"G/L Account");
        end;
    end;

    #endregion
    #region Obsolete

    [Obsolete('Use HWC Version', '2023-06-28')]
    procedure StartPayment(EFTSetup: Record "NPR EFT Setup"; Amount: Decimal; CurrencyCode: Code[10]; SalePOS: Record "NPR POS Sale"): Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionRequestToRecover: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
    begin
        if PerformRecoveryInstead(SalePOS, EFTSetup."EFT Integration Type", EFTTransactionRequestToRecover) then begin
            EFTFrameworkMgt.CreateLookupTransactionRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", EFTTransactionRequestToRecover."Entry No.")
        end else begin
            if (Amount >= 0) then
                EFTFrameworkMgt.CreatePaymentOfGoodsRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", CurrencyCode, Amount)
            else
                EFTFrameworkMgt.CreateRefundRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", CurrencyCode, Abs(Amount), 0);
        end;

        Commit(); // Save the request record data regardless of any later errors when invoking.
        StoreActionState(EFTTransactionRequest); // So the outer PAYMENT workflow can decide to attempt end sale or not.
        SendRequest(EFTTransactionRequest);
        exit(EFTTransactionRequest."Entry No.");
    end;

    [Obsolete('Use HWC Version', '2023-06-28')]
    procedure StartVoid(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; RequestEntryNoToVoid: Integer; IsManualVoid: Boolean): Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequestToRecover: Record "NPR EFT Transaction Request";
    begin

        CheckIfTrxCanBeVoided(RequestEntryNoToVoid, SalePOS);

        if PerformRecoveryInstead(SalePOS, EFTSetup."EFT Integration Type", EFTTransactionRequestToRecover) then begin
            EFTFrameworkMgt.CreateLookupTransactionRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", EFTTransactionRequestToRecover."Entry No.");
        end else begin
            EFTFrameworkMgt.CreateVoidRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", RequestEntryNoToVoid, IsManualVoid);
        end;
        Commit();
        SendRequest(EFTTransactionRequest);
        exit(EFTTransactionRequest."Entry No.");
    end;

    [Obsolete('Use HWC Version', '2023-06-28')]
    procedure StartReferencedRefund(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; CurrencyCode: Code[10]; AmountToRefund: Decimal; OriginalRequestEntryNo: Integer): Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequestToRecover: Record "NPR EFT Transaction Request";
    begin

        if PerformRecoveryInstead(SalePOS, EFTSetup."EFT Integration Type", EFTTransactionRequestToRecover) then begin
            EFTFrameworkMgt.CreateLookupTransactionRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", EFTTransactionRequestToRecover."Entry No.");
        end else begin
            EFTFrameworkMgt.CreateRefundRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", CurrencyCode, Abs(AmountToRefund), OriginalRequestEntryNo);
        end;
        Commit();
        SendRequest(EFTTransactionRequest);
        exit(EFTTransactionRequest."Entry No.");
    end;

    [Obsolete('Use HWC Version', '2023-06-28')]
    procedure StartGiftCardLoad(EFTSetup: Record "NPR EFT Setup"; Amount: Decimal; CurrencyCode: Code[10]; SalePOS: Record "NPR POS Sale"): Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequestToRecover: Record "NPR EFT Transaction Request";
    begin

        if PerformRecoveryInstead(SalePOS, EFTSetup."EFT Integration Type", EFTTransactionRequestToRecover) then begin
            EFTFrameworkMgt.CreateLookupTransactionRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", EFTTransactionRequestToRecover."Entry No.");
        end else begin
            EFTFrameworkMgt.CreateGiftcardLoadRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", CurrencyCode, Amount);
        end;
        Commit();
        SendRequest(EFTTransactionRequest);
        exit(EFTTransactionRequest."Entry No.");
    end;

    [Obsolete('Use HWC Version', '2023-06-28')]
    procedure StartLookup(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; EntryNoToLookup: Integer): Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        CheckIfTrxResultAlreadyKnown(EntryNoToLookup);

        EFTFrameworkMgt.CreateLookupTransactionRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", EntryNoToLookup);
        Commit();
        SendRequest(EFTTransactionRequest);
        exit(EFTTransactionRequest."Entry No.");
    end;

    [Obsolete('Use HWC Version', '2023-06-28')]
    procedure StartBeginWorkshift(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"): Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTFrameworkMgt.CreateBeginWorkshiftRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.");
        Commit();
        SendRequest(EFTTransactionRequest);
        exit(EFTTransactionRequest."Entry No.");
    end;

    [Obsolete('Use HWC Version', '2023-06-28')]
    procedure StartEndWorkshift(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"): Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTFrameworkMgt.CreateEndWorkshiftRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.");
        Commit();
        SendRequest(EFTTransactionRequest);
        exit(EFTTransactionRequest."Entry No.");
    end;


    [Obsolete('Use HWC Version', '2023-06-28')]
    procedure StartVerifySetup(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"): Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTFrameworkMgt.CreateVerifySetupRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.");
        Commit();
        SendRequest(EFTTransactionRequest);
        exit(EFTTransactionRequest."Entry No.");
    end;

    [Obsolete('Use HWC Version', '2023-06-28')]
    procedure StartAuxOperation(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; AuxFunction: Integer): Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTFrameworkMgt.CreateAuxRequest(EFTTransactionRequest, EFTSetup, AuxFunction, SalePOS."Register No.", SalePOS."Sales Ticket No.");
        Commit();
        SendRequest(EFTTransactionRequest);
        exit(EFTTransactionRequest."Entry No.");
    end;

    [Obsolete('Use HWC', '2023-06-28')]
    local procedure SendRequest(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEndManagement, true);
        EFTFrameworkMgt.PauseFrontEndBeforeEFTRequest(EFTTransactionRequest, POSFrontEndManagement);

        EFTFrameworkMgt.SendRequest(EFTTransactionRequest);
    end;

    [Obsolete('Use workflow v3 approach', '2023-06-28')]
    local procedure StoreActionState(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.StoreActionState('TransactionRequest_EntryNo', EFTTransactionRequest."Entry No.");
        POSSession.StoreActionState('TransactionRequest_Token', EFTTransactionRequest.Token);
    end;

    #endregion
}

