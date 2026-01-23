report 6014436 "NPR Update Retention Policy"
{
    Caption = 'Update Retention Policy';
    UsageCategory = None;
    ProcessingOnly = true;
    UseRequestPage = false;
#if not BC17
    Extensible = false;
#endif

#if (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
    Permissions =
        tabledata "Retention Period" = rim,
        tabledata "Retention Policy Setup" = rimd,
        tabledata "NPR Data Log Field" = rd,
        tabledata "NPR Tax Free Voucher" = rd,
        tabledata "NPR POS Saved Sale Entry" = rd,
        tabledata "NPR POS Saved Sale Line" = rd,
        tabledata "NPR NpCs Arch. Document" = rd,
        tabledata "NPR Nc Task" = rd,
        tabledata "NPR Exchange Label" = rd,
        tabledata "NPR NpGp POS Sales Entry" = rd,
        tabledata "NPR POS Entry Output Log" = rd,
        tabledata "NPR Nc Import Entry" = rd,
        tabledata "NPR POS Period Register" = rd,
        tabledata "NPR POS Entry" = rd,
        tabledata "NPR POS Entry Sales Line" = rd,
        tabledata "NPR POS Entry Payment Line" = rd,
        tabledata "NPR POS Balancing Line" = rd,
        tabledata "NPR POS Entry Tax Line" = rd,
        tabledata "NPR POS Posting Log" = rd,
        tabledata "NPR EFT Transaction Request" = rd,
        tabledata "NPR Aux. Value Entry" = rd,
        tabledata "NPR Aux. Item Ledger Entry" = rd,
        tabledata "NPR Replication Error Log" = rd,
        tabledata "NPR BTF EndPoint Error Log" = rd;
#endif

    trigger OnPreReport()
    var
        ConfirmUpdateLbl: Label 'System will update Retention Policy with NPCore defined tables. Continue?';
        UpdateFinishedLbl: Label 'Update is finished.';
        RetenPolInstall: Codeunit "NPR Reten. Pol. Install";
    begin
        if not Confirm(ConfirmUpdateLbl, false) then
            exit;

        RetenPolInstall.AddAllowedTables(false);

        Message(UpdateFinishedLbl);
    end;
}