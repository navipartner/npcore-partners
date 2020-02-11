codeunit 6184473 "EFT Payment Mgt."
{
    // NPR5.46/MMV /20180725 CASE 290734 Created object
    // NPR5.48/MMV /20190114 CASE 341237 Skip recovery prompt for a failed transaction when in self-service mode.
    //                                   Accept recovery of zero amounts without a currency specified.
    //                                   Moved reverse flags inside the main eft database transaction.
    // NPR5.50/MMV /20190508 CASE 354510 Store action state.
    // NPR5.51/MMV /20190619 CASE 359229 Added safeguard against result amount without success.
    // NPR5.51/MMV /20190603 CASE 355433 Moved implicit behaviour from events to function invocations
    // NPR5.53/MMV /20191203 CASE 349520 Only recover to payment line when original trx was unsuccessful. This should logically be implied but added safeguard against integration specific bugs.
    //                                   Improved captions with clear indication of happy/sad paths.


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Backend action for handling EFT payments';
        ERROR_SESSION: Label 'Critical Error: Session object could not be retrieved by EFT Framework';
        CAPTION_RECOVER_PROMPT: Label 'The last %1 transaction on this register never completed successfully.\Do you want to attempt recovery of the below transaction now?\(This is strongly recommended but can be done later on the EFT transaction list)\\From Sales Ticket No.: %2\Type: %3\Amount: %4 %5\External Ref. No.: %6';
        CAPTION_RECOVER_FAIL_HARD: Label 'UNKNOWN:\Lookup failed for %1 transaction entry no. %2. No connection could be established.\Please try again later.';
        CAPTION_RECOVER_FAIL_SOFT: Label 'UNKNOWN:\Cannot lookup %1 result for transaction entry no. %2';
        CAPTION_RECOVER_SYNC: Label 'SUCCESS:\%1 transaction result is in sync with the originally recorded transaction result:\\From Sales Ticket No.: %2\Type: %3\Amount: %4 %5\External Ref. No.: %6';
        CAPTION_RECOVER_EARLIER: Label '%1 transaction result has already been recovered by an earlier lookup request (Entry No. %2):\\From Sales Ticket No.: %3\Type: %4\Recovered Amount: %5 %6\External Ref. No.: %7';
        CAPTION_RECOVER_SAVE: Label 'SUCCESS:\A lost %1 transaction result from the current sale was recovered and re-created as payment line:\\Type: %3\Amount: %4 %5\External Ref. No.: %6';
        CAPTION_RECOVER_WARN: Label 'WARNING:\A %1 transaction result from an earlier sale was recovered. The recovered amount is out of sync with what the system recorded initially.\We recommend checking the sale details manually in %3 and reversing the transaction if necessary.\\From Sales Ticket No.: %2\Type: %5\Amount: %6 %7\External Ref. No.: %8';
        CAPTION_RECOVER_WARN_STRONG: Label 'WARNING:\A %1 transaction result from an earlier sale that never ended correctly was recovered. If the sale was cancelled this transaction should be reversed.\\From Sales Ticket No.: %2\Type: %4\Amount: %5 %6\External Ref. No.: %7';
        CAPTION_RECOVER_BUG_MISMATCH: Label 'ERROR:\%1 lookup result does not match the original result!\New Amount: %2 %3\\Original Sales Ticket No.: %4\Type: %5\Original Amount: %6 %7\External Ref. No.: %8';

    procedure StartPayment(EFTSetup: Record "EFT Setup";PaymentTypePOS: Record "Payment Type POS";Amount: Decimal;CurrencyCode: Code[10];SalePOS: Record "Sale POS")
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        CreateEftTransactionRequest(EFTSetup, PaymentTypePOS, Amount, CurrencyCode, SalePOS, EFTTransactionRequest);
        Commit; // Save the request record data regardless of any later errors when invoking.
        StoreActionState(EFTTransactionRequest);
        SendRequest(EFTTransactionRequest);
    end;

    procedure HandleIntegrationResponse(EftTransactionRequest: Record "EFT Transaction Request")
    var
        POSSession: Codeunit "POS Session";
        POSFrontEnd: Codeunit "POS Front End Management";
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
          Error(ERROR_SESSION);
        POSFrontEnd.GetSession(POSSession);

        case EftTransactionRequest."Processing Type" of
          EftTransactionRequest."Processing Type"::REFUND,
          EftTransactionRequest."Processing Type"::PAYMENT : EftPaymentResponseReceived(EftTransactionRequest, POSFrontEnd, POSSession);
          EftTransactionRequest."Processing Type"::VOID : EftVoidResponseReceived(EftTransactionRequest, POSFrontEnd, POSSession);
          EftTransactionRequest."Processing Type"::LOOK_UP : EftLookupResponseReceived(EftTransactionRequest, POSFrontEnd, POSSession);
        end;
    end;

    local procedure EftPaymentResponseReceived(EftTransactionRequest: Record "EFT Transaction Request";POSFrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session")
    var
        POSSale: Codeunit "POS Sale";
        PaymentTypePOS: Record "Payment Type POS";
        ReturnPaymentTypePOS: Record "Payment Type POS";
        Register: Record Register;
        EFTInterface: Codeunit "EFT Interface";
        OriginalEftTransactionRequest: Record "EFT Transaction Request";
        Skip: Boolean;
    begin
        SetFinancialImpact(EftTransactionRequest);
        InsertPaymentLine(POSSession, EftTransactionRequest);
        MarkOriginalTransactionAsReversed(EftTransactionRequest);
        Commit; // This commit should handle both the payment line insertion and EFT transaction record result modification in one transaction to prevent synchronization issues.
        EFTInterface.OnAfterFinancialCommit(EftTransactionRequest);
        POSSession.RequestRefreshData();

        if EftTransactionRequest.Successful  then begin
          if not ConfirmEftPayment(EftTransactionRequest) then
            exit; //Don't resume front end straight away as a subscriber indicated the transaction might be annulled now.

          POSSession.AddServerStopwatch('EFT_PAYMENT', EftTransactionRequest.Finished - EftTransactionRequest.Started);
        end;

        EFTInterface.OnBeforeResumeFrontEnd(EftTransactionRequest, Skip);
        if not Skip then
          POSFrontEnd.ResumeWorkflow();
    end;

    local procedure EftLookupResponseReceived(EftTransactionRequest: Record "EFT Transaction Request";POSFrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session")
    var
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        OriginalEftTransactionRequest: Record "EFT Transaction Request";
        EFTInterface: Codeunit "EFT Interface";
        OldRecoveryRequest: Record "EFT Transaction Request";
        AuditRoll: Record "Audit Roll";
        FinancialRecovery: Boolean;
        Skip: Boolean;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        OriginalEftTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");

        with EftTransactionRequest do begin
          case true of
            //Recovery did not fail gracefully
            ((Finished = 0DT) or (not "External Result Received")) :
              Message(CAPTION_RECOVER_FAIL_HARD, "Integration Type", OriginalEftTransactionRequest."Entry No.");

            //Recovery failed correctly.
            (not EftTransactionRequest.Successful) :
              Message(CAPTION_RECOVER_FAIL_SOFT, "Integration Type", OriginalEftTransactionRequest."Entry No.");

            //Recovered transaction is in sync, happy path!
            ((OriginalEftTransactionRequest."Result Amount" = "Result Amount") and
              ((OriginalEftTransactionRequest."Currency Code" = "Currency Code") or ("Result Amount" = 0))) :
              Message(CAPTION_RECOVER_SYNC, "Integration Type", OriginalEftTransactionRequest."Sales Ticket No.", Format(OriginalEftTransactionRequest."Processing Type"), "Result Amount", "Currency Code",
                                            "Reference Number Output");

            //Already recovered previously - stop here
            (OriginalEftTransactionRequest.Recovered) :
              begin
                OldRecoveryRequest.Get(OriginalEftTransactionRequest."Recovered by Entry No.");
                Message(CAPTION_RECOVER_EARLIER, "Integration Type", OldRecoveryRequest."Entry No.", OriginalEftTransactionRequest."Sales Ticket No.", Format(OriginalEftTransactionRequest."Processing Type"),
                                                 OldRecoveryRequest."Result Amount", OldRecoveryRequest."Currency Code", OldRecoveryRequest."Reference Number Output");
              end;

        //-NPR5.53 [349520]
            //Detected programming/integration bug: mismatch in amount even though original was logged as successful.
            (OriginalEftTransactionRequest.Successful and (OriginalEftTransactionRequest."Result Amount" <> 0)):
              begin
                Message(CAPTION_RECOVER_BUG_MISMATCH,
                  "Integration Type",
                  "Result Amount",
                  "Currency Code",
                  OriginalEftTransactionRequest."Sales Ticket No.",
                  Format(OriginalEftTransactionRequest."Processing Type"),
                  OriginalEftTransactionRequest."Result Amount",
                  OriginalEftTransactionRequest."Currency Code",
                  OriginalEftTransactionRequest."Reference Number Output");
              end;
        //+NPR5.53 [349520]

            //Recovered transaction is out of sync and from the currently active sale. We can re-create it, happy path!
            (OriginalEftTransactionRequest."Sales Ticket No." = SalePOS."Sales Ticket No.") :
              begin
                FinancialRecovery := true;
                Message(CAPTION_RECOVER_SAVE, "Integration Type", OriginalEftTransactionRequest."Sales Ticket No.", Format(OriginalEftTransactionRequest."Processing Type"), "Result Amount", "Currency Code",
                                              "Reference Number Output");
              end;

            //Out of sync from previous sale that ended successfully. Salesperson might have used some "hacks" to end it like payment type misuse. We simply warn.
            (OriginalSaleSuccessful(OriginalEftTransactionRequest."Sales Ticket No.")) :
              begin
                SetFinancialImpact(EftTransactionRequest);
                Message(CAPTION_RECOVER_WARN, "Integration Type", OriginalEftTransactionRequest."Sales Ticket No.", AuditRoll.TableCaption, OriginalEftTransactionRequest."Entry No.",
                                              Format(OriginalEftTransactionRequest."Processing Type"), "Result Amount", "Currency Code", "Reference Number Output");
              end;

            else
              //Out of sync from previous sale that never ended. We STRONGLY warn that it should be voided or sale should end.
              begin
                SetFinancialImpact(EftTransactionRequest);
                Message(CAPTION_RECOVER_WARN_STRONG, "Integration Type", OriginalEftTransactionRequest."Sales Ticket No.", OriginalEftTransactionRequest."Entry No.",
                                              Format(OriginalEftTransactionRequest."Processing Type"), "Result Amount", "Currency Code", "Reference Number Output");
              end;
          end;
        end;

        if (EftTransactionRequest.Successful) and (not OriginalEftTransactionRequest.Successful) then
          MarkAsRecovered(OriginalEftTransactionRequest, EftTransactionRequest."Entry No.");

        if FinancialRecovery then begin
          //Ongoing workflow will be resumed later by the response handler
          case OriginalEftTransactionRequest."Processing Type" of
            OriginalEftTransactionRequest."Processing Type"::VOID : EftVoidResponseReceived(EftTransactionRequest, POSFrontEnd, POSSession);

            OriginalEftTransactionRequest."Processing Type"::REFUND,
            OriginalEftTransactionRequest."Processing Type"::PAYMENT : EftPaymentResponseReceived(EftTransactionRequest, POSFrontEnd, POSSession);
          end;
        end else begin
          //-NPR5.48 [341237]
          EFTInterface.OnBeforeResumeFrontEnd(EftTransactionRequest, Skip);
          if not Skip then
          //+NPR5.48 [341237]
            POSFrontEnd.ResumeWorkflow();
        end;
    end;

    local procedure EftVoidResponseReceived(EftTransactionRequest: Record "EFT Transaction Request";POSFrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session")
    var
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        OriginalEftTransactionRequest: Record "EFT Transaction Request";
        EFTInterface: Codeunit "EFT Interface";
        OriginalSalesTicketNo: Text;
        Skip: Boolean;
    begin
        //-NPR5.48 [341237]
        EFTInterface.OnBeforeResumeFrontEnd(EftTransactionRequest, Skip);
        if not Skip then
        //+NPR5.48 [341237]
          POSFrontEnd.ResumeWorkflow();
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

        if not OriginalEftTransactionRequest.Successful then begin
          OriginalSalesTicketNo := OriginalEftTransactionRequest."Sales Ticket No.";
          if OriginalEftTransactionRequest."Recovered by Entry No." <> 0 then
            OriginalEftTransactionRequest.Get(OriginalEftTransactionRequest."Recovered by Entry No.");
          if OriginalSalesTicketNo <> OriginalEftTransactionRequest."Sales Ticket No." then
            exit; //There is only a chance of financial impact from an unsuccessful void if the result was recovered within the same sale it was lost.
        end;

        if not OriginalEftTransactionRequest.Successful then
          exit;
        if not OriginalEftTransactionRequest."External Result Received" then
          exit;
        if OriginalEftTransactionRequest.Finished = 0DT then
          exit;
        if OriginalEftTransactionRequest."Result Amount" = 0 then
          exit;
        if not ((OriginalEftTransactionRequest."Sales Ticket No." = EftTransactionRequest."Sales Ticket No.") or OriginalSaleSuccessful(OriginalEftTransactionRequest."Sales Ticket No."))then
          exit;

        //The transaction that is now void had financial impact that was recorded earlier in NAV. To balance it out, we create a reverse payment line in the active sale.
        InsertPaymentLine(POSSession, EftTransactionRequest);
        Commit;
        EFTInterface.OnAfterFinancialCommit(EftTransactionRequest);
        POSSession.RequestRefreshData();
    end;

    local procedure "--"()
    begin
    end;

    local procedure CreateEftTransactionRequest(EFTSetup: Record "EFT Setup";PaymentTypePOS: Record "Payment Type POS";Amount: Decimal;CurrencyCode: Code[10];SalePOS: Record "Sale POS";var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        EFTIntegration: Codeunit "EFT Framework Mgt.";
        EFTTransactionRequestToRecover: Record "EFT Transaction Request";
    begin
        if PerformRecoveryInstead(SalePOS, EFTSetup."EFT Integration Type", EFTTransactionRequestToRecover) then
          EFTIntegration.CreateLookupTransactionRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", EFTTransactionRequestToRecover."Entry No.")
        else
          if (Amount >= 0) then
            EFTIntegration.CreatePaymentOfGoodsRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", CurrencyCode, Amount)
          else
            EFTIntegration.CreateRefundRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", CurrencyCode, Abs(Amount), 0);
    end;

    local procedure SendRequest(var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        Handled: Boolean;
        EFTIntegration: Codeunit "EFT Framework Mgt.";
    begin
        EFTIntegration.SendRequest(EFTTransactionRequest);
    end;

    local procedure InsertPaymentLine(POSSession: Codeunit "POS Session";var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        POSPaymentLine: Codeunit "POS Payment Line";
        POSLine: Record "Sale Line POS";
    begin
        POSSession.GetPaymentLine (POSPaymentLine);
        POSPaymentLine.GetPaymentLine (POSLine);

        POSLine."No." := EFTTransactionRequest."POS Payment Type Code";
        POSLine."EFT Approved" := EFTTransactionRequest.Successful;
        POSLine.Description := CopyStr (EFTTransactionRequest."POS Description", 1, MaxStrLen (POSLine.Description));
        POSLine.Reference := CopyStr (EFTTransactionRequest."Reference Number Output", 1, MaxStrLen (POSLine.Reference));
        //-NPR5.51 [359229]
        if POSLine."EFT Approved" then begin
        //+NPR5.51 [359229]
          POSLine."Amount Including VAT" := EFTTransactionRequest."Result Amount";
          POSLine."Currency Amount" := POSLine."Amount Including VAT";
        end;

        POSPaymentLine.InsertPaymentLine (POSLine, 0);

        //-NPR5.48 [341237]
        POSPaymentLine.GetCurrentPaymentLine(POSLine);
        EFTTransactionRequest."Sales Line No." := POSLine."Line No.";
        EFTTransactionRequest.Modify;
        //+NPR5.48 [341237]
    end;

    local procedure GetPaymentTypePOS(PaymentTypeCode: Text;RegisterNo: Text;var PaymentTypePOSOut: Record "Payment Type POS")
    begin
        if (PaymentTypePOSOut.Get (PaymentTypeCode, RegisterNo)) then
          exit;
        PaymentTypePOSOut.Get (PaymentTypeCode, '');
    end;

    local procedure PerformRecoveryInstead(SalePOS: Record "Sale POS";IntegrationType: Text;var EFTTransactionRequestToRecover: Record "EFT Transaction Request"): Boolean
    var
        EFTInterface: Codeunit "EFT Interface";
        Skip: Boolean;
    begin
        with EFTTransactionRequestToRecover do begin
          SetRange("Register No.", SalePOS."Register No.");
          SetRange("Integration Type", IntegrationType);
          SetFilter("Processing Type", '%1|%2|%3', "Processing Type"::PAYMENT, "Processing Type"::REFUND, "Processing Type"::VOID);
          if not FindLast then
            exit(false);

          if not Recoverable then
            exit(false);

          if Recovered then
            exit(false);

          if ("External Result Received" and (Finished <> 0DT)) then
            exit(false);

          if "Self Service" then
            exit(false);

          if ("Processing Type" = "Processing Type"::VOID) then
            if "Sales Ticket No." <> SalePOS."Sales Ticket No." then
              exit(false); //We can only hope to recover a successful void result if we are still in the same sale.
        end;

        EFTInterface.OnBeforeLookupPrompt(EFTTransactionRequestToRecover, Skip);
        if Skip then
          exit(false);

        with EFTTransactionRequestToRecover do
          exit(Confirm(CAPTION_RECOVER_PROMPT, true, "Integration Type", "Sales Ticket No.", "Processing Type", "Amount Input", "Currency Code", "Reference Number Output"));
    end;

    local procedure ConfirmEftPayment(EFTTransactionRequest: Record "EFT Transaction Request"): Boolean
    var
        EFTIntegration: Codeunit "EFT Framework Mgt.";
        Annul: Boolean;
    begin
        EFTIntegration.ConfirmAfterPayment(EFTTransactionRequest, Annul);
        exit(not Annul);
    end;

    local procedure OriginalSaleSuccessful(ReceiptNo: Text): Boolean
    var
        AuditRoll: Record "Audit Roll";
    begin
        AuditRoll.SetRange("Sales Ticket No.", ReceiptNo);
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Payment);
        exit(not AuditRoll.IsEmpty);
    end;

    local procedure MarkOriginalTransactionAsReversed(EFTTransactionRequest: Record "EFT Transaction Request")
    var
        OriginalEftTransactionRequest: Record "EFT Transaction Request";
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

    local procedure MarkAsReversed(var EFTTransactionRequest: Record "EFT Transaction Request";ReversedByEntryNo: Integer)
    begin
        if EFTTransactionRequest.Reversed then
          exit;

        EFTTransactionRequest.Reversed := true;
        EFTTransactionRequest."Reversed by Entry No." := ReversedByEntryNo;
        EFTTransactionRequest.Modify;
    end;

    local procedure MarkAsRecovered(var EFTTransactionRequest: Record "EFT Transaction Request";RecoveredByEntryNo: Integer)
    begin
        if EFTTransactionRequest.Recovered then
          exit;

        EFTTransactionRequest.Recovered := true;
        EFTTransactionRequest."Recovered by Entry No." := RecoveredByEntryNo;
        EFTTransactionRequest.Modify;
    end;

    local procedure GetInitialRequest(InitializedByEntryNo: Integer;var EFTTransactionRequestOut: Record "EFT Transaction Request"): Boolean
    begin
        if InitializedByEntryNo = 0 then
          exit(false);
        exit(EFTTransactionRequestOut.Get(InitializedByEntryNo));
    end;

    local procedure SetFinancialImpact(var EftTransactionRequest: Record "EFT Transaction Request")
    begin
        if (not EftTransactionRequest."Financial Impact") then
          if (EftTransactionRequest."Result Amount" <> 0) and (EftTransactionRequest.Successful) then begin
            EftTransactionRequest."Financial Impact" := true;
            EftTransactionRequest.Modify;
          end;
    end;

    local procedure StoreActionState(EFTTransactionRequest: Record "EFT Transaction Request")
    var
        POSSession: Codeunit "POS Session";
    begin
        //-NPR5.50 [354510]
        POSSession.GetSession(POSSession, true);
        POSSession.StoreActionState ('TransactionRequest_EntryNo', EFTTransactionRequest."Entry No.");
        POSSession.StoreActionState ('TransactionRequest_Token', EFTTransactionRequest.Token);
        //+NPR5.50 [354510]
    end;
}

