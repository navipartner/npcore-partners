codeunit 6184929 "NPR Adyen Post Payment Lines"
{
    Access = Internal;
    trigger OnRun()
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        PayByLinkSetup: Record "NPR Pay By Link Setup";
    begin
        if not PayByLinkSetup.Get() then
            exit;
        
        if not PayByLinkSetup."Enable Pay by Link" then
            exit;

        if not PayByLinkSetup."Enable Automatic Posting" then
            exit;

        MagentoPaymentLine.SetRange("Payment Gateway Code", PayByLinkSetup."Payment Gateaway Code");
        MagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
        MagentoPaymentLine.SetRange(Posted, false);
        MagentoPaymentLine.SetFilter(Amount, '<>%1', 0);
        MagentoPaymentLine.SetFilter("Transaction ID", '<>%1', '');
        MagentoPaymentLine.SetFilter("Payment ID", '<>%1', '');
        MagentoPaymentLine.SetRange("Posting Error", false);
        MagentoPaymentLine.SetRange("Skip Posting", false);
        if MagentoPaymentLine.FindSet() then
            repeat
                ProcessPaymentLine(MagentoPaymentLine);
            until MagentoPaymentLine.Next() = 0;
    end;

    [TryFunction]
    procedure TryPostPaymentLine(MagentoPaymentLine: Record "NPR Magento Payment Line");
    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        MagentoPmtAdyenMgt: Codeunit "NPR Magento Pmt. Mgt.";
    begin
        MagentoPmtAdyenMgt.PostPaymentLine(MagentoPaymentLine, GenJnlPostLine);
    end;


    [TryFunction]
    local procedure TryCapturePaymentLine(MagentoPaymentLine: Record "NPR Magento Payment Line");
    var
        MagentoPmtAdyenMgt: Codeunit "NPR Magento Pmt. Mgt.";
    begin
        MagentoPmtAdyenMgt.CapturePaymentLine(MagentoPaymentLine);
    end;

    local procedure UpdateMagentoPaymentLine(var MagentoPaymentLine: Record "NPR Magento Payment Line")
    var
        PayByLinkSetup: Record "NPR Pay By Link Setup";
    begin
        If not PayByLinkSetup.Get(MagentoPaymentLine."Payment Gateway Code") then
            exit;

        MagentoPaymentLine."Try Posting Count" += 1;
        If MagentoPaymentLine."Try Posting Count" >= PayByLinkSetup."Posting Retry Count" then
            MagentoPaymentLine."Posting Error" := true;
        MagentoPaymentLine.Modify();
    end;

    local procedure ProcessPaymentLine(var MagentoPaymentLine: Record "NPR Magento Payment Line")
    var
        MagentoPmtAdyenMgt: Codeunit "NPR Magento Pmt. Mgt.";
        Success: Boolean;
    begin
        ClearLastError();
        Success := TryPostPaymentLine(MagentoPaymentLine);
        MagentoPmtAdyenMgt.InsertPostingLog(MagentoPaymentLine, Success);
        if not Success then
            UpdateMagentoPaymentLine(MagentoPaymentLine);
        Commit();
        if Success then
            TryCapturePaymentLine(MagentoPaymentLine);
    end;

}