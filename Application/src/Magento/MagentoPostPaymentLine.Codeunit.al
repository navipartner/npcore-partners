codeunit 6248374 "NPR Magento Post Payment Line"
{
    Access = Internal;
    TableNo = "NPR Magento Payment Line";

    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";

    trigger OnRun()
    begin
        MagentoPmtMgt.PostPaymentLine(Rec, GenJnlPostLine);
    end;
}