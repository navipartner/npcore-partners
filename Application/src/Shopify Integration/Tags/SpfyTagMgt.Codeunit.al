#if not BC17
codeunit 6248287 "NPR Spfy Tag Mgt."
{
    Access = Internal;

    internal procedure ShopifyEntityTagsUpdateQuery(NcTask: Record "NPR Nc Task"; ShopifyOwnerType: Enum "NPR Spfy Tag Owner Type"; ShopifyOwnerID: Text[30]; var QueryStream: OutStream) SendToShopify: Boolean
    var
        CurrentEntityTags: JsonArray;
        RequestJson: JsonObject;
        TagUpdateSet: JsonObject;
        OwnerTypeTxt: Text;
        QueryTok: Label 'mutation UdpateTags($ownerId: ID!, $removeTags: [String!]!, $addTags: [String!]!) { tagsRemove(id: $ownerId, tags: $removeTags) { node { id } userErrors{ field message }} tagsAdd(id: $ownerId, tags: $addTags) { node { id } userErrors{ field message }}}', Locked = true;
    begin
        OwnerTypeTxt := GetOwnerTypeAsText(ShopifyOwnerType);
        GetShopifyEntityTags(OwnerTypeTxt, ShopifyOwnerID, NcTask."Store Code", false, CurrentEntityTags);
        SendToShopify := GenerateTagSet(NcTask."Entry No.", NcTask."Record ID", OwnerTypeTxt, ShopifyOwnerID, CurrentEntityTags, TagUpdateSet);

        RequestJson.Add('query', QueryTok);
        RequestJson.Add('variables', TagUpdateSet);
        RequestJson.WriteTo(QueryStream);
    end;

    local procedure GetShopifyEntityTags(OwnerTypeTxt: Text; ShopifyOwnerID: Text[30]; ShopifyStoreCode: Code[20]; WithDialog: Boolean; var ShopifyEntityTags: JsonArray)
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ShopifyResponse: JsonToken;
        Window: Dialog;
        QueryingShopifyLbl: Label 'Querying Shopify...';
        CouldNotGetTagsErr: Label 'Could not get tags from Shopify. The following error occured: %1', Comment = '%1 - Shopify returned error text.';
    begin
        if WithDialog then
            WithDialog := GuiAllowed;
        if WithDialog then
            Window.Open(QueryingShopifyLbl);
        ClearLastError();
        if not RetrieveEntityTagsFromShopify(OwnerTypeTxt, ShopifyOwnerID, ShopifyStoreCode, ShopifyResponse) then
            Error(CouldNotGetTagsErr, GetLastErrorText());
        ShopifyResponse.SelectToken(StrSubstNo('data.%1.tags', SpfyIntegrationMgt.LowerFirstLetter(OwnerTypeTxt)), ShopifyResponse);
        ShopifyEntityTags := ShopifyResponse.AsArray();
        if WithDialog then
            Window.Close();
    end;

    local procedure RetrieveEntityTagsFromShopify(OwnerTypeTxt: Text; ShopifyOwnerID: Text[30]; ShopifyStoreCode: Code[20]; var ShopifyResponse: JsonToken): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        QueryStream: OutStream;
        RequestJson: JsonObject;
        VariablesJson: JsonObject;
        QueryTok: Label 'query GetTags($ownerId: ID!) { %1(id: $ownerId) { id tags }}', Locked = true;
    begin
        VariablesJson.Add('ownerId', StrSubstNo('gid://shopify/%1/%2', OwnerTypeTxt, ShopifyOwnerID));
        RequestJson.Add('query', StrSubstNo(QueryTok, SpfyIntegrationMgt.LowerFirstLetter(OwnerTypeTxt)));
        RequestJson.Add('variables', VariablesJson);

        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        RequestJson.WriteTo(QueryStream);
        exit(SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse));
    end;

    local procedure GenerateTagSet(NcTaskEntryNo: Integer; EntityRecID: RecordId; OwnerTypeTxt: Text; ShopifyOwnerID: Text[30]; CurrentEntityTags: JsonArray; var TagUpdateSet: JsonObject): Boolean
    var
        TagUpdateRequest: Record "NPR Spfy Tag Update Request";
        AddTags: JsonArray;
        RemoveTags: JsonArray;
    begin
        Clear(TagUpdateSet);
#if not (BC18 or BC19 or BC20 or BC21)
        TagUpdateRequest.ReadIsolation := IsolationLevel::UpdLock;
#else
        TagUpdateRequest.LockTable();
#endif
        TagUpdateRequest.SetCurrentKey("Table No.", "BC Record ID", Type);
        TagUpdateRequest.SetRange("Table No.", EntityRecID.TableNo());
        TagUpdateRequest.SetRange("BC Record ID", EntityRecID);
        TagUpdateRequest.SetRange(Type, TagUpdateRequest.Type::Remove);
        TagUpdateRequest.SetFilter("Nc Task Entry No.", '%1|%2', 0, NcTaskEntryNo);
        if TagUpdateRequest.FindSet() then
            repeat
                TouchTagUpdateRequest(TagUpdateRequest, NcTaskEntryNo, CurrentEntityTags.IndexOf(TagUpdateRequest."Tag Value") <> -1, RemoveTags);  // Tag is present in Shopify, but should be removed
            until TagUpdateRequest.Next() = 0;

        TagUpdateRequest.SetRange(Type, TagUpdateRequest.Type::"Add");
        if TagUpdateRequest.FindSet() then
            repeat
                TouchTagUpdateRequest(TagUpdateRequest, NcTaskEntryNo, CurrentEntityTags.IndexOf(TagUpdateRequest."Tag Value") = -1, AddTags); // Tag is not present in Shopify, but should be added
            until TagUpdateRequest.Next() = 0;

        TagUpdateSet.Add('ownerId', StrSubstNo('gid://shopify/%1/%2', OwnerTypeTxt, ShopifyOwnerID));
        TagUpdateSet.Add('addTags', AddTags);
        TagUpdateSet.Add('removeTags', RemoveTags);
        exit((AddTags.Count() > 0) or (RemoveTags.Count() > 0));
    end;

    local procedure TouchTagUpdateRequest(TagUpdateRequest: Record "NPR Spfy Tag Update Request"; NcTaskEntryNo: Integer; AddTagToArray: Boolean; var TagsToUpdate: JsonArray)
    var
        NcTask: Record "NPR Nc Task";
    begin
        if not (TagUpdateRequest."Nc Task Entry No." in [0, NcTaskEntryNo]) then begin
            NcTask.SetRange("Entry No.", TagUpdateRequest."Nc Task Entry No.");
            if not NcTask.IsEmpty() then
                exit;
            TagUpdateRequest."Nc Task Entry No." := 0;
        end;
        if AddTagToArray then
            if TagsToUpdate.IndexOf(TagUpdateRequest."Tag Value") = -1 then
                TagsToUpdate.Add(TagUpdateRequest."Tag Value");

        if TagUpdateRequest."Nc Task Entry No." = 0 then begin
            TagUpdateRequest."Nc Task Entry No." := NcTaskEntryNo;
            TagUpdateRequest.Modify();
        end;
    end;

    internal procedure RemoveTagUpdateRequests(NcTaskEntryNo: BigInteger)
    var
        TagUpdateRequest: Record "NPR Spfy Tag Update Request";
    begin
        TagUpdateRequest.SetRange("Nc Task Entry No.", NcTaskEntryNo);
        if not TagUpdateRequest.IsEmpty() then
            TagUpdateRequest.DeleteAll();
    end;

    local procedure GetOwnerTypeAsText(ShopifyOwnerType: Enum "NPR Spfy Tag Owner Type") Result: Text
    var
        SpfyTagMgtPublic: Codeunit "NPR Spfy Tag Mgt. Public";
        Handled: Boolean;
        ShopifyOwnerTypesTxt: Label 'Product', Locked = true;
        UndefinedOwnerTypeErr: Label 'Shopify tag owner type was not set or is not supported (owner type = "%1"). This is a programming bug, not a user error. Please contact system vendor.';
    begin
        SpfyTagMgtPublic.OnGetOwnerTypeAsText(ShopifyOwnerType, Result, Handled);
        if Handled then
            exit;
        if not (ShopifyOwnerType in [ShopifyOwnerType::PRODUCT]) then
            Error(UndefinedOwnerTypeErr, ShopifyOwnerType);
        Result := SelectStr(ShopifyOwnerType.AsInteger(), ShopifyOwnerTypesTxt);
    end;
}
#endif