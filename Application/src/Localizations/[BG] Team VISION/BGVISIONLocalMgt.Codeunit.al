codeunit 6060088 "NPR BG VISION Local. Mgt."
{
    Access = Internal;
    Permissions = tabledata "VAT Entry" = rmid;

    var
        HasBGVISIONLocalisationSetup: Boolean;

    internal procedure GetLocalisationSetupEnabled(): Boolean
    var
        BGVISIONLocalisationSetup: Record "NPR BG Vision Local. Setup";
    begin
        if not HasBGVISIONLocalisationSetup then
            if not BGVISIONLocalisationSetup.Get() then
                exit(false);

        exit(BGVISIONLocalisationSetup."Enable BG VISION Local");
    end;

    internal procedure ModifySalesProtocolTVB(POSEntry: Record "NPR POS Entry")
    var
        VATEntry: Record "VAT Entry";
        RecRef: RecordRef;
        FieldReference: FieldRef;
    begin
        VATEntry.SetRange("Document No.", POSEntry."Document No.");
        VATEntry.SetRange("Posting Date", POSEntry."Posting Date");
        if not VATEntry.FindSet() then
            exit;
        repeat
            RecRef.Open(Database::"VAT Entry");
            RecRef.Get(VATEntry.RecordId);
            if not RecRef.FieldExist(26006510) then
                exit;
            FieldReference := RecRef.Field(26006510);
            FieldReference.Value(true);
            RecRef.Modify();
            RecRef.Close();
        until VATEntry.Next() = 0;
    end;

    internal procedure GetCustomerIdentificationNoTVB(Customer: Record Customer; var IdentificationNo: Text; var Handled: Boolean)
    var
        RecRef: RecordRef;
        FieldReference: FieldRef;
    begin
        RecRef.Open(Database::Customer);
        RecRef.Get(Customer.RecordId());
        if not RecRef.FieldExist(26006501) then
            exit;
        FieldReference := RecRef.Field(26006501);
        IdentificationNo := FieldReference.Value();
        Handled := true;
        RecRef.Close();
    end;
}
