codeunit 6014666 "NPR Lookup: Customer" implements "NPR IPOSLookupType"
{
    #region NPR IPOSLookup implementation
    procedure InitializeDataRead(var RecRef: RecordRef);
    var
        Rec: Record Customer;
    begin
        Rec.SetLoadFields("No.", Name, "Customer Posting Group");
        RecRef.GetTable(Rec);
    end;

    procedure GetLookupEntry(RecRef: RecordRef) Row: JsonObject;
    var
        Rec: Record Customer;
    begin
        RecRef.SetTable(Rec);
        Row.Add('id', Rec."No.");
        Row.Add('name', Rec.Name);
        Row.Add('post_group', Rec."Customer Posting Group");
    end;
    #endregion
}
