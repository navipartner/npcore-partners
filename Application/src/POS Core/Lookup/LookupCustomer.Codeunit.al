codeunit 6014666 "NPR Lookup: Customer" implements "NPR IPOSLookupType"
{
    Access = Internal;
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

    procedure IsMatchForSearch(RecRef: RecordRef; SearchFilter: Text): Boolean;
    var
        Rec: Record Customer;
        No: Text;
        PostGroup: Text;
    begin
        RecRef.SetTable(Rec);

        if (Rec.Name.ToLower().Contains(SearchFilter)) then
            exit(true);

        No := Rec."No.";
        if (No.ToLower().Contains(SearchFilter)) then
            exit(true);

        PostGroup := Rec."Customer Posting Group";
        if (PostGroup.ToLower().Contains(SearchFilter)) then
            exit(true);

        exit(false);
    end;
    #endregion
}
