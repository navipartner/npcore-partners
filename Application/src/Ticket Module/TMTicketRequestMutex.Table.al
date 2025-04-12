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
    internal procedure Acquire(Token: Text[100]; BCSessionId: Integer): Boolean
    var
        Mutex: Record "NPR TM TicketRequestMutex";
    begin
        Mutex.SessionTokenId := Token;
        Mutex.BusinessCentralSessionId := BCSessionId;

        exit(Mutex.Insert());
    end;

}