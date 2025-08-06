table 6151154 "NPR TM TicketRequestMutex"
{
    Access = Internal;
    DataClassification = CustomerContent;

    fields
    {
        field(1; SessionTokenId; Text[100])
        {
            Caption = 'Session Token ID';
            DataClassification = CustomerContent;
        }

        field(10; BusinessCentralSessionId; Integer)
        {
            Caption = 'Business Central Session ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; SessionTokenId)
        {
            Clustered = true;
        }
    }

    internal procedure IsLocked(Token: Text[100]): Boolean
    var
        Mutex: Record "NPR TM TicketRequestMutex";
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        Mutex.ReadIsolation := ReadIsolation::ReadUncommitted;
#endif
        Mutex.SetFilter(SessionTokenId, '%1', Token);
        exit(not (Mutex.IsEmpty()));
    end;

    internal procedure Acquire(Token: Text[100]; BCSessionId: Integer): Boolean
    var
        Mutex: Record "NPR TM TicketRequestMutex";
    begin
        Mutex.SessionTokenId := Token;
        Mutex.BusinessCentralSessionId := BCSessionId;

        exit(Mutex.Insert());
    end;

    internal procedure Release(Token: Text[100]): Boolean
    var
        Mutex: Record "NPR TM TicketRequestMutex";
    begin
        if (not Mutex.Get(Token)) then
            exit(false);

        exit(Mutex.Delete());
    end;

}