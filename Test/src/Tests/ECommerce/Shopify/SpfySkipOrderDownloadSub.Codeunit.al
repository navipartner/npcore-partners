#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85466 "NPR Spfy SkipOrderDownloadSub"
{
    EventSubscriberInstance = Manual;

    var
        _LastTags: List of [Text];
        _SkipTag: Text;
        _LastStoreCode: Code[20];
        _LastOrderStatus: Enum "NPR SpfyAPIDocumentStatus";
        _InvocationCount: Integer;
        _SkipEverything: Boolean;

    procedure Reset()
    begin
        _InvocationCount := 0;
        _LastStoreCode := '';
        _LastOrderStatus := _LastOrderStatus::" ";
        Clear(_LastTags);
        _SkipTag := '';
        _SkipEverything := false;
    end;

    /// <summary>
    /// Skips only orders carrying this tag, which is the shape a real subscriber takes: the rule reads the
    /// normalised Tags list rather than parsing 'tags' off the order token.
    /// </summary>
    procedure SkipWhenTagged(Tag: Text)
    begin
        _SkipTag := Tag;
    end;

    procedure SkipEverything()
    begin
        _SkipEverything := true;
    end;

    procedure InvocationCount(): Integer
    begin
        exit(_InvocationCount);
    end;

    procedure LastStoreCode(): Code[20]
    begin
        exit(_LastStoreCode);
    end;

    procedure LastOrderStatus(): Enum "NPR SpfyAPIDocumentStatus"
    begin
        exit(_LastOrderStatus);
    end;

    procedure LastTags(): List of [Text]
    begin
        exit(_LastTags);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Spfy Integration Events", OnCheckIfShouldSkipOrderDownload, '', false, false)]
    local procedure OnCheckIfShouldSkipOrderDownload(ShopifyStoreCode: Code[20]; Order: JsonToken; OrderStatus: Enum "NPR SpfyAPIDocumentStatus"; Tags: List of [Text]; var SkipImport: Boolean)
    begin
        _InvocationCount += 1;
        _LastStoreCode := ShopifyStoreCode;
        _LastOrderStatus := OrderStatus;
        _LastTags := Tags;

        if _SkipEverything then begin
            SkipImport := true;
            exit;
        end;

        if _SkipTag = '' then
            exit;
        if Tags.Contains(_SkipTag) then
            SkipImport := true;
    end;
}
#endif
