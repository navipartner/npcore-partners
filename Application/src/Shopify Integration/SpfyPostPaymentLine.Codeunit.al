#if not BC17
codeunit 6248338 "NPR Spfy Post Payment Line"
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
#endif