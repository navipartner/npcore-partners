#if not BC17
codeunit 85365 "NPR Spfy Item Resolution Mock"
{
    // Stands in for a customer extension that resolves Shopify items the standard SKU lookup cannot resolve.
    // Captures what "NPR Spfy Integration Events".OnResolveUnknownItem hands out, so the tests can assert both
    // the resolution result and that subscribers get the context they need to decide whether to act.
    //
    // Doubles as the reference implementation of the event contract, so it abstains when the SKU is already
    // claimed rather than overwriting. The second subscriber below models a competing extension bound to the same
    // event, which is the case that makes abstaining matter.
    EventSubscriberInstance = Manual;

    var
        _ResolveToItemNo: Code[20];
        _ResolveToVariantCode: Code[10];
        _CompetingItemNo: Code[20];
        _CapturedStoreCode: Code[20];
        _CapturedLineID: BigInteger;
        _CapturedTitle: Text;
        _CapturedSku: Text;
        _CallCount: Integer;
        _ClaimCount: Integer;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Spfy Integration Events", 'OnResolveUnknownItem', '', false, false)]
    local procedure ResolveItemOnResolveUnknownItem(ShopifyStoreCode: Code[20]; ShopifyJToken: JsonToken; Sku: Text; var ItemVariant: Record "Item Variant")
    var
        JsonHelper: Codeunit "NPR Json Helper";
    begin
        _CallCount += 1;
        _CapturedStoreCode := ShopifyStoreCode;
        _CapturedSku := Sku;
        // The legacy order import reads the line item id as a big integer, the same way "NPR Spfy Order Mgt." does.
        _CapturedLineID := JsonHelper.GetJBigInteger(ShopifyJToken, 'id', false);
        _CapturedTitle := JsonHelper.GetJText(ShopifyJToken, 'title', false);

        if ItemVariant."Item No." <> '' then
            exit;

        if _ResolveToVariantCode <> '' then
            ItemVariant.Code := _ResolveToVariantCode;
        if _ResolveToItemNo = '' then
            exit;
        ItemVariant."Item No." := _ResolveToItemNo;
        _ClaimCount += 1;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Spfy Integration Events", 'OnResolveUnknownItem', '', false, false)]
    local procedure CompetingResolveItemOnResolveUnknownItem(var ItemVariant: Record "Item Variant")
    begin
        if _CompetingItemNo = '' then
            exit;
        if ItemVariant."Item No." <> '' then
            exit;
        ItemVariant."Item No." := _CompetingItemNo;
        _ClaimCount += 1;
    end;

    /// <summary>
    /// Makes the subscriber resolve to the given item, and optionally to one of its variants. Pass a blank ItemNo
    /// with a variant code to model a subscriber that writes to the record but declines to resolve the item.
    /// </summary>
    procedure SetResolution(ItemNo: Code[20]; VariantCode: Code[10])
    begin
        _ResolveToItemNo := ItemNo;
        _ResolveToVariantCode := VariantCode;
    end;

    /// <summary>Activates a second subscriber that resolves the same SKU to a different item.</summary>
    procedure SetCompetingResolution(ItemNo: Code[20])
    begin
        _CompetingItemNo := ItemNo;
    end;

    procedure CallCount(): Integer
    begin
        exit(_CallCount);
    end;

    procedure ClaimCount(): Integer
    begin
        exit(_ClaimCount);
    end;

    procedure CapturedStoreCode(): Code[20]
    begin
        exit(_CapturedStoreCode);
    end;

    procedure CapturedLineID(): BigInteger
    begin
        exit(_CapturedLineID);
    end;

    procedure CapturedTitle(): Text
    begin
        exit(_CapturedTitle);
    end;

    procedure CapturedSku(): Text
    begin
        exit(_CapturedSku);
    end;
}
#endif
