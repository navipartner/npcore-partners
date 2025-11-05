#if not (BC17 or BC18 or BC19 or BC20)
table 6151263 "NPR Spfy Export Pointer Buffer"
{
    Access = Internal;
    Caption = 'Shopify Data Export Pointer Buffer';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Shopify Store Code"; Code[20])
        {
            Caption = 'Shopify Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Spfy Store".Code;
        }
        field(10; "Cut-Off Date"; Date)
        {
            Caption = 'Cut-Off Date';
            DataClassification = CustomerContent;
        }
        field(20; "Cut-Off POS Entry Row Version"; BigInteger)
        {
            Caption = 'Cut-Off POS Entry Row Version';
            DataClassification = CustomerContent;
        }
        field(30; "New Last POS Entry Row Version"; BigInteger)
        {
            Caption = 'New Last POS Entry Row Version';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Shopify Store Code")
        {
            Clustered = true;
        }
    }

    internal procedure Add(ShopifyStoreCode: Code[20]; CutOffDate: Date; LastPOSEntryRowVersion: BigInteger)
    begin
        "Shopify Store Code" := ShopifyStoreCode;
        if not Find() then begin
            Init();
            Insert();
        end;
        "Cut-Off Date" := CutOffDate;
        "Cut-Off POS Entry Row Version" := LastPOSEntryRowVersion;
        Modify();
    end;

    internal procedure GetSpfyStoreFilter() SpfyStoreFilter: Text
    begin
        SpfyStoreFilter := '';
        if not FindSet() then
            exit;
        repeat
            if SpfyStoreFilter <> '' then
                SpfyStoreFilter += '|';
            SpfyStoreFilter += "Shopify Store Code";
        until Next() = 0;
    end;

    internal procedure GetMinLastPOSEntryRowVersion(): BigInteger
    var
        MinRowVersion: BigInteger;
    begin
        if not FindSet() then
            exit(0);
        MinRowVersion := -1;
        repeat
            if (MinRowVersion = -1) or ("Cut-Off POS Entry Row Version" < MinRowVersion) then
                MinRowVersion := "Cut-Off POS Entry Row Version";
        until Next() = 0;
        if MinRowVersion = -1 then
            exit(0);
        exit(MinRowVersion);
    end;

    internal procedure CheckIfScopeIsNotEmpty()
    var
        SpfyIntegrationNotEnabledErr: Label 'Sending POS customer purchases is not enabled for any of your selected Shopify stores.';
    begin
        if IsEmpty() then
            Error(SpfyIntegrationNotEnabledErr);
    end;
}
#endif