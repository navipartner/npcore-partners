codeunit 6248270 "NPR Resume Sale Mgt Events"
{
    [IntegrationEvent(true, false)]
    internal procedure OnBeforePromptResumeSale(var SalePOS: Record "NPR POS Sale"; POSSession: Codeunit "NPR POS Session"; var SkipDialog: Boolean; var ActionOption: Option " ",Resume,CancelAndNew,SaveAsQuote; var ActionOnCancelError: Option " ",Resume,SaveAsQuote,ShowError; var Handled: Boolean)
    begin
    end;
}
