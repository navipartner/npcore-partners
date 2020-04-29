codeunit 6150645 "POS Cache Warmup"
{
    // NPR5.40/MMV /20180319 CASE 308059 Created object


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
        if Object.FindSet then
          repeat
            LoadTable(Object.ID,true);
          until Object.Next = 0;

        LoadTable(DATABASE::Item,false);
        LoadTable(DATABASE::"Item Variant",true);
        LoadTable(DATABASE::"NP Retail Setup",true);
        LoadTable(DATABASE::"Retail Setup",true);
        LoadTable(DATABASE::Register,true);
        LoadTable(DATABASE::"Audit Roll",true);
        LoadTable(DATABASE::"Sales Line Discount",true);
        LoadTable(DATABASE::"Mixed Discount",true);
        LoadTable(DATABASE::"Mixed Discount Line",true);
        LoadTable(DATABASE::"Period Discount",true);
        LoadTable(DATABASE::"Period Discount Line",true);
        LoadTable(DATABASE::"Quantity Discount Header",true);
        LoadTable(DATABASE::"Quantity Discount Line",true);
        LoadTable(DATABASE::"Dependency Management Setup",true);
    end;

    local procedure LoadTable(TableID: Integer;CalcBlobs: Boolean)
    var
        RecRef: RecordRef;
        BlobFields: Record "Field";
        FieldRef: FieldRef;
    begin
        RecRef.Open(TableID);
        BlobFields.SetRange(TableNo, TableID);
        BlobFields.SetRange(Type, BlobFields.Type::BLOB);

        if RecRef.FindSet then
          repeat
            if CalcBlobs then
              if BlobFields.FindSet then
                repeat
                  FieldRef := RecRef.Field(BlobFields."No.");
                  FieldRef.CalcField;
                until BlobFields.Next = 0;
          until RecRef.Next = 0;
    end;
}

