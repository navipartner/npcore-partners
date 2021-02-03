codeunit 6150645 "NPR POS Cache Warmup"
{
    trigger OnRun()
    begin
        WarmupCache();
    end;

    procedure WarmupCache()
    var
        "Object": Record "Object";
    begin
        Object.SetRange(Type, Object.Type::Table);
        Object.SetFilter(Name, '*POS*');
        Object.SetFilter("Version List", '*NPR*');
        if Object.FindSet() then
            repeat
                LoadTable(Object.ID, true);
            until Object.Next() = 0;

        LoadTable(DATABASE::Item, false);
        LoadTable(DATABASE::"Item Variant", true);
        LoadTable(DATABASE::"NPR NP Retail Setup", true);
        LoadTable(DATABASE::"NPR Retail Setup", true);
        LoadTable(DATABASE::"NPR Register", true);
        LoadTable(DATABASE::"NPR Audit Roll", true);
        LoadTable(DATABASE::"Sales Line Discount", true);
        LoadTable(DATABASE::"NPR Mixed Discount", true);
        LoadTable(DATABASE::"NPR Mixed Discount Line", true);
        LoadTable(DATABASE::"NPR Period Discount", true);
        LoadTable(DATABASE::"NPR Period Discount Line", true);
        LoadTable(DATABASE::"NPR Quantity Discount Header", true);
        LoadTable(DATABASE::"NPR Quantity Discount Line", true);
        LoadTable(DATABASE::"NPR Dependency Mgt. Setup", true);
    end;

    local procedure LoadTable(TableID: Integer; CalcBlobs: Boolean)
    var
        BlobFields: Record "Field";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.Open(TableID);
        BlobFields.SetRange(TableNo, TableID);
        BlobFields.SetRange(Type, BlobFields.Type::BLOB);

        if RecRef.FindSet() then
            repeat
                if CalcBlobs then
                    if BlobFields.FindSet() then
                        repeat
                            FieldRef := RecRef.Field(BlobFields."No.");
                            FieldRef.CalcField();
                        until BlobFields.Next() = 0;
            until RecRef.Next() = 0;
    end;
}

