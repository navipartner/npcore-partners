codeunit 6059883 "NPR POS Action: EFTGiftCard B."
{
    Access = Internal;

    procedure PrepareGiftCardLoad(POSSale: Codeunit "NPR POS Sale"; Amount: Decimal; PaymentMethod: Code[10]) WorkflowRequest: JsonObject
    var
        EFTSetup: Record "NPR EFT Setup";
        SalePOS: Record "NPR POS Sale";
        POSPaymentMethod: Record "NPR POS Payment Method";
        EFTPaymentMgt: Codeunit "NPR EFT Transaction Mgt.";
        POSSession: Codeunit "NPR POS Session";
        Mechanism: Enum "NPR EFT Request Mechanism";
        EntryNo: Integer;
        IntegrationRequest: JsonObject;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        Workflow: Text;
    begin
        POSSale.GetCurrentSale(SalePOS);
        POSPaymentMethod.Get(PaymentMethod);

        EFTSetup.FindSetup(SalePOS."Register No.", POSPaymentMethod.Code);
        EFTPaymentMgt.GetPOSPostingSetupAccountNo(POSSession, POSPaymentMethod.Code);

        EntryNo := EFTPaymentMgt.PrepareGiftCardLoad(EFTSetup, Amount, '', SalePOS."Register No.", SalePOS."Sales Ticket No.", IntegrationRequest, Mechanism, Workflow);
        EFTTransactionRequest.Get(EntryNo);

        EFTTransactionMgt.SendRequestIfSynchronous(EntryNo, IntegrationRequest, Mechanism);

        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
        if Mechanism = Mechanism::Synchronous then begin
            WorkflowRequest.Add('synchronousRequest', true);
            EFTTransactionRequest.Get(EntryNo);
            WorkflowRequest.Add('synchronousSuccess', EFTTransactionRequest.Successful);
        end;
        exit(WorkflowRequest);
    end;

    procedure InsertVoucherDiscountLine(EftEntryNo: Integer; DiscountPercent: Decimal; Amount: Decimal): Guid
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        LineAmount: Decimal;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Currency: Record Currency;
        POSSession: Codeunit "NPR POS Session";
        DiscountLbl: Label 'Discount';
    begin
        EFTTransactionRequest.Get(EftEntryNo);
        if (not EFTTransactionRequest.Successful) or (EFTTransactionRequest."Result Amount" = 0) or (EFTTransactionRequest."Processing Type" <> EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD) then begin
            Error('');
        end;
        EFTTransactionRequest.TestField(Successful);
        EFTTransactionRequest.TestField("Result Amount");

        if DiscountPercent = 0 then
            exit;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);


        if SaleLinePOS."Currency Code" = '' then begin
            Currency.InitRoundingPrecision();
        end else begin
            Currency.Get(SaleLinePOS."Currency Code");
        end;

        LineAmount := Round((Amount / 100) * (DiscountPercent), Currency."Amount Rounding Precision") * -1;

        SaleLinePOS.Validate("Line Type", SaleLinePOS."Line Type"::"Customer Deposit");
        SaleLinePOS.Validate("No.", EFTTransactionMgt.GetPOSPostingSetupAccountNo(POSSession, EFTTransactionRequest."Original POS Payment Type Code"));
        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS.Description := CopyStr(SaleLinePOS.Description + ' - ' + DiscountLbl, 1, MaxStrLen(SaleLinePOS.Description));
        SaleLinePOS.Validate("Unit Price", LineAmount);
        SaleLinePOS.Validate("Amount Including VAT", LineAmount);
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, true);

        exit(SaleLinePOS.SystemId);
    end;
}