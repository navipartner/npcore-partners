codeunit 6060066 "NPR PG Try Capture Payment"
{
    Access = Internal;
    TableNo = "NPR Magento Payment Line";

    var
        _Initialized: Boolean;
        _Request: Record "NPR PG Payment Request";
        _Response: Record "NPR PG Payment Response";
        NotInitializedErr: Label 'Codeunit not initialized. This is a programming error. Contact system vendor.';

    trigger OnRun()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if (not _Initialized) then
            Error(NotInitializedErr);

        PaymentGateway.Get(Rec."Payment Gateway Code");
        if (PaymentGateway."Capture Codeunit Id" <> 0) then begin
            PaymentLine := Rec;
            MagentoPmtMgt.CapturePaymentLineEvents(PaymentLine);
            Rec := PaymentLine;

            if (Rec."Date Captured" <> 0D) then
                _Response."Response Success" := true;

            if (Rec."Charge ID" <> '') then
                _Response."Response Operation Id" := Rec."Charge ID";

            exit;
        end;

        CapturePayment();
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure CapturePayment()
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        IPaymentGateway: Interface "NPR IPaymentGateway";
    begin
        PaymentGateway.Get(_Request."Payment Gateway Code");
        IPaymentGateway := PaymentGateway."Integration Type";
        IPaymentGateway.Capture(_Request, _Response);
    end;

    internal procedure SetParameters(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    begin
        _Request := Request;
        _Response := Response;
        _Initialized := true;
    end;

    internal procedure GetParameters(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    begin
        Request := _Request;
        Response := _Response;
    end;
}