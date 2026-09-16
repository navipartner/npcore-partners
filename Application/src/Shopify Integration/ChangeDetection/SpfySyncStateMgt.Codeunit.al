codeunit 6151227 "NPR Spfy Sync State Mgt"
{
    Access = Internal;

    procedure PayloadVersion(): Integer
    begin
        exit(1);
    end;

    procedure GetBaseline(TableNo: Integer; EntitySystemId: Guid; StoreCode: Code[20]; var Baseline: JsonObject)
    var
        SyncState: Record "NPR Spfy Sync State";
        TypeHelper: Codeunit "Type Helper";
        InStr: InStream;
        ParametersText: Text;
    begin
        Clear(Baseline);
        if not SyncState.Get(TableNo, EntitySystemId, StoreCode) then
            exit;
        if SyncState."Payload Version" <> PayloadVersion() then
            exit;
        SyncState.CalcFields(Parameters);
        if not SyncState.Parameters.HasValue() then
            exit;
        SyncState.Parameters.CreateInStream(InStr, TextEncoding::UTF8);
        ParametersText := TypeHelper.ReadAsTextWithSeparator(InStr, TypeHelper.LFSeparator());
        if ParametersText <> '' then
            Baseline.ReadFrom(ParametersText);
    end;

    procedure Facet(var Baseline: JsonObject; FacetKey: Text): Text
    var
        Token: JsonToken;
    begin
        if Baseline.Get(FacetKey, Token) then
            if Token.IsValue() and not Token.AsValue().IsNull() then
                exit(Token.AsValue().AsText());
        exit('');
    end;

    procedure SetFacet(var Baseline: JsonObject; FacetKey: Text; Value: Text)
    begin
        if Baseline.Contains(FacetKey) then
            Baseline.Remove(FacetKey);
        Baseline.Add(FacetKey, Value);
    end;

    procedure FacetAsDecimal(var Baseline: JsonObject; FacetKey: Text): Decimal
    var
        Value: Decimal;
        ValueText: Text;
    begin
        ValueText := Facet(Baseline, FacetKey);
        if (ValueText = '') or not Evaluate(Value, ValueText, 9) then
            exit(0);
        exit(Value);
    end;

    procedure SetFacetDecimal(var Baseline: JsonObject; FacetKey: Text; Value: Decimal)
    begin
        SetFacet(Baseline, FacetKey, Format(Value, 0, 9));
    end;

    procedure GetItemCostKey(): Text
    begin
        exit('itemCost');
    end;

    procedure GetItemCategoryCodeKey(): Text
    begin
        exit('itemCategoryCode');
    end;

    procedure GetItemVariantHashKey(): Text
    begin
        exit('itemVariantHash');
    end;

    procedure GetStoreItemLinkHashKey(): Text
    begin
        exit('storeItemLinkHash');
    end;

    procedure GetStoreCustomerLinkHashKey(): Text
    begin
        exit('storeCustomerLinkHash');
    end;

    procedure GetItemVariantModifHashKey(): Text
    begin
        exit('itemVariantModifHash');
    end;

    procedure GetEntityMetafieldHashKey(): Text
    begin
        exit('entityMetafieldHash');
    end;

    procedure GetVoucherEndingDateKey(): Text
    begin
        exit('voucherEndingDate');
    end;

    procedure GetSalesLineItemNoKey(): Text
    begin
        exit('salesLineItemNo');
    end;

    procedure GetSalesLineVariantCodeKey(): Text
    begin
        exit('salesLineVariantCode');
    end;

    procedure GetSalesLineLocationCodeKey(): Text
    begin
        exit('salesLineLocationCode');
    end;

    procedure GetSalesLineQtyKey(): Text
    begin
        exit('salesLineQty');
    end;

    procedure GetTransferLineItemNoKey(): Text
    begin
        exit('transferLineItemNo');
    end;

    procedure GetTransferLineVariantCodeKey(): Text
    begin
        exit('transferLineVariantCode');
    end;

    procedure GetTransferLineFromCodeKey(): Text
    begin
        exit('transferLineFromCode');
    end;

    procedure GetTransferLineToCodeKey(): Text
    begin
        exit('transferLineToCode');
    end;

    procedure GetTransferLineQtyKey(): Text
    begin
        exit('transferLineQty');
    end;

    procedure GetTransferLineQtyInTransitKey(): Text
    begin
        exit('transferLineQtyInTransit');
    end;

    procedure GetSkuSafetyStockKey(): Text
    begin
        exit('skuSafetyStock');
    end;

    procedure GetSkuItemNoKey(): Text
    begin
        exit('skuItemNo');
    end;

    procedure GetSkuVariantCodeKey(): Text
    begin
        exit('skuVariantCode');
    end;

    procedure GetSkuLocationCodeKey(): Text
    begin
        exit('skuLocationCode');
    end;

    procedure GetItemSafetyStockKey(): Text
    begin
        exit('itemSafetyStock');
    end;

    procedure GetSalesLineInvKey(SystemId: Guid; var TempSalesLine: Record "Sales Line" temporary): Boolean
    var
        Baseline: JsonObject;
    begin
        Clear(TempSalesLine);
        GetBaseline(Database::"Sales Line", SystemId, '', Baseline);
        if not Baseline.Contains(GetSalesLineItemNoKey()) then
            exit(false);
        TempSalesLine."No." := CopyStr(Facet(Baseline, GetSalesLineItemNoKey()), 1, MaxStrLen(TempSalesLine."No."));
        TempSalesLine."Variant Code" := CopyStr(Facet(Baseline, GetSalesLineVariantCodeKey()), 1, MaxStrLen(TempSalesLine."Variant Code"));
        TempSalesLine."Location Code" := CopyStr(Facet(Baseline, GetSalesLineLocationCodeKey()), 1, MaxStrLen(TempSalesLine."Location Code"));
        TempSalesLine."Outstanding Qty. (Base)" := FacetAsDecimal(Baseline, GetSalesLineQtyKey());
        exit(true);
    end;

    procedure SetSalesLineInvKey(SalesLine: Record "Sales Line")
    var
        Baseline: JsonObject;
    begin
        GetBaseline(Database::"Sales Line", SalesLine.SystemId, '', Baseline);
        SetFacet(Baseline, GetSalesLineItemNoKey(), SalesLine."No.");
        SetFacet(Baseline, GetSalesLineVariantCodeKey(), SalesLine."Variant Code");
        SetFacet(Baseline, GetSalesLineLocationCodeKey(), SalesLine."Location Code");
        SetFacetDecimal(Baseline, GetSalesLineQtyKey(), SalesLine."Outstanding Qty. (Base)");
        SaveBaseline(Database::"Sales Line", SalesLine.SystemId, '', Baseline);
    end;

    procedure GetTransferLineInvKey(SystemId: Guid; var TempTransferLine: Record "Transfer Line" temporary): Boolean
    var
        Baseline: JsonObject;
    begin
        Clear(TempTransferLine);
        GetBaseline(Database::"Transfer Line", SystemId, '', Baseline);
        if not Baseline.Contains(GetTransferLineItemNoKey()) then
            exit(false);
        TempTransferLine."Item No." := CopyStr(Facet(Baseline, GetTransferLineItemNoKey()), 1, MaxStrLen(TempTransferLine."Item No."));
        TempTransferLine."Variant Code" := CopyStr(Facet(Baseline, GetTransferLineVariantCodeKey()), 1, MaxStrLen(TempTransferLine."Variant Code"));
        TempTransferLine."Transfer-from Code" := CopyStr(Facet(Baseline, GetTransferLineFromCodeKey()), 1, MaxStrLen(TempTransferLine."Transfer-from Code"));
        TempTransferLine."Transfer-to Code" := CopyStr(Facet(Baseline, GetTransferLineToCodeKey()), 1, MaxStrLen(TempTransferLine."Transfer-to Code"));
        TempTransferLine."Outstanding Qty. (Base)" := FacetAsDecimal(Baseline, GetTransferLineQtyKey());
        TempTransferLine."Qty. in Transit (Base)" := FacetAsDecimal(Baseline, GetTransferLineQtyInTransitKey());
        exit(true);
    end;

    procedure SetTransferLineInvKey(TransferLine: Record "Transfer Line")
    var
        Baseline: JsonObject;
    begin
        GetBaseline(Database::"Transfer Line", TransferLine.SystemId, '', Baseline);
        SetFacet(Baseline, GetTransferLineItemNoKey(), TransferLine."Item No.");
        SetFacet(Baseline, GetTransferLineVariantCodeKey(), TransferLine."Variant Code");
        SetFacet(Baseline, GetTransferLineFromCodeKey(), TransferLine."Transfer-from Code");
        SetFacet(Baseline, GetTransferLineToCodeKey(), TransferLine."Transfer-to Code");
        SetFacetDecimal(Baseline, GetTransferLineQtyKey(), TransferLine."Outstanding Qty. (Base)");
        SetFacetDecimal(Baseline, GetTransferLineQtyInTransitKey(), TransferLine."Qty. in Transit (Base)");
        SaveBaseline(Database::"Transfer Line", TransferLine.SystemId, '', Baseline);
    end;

    procedure GetSkuInvKey(SystemId: Guid; var TempSKU: Record "Stockkeeping Unit" temporary): Boolean
    var
        Baseline: JsonObject;
    begin
        Clear(TempSKU);
        GetBaseline(Database::"Stockkeeping Unit", SystemId, '', Baseline);
        if not Baseline.Contains(GetSkuItemNoKey()) then
            exit(false);
        TempSKU."Item No." := CopyStr(Facet(Baseline, GetSkuItemNoKey()), 1, MaxStrLen(TempSKU."Item No."));
        TempSKU."Variant Code" := CopyStr(Facet(Baseline, GetSkuVariantCodeKey()), 1, MaxStrLen(TempSKU."Variant Code"));
        TempSKU."Location Code" := CopyStr(Facet(Baseline, GetSkuLocationCodeKey()), 1, MaxStrLen(TempSKU."Location Code"));
        TempSKU."NPR Spfy Safety Stock Quantity" := FacetAsDecimal(Baseline, GetSkuSafetyStockKey());
        exit(true);
    end;

    procedure SetSkuInvKey(SKU: Record "Stockkeeping Unit")
    var
        Baseline: JsonObject;
    begin
        GetBaseline(Database::"Stockkeeping Unit", SKU.SystemId, '', Baseline);
        SetFacet(Baseline, GetSkuItemNoKey(), SKU."Item No.");
        SetFacet(Baseline, GetSkuVariantCodeKey(), SKU."Variant Code");
        SetFacet(Baseline, GetSkuLocationCodeKey(), SKU."Location Code");
        SetFacetDecimal(Baseline, GetSkuSafetyStockKey(), SKU."NPR Spfy Safety Stock Quantity");
        SaveBaseline(Database::"Stockkeeping Unit", SKU.SystemId, '', Baseline);
    end;

    procedure SaveBaseline(TableNo: Integer; EntitySystemId: Guid; StoreCode: Code[20]; Baseline: JsonObject)
    var
        SyncState: Record "NPR Spfy Sync State";
        OutStr: OutStream;
        ParametersText: Text;
        IsNew: Boolean;
    begin
        IsNew := not SyncState.Get(TableNo, EntitySystemId, StoreCode);
        if IsNew then begin
            SyncState.Init();
            SyncState."Table No." := TableNo;
            SyncState."Entity System Id" := EntitySystemId;
            SyncState."Shopify Store Code" := StoreCode;
        end;
        Baseline.WriteTo(ParametersText);
        Clear(SyncState.Parameters);
        SyncState.Parameters.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(ParametersText);
        SyncState."Payload Version" := PayloadVersion();
        if IsNew then
            SyncState.Insert(true)
        else
            SyncState.Modify(true);
    end;

    procedure RemoveBaseline(TableNo: Integer; EntitySystemId: Guid; StoreCode: Code[20])
    var
        SyncState: Record "NPR Spfy Sync State";
    begin
        if SyncState.Get(TableNo, EntitySystemId, StoreCode) then
            SyncState.Delete(true);
    end;

    procedure HasBaseline(TableNo: Integer; EntitySystemId: Guid; StoreCode: Code[20]): Boolean
    var
        SyncState: Record "NPR Spfy Sync State";
    begin
        exit(SyncState.Get(TableNo, EntitySystemId, StoreCode));
    end;

    procedure RemoveBaselineAllStores(TableNo: Integer; EntitySystemId: Guid)
    var
        SyncState: Record "NPR Spfy Sync State";
    begin
        SyncState.SetRange("Table No.", TableNo);
        SyncState.SetRange("Entity System Id", EntitySystemId);
        if not SyncState.IsEmpty() then
            SyncState.DeleteAll(true);
    end;

    internal procedure CountBaselinesForTable(TableNo: Integer): Integer
    var
        SyncState: Record "NPR Spfy Sync State";
    begin
        SyncState.SetRange("Table No.", TableNo);
        exit(SyncState.Count());
    end;

    internal procedure CountBaselinesForTableAndStore(TableNo: Integer; StoreCode: Code[20]): Integer
    var
        SyncState: Record "NPR Spfy Sync State";
    begin
        SyncState.SetRange("Table No.", TableNo);
        SyncState.SetRange("Shopify Store Code", StoreCode);
        exit(SyncState.Count());
    end;

    internal procedure DeleteBaselinesForTable(TableNo: Integer) DeletedCount: Integer
    var
        SyncState: Record "NPR Spfy Sync State";
    begin
        SyncState.SetRange("Table No.", TableNo);
        DeletedCount := SyncState.Count();
        if DeletedCount = 0 then
            exit;
        SyncState.DeleteAll(true);
    end;

    internal procedure DeleteBaselinesForTableAndStore(TableNo: Integer; StoreCode: Code[20]) DeletedCount: Integer
    var
        SyncState: Record "NPR Spfy Sync State";
    begin
        // StoreCode = '' targets ONLY store-agnostic rows (blank is a real key value, not a wildcard).
        SyncState.SetRange("Table No.", TableNo);
        SyncState.SetRange("Shopify Store Code", StoreCode);
        DeletedCount := SyncState.Count();
        if DeletedCount = 0 then
            exit;
        SyncState.DeleteAll(true);
    end;

    internal procedure CountMetafieldBaselinesForOwner(OwnerTableNo: Integer; OwnerRecordId: RecordId): Integer
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        MetafieldCount: Integer;
    begin
        SpfyEntityMetafield.SetRange("Table No.", OwnerTableNo);
        SpfyEntityMetafield.SetRange("BC Record ID", OwnerRecordId);
        if SpfyEntityMetafield.FindSet() then
            repeat
                if HasBaseline(Database::"NPR Spfy Entity Metafield", SpfyEntityMetafield.SystemId, '') then
                    MetafieldCount += 1;
            until SpfyEntityMetafield.Next() = 0;
        exit(MetafieldCount);
    end;

    internal procedure DeleteMetafieldBaselinesForOwner(OwnerTableNo: Integer; OwnerRecordId: RecordId) DeletedCount: Integer
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
    begin
        // Metafield baselines are keyed store-blank; store scoping comes from the OWNER link row.
        SpfyEntityMetafield.SetRange("Table No.", OwnerTableNo);
        SpfyEntityMetafield.SetRange("BC Record ID", OwnerRecordId);
        if SpfyEntityMetafield.FindSet() then
            repeat
                if HasBaseline(Database::"NPR Spfy Entity Metafield", SpfyEntityMetafield.SystemId, '') then begin
                    RemoveBaseline(Database::"NPR Spfy Entity Metafield", SpfyEntityMetafield.SystemId, '');
                    DeletedCount += 1;
                end;
            until SpfyEntityMetafield.Next() = 0;
    end;

    procedure ItemCategoryCode(Item: Record Item): Text
    begin
        exit(Item."Item Category Code");
    end;

    procedure StoreItemLinkPayloadHash(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"): Text
    var
        RecRef: RecordRef;
        Include: List of [Integer];
    begin
        RecRef.GetTable(SpfyStoreItemLink);
        Include.Add(SpfyStoreItemLink.FieldNo("Shopify Name"));
        Include.Add(SpfyStoreItemLink.FieldNo("Shopify Description"));
        Include.Add(SpfyStoreItemLink.FieldNo(Vendor));
        exit(FieldsHash(RecRef, Include));
    end;

    procedure StoreCustomerLinkPayloadHash(SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"): Text
    var
        RecRef: RecordRef;
        Include: List of [Integer];
    begin
        RecRef.GetTable(SpfyStoreCustomerLink);
        Include.Add(SpfyStoreCustomerLink.FieldNo("First Name"));
        Include.Add(SpfyStoreCustomerLink.FieldNo("Last Name"));
        Include.Add(SpfyStoreCustomerLink.FieldNo("E-Mail"));
        Include.Add(SpfyStoreCustomerLink.FieldNo("Phone No."));
        Include.Add(SpfyStoreCustomerLink.FieldNo("E-mail Marketing State"));
        Include.Add(SpfyStoreCustomerLink.FieldNo(Address));
        Include.Add(SpfyStoreCustomerLink.FieldNo("Address 2"));
        Include.Add(SpfyStoreCustomerLink.FieldNo(City));
        Include.Add(SpfyStoreCustomerLink.FieldNo(County));
        Include.Add(SpfyStoreCustomerLink.FieldNo("Post Code"));
        Include.Add(SpfyStoreCustomerLink.FieldNo("Country/Region Code"));
        exit(FieldsHash(RecRef, Include));
    end;

    procedure ItemVariantModifHash(SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif."): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(SpfyItemVariantModif);
        exit(RecordHash(RecRef));
    end;

    procedure EntityMetafieldPayloadHash(SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"): Text
    var
        RecRef: RecordRef;
        Include: List of [Integer];
    begin
        RecRef.GetTable(SpfyEntityMetafield);
        Include.Add(SpfyEntityMetafield.FieldNo("Metafield ID"));
        Include.Add(SpfyEntityMetafield.FieldNo("Metafield Key"));
        Include.Add(SpfyEntityMetafield.FieldNo("Metafield Raw Value"));
        exit(FieldsHash(RecRef, Include));
    end;

    procedure AdvanceStoreItemLinkBaseline(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    begin
        if not FeatureEnabled() then
            exit;
        SeedStoreItemLinkBaseline(SpfyStoreItemLink);
    end;

    procedure AdvanceStoreCustomerLinkBaseline(SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    begin
        if not FeatureEnabled() then
            exit;
        SeedStoreCustomerLinkBaseline(SpfyStoreCustomerLink);
    end;

    procedure AdvanceItemVariantModifBaseline(SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.")
    begin
        if not FeatureEnabled() then
            exit;
        SeedItemVariantModifBaseline(SpfyItemVariantModif);
    end;

    procedure AdvanceEntityMetafieldBaseline(SpfyEntityMetafield: Record "NPR Spfy Entity Metafield")
    begin
        if not FeatureEnabled() then
            exit;
        SeedEntityMetafieldBaseline(SpfyEntityMetafield);
    end;

    procedure SeedStoreItemLinkBaseline(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        Baseline: JsonObject;
    begin
        GetBaseline(Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.SystemId, SpfyStoreItemLink."Shopify Store Code", Baseline);
        SetFacet(Baseline, GetStoreItemLinkHashKey(), StoreItemLinkPayloadHash(SpfyStoreItemLink));
        SaveBaseline(Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.SystemId, SpfyStoreItemLink."Shopify Store Code", Baseline);
    end;

    procedure SeedStoreCustomerLinkBaseline(SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    var
        Baseline: JsonObject;
    begin
        GetBaseline(Database::"NPR Spfy Store-Customer Link", SpfyStoreCustomerLink.SystemId, SpfyStoreCustomerLink."Shopify Store Code", Baseline);
        SetFacet(Baseline, GetStoreCustomerLinkHashKey(), StoreCustomerLinkPayloadHash(SpfyStoreCustomerLink));
        SaveBaseline(Database::"NPR Spfy Store-Customer Link", SpfyStoreCustomerLink.SystemId, SpfyStoreCustomerLink."Shopify Store Code", Baseline);
    end;

    procedure SeedItemVariantModifBaseline(SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.")
    var
        Baseline: JsonObject;
    begin
        GetBaseline(Database::"NPR Spfy Item Variant Modif.", SpfyItemVariantModif.SystemId, SpfyItemVariantModif."Shopify Store Code", Baseline);
        SetFacet(Baseline, GetItemVariantModifHashKey(), ItemVariantModifHash(SpfyItemVariantModif));
        SaveBaseline(Database::"NPR Spfy Item Variant Modif.", SpfyItemVariantModif.SystemId, SpfyItemVariantModif."Shopify Store Code", Baseline);
    end;

    procedure SeedEntityMetafieldBaseline(SpfyEntityMetafield: Record "NPR Spfy Entity Metafield")
    var
        Baseline: JsonObject;
    begin
        GetBaseline(Database::"NPR Spfy Entity Metafield", SpfyEntityMetafield.SystemId, '', Baseline);
        SetFacet(Baseline, GetEntityMetafieldHashKey(), EntityMetafieldPayloadHash(SpfyEntityMetafield));
        SaveBaseline(Database::"NPR Spfy Entity Metafield", SpfyEntityMetafield.SystemId, '', Baseline);
    end;

    procedure SeedItemBaseline(Item: Record Item; StoreCode: Code[20])
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        Baseline: JsonObject;
    begin
        GetBaseline(Database::Item, Item.SystemId, StoreCode, Baseline);
        SetFacetDecimal(Baseline, GetItemCostKey(), Item."Last Direct Cost");
        SetFacet(Baseline, GetItemCategoryCodeKey(), ItemCategoryCode(Item));
        // Only the enabled area compares this facet; stamping it while off would swallow the first recalc after a later enable.
        if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels", StoreCode) then
            SetFacetDecimal(Baseline, GetItemSafetyStockKey(), Item."NPR Spfy Safety Stock Quantity");
        SaveBaseline(Database::Item, Item.SystemId, StoreCode, Baseline);
    end;

    procedure SeedItemVariantBaseline(ItemVariant: Record "Item Variant")
    var
        Baseline: JsonObject;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(ItemVariant);
        GetBaseline(Database::"Item Variant", ItemVariant.SystemId, '', Baseline);
        SetFacet(Baseline, GetItemVariantHashKey(), RecordHash(RecRef));
        SaveBaseline(Database::"Item Variant", ItemVariant.SystemId, '', Baseline);
    end;

    procedure SeedVoucherBaseline(Voucher: Record "NPR NpRv Voucher"; StoreCode: Code[20])
    var
        Baseline: JsonObject;
    begin
        GetBaseline(Database::"NPR NpRv Voucher", Voucher.SystemId, StoreCode, Baseline);
        SetFacet(Baseline, GetVoucherEndingDateKey(), Format(DT2Date(Voucher."Ending Date"), 0, 9));
        SaveBaseline(Database::"NPR NpRv Voucher", Voucher.SystemId, StoreCode, Baseline);
    end;

    local procedure FeatureEnabled(): Boolean
    var
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
    begin
        exit(SpfyRowVersionFeature.IsFeatureEnabled());
    end;

    procedure FieldsHash(RecRef: RecordRef; IncludeFieldNos: List of [Integer]): Text
    var
        Builder: TextBuilder;
        FieldNo: Integer;
    begin
        foreach FieldNo in IncludeFieldNos do
            AppendFieldValue(Builder, RecRef.Field(FieldNo));
        exit(Hash(Builder.ToText()));
    end;

    procedure FieldsHashExcept(RecRef: RecordRef; ExcludeFieldNos: List of [Integer]): Text
    var
        Builder: TextBuilder;
        FRef: FieldRef;
        i: Integer;
    begin
        for i := 1 to RecRef.FieldCount() do begin
            FRef := RecRef.FieldIndex(i);
            if IsHashableField(FRef) and not ExcludeFieldNos.Contains(FRef.Number()) then
                AppendFieldValue(Builder, FRef);
        end;
        exit(Hash(Builder.ToText()));
    end;

    procedure RecordHash(RecRef: RecordRef): Text
    var
        EmptyExclude: List of [Integer];
    begin
        exit(FieldsHashExcept(RecRef, EmptyExclude));
    end;

    procedure Hash(InputText: Text): Text
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        exit(CryptographyManagement.GenerateHash(InputText, HashAlgorithmType::SHA256));
    end;

    // Length-prefixed ("length:value") so a value containing the delimiter can't shift field boundaries and hide a change.
    local procedure AppendFieldValue(var Builder: TextBuilder; FRef: FieldRef)
    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        InStr: InStream;
        ValueText: Text;
    begin
        if FRef.Type() = FieldType::Blob then begin
            FRef.CalcField();
            TempBlob.FromFieldRef(FRef);
            if TempBlob.HasValue() then begin
                TempBlob.CreateInStream(InStr);
                ValueText := Base64Convert.ToBase64(InStr);   // RAW bytes — never decode as text (encoding varies per blob)
            end;
        end else
            ValueText := Format(FRef.Value(), 0, 9);

        Builder.Append(Format(StrLen(ValueText)));
        Builder.Append(':');
        Builder.Append(ValueText);
    end;

    local procedure IsHashableField(FRef: FieldRef): Boolean
    begin
        // Skip the rowversion field (0) and system fields (>= 2000000000).
        exit((FRef.Class() = FieldClass::Normal) and (FRef.Number() <> 0) and (FRef.Number() < 2000000000));
    end;
}
