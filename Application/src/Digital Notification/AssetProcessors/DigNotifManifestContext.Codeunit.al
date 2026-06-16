#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248198 "NPR DigNotif Manifest Context"
{
    Access = Internal;

    var
        _ManifestId: Guid;
        _AssetsAdded: Integer;
        _Setup: Record "NPR Digital Notification Setup";
        _Processed: Dictionary of [Text, Boolean];

    procedure Initialize(ManifestIdParam: Guid; DigitalNotifSetup: Record "NPR Digital Notification Setup")
    begin
        _ManifestId := ManifestIdParam;
        _Setup := DigitalNotifSetup;
        _AssetsAdded := 0;
        Clear(_Processed);
    end;

    procedure ManifestId(): Guid
    begin
        exit(_ManifestId);
    end;

    procedure Setup(): Record "NPR Digital Notification Setup"
    begin
        exit(_Setup);
    end;

    procedure RegisterAsset()
    begin
        _AssetsAdded += 1;
    end;

    procedure AssetsAdded(): Integer
    begin
        exit(_AssetsAdded);
    end;

    // Returns TRUE if this record was already processed (caller skips); otherwise records it and returns FALSE.
    // Keyed on RecordId (table no. + primary key): globally unique, table-scoped, works for any PK shape.
    procedure AlreadyProcessed(RecVariant: Variant): Boolean
    var
        RecRef: RecordRef;
        KeyText: Text;
    begin
        RecRef.GetTable(RecVariant);
        KeyText := Format(RecRef.RecordId());
        if _Processed.ContainsKey(KeyText) then
            exit(true);
        _Processed.Add(KeyText, true);
        exit(false);
    end;
}
#endif
