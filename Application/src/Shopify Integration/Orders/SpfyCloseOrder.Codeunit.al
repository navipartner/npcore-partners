#if not BC17
codeunit 6184807 "NPR Spfy Close Order"
{
    Access = Internal;
    TableNo = "NPR Nc Task";

    trigger OnRun()
    begin
        Rec.TestField("Table No.", Rec."Record ID".TableNo);
        case Rec."Table No." of
            Database::"Sales Header":
                CloseShopifyOrder(Rec);
        end;
    end;

    internal procedure InitSendCloseRequestTaskBeforeDeleteSalesHeader(var Rec: Record "Sales Header")
    var
        NcTask: Record "NPR Nc Task";
        SalesInvoice: Record "Sales Invoice Header";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
        SpfyOrderId: Text[30];
    begin
        if Rec.IsTemporary() then
            exit;
        if Rec."Document Type" <> Rec."Document Type"::Order then
            exit;
        SpfyOrderId := SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if SpfyOrderId = '' then
            exit;
        NcTask."Store Code" := CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Store Code"), 1, MaxStrLen(NcTask."Store Code"));
        if NcTask."Store Code" = '' then
            exit;
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Close Order Requests", NcTask."Store Code") then
            exit;
        // Check if the document was posted to avoid triggering closing on Shopify 
        SalesInvoice.SetRange("Order No.", Rec."No.");
        if SalesInvoice.IsEmpty() then
            exit;
        if Rec."No." <> '' then
            RecRef.GetTable(Rec);

        SpfyScheduleSend.InitNcTask(NcTask."Store Code", RecRef, SpfyOrderId, NcTask.Type::Delete, NcTask);
    end;

    local procedure CloseShopifyOrder(var NcTask: Record "NPR Nc Task")
    var
        ShopifyResponse: JsonToken;
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();

        Success := SendCloseOrderRequestGraphQL(NcTask, ShopifyResponse);
        NcTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error('');
    end;

    procedure SendCloseOrderRequestGraphQL(var NcTask: Record "NPR Nc Task"; var ShopifyResponse: JsonToken): Boolean
    var
        InputObj: JsonObject;
        RootObj: JsonObject;
        VariablesObj: JsonObject;
        OutStr: OutStream;
        OrderGID: Text;
        CloseOrderMutationTxt: Label 'mutation CloseOrder($input: OrderCloseInput!) {orderClose(input: $input) { order { id closedAt } userErrors { field message } } }', Locked = true;
    begin
        OrderGID := 'gid://shopify/Order/' + NcTask."Record Value";
        InputObj.Add('id', OrderGID);
        VariablesObj.Add('input', InputObj);
        RootObj.Add('query', CloseOrderMutationTxt);
        RootObj.Add('variables', VariablesObj);
        NcTask."Data Output".CreateOutStream(OutStr, TextEncoding::UTF8);
        RootObj.WriteTo(OutStr);
        exit(SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse));
    end;

    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
}
#endif