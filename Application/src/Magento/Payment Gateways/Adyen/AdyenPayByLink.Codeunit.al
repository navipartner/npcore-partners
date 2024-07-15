codeunit 6184956 "NPR Adyen Pay By Link" implements "NPR Pay by Link"
{
    Access = Internal;
    procedure SetDocument(RecVariant: Variant)
    begin
        _RecVariant := RecVariant;
    end;

    procedure SetShowDialog()
    begin
        _ShowDialog := true;
    end;

    procedure IssuePayByLink()
    begin
        MagentoPmtAdyenMgt.IssuePayByLink(_RecVariant, _ShowDialog);
    end;

    procedure CancelPayByLink(var PaymentLine: Record "NPR Magento Payment Line")
    begin
        MagentoPmtAdyenMgt.CancelAdyenPayByLink(PaymentLine);
    end;

    var
        _ShowDialog: Boolean;
        _RecVariant: Variant;
        MagentoPmtAdyenMgt: Codeunit "NPR Magento Pmt. Adyen Mgt.";

}