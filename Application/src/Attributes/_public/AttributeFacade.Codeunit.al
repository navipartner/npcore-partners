codeunit 6248732 "NPR Attribute Facade"
{
    // Public facade over the attribute framework for Integer-PK ("Entry No.") records.
    // Dependent apps use this instead of the internal "NPR Attribute Management" Integer-PK
    // procedures and the internal "NPR Attribute Key" table. It also hides the stored
    // "MDR Code PK" formatting convention (Format(EntryNo, 0, '<integer>')) so callers cannot
    // get it wrong.
    Access = Public;

    /// <summary>
    /// Sets a single shortcut-attribute value on an Integer-PK ("Entry No.") record.
    /// Inserts the value on first write and updates it thereafter.
    /// </summary>
    /// <param name="TableID">Object ID of the owning table (e.g. Database::"NPR MM Membership").</param>
    /// <param name="AttributeReference">The per-table "Shortcut Attribute ID" of the attribute,
    /// resolved from "NPR Attribute ID".Get(TableID, AttributeCode).</param>
    /// <param name="EntryNo">The Integer primary key ("Entry No.") of the owning record.</param>
    /// <param name="TextValue">The value to store; on return holds the normalized stored value.</param>
    procedure SetEntryAttributeValue(TableID: Integer; AttributeReference: Integer; EntryNo: Integer; var TextValue: Text[250])
    var
        AttributeMgt: Codeunit "NPR Attribute Management";
    begin
        AttributeMgt.SetEntryAttributeValue(TableID, AttributeReference, EntryNo, TextValue);
    end;

    /// <summary>
    /// Resolves the owning record (table + Integer "Entry No.") for a given Attribute Set ID.
    /// Use this from an "NPR Attribute Value Set" event subscriber to discover which record an
    /// attribute set belongs to. Returns false when the set is unknown or its stored key does not
    /// parse as an Integer. A numeric key stored by a Code-PK table also parses, so this is not a
    /// proof that the owner is an Integer-PK record: validate <paramref name="OwnerTableID"/>
    /// against your own table before using <paramref name="OwnerEntryNo"/>.
    /// </summary>
    /// <param name="AttributeSetID">The "Attribute Set ID" from an "NPR Attribute Value Set" record.</param>
    /// <param name="OwnerTableID">On success, the owning table's object ID. Validate this against your own table.</param>
    /// <param name="OwnerEntryNo">On success, the owning record's Integer primary key.</param>
    /// <returns>True if the set exists and its stored key parses as an Integer; the caller must still validate <paramref name="OwnerTableID"/>.</returns>
    procedure GetEntryAttributeOwner(AttributeSetID: Integer; var OwnerTableID: Integer; var OwnerEntryNo: Integer): Boolean
    var
        AttributeMgt: Codeunit "NPR Attribute Management";
        OwnerPKCode: Code[20];
        ResolvedTableID: Integer;
        ParsedEntryNo: Integer;
    begin
        if not AttributeMgt.GetAttributeKeyOwner(AttributeSetID, ResolvedTableID, OwnerPKCode) then
            exit(false);
        if not Evaluate(ParsedEntryNo, OwnerPKCode) then
            exit(false);
        OwnerTableID := ResolvedTableID;
        OwnerEntryNo := ParsedEntryNo;
        exit(true);
    end;

    /// <summary>
    /// Deletes a single attribute value on an Integer-PK record, mirroring a source-side delete.
    /// Silent no-op when the record has no attribute set or no value for the given code.
    /// </summary>
    /// <param name="TableID">Object ID of the owning table.</param>
    /// <param name="EntryNo">The Integer primary key ("Entry No.") of the owning record.</param>
    /// <param name="AttributeCode">The attribute code to clear.</param>
    procedure ClearEntryAttributeValue(TableID: Integer; EntryNo: Integer; AttributeCode: Code[20])
    var
        AttributeMgt: Codeunit "NPR Attribute Management";
        AttributeValueSet: Record "NPR Attribute Value Set";
        AttributeSetID: Integer;
    begin
        if not AttributeMgt.GetAttributeSetID(Format(EntryNo, 0, '<integer>'), TableID, AttributeSetID) then
            exit;
        if AttributeValueSet.Get(AttributeSetID, AttributeCode) then
            AttributeValueSet.Delete(true);
    end;
}
