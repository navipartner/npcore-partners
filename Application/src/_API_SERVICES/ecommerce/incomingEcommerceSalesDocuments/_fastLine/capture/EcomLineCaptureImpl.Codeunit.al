#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248647 "NPR EcomLineCaptureImpl"
{
    Access = Internal;

    internal procedure Process(var PaymentLine: Record "NPR Magento Payment Line")
    begin
        case PaymentLine."Payment Type" of
            PaymentLine."Payment Type"::"Payment Method":
                CapturePaymentLine(PaymentLine);
            PaymentLine."Payment Type"::Voucher:
                CaptureVoucherLine(PaymentLine);
        end;
    end;

    local procedure CapturePaymentLine(var PaymentLine: Record "NPR Magento Payment Line")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        PaymentEventType: Option " ",Capture,Refund,Cancel;
    begin
        //lock records
        PaymentLine.ReadIsolation := PaymentLine.ReadIsolation::UpdLock;
        PaymentLine.Get(PaymentLine.RecordId);

        EcomSalesHeader.GetBySystemId(PaymentLine."NPR Inc Ecom Sale Id");

        Clear(MagentoPmtMgt);
        case
            EcomSalesHeader."Document Type" of
            EcomSalesHeader."Document Type"::Order:
                PaymentEventType := PaymentEventType::Capture;
            EcomSalesHeader."Document Type"::"Return Order":
                PaymentEventType := PaymentEventType::Refund;
        end;
        MagentoPmtMgt.SetProcessingOptions(PaymentEventType);
        MagentoPmtMgt.Run(PaymentLine);

        //Refresh records and lock
        PaymentLine.ReadIsolation := PaymentLine.ReadIsolation::UpdLock;
        PaymentLine.Get(PaymentLine.RecordId);
    end;

    local procedure CaptureVoucherLine(var PaymentLine: Record "NPR Magento Payment Line")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        VoucherSalesLineNotFoundErr: Label 'Voucher sales line not found for ecom sale %1 and reference %2. This is a programming bug.', Comment = '%1 - ecom sale id, %2 - voucher reference';
    begin
        //lock records
        PaymentLine.ReadIsolation := PaymentLine.ReadIsolation::UpdLock;
        PaymentLine.Get(PaymentLine.RecordId);

        if PaymentLine."Date Captured" <> 0D then
            exit;

        NpRvSalesLine.Reset();
        NpRvSalesLine.SetRange("NPR Inc Ecom Sale Id", PaymentLine."NPR Inc Ecom Sale Id");
        NpRvSalesLine.SetRange("Reference No.", PaymentLine."No.");
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        if not NpRvSalesLine.FindFirst() then
            Error(VoucherSalesLineNotFoundErr, PaymentLine."NPR Inc Ecom Sale Id", PaymentLine."No.");

        if NpRvVoucherMgt.PostIncEcomPayment(NpRvSalesLine, PaymentLine) then begin
            PaymentLine."Date Captured" := Today;
            PaymentLine.Modify(true);
        end;
    end;
}
#endif
