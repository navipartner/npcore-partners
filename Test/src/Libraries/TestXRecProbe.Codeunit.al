codeunit 85519 "NPR Test xRec Probe"
{
    // Manually bound observer of modify events on tables whose NP Retail subscribers once replaced xRec. For a code-driven
    // Modify the platform hands subscribers an xRec that already carries the values being written (it only knows a true
    // before-image for page edits), and Microsoft's workflow rules rely on that. Per table the probe records whether the
    // field under test still reads the same in xRec and Rec, which is false as soon as an earlier subscriber replaces xRec
    // with the row from the database.
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _ModifySeen: Dictionary of [Integer, Boolean];
        _XRecCarriesRecValue: Dictionary of [Integer, Boolean];

    procedure ModifySeen(TableNo: Integer): Boolean
    begin
        exit(_ModifySeen.ContainsKey(TableNo));
    end;

    procedure XRecCarriesRecValue(TableNo: Integer): Boolean
    var
        Carries: Boolean;
    begin
        if not _XRecCarriesRecValue.Get(TableNo, Carries) then
            exit(false);
        exit(Carries);
    end;

    local procedure Record(TableNo: Integer; Carries: Boolean)
    begin
        _ModifySeen.Set(TableNo, true);
        _XRecCarriesRecValue.Set(TableNo, Carries);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterModifyEvent, '', false, false)]
    local procedure RecordCustomerModify(var Rec: Record Customer; var xRec: Record Customer)
    begin
        if not Rec.IsTemporary() then
            Record(Database::Customer, xRec.Name = Rec.Name);
    end;
}
