codeunit 6184929 "NPR Adyen Post Payment Lines"
{
    Access = Internal;
    trigger OnRun()
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        AdyenSetup: Record "NPR Adyen Setup";
    begin
        if not AdyenSetup.Get() then
            exit;

        if not AdyenSetup."Enable Pay by Link" then
            exit;

        if not AdyenSetup."PayByLink Enable Auto Posting" then
            exit;

        MagentoPaymentLine.SetRange("Payment Gateway Code", AdyenSetup."Pay By Link Gateaway Code");
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

    local procedure UpdateMagentoPaymentLine(var MagentoPaymentLine: Record "NPR Magento Payment Line")
    var
        AdyenSetup: Record "NPR Adyen Setup";
    begin
        If not AdyenSetup.Get() then
            exit;

        MagentoPaymentLine."Try Posting Count" += 1;
        If MagentoPaymentLine."Try Posting Count" >= AdyenSetup."PayByLink Posting Retry Count" then
            MagentoPaymentLine."Posting Error" := true;
        MagentoPaymentLine.Modify();
    end;

    local procedure ProcessPaymentLine(var MagentoPaymentLine: Record "NPR Magento Payment Line")
    var
        MagentoPmtAdyenMgt: Codeunit "NPR Magento Pmt. Mgt.";
        PostPaymentLine: Codeunit "NPR Magento Post Payment Line";
        Success: Boolean;
    begin
        ClearLastError();
        Success := PostPaymentLine.Run(MagentoPaymentLine);
        MagentoPmtAdyenMgt.InsertPostingLog(MagentoPaymentLine, Success);
        if not Success then
            UpdateMagentoPaymentLine(MagentoPaymentLine);
        Commit();
        if Success then
            MagentoPmtAdyenMgt.CapturePaymentLine(MagentoPaymentLine);
    end;
}