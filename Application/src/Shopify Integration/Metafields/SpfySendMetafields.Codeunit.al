#if not BC17
codeunit 6248554 "NPR Spfy Send Metafields"
{
    Access = Internal;
    TableNo = "NPR Nc Task";

    trigger OnRun()
    begin
        Rec.TestField("Store Code");
        case Rec."Table No." of
            Database::"NPR Spfy Entity Metafield":
                SendMetafields(Rec);
        end;
    end;

    local procedure SendMetafields(var NcTask: Record "NPR Nc Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        ShopifyResponse: JsonToken;
        ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type";
        ShopifyOwnerID: Text[30];
        SendToShopify: Boolean;
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        Clear(SpfyMetafieldMgt);
        ClearLastError();

        Success := PrepareMetafieldUpdateRequest(NcTask, SpfyMetafieldMgt, ShopifyOwnerType, ShopifyOwnerID, SendToShopify);
        if SendToShopify then
            Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse);

        NcTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());
        if not SendToShopify then
            exit;
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error('');
        SpfyMetafieldMgt.RequestMetafieldValuesFromShopifyAndUpdateBCData(NcTask."Record ID", ShopifyOwnerType, ShopifyOwnerID, NcTask."Store Code");
    end;

    [TryFunction]
    local procedure PrepareMetafieldUpdateRequest(var NcTask: Record "NPR Nc Task"; var SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt."; var ShopifyOwnerType: Enum "NPR Spfy Metafield Owner Type"; var ShopifyOwnerID: Text[30]; var SendToShopify: Boolean)
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyMetafieldMgtPublic: Codeunit "NPR Spfy Metafield Mgt. Public";
        RecRef: RecordRef;
        OwnerRecID: RecordId;
        QueryStream: OutStream;
        ShopifyStoreCode: Code[20];
        Handled: Boolean;
    begin
        RecRef := NcTask."Record ID".GetRecord();
        SpfyMetafieldMgtPublic.OnPrepareMetafieldUpdateRequest(RecRef, OwnerRecID, ShopifyOwnerType, ShopifyOwnerID, ShopifyStoreCode, Handled);
        if not Handled then
            case RecRef.Number() of
                Database::"NPR Spfy Store-Item Link":
                    begin
                        RecRef.SetTable(SpfyStoreItemLink);
                        if SpfyStoreItemLink.Type = SpfyStoreItemLink.Type::Item then
                            ShopifyOwnerType := ShopifyOwnerType::PRODUCT
                        else
                            ShopifyOwnerType := ShopifyOwnerType::PRODUCTVARIANT;
                        OwnerRecID := SpfyStoreItemLink.RecordId();
                        ShopifyStoreCode := SpfyStoreItemLink."Shopify Store Code";
                    end;

                Database::"NPR Spfy Store-Customer Link":
                    begin
                        RecRef.SetTable(SpfyStoreCustomerLink);
                        ShopifyOwnerType := ShopifyOwnerType::CUSTOMER;
                        OwnerRecID := SpfyStoreCustomerLink.RecordId();
                        ShopifyStoreCode := SpfyStoreCustomerLink."Shopify Store Code";
                    end;

                else
                    exit;
            end;

        if ShopifyOwnerID = '' then
            ShopifyOwnerID := SpfyAssignedIDMgt.GetAssignedShopifyID(OwnerRecID, "NPR Spfy ID Type"::"Entry ID");
        if (ShopifyOwnerType = ShopifyOwnerType::" ") or (ShopifyOwnerID = '') or (ShopifyStoreCode = '') then
            exit;

        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        SendToShopify := SpfyMetafieldMgt.ShopifyEntityMetafieldValueUpdateQuery(OwnerRecID, ShopifyOwnerType, ShopifyOwnerID, ShopifyStoreCode, QueryStream);
    end;
}
#endif