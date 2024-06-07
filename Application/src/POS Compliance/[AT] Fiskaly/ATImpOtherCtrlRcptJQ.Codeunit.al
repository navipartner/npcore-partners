codeunit 6184911 "NPR AT Imp Other Ctrl Rcpt JQ"
{
    Access = Internal;

    trigger OnRun()
    var
        ATCashRegister: Record "NPR AT Cash Register";
        ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
    begin
        ATCashRegister.SetFilter("AT SCU Code", '<>%1', '');
        ATCashRegister.SetFilter(State, '<>%1&<>%2', ATCashRegister.State::DECOMMISSIONED, ATCashRegister.State::DEFECTIVE);
        if ATCashRegister.IsEmpty() then
            exit;

        ATCashRegister.FindSet();

        repeat
            ATFiskalyCommunication.ListCashRegisterReceipts(ATCashRegister, Enum::"NPR AT Audit Entry Type"::"Control Transaction", ATFiskalyCommunication.GetListOtherCashRegisterControlReceiptsQueryParameters());
        until ATCashRegister.Next() = 0;
    end;
}