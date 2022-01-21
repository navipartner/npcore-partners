codeunit 6059774 "NPR Rep. WS Functions"
{

    Access = Internal;
    procedure GetLastReplicationCounter(tableId: Integer): BigInteger
    var
        RecRef: RecordRef;
        FRef: FieldRef;
        DataTypeMgmt: Codeunit "Data Type Management";
        ReplicationKeyIndex: Integer;
    begin
        RecRef.Open(tableId); //open RecordRef using table id.
        if not DataTypeMgmt.FindFieldByName(RecRef, FRef, 'NPR Replication Counter') then
            if not DataTypeMgmt.FindFieldByName(RecRef, FRef, 'Replication Counter') then
                Error('Replication Counter field not found.');

        ReplicationKeyIndex := GetReplicationCounterKeyIndex(RecRef, FRef);
        IF ReplicationKeyIndex <= 1 then
            Error(MissingKeyReplicationCounterErr, RecRef.Name, FRef.Name);

        RecRef.CurrentKeyIndex(ReplicationKeyIndex);
        RecRef.FindLast();
        Exit(RecRef.Field(FRef.Number).Value);
    end;

    local procedure GetReplicationCounterKeyIndex(RecRef: RecordRef; RepCounterFieldRef: FieldRef): Integer
    var
        i: Integer;
        KRef: KeyRef;
        FRef: FieldRef;
    begin
        For i := 1 to RecRef.KeyCount do begin
            KRef := RecRef.KeyIndex(i);
            IF KRef.Active then
                IF KRef.FieldCount = 1 then begin //we are looking for the key with only one field --> Replication Counter
                    FRef := KRef.FieldIndex(1);
                    IF FRef.Name = RepCounterFieldRef.Name then
                        exit(i);
                end;
        end;
    end;

    var
        MissingKeyReplicationCounterErr: Label 'Secondary Key for table ''%1'' on field ''%2'' is missing. This is a programming error.';
}
