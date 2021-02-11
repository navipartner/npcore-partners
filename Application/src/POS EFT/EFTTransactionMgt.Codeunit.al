codeunit 6184473 "NPR EFT Transaction Mgt."
{
    // Public API for EFT operations.
    // 
    // 
    // NPR5.46/MMV /20180725 CASE 290734 Created object
    // NPR5.48/MMV /20190114 CASE 341237 Skip recovery prompt for a failed transaction when in self-service mode.
    //                                   Accept recovery of zero amounts without a currency specified.
    //                                   Moved reverse flags inside the main eft database transaction.
    // NPR5.50/MMV /20190508 CASE 354510 Store action state.
    // NPR5.51/MMV /20190619 CASE 359229 Added safeguard against result amount without success.
    // NPR5.51/MMV /20190603 CASE 355433 Moved implicit behaviour from events to function invocations
    // NPR5.53/MMV /20191203 CASE 349520 Only recover to payment line when original trx was unsuccessful. This should logically be implied but added safeguard against integration specific bugs.
    //                                   Improved captions with clear indication of happy/sad paths.
    // NPR5.54/MMV /20200131 CASE 377533 Changed captions after recovery to be more intuitive.
    // NPR5.54/MMV /20200225 CASE 364340 Added support for surcharge and tip.
    //                                   Consolidated all request types into this codeunit for more code-reuse.
    //                                   Renamed to "EFT Transaction Mgt." to indicate purpose better.
    //                                   Refactored the void & lookup flow to better fit the new sales recovery mechanism.
    // NPR5.55/MMV /20200420 CASE 386254 Added WF2 methods, unattended lookup skip, adjusted captions & fixed sale completion check.
    // NPR5.55/MMV /20200701 CASE 412426 Disable LOCKTIMEOUT in sensitive areas.


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Backend action for handling EFT payments';
        ERROR_SESSION: Label 'Critical Error: Session object could not be retrieved by EFT Framework';
        CAPTION_RECOVER_PROMPT: Label 'The last %1 transaction on this register never completed successfully.\Do you want to attempt recovery of the below transaction now?\(This is strongly recommended)\\From Sales Ticket No.: %2\Type: %3\Amount: %4 %5\External Ref. No.: %6';
        CAPTION_RECOVER_FAIL_HARD: Label 'LOOKUP UNKNOWN:\%1 lookup request failed. Check the connection and try again.';
        CAPTION_RECOVER_FAIL_SOFT: Label 'LOOKUP UNKNOWN:\Cannot lookup %1 result for transaction entry no. %2';
        CAPTION_RECOVER_SYNC: Label 'LOOKUP SUCCESS:\In sync with the originally recorded transaction result:\\%1\From Sales Ticket No.: %2\Type: %3\Amount: %4 %5\External Ref. No.: %6';
        CAPTION_RECOVER_SYNC_ZERO: Label 'LOOKUP SUCCESS:\Recovered transaction result:\(ZERO AMOUNT - NO MONEY WAS TRANSFERRED)\\%1\From Sales Ticket No.: %2\Type: %3\Amount: %4 %5\External Ref. No.: %6';
        CAPTION_RECOVER_EARLIER: Label 'LOOKUP SUCCESS:\%1 transaction result has already been recovered by an earlier lookup request (Entry No. %2):\\From Sales Ticket No.: %3\Type: %4\Recovered Amount: %5 %6\External Ref. No.: %7';
        CAPTION_RECOVER_SAVE: Label 'LOOKUP SUCCESS:\A lost transaction result from the current sale was recovered and re-created as payment line:\\%1\Type: %3\Amount: %4 %5\External Ref. No.: %6';
        CAPTION_RECOVER_WARN: Label 'LOOKUP WARNING:\A transaction result from an earlier sale was recovered. The recovered amount is out of sync with what the system recorded initially.\We recommend checking the sale details manually in %3 and reversing the transaction if necessary.\\%1\From Sales Ticket No.: %2\Type: %5\Amount: %6 %7\External Ref. No.: %8';
        CAPTION_RECOVER_WARN_STRONG: Label 'LOOKUP WARNING:\A transaction result from an earlier sale that never ended correctly was recovered. If the sale was cancelled this transaction should be reversed.\\%1\From Sales Ticket No.: %2\Type: %4\Amount: %5 %6\External Ref. No.: %7';
        CAPTION_RECOVER_BUG_MISMATCH: Label 'LOOKUP ERROR:\%1 lookup result does not match the original result!\New Amount: %2 %3\\Original Sales Ticket No.: %4\Type: %5\Original Amount: %6 %7\External Ref. No.: %8';
        WARNING_GIFT_TYPE: Label 'LOOKUP WARNING:\The payment type %1 used for %2 is not set as %3. This is either caused by a wrong card swipe on terminal or incorrect setup.';
        RESULT_KNOWN: Label 'LOOKUP SUCCESS:\%1 transaction result is already known:\\From Sales Ticket No.: %2\Type: %3\Successful: %4\Amount: %5 %6\External Ref. No.: %7';
        ALREADY_VOID: Label '%1, %2 %3 has already been voided';
        RESULT_UNKNOWN: Label 'Cannot void a transaction with unknown result. Perform a lookup first to recover the lost result and try again.';
        SALE_NOT_FOUND: Label 'Could not find sale linked with trx. It needs to be either finished or active in the current POS sale before a void operation is allowed.';
        QUOTE_OUT_OF_SYNC: Label 'LOOKUP WARNING:\Transaction result is out of sync, but cannot be recreated unless %1 %2 is loaded first. Please load that sale and lookup transaction again!';
        MISSING_ORIGINAL: Label 'LOOKUP WARNING:\A transaction result was recovered but the original sale connected to it, is missing.If the sale was cancelled the transaction should be reversed.\\%1\From Sales Ticket No.: %2\Type: %3\Amount: %4 %5\External Ref. No.: %6';

    local procedure "// Workflow V1"()
    begin
    end;

    procedure StartPayment(EFTSetup: Record "NPR EFT Setup"; PaymentTypePOS: Record "NPR Payment Type POS"; Amount: Decimal; CurrencyCode: Code[10]; SalePOS: Record "NPR Sale POS"): Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionRequestToRecover: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
    begin
        //-NPR5.54 [364340]
        if PerformRecoveryInstead(SalePOS, EFTSetup."EFT Integration Type", EFTTransactionRequestToRecover) then begin
            EFTFrameworkMgt.CreateLookupTransactionRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", EFTTransactionRequestToRecover."Entry No.")
        end else begin
            if (Amount >= 0) then
                EFTFrameworkMgt.CreatePaymentOfGoodsRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", CurrencyCode, Amount)
            else
                EFTFrameworkMgt.CreateRefundRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", CurrencyCode, Abs(Amount), 0);
        end;
        //+NPR5.54 [364340]
        Commit; // Save the request record data regardless of any later errors when invoking.
        StoreActionState(EFTTransactionRequest); // So the outer PAYMENT workflow can decide to attempt end sale or not.
        SendRequest(EFTTransactionRequest);
        //-NPR5.54 [364340]
        exit(EFTTransactionRequest."Entry No.");
        //+NPR5.54 [364340]
    end;

    procedure StartVoid(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR Sale POS"; RequestEntryNoToVoid: Integer; IsManualVoid: Boolean): Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequestToRecover: Record "NPR EFT Transaction Request";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
    begin
        //-NPR5.54 [364340]
        CheckIfTrxCanBeVoided(RequestEntryNoToVoid, SalePOS);

        if PerformRecoveryInstead(SalePOS, EFTSetup."EFT Integration Type", EFTTransactionRequestToRecover) then begin
            EFTFrameworkMgt.CreateLookupTransactionRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", EFTTransactionRequestToRecover."Entry No.");
        end else begin
            EFTFrameworkMgt.CreateVoidRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", RequestEntryNoToVoid, IsManualVoid);
        end;
        Commit;
        SendRequest(EFTTransactionRequest);
        exit(EFTTransactionRequest."Entry No.");
        //+NPR5.54 [364340]
    end;

    procedure StartReferencedRefund(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR Sale POS"; CurrencyCode: Code[10]; AmountToRefund: Decimal; OriginalRequestEntryNo: Integer): Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequestToRecover: Record "NPR EFT Transaction Request";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
    begin
        //-NPR5.54 [364340]
        if PerformRecoveryInstead(SalePOS, EFTSetup."EFT Integration Type", EFTTransactionRequestToRecover) then begin
            EFTFrameworkMgt.CreateLookupTransactionRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", EFTTransactionRequestToRecover."Entry No.");
        end else begin
            EFTFrameworkMgt.CreateRefundRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", CurrencyCode, Abs(AmountToRefund), OriginalRequestEntryNo);
        end;
        Commit;
        SendRequest(EFTTransactionRequest);
        exit(EFTTransactionRequest."Entry No.");
        //+NPR5.54 [364340]
    end;

    procedure StartGiftCardLoad(EFTSetup: Record "NPR EFT Setup"; PaymentTypePOS: Record "NPR Payment Type POS"; Amount: Decimal; CurrencyCode: Code[10]; SalePOS: Record "NPR Sale POS"): Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequestToRecover: Record "NPR EFT Transaction Request";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
    begin
        //-NPR5.54 [364340]
        if PerformRecoveryInstead(SalePOS, EFTSetup."EFT Integration Type", EFTTransactionRequestToRecover) then begin
            EFTFrameworkMgt.CreateLookupTransactionRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", EFTTransactionRequestToRecover."Entry No.");
        end else begin
            EFTFrameworkMgt.CreateGiftcardLoadRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", CurrencyCode, Amount);
        end;
        Commit;
        SendRequest(EFTTransactionRequest);
        exit(EFTTransactionRequest."Entry No.");
        //+NPR5.54 [364340]
    end;

    procedure StartLookup(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR Sale POS"; EntryNoToLookup: Integer): Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
    begin
        //-NPR5.54 [364340]
        CheckIfTrxResultAlreadyKnown(EntryNoToLookup);

        EFTFrameworkMgt.CreateLookupTransactionRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", EntryNoToLookup);
        Commit;
        SendRequest(EFTTransactionRequest);
        exit(EFTTransactionRequest."Entry No.");
        //+NPR5.54 [364340]
    end;

    procedure StartBeginWorkshift(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR Sale POS"): Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
    begin
        //-NPR5.54 [364340]
        EFTFrameworkMgt.CreateBeginWorkshiftRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.");
        Commit;
        SendRequest(EFTTransactionRequest);
        exit(EFTTransactionRequest."Entry No.");
        //+NPR5.54 [364340]
    end;

    procedure StartEndWorkshift(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR Sale POS"): Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
    begin
        //-NPR5.54 [364340]
        EFTFrameworkMgt.CreateEndWorkshiftRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.");
        Commit;
        SendRequest(EFTTransactionRequest);
        exit(EFTTransactionRequest."Entry No.");
        //+NPR5.54 [364340]
    end;

    procedure StartVerifySetup(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR Sale POS"): Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
    begin
        //-NPR5.54 [364340]
        EFTFrameworkMgt.CreateVerifySetupRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.");
        Commit;
        SendRequest(EFTTransactionRequest);
        exit(EFTTransactionRequest."Entry No.");
        //+NPR5.54 [364340]
    end;

    procedure StartAuxOperation(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR Sale POS"; AuxFunction: Integer): Integer
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
    begin
        //-NPR5.54 [364340]
        EFTFrameworkMgt.CreateAuxRequest(EFTTransactionRequest, EFTSetup, AuxFunction, SalePOS."Register No.", SalePOS."Sales Ticket No.");
        Commit;
        SendRequest(EFTTransactionRequest);
        exit(EFTTransactionRequest."Entry No.");
        //+NPR5.54 [364340]
    end;

    local procedure "// Workflow V2"()
    begin
    end;

    procedure PreparePayment(EFTSetup: Record "NPR EFT Setup"; PaymentTypePOS: Record "NPR Payment Type POS"; Amount: Decimal; CurrencyCode: Code[10]; SalePOS: Record "NPR Sale POS"; var IntegrationWorkflowOut: Text): Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionRequestToRecover: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
    begin
        //-NPR5.55 [386254]
        if PerformRecoveryInstead(SalePOS, EFTSetup."EFT Integration Type", EFTTransactionRequestToRecover) then begin
            EFTFrameworkMgt.CreateLookupTransactionRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", EFTTransactionRequestToRecover."Entry No.")
        end else begin
            if (Amount >= 0) then
                EFTFrameworkMgt.CreatePaymentOfGoodsRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", CurrencyCode, Amount)
            else
                EFTFrameworkMgt.CreateRefundRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", CurrencyCode, Abs(Amount), 0);
        end;

        IntegrationWorkflowOut := EFTFrameworkMgt.GetIntegrationWorkflow(EFTTransactionRequest);

        Commit; // Save the request record data regardless of any later errors when invoking.

        exit(EFTTransactionRequest."Entry No.");
        //+NPR5.55 [386254]
    end;

    local procedure "// Response Handlers"()
    begin
    end;

    procedure HandleIntegrationResponse(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
            Error(ERROR_SESSION);
        POSFrontEnd.GetSession(POSSession);

        //-NPR5.55 [412426]
        LockTimeout(false);
        //+NPR5.55 [412426]

        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::REFUND,
          EftTransactionRequest."Processing Type"::PAYMENT:
                EftPaymentResponseReceived(EftTransactionRequest, POSFrontEnd, POSSession);
            EftTransactionRequest."Processing Type"::VOID:
                EftVoidResponseReceived(EftTransactionRequest, POSFrontEnd, POSSession);
            EftTransactionRequest."Processing Type"::LOOK_UP:
                EftLookupResponseReceived(EftTransactionRequest, POSFrontEnd, POSSession);
            //-NPR5.54 [364340]
            EftTransactionRequest."Processing Type"::GIFTCARD_LOAD:
                GiftCardLoadResponseReceived(EftTransactionRequest, POSFrontEnd, POSSession);
        //+NPR5.54 [364340]
        end;
    end;

    local procedure EftPaymentResponseReceived(EftTransactionRequest: Record "NPR EFT Transaction Request"; POSFrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        POSSale: Codeunit "NPR POS Sale";
        PaymentTypePOS: Record "NPR Payment Type POS";
        ReturnPaymentTypePOS: Record "NPR Payment Type POS";
        Register: Record "NPR Register";
        EFTInterface: Codeunit "NPR EFT Interface";
        OriginalEftTransactionRequest: Record "NPR EFT Transaction Request";
        Skip: Boolean;
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
    begin
        SetFinancialImpact(EftTransactionRequest);
        InsertPaymentLine(POSSession, EftTransactionRequest);
        //-NPR5.54 [364340]
        HandleSurcharge(POSSession, EftTransactionRequest);
        HandleTip(POSSession, EftTransactionRequest);
        //+NPR5.54 [364340]
        MarkOriginalTransactionAsReversed(EftTransactionRequest);
        Commit; // This commit should handle both the sale line(s) insertion and trx record "Result Processed" := true in the same transaction. On failure, lookup of trx result is needed.
        EFTInterface.OnAfterFinancialCommit(EftTransactionRequest);
        POSSession.RequestRefreshData();

        if EftTransactionRequest.Successful then begin
            if not ConfirmEftPayment(EftTransactionRequest) then
                exit; //Don't resume front end straight away as a subscriber indicated the transaction might need to be annulled now, for example due to signature decline

            POSSession.AddServerStopwatch('EFT_PAYMENT', EftTransactionRequest.Finished - EftTransactionRequest.Started);
        end;

        //-NPR5.54 [364340]
        EFTFrameworkMgt.ResumeFrontEndAfterEFTRequest(EftTransactionRequest, POSFrontEnd);
        //+NPR5.54 [364340]
    end;

    local procedure EftLookupResponseReceived(EftTransactionRequest: Record "NPR EFT Transaction Request"; POSFrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        OriginalEftTransactionRequest: Record "NPR EFT Transaction Request";
        EFTInterface: Codeunit "NPR EFT Interface";
        OldRecoveryRequest: Record "NPR EFT Transaction Request";
        AuditRoll: Record "NPR Audit Roll";
        FinancialRecovery: Boolean;
        Skip: Boolean;
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        OriginalEftTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");

        //+NPR5.54 [364340]
        case true of
            LookupError(EftTransactionRequest, OriginalEftTransactionRequest):
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
        //+NPR5.54 [364340]
    end;

    local procedure EftVoidResponseReceived(EftTransactionRequest: Record "NPR EFT Transaction Request"; POSFrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        OriginalEftTransactionRequest: Record "NPR EFT Transaction Request";
        EFTInterface: Codeunit "NPR EFT Interface";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
    begin
        //-NPR5.54 [364340]
        EFTFrameworkMgt.ResumeFrontEndAfterEFTRequest(EftTransactionRequest, POSFrontEnd);
        //+NPR5.54 [364340]
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

        //-NPR5.54 [364340]
        case OriginalEftTransactionRequest."Processing Type" of
            OriginalEftTransactionRequest."Processing Type"::PAYMENT,
          OriginalEftTransactionRequest."Processing Type"::REFUND:
                InsertPaymentLine(POSSession, EftTransactionRequest);

            OriginalEftTransactionRequest."Processing Type"::GIFTCARD_LOAD:
                InsertSaleVoucherLine(POSSession, EftTransactionRequest);
        end;
        HandleSurcharge(POSSession, EftTransactionRequest);
        HandleTip(POSSession, EftTransactionRequest);
        //+NPR5.54 [364340]
        Commit;
        EFTInterface.OnAfterFinancialCommit(EftTransactionRequest);
        POSSession.RequestRefreshData();
    end;

    local procedure "// Aux"()
    begin
    end;

    local procedure SendRequest(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
    begin
        //-NPR5.54 [364340]
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEndManagement, true);
        EFTFrameworkMgt.PauseFrontEndBeforeEFTRequest(EFTTransactionRequest, POSFrontEndManagement);
        //+NPR5.54 [364340]
        EFTFrameworkMgt.SendRequest(EFTTransactionRequest);
    end;

    local procedure InsertPaymentLine(POSSession: Codeunit "NPR POS Session"; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSLine: Record "NPR Sale Line POS";
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetPaymentLine(POSLine);

        POSLine."No." := EFTTransactionRequest."POS Payment Type Code";
        POSLine."EFT Approved" := EFTTransactionRequest.Successful;
        POSLine.Description := CopyStr(EFTTransactionRequest."POS Description", 1, MaxStrLen(POSLine.Description));
        POSLine.Reference := CopyStr(EFTTransactionRequest."Reference Number Output", 1, MaxStrLen(POSLine.Reference));
        if POSLine."EFT Approved" then begin
            POSLine."Amount Including VAT" := EFTTransactionRequest."Result Amount";
            POSLine."Currency Amount" := POSLine."Amount Including VAT";
        end;

        POSPaymentLine.InsertPaymentLine(POSLine, 0);

        POSPaymentLine.GetCurrentPaymentLine(POSLine);
        EFTTransactionRequest."Sales Line No." := POSLine."Line No.";
        //-NPR5.54 [364340]
        EFTTransactionRequest."Sales Line ID" := POSLine."Retail ID";
        //+NPR5.54 [364340]
        EFTTransactionRequest.Modify;
    end;

    local procedure HandleSurcharge(POSSession: Codeunit "NPR POS Session"; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR Sale Line POS";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        OriginalProcessingType: Integer;
        PaymentTypePOS: Record "NPR Payment Type POS";
    begin
        //-NPR5.54 [364340]
        if not EFTTransactionRequest.Successful then
            exit;
        if EFTTransactionRequest."Fee Amount" = 0 then
            exit;

        OriginalProcessingType := EFTTransactionRequest."Processing Type";
        if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::LOOK_UP then begin
            OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
            OriginalProcessingType := OriginalEFTTransactionRequest."Processing Type";
        end;

        PaymentTypePOS.GetByRegister(EFTTransactionRequest."POS Payment Type Code", EFTTransactionRequest."Register No.");
        PaymentTypePOS.TestField("EFT Surcharge Service Item No.");

        case OriginalProcessingType of
            EFTTransactionRequest."Processing Type"::PAYMENT:
                EFTTransactionRequest."Fee Line ID" := InsertServiceItemLine(POSSession, PaymentTypePOS."EFT Surcharge Service Item No.", EFTTransactionRequest."Fee Amount", '', 1);

            EFTTransactionRequest."Processing Type"::REFUND,
          EFTTransactionRequest."Processing Type"::VOID:
                EFTTransactionRequest."Fee Line ID" := InsertServiceItemLine(POSSession, PaymentTypePOS."EFT Surcharge Service Item No.", EFTTransactionRequest."Fee Amount", ' - ' + Format(EFTTransactionRequest."Processing Type"), -1);
        end;
        EFTTransactionRequest.Modify;
        //+NPR5.54 [364340]
    end;

    local procedure HandleTip(POSSession: Codeunit "NPR POS Session"; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR Sale Line POS";
        PaymentTypePOS: Record "NPR Payment Type POS";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        OriginalProcessingType: Integer;
    begin
        //-NPR5.54 [364340]
        if not EFTTransactionRequest.Successful then
            exit;
        if EFTTransactionRequest."Tip Amount" = 0 then
            exit;

        OriginalProcessingType := EFTTransactionRequest."Processing Type";
        if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::LOOK_UP then begin
            OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
            OriginalProcessingType := OriginalEFTTransactionRequest."Processing Type";
        end;

        PaymentTypePOS.GetByRegister(EFTTransactionRequest."POS Payment Type Code", EFTTransactionRequest."Register No.");
        PaymentTypePOS.TestField("EFT Tip Service Item No.");

        case OriginalProcessingType of
            EFTTransactionRequest."Processing Type"::PAYMENT:
                EFTTransactionRequest."Tip Line ID" := InsertServiceItemLine(POSSession, PaymentTypePOS."EFT Tip Service Item No.", EFTTransactionRequest."Tip Amount", '', 1);

            EFTTransactionRequest."Processing Type"::REFUND,
          EFTTransactionRequest."Processing Type"::VOID:
                EFTTransactionRequest."Tip Line ID" := InsertServiceItemLine(POSSession, PaymentTypePOS."EFT Tip Service Item No.", EFTTransactionRequest."Tip Amount", ' - ' + Format(EFTTransactionRequest."Processing Type"), -1);
        end;
        EFTTransactionRequest.Modify;
        //+NPR5.54 [364340]
    end;

    local procedure InsertServiceItemLine(POSSession: Codeunit "NPR POS Session"; ItemNo: Text; Amount: Decimal; DescriptionPostFix: Text; Qty: Integer) LineRetailID: Guid
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR Sale Line POS";
        Item: Record Item;
    begin
        //-NPR5.54 [364340]
        Item.Get(ItemNo);
        Item.TestField(Type, Item.Type::Service);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS.Validate(Type, SaleLinePOS.Type::Item);
        SaleLinePOS.Validate("Sale Type", SaleLinePOS."Sale Type"::Sale);
        SaleLinePOS.Validate("No.", ItemNo);
        SaleLinePOS.Validate(Quantity, Qty);
        SaleLinePOS.Validate("Unit Price", Amount);
        if DescriptionPostFix <> '' then begin
            SaleLinePOS.Description := CopyStr(SaleLinePOS.Description + DescriptionPostFix, 1, MaxStrLen(SaleLinePOS.Description));
        end;
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
        exit(SaleLinePOS."Retail ID");
        //+NPR5.54 [364340]
    end;

    local procedure GiftCardLoadResponseReceived(EftTransactionRequest: Record "NPR EFT Transaction Request"; POSFrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        POSSale: Codeunit "NPR POS Sale";
        PaymentTypePOS: Record "NPR Payment Type POS";
        ReturnPaymentTypePOS: Record "NPR Payment Type POS";
        Register: Record "NPR Register";
        EFTInterface: Codeunit "NPR EFT Interface";
        OriginalEftTransactionRequest: Record "NPR EFT Transaction Request";
        Skip: Boolean;
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
    begin
        //-NPR5.54 [364340]
        SetFinancialImpact(EftTransactionRequest);
        InsertSaleVoucherLine(POSSession, EftTransactionRequest);
        Commit; // This commit should handle both the sale line insertion and EFT transaction record result modification in one transaction to prevent synchronization issues.
        WarnIfVoucherPaymentTypeMismatch(EftTransactionRequest);
        EFTInterface.OnAfterFinancialCommit(EftTransactionRequest);
        POSSession.RequestRefreshData();

        EFTFrameworkMgt.ResumeFrontEndAfterEFTRequest(EftTransactionRequest, POSFrontEnd);
        //+NPR5.54 [364340]
    end;

    local procedure WarnIfVoucherPaymentTypeMismatch(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        PaymentTypePOS: Record "NPR Payment Type POS";
    begin
        //-NPR5.54 [364340]
        PaymentTypePOS.GetByRegister(EFTTransactionRequest."POS Payment Type Code", EFTTransactionRequest."Register No.");
        if PaymentTypePOS."Processing Type" <> PaymentTypePOS."Processing Type"::"Gift Voucher" then
            Message(WARNING_GIFT_TYPE, PaymentTypePOS."No.", EFTTransactionRequest."Processing Type", PaymentTypePOS."Processing Type"::"Gift Voucher");
        //+NPR5.54 [364340]
    end;

    local procedure InsertSaleVoucherLine(POSSession: Codeunit "NPR POS Session"; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        PaymentTypePOS: Record "NPR Payment Type POS";
        LineAmount: Decimal;
    begin
        //-NPR5.54 [364340]
        if not EFTTransactionRequest.Successful then
            exit;
        if EFTTransactionRequest."Result Amount" = 0 then
            exit;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);

        PaymentTypePOS.GetByRegister(EFTTransactionRequest."Original POS Payment Type Code", EFTTransactionRequest."Register No.");

        LineAmount := EFTTransactionRequest."Result Amount" * -1;

        SaleLinePOS.Validate("Sale Type", SaleLinePOS."Sale Type"::Deposit);
        SaleLinePOS.Validate(Type, SaleLinePOS.Type::"G/L Entry");
        SaleLinePOS.Validate("No.", PaymentTypePOS."G/L Account No.");
        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS."EFT Approved" := EFTTransactionRequest.Successful;
        SaleLinePOS.Description := CopyStr(SaleLinePOS.Description + ' - ' + EFTTransactionRequest."Card Number", 1, MaxStrLen(SaleLinePOS.Description));
        SaleLinePOS.Reference := CopyStr(EFTTransactionRequest."Reference Number Output", 1, MaxStrLen(SaleLinePOS.Reference));
        SaleLinePOS.Validate("Unit Price", LineAmount);
        SaleLinePOS.Validate("Amount Including VAT", LineAmount);
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, true);

        EFTTransactionRequest."Sales Line No." := SaleLinePOS."Line No.";
        EFTTransactionRequest."Sales Line ID" := SaleLinePOS."Retail ID";
        EFTTransactionRequest.Modify;

        POSSession.RequestRefreshData();
        //+NPR5.54 [364340]
    end;

    local procedure PerformRecoveryInstead(SalePOS: Record "NPR Sale POS"; IntegrationType: Text; var EFTTransactionRequestToRecover: Record "NPR EFT Transaction Request"): Boolean
    var
        EFTInterface: Codeunit "NPR EFT Interface";
        Skip: Boolean;
    begin
        with EFTTransactionRequestToRecover do begin
            SetRange("Register No.", SalePOS."Register No.");
            SetRange("Integration Type", IntegrationType);
            //-NPR5.54 [364340]
            SetFilter("Processing Type", '%1|%2|%3|%4', "Processing Type"::PAYMENT, "Processing Type"::REFUND, "Processing Type"::VOID, "Processing Type"::GIFTCARD_LOAD);
            //+NPR5.54 [364340]
            if not FindLast then
                exit(false);

            if not Recoverable then
                exit(false);

            if Recovered then
                exit(false);

            if ("External Result Known" and (Finished <> 0DT)) then
                exit(false);

            //-NPR5.55 [386254]
            if "Self Service" then
                exit(false);
            //+NPR5.55 [386254]

            //-NPR5.54 [364340]
            //  IF ("Processing Type" = "Processing Type"::VOID) THEN
            //    IF "Sales Ticket No." <> SalePOS."Sales Ticket No." THEN
            //      EXIT(FALSE); //We can only hope to recover a successful void result if we are still in the same sale.
            //+NPR5.54 [364340]
        end;

        EFTInterface.OnBeforeLookupPrompt(EFTTransactionRequestToRecover, Skip);
        if Skip then
            exit(false);

        with EFTTransactionRequestToRecover do
            exit(Confirm(CAPTION_RECOVER_PROMPT, true, "Integration Type", "Sales Ticket No.", "Processing Type", "Amount Input", "Currency Code", "Reference Number Output"));
    end;

    local procedure ConfirmEftPayment(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        EFTIntegration: Codeunit "NPR EFT Framework Mgt.";
        Annul: Boolean;
    begin
        EFTIntegration.ConfirmAfterPayment(EFTTransactionRequest, Annul);
        exit(not Annul);
    end;

    local procedure OriginalSaleSuccessful(ReceiptNo: Text; RetailID: Guid): Boolean
    var
        AuditRoll: Record "NPR Audit Roll";
        NPRetailSetup: Record "NPR NP Retail Setup";
        POSEntry: Record "NPR POS Entry";
    begin
        //-NPR5.54 [364340]
        if NPRetailSetup.Get then begin
            POSEntry.SetRange("Retail ID", RetailID);
            //-NPR5.55 [386254]
            POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
            //+NPR5.55 [386254]
            exit(not POSEntry.IsEmpty);
        end;
        //+NPR5.54 [364340]

        AuditRoll.SetRange("Sales Ticket No.", ReceiptNo);
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Payment);
        exit(not AuditRoll.IsEmpty);
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
        EFTTransactionRequest.Modify;
    end;

    local procedure MarkAsRecovered(var OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        //-NPR5.54 [364340]
        if OriginalEFTTransactionRequest.Recovered then
            exit;

        OriginalEFTTransactionRequest.Recovered := true;
        OriginalEFTTransactionRequest."Recovered by Entry No." := EFTTransactionRequest."Entry No.";
        OriginalEFTTransactionRequest.Modify;
        //+NPR5.54 [364340]
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
                EftTransactionRequest.Modify;
            end;
    end;

    local procedure StoreActionState(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        //-NPR5.50 [354510]
        POSSession.GetSession(POSSession, true);
        POSSession.StoreActionState('TransactionRequest_EntryNo', EFTTransactionRequest."Entry No.");
        POSSession.StoreActionState('TransactionRequest_Token', EFTTransactionRequest.Token);
        //+NPR5.50 [354510]
    end;

    local procedure CheckIfTrxResultAlreadyKnown(EntryNo: Integer)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        RecoveredEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        //-NPR5.54 [364340]
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
        //+NPR5.54 [364340]
    end;

    local procedure CheckIfTrxCanBeVoided(EntryNo: Integer; SalePOS: Record "NPR Sale POS")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        //-NPR5.54 [364340]
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

        if (not OriginalSaleSuccessful(EFTTransactionRequest."Sales Ticket No.", EFTTransactionRequest."Sales ID")) and (EFTTransactionRequest."Sales ID" <> SalePOS."Retail ID") then begin
            Error(SALE_NOT_FOUND);
        end;
        //+NPR5.54 [364340]
    end;

    local procedure LookupError(EFTTransactionRequest: Record "NPR EFT Transaction Request"; OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin
        //-NPR5.54 [364340]
        if ((EFTTransactionRequest.Finished = 0DT) or (not EFTTransactionRequest."External Result Known")) then begin
            Message(CAPTION_RECOVER_FAIL_HARD, EFTTransactionRequest."Integration Type");
            exit(true);
        end;
        //+NPR5.54 [364340]
    end;

    local procedure LookupFailure(EFTTransactionRequest: Record "NPR EFT Transaction Request"; OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin
        //-NPR5.54 [364340]
        if (not EFTTransactionRequest.Successful) then begin
            Message(CAPTION_RECOVER_FAIL_SOFT, EFTTransactionRequest."Integration Type", OriginalEFTTransactionRequest."Entry No.");
            exit(true);
        end;
        //+NPR5.54 [364340]
    end;

    local procedure LookupInSyncNoFinancialImpact(EFTTransactionRequest: Record "NPR EFT Transaction Request"; OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin
        //-NPR5.54 [364340]
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
        //+NPR5.54 [364340]
    end;

    local procedure LookupOutOfSyncAndSaleIsCurrent(EFTTransactionRequest: Record "NPR EFT Transaction Request"; OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin
        //-NPR5.54 [364340]
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
        //+NPR5.54 [364340]
    end;

    local procedure LookupOutOfSyncAndSaleIsParked(EFTTransactionRequest: Record "NPR EFT Transaction Request"; OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        POSQuoteEntry: Record "NPR POS Quote Entry";
    begin
        //-NPR5.54 [364340]
        if (EFTTransactionRequest."Result Amount" <> 0) then begin
            POSQuoteEntry.SetRange("Retail ID", OriginalEFTTransactionRequest."Sales ID");
            if (not POSQuoteEntry.IsEmpty) then begin
                Message(QUOTE_OUT_OF_SYNC, POSQuoteEntry.TableCaption, POSQuoteEntry."Sales Ticket No.");
                exit(true);
            end;
        end;
        //+NPR5.54 [364340]
    end;

    local procedure LookupOutOfSyncAndSaleIsFinished(EFTTransactionRequest: Record "NPR EFT Transaction Request"; OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        POSEntry: Record "NPR POS Entry";
    begin
        //-NPR5.54 [364340]
        if (EFTTransactionRequest."Result Amount" <> 0) then begin
            if (OriginalSaleSuccessful(OriginalEFTTransactionRequest."Sales Ticket No.", OriginalEFTTransactionRequest."Sales ID")) then begin
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
        //+NPR5.54 [364340]
    end;

    local procedure LookupOutOfSyncAndSaleIsOnAnotherUnit(EFTTransactionRequest: Record "NPR EFT Transaction Request"; OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        SalePOS: Record "NPR Sale POS";
    begin
        //-NPR5.54 [364340]
        if (EFTTransactionRequest."Result Amount" <> 0) and (EFTTransactionRequest."Sales ID" <> OriginalEFTTransactionRequest."Sales ID") then begin
            SalePOS.SetRange("Retail ID", OriginalEFTTransactionRequest."Sales ID");
            if (not SalePOS.IsEmpty) then begin
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
        //+NPR5.54 [364340]
    end;

    local procedure LookupOutOfSyncAndSaleIsLost(EFTTransactionRequest: Record "NPR EFT Transaction Request"; OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin
        //-NPR5.54 [364340]
        Message(MISSING_ORIGINAL,
          EFTTransactionRequest."Integration Type",
          OriginalEFTTransactionRequest."Sales Ticket No.",
          Format(OriginalEFTTransactionRequest."Processing Type"),
          EFTTransactionRequest."Result Amount",
          EFTTransactionRequest."Currency Code",
          EFTTransactionRequest."Reference Number Output");
        //+NPR5.54 [364340]
    end;
}

