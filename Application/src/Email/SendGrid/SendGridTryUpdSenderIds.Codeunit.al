#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248276 "NPR SendGrid Try Upd SenderIds"
{
    Access = Internal;

    trigger OnRun()
    var
        Client: Codeunit "NPR SendGrid Client";
    begin
        Client.UpdateLocalSenderIdentities();
    end;
}
#endif