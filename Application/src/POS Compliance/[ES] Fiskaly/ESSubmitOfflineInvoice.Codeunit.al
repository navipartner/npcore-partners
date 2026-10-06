codeunit 6151298 "NPR ES Submit Offline Invoice"
{
    Access = Internal;
    TableNo = "NPR ES POS Audit Log Aux. Info";

    var
        _ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";

    trigger OnRun()
    begin
        _ESFiskalyCommunication.SetLimitedRequestTimeout();
        _ESFiskalyCommunication.SubmitOfflineInvoice(Rec);
    end;

    internal procedure IsLastFailureTransient(): Boolean
    begin
        exit(_ESFiskalyCommunication.IsLastSubmissionFailureTransient());
    end;
}
