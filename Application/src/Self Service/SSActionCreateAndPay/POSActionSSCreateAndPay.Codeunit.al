codeunit 6151443 "NPR POSAction SS CreateAndPay" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        _ExistingSale: Option None,Same,Partial;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This action allows you to create a POS sale and fully pay it via terminal';
        ParamSaleIdentifierTitle: Label 'Sale Identifier';
        ParamSaleIdentifierDesc: Label 'The identifier of the sale to be created';
        SaleContentTitle: Label 'Sale Contents';
        SaleCOntentDesc: Label 'The contents of the sale to be created';
        PaymentTypeTitle: Label 'Payment Type';
        PaymentTypeDesc: Label 'The payment type to pay with';
        CouponTitle: Label 'Coupons';
        CouponDesc: Label 'Coupons to apply to the sale';
        VoucherTitle: Label 'Vouchers';
        VoucherDesc: Label 'Vouchers to apply to the sale';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.SetWorkflowTypeUnattended();
        WorkflowConfig.AddTextParameter('saleSystemId', '', ParamSaleIdentifierTitle, ParamSaleIdentifierDesc);
        WorkflowConfig.AddTextParameter('saleContents', '', SaleContentTitle, SaleContentDesc);
        WorkflowConfig.AddTextParameter('paymentType', '', PaymentTypeTitle, PaymentTypeDesc);
        WorkflowConfig.AddTextParameter('coupons', '', CouponTitle, CouponDesc);
        WorkflowConfig.AddTextParameter('vouchers', '', VoucherTitle, VoucherDesc);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
    begin
        case Step of
            'createAndPreparePayment':
                FrontEnd.WorkflowResponse(CreateAndPreparePayment(Context, Sale, SaleLine, PaymentLine));
        end;
    end;

    procedure CreateAndPreparePayment(Context: codeunit "NPR POS JSON Helper"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"): JsonObject
    var
        SaleContents: JsonObject;
        SaleSystemId: Guid;
        TicketToken: Text;
        JToken: JsonToken;
        ExistingSale: Integer;
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        TMTicketRetailMgt: Codeunit "NPR TM Ticket Retail Mgt.";
        POSSaleRec: Record "NPR POS Sale";
        Coupons: JsonArray;
        Vouchers: JsonArray;
    begin

        if (not Evaluate(SaleSystemId, Context.GetStringParameter('saleSystemId'))) then
            Clear(SaleSystemId);

        if (SaleContents.ReadFrom(Context.GetStringParameter('saleContents'))) then begin
            SaleContents.Get('ticketToken', JToken);
            TicketToken := JToken.AsValue().AsText();

            if (SaleContents.Get('coupons', JToken)) then
                if (JToken.IsArray()) then
                    Coupons := JToken.AsArray();

            if (SaleContents.Get('vouchers', JToken)) then
                if (JToken.IsArray()) then
                    Vouchers := JToken.AsArray();
        end;

        ExistingSale := CheckForExistingSale(SaleSystemId, TicketToken);

        case ExistingSale of
            _ExistingSale::Same:
                begin
                    //try end sale again with payment (skips actual payment if 0 remaining)
                    exit(GetPaymentWorkflow(Context));
                end;

            _ExistingSale::Partial:
                begin
                    // When there are sales lines and payment lines with unmatched amount, we are in trouble
                    Commit();

                    // Sale needs to be handled by a human
                    // This should cause a client lock-down and when SS client is restarted, the sale is resumed and moved to parked sales
                    Error('This sale needs to be handled by help desk.');
                end;
        end;

        // Order is resent could have been edited
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(POSSaleRec);
        TMTicketRetailMgt.CreatePOSLinesForReservationRequest(TicketToken, POSSaleRec);

        ApplySelfServiceCoupons(POSSale, SaleLine, Coupons);
        ApplySelfServiceVouchers(POSSale, SaleLine, PaymentLine, Vouchers);

        exit(GetPaymentWorkflow(Context));
    end;

    local procedure ApplySelfServiceCoupons(Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; Coupons: JsonArray)
    var
        CouponHandler: Codeunit "NPR POS Action: Scan Coupon B";
        RequireSerialNo: Boolean;
        ReferenceNo: Text[50];
        CouponToken, CouponsToken : JsonToken;
        ReservedCoupon: Record "NPR NpDc Ext. Coupon Reserv.";
    begin
        foreach CouponsToken in Coupons do begin
            ReferenceNo := '';
            if (CouponsToken.IsObject()) then
                if (CouponsToken.AsObject().Get('referenceNo', CouponToken)) then
                    ReferenceNo := CopyStr(CouponToken.AsValue().AsText(), 1, MaxStrLen(ReferenceNo));

            if (CouponsToken.IsValue()) then
                ReferenceNo := CopyStr(CouponsToken.AsValue().AsText(), 1, MaxStrLen(ReferenceNo));

            if (ReferenceNo <> '') then begin
                ReservedCoupon.SetFilter("Reference No.", '=%1', ReferenceNo);
                if (ReservedCoupon.FindFirst()) then
                    ReservedCoupon.Delete();

                CouponHandler.ScanCoupon(ReferenceNo, Sale, SaleLine, RequireSerialNo);
            end;
        end;
    end;

    local procedure ApplySelfServiceVouchers(Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Vouchers: JsonArray)
    var
        VoucherToken, VouchersToken : JsonToken;
        VoucherHandler2: Codeunit "NPR POS Action Scan Voucher2B";
        Voucher: Record "NPR NpRv Voucher";
        VoucherReservation: Record "NPR NpRv Sales Line";
        ReferenceNo: Text[50];
        ActionContext: JsonObject;
        SaleAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        AmountToRedeem: Decimal;
    begin
        foreach VouchersToken in Vouchers do begin
            ReferenceNo := '';
            if (VouchersToken.IsObject()) then
                if (VouchersToken.AsObject().Get('referenceNo', VoucherToken)) then
                    ReferenceNo := CopyStr(VoucherToken.AsValue().AsText(), 1, MaxStrLen(ReferenceNo));

            if (VouchersToken.IsValue()) then
                ReferenceNo := CopyStr(VouchersToken.AsValue().AsText(), 1, MaxStrLen(ReferenceNo));

            if (ReferenceNo <> '') then begin
                Voucher.SetAutoCalcFields(Amount);
                Voucher.SetFilter("Reference No.", '=%1', ReferenceNo);
                Voucher.FindFirst(); // Blow up if voucher does not exist

                VoucherReservation.SetFilter("Reference No.", '=%1', ReferenceNo);
                VoucherReservation.SetFilter(Type, '=%1', VoucherReservation.Type::Payment);
                if (VoucherReservation.FindSet()) then begin
                    repeat
                        VoucherReservation.Delete();
                    until (VoucherReservation.Next() = 0);
                end;

                // Redeem amount selection is greedy, it will redeem as much as possible
                PaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, AmountToRedeem);
                if (AmountToRedeem > Voucher.Amount) then
                    AmountToRedeem := Voucher.Amount;

                VoucherHandler2.ProcessPayment(
                        Voucher."Voucher Type",
                        ReferenceNo,
                        AmountToRedeem,
                        Sale,
                        PaymentLine,
                        SaleLine,
                        false,
                        ActionContext);
            end;
        end;
    end;


    local procedure CheckForExistingSale(SaleSystemId: Guid; TicketToken: Text): Integer
    var
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSaleRec: Record "NPR POS Sale";
        TMTicketRetailMgt: Codeunit "NPR TM Ticket Retail Mgt.";
        SaleAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        Subtotal: Decimal;
    begin

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSession.GetPaymentLine(POSPaymentLine);
        POSSale.GetCurrentSale(POSSaleRec);

        if POSSaleRec."Sales Ticket No." = '' then
            Error('Required workflow SS_INIT_SALE did not create a sale. This is a programming error.'); // Will cause front-end to lock-down

        if (not IsNullGuid(SaleSystemId)) then
            if (POSSaleRec.SystemId <> SaleSystemId) then
                Error('Backend and frontend disagree on which sale is current sale. This is a programming error.'); // Will cause front-end to lock-down

        if (POSSaleLine.IsEmpty() and POSPaymentLine.IsEmpty()) then
            exit(_ExistingSale::None); // Apply incoming request

        if (POSPaymentLine.IsEmpty()) then begin
            POSSaleLine.DeleteAll();
            exit(_ExistingSale::None); // Reapply incoming request
        end;

        // There are payments lines
        POSPaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);
        if (PaidAmount = 0) then begin
            POSSaleLine.DeleteAll(); // Previous payment was declined and order was edited
            exit(_ExistingSale::None); // Reapply incoming request
        end;

        // There is some paid amount, apply pending changes, delete pos sales lines and apply incoming request
        POSSaleLine.DeleteAll();
        TMTicketRetailMgt.CreatePOSLinesForReservationRequest(TicketToken, POSSaleRec); // Reapply incoming request
        POSPaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);
        if (SaleAmount = PaidAmount) then
            exit(_ExistingSale::Same);

        // Worst case, go to lock-down sales amount and paid amount are different
        exit(_ExistingSale::Partial);
    end;

    local procedure GetPaymentWorkflow(JSON: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        workflowParameters: JsonObject;
        paymentType: Text;
        EFTSetup: Record "NPR EFT Setup";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSetup(POSSetup);
        paymentType := JSON.GetStringParameter('paymentType');
        if paymentType = '' then begin
            EFTSetup.SetRange("POS Unit No.", POSSetup.GetPOSUnitNo());
            EFTSetup.FindFirst();
            paymentType := EFTSetup."Payment Type POS";
        end;
        workflowParameters.Add('PaymentType', paymentType);

        Response.Add('paymentWorkflow', Format(Enum::"NPR POS Workflow"::"SS-PAYMENT"));
        Response.Add('paymentWorkflowParameters', workflowParameters)
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSSCreateAndPay.js###
'let main=async({parameters:a})=>{let{paymentWorkflow:r,paymentWorkflowParameters:t}=await workflow.respond("createAndPreparePayment",a.SaleContents),e=await workflow.run(r,{parameters:t});if(!e.success)throw console.info("[SS Create And Pay] payment result: "+e.success),new Error("DECLINED")};'
        )
    end;
}
