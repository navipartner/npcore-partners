codeunit 6184900 "Temp Blob Management"
{
    procedure ToRecord(var SourceTempBlob: Codeunit "Temp Blob"; var RecordVariant: Variant; FieldNo: Integer)
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        RecRef.GetTable(RecordVariant);
        FldRef := RecRef.Field(FieldNo);
        SourceTempBlob.ToFieldRef(FldRef);
    end;
}