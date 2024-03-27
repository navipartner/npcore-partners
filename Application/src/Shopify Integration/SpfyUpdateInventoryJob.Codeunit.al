#if not BC17
codeunit 6184822 "NPR Spfy Update Inventory Job"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun();
    var
        LastProcessedItemNo: Code[20];
        SpfyStoreCode: Code[20];
        BatchSize: Integer;
        StartOverOnFinish: Boolean;
    begin
        GetParameters(Rec."Parameter String", LastProcessedItemNo, BatchSize, StartOverOnFinish, SpfyStoreCode);
        ProcessSpfyInventoryUpdate(LastProcessedItemNo, BatchSize, StartOverOnFinish, SpfyStoreCode);
        SaveParameters(Rec, LastProcessedItemNo, BatchSize, StartOverOnFinish, SpfyStoreCode);
    end;

    local procedure ProcessSpfyInventoryUpdate(var LastProcessedItemNo: Code[20]; BatchSize: Integer; StartOverOnFinish: Boolean; SpfyStoreCode: Code[20])
    var
        Item: Record Item;
        ShopifyStore: Record "NPR Spfy Store";
        Counter: Integer;
        NoMoreRecordsToProcess: Boolean;
        RestartNotEnabledErr: Label 'All items have been successfully processed. Please stop the job, or adjust parameters to allow the system to start over.';
    begin
        If LastProcessedItemNo <> '' then
            Item.SetFilter("No.", '%1..', LastProcessedItemNo);
        NoMoreRecordsToProcess := not Item.FindSet();
        if not NoMoreRecordsToProcess and (Item."No." = LastProcessedItemNo) then
            NoMoreRecordsToProcess := Item.Next() = 0;
        if NoMoreRecordsToProcess then begin
            if StartOverOnFinish then begin
                LastProcessedItemNo := '';
                exit;
            end;
            Error(RestartNotEnabledErr);
        end;

        if SpfyStoreCode <> '' then begin
            ShopifyStore.Get(SpfyStoreCode);
            ShopifyStore.SetRecFilter();
        end;

        repeat
            Counter += 1;
            ProcessItem(Item, ShopifyStore);
            Commit();

            LastProcessedItemNo := Item."No.";
            NoMoreRecordsToProcess := Item.Next() = 0;
        until (Counter = BatchSize) or NoMoreRecordsToProcess;

        if NoMoreRecordsToProcess and StartOverOnFinish then
            LastProcessedItemNo := '';
    end;

    local procedure ProcessItem(Item: Record Item; var ShopifyStore: Record "NPR Spfy Store")
    var
        InventoryLevel: Record "NPR Spfy Inventory Level";
        InventoryLevelMgt: Codeunit "NPR Spfy Inventory Level Mgt.";
        SendItemAndInventory: Codeunit "NPR Spfy Send Items&Inventory";
    begin
        SendItemAndInventory.MarkItemAlreadyOnShopify(Item, ShopifyStore, false, false);

        InventoryLevel.SetRange("Item No.", Item."No.");
        ShopifyStore.CopyFilter(Code, InventoryLevel."Shopify Store Code");
        if not InventoryLevel.IsEmpty() then
            InventoryLevel.DeleteAll();

        Item.SetRecFilter();
        InventoryLevelMgt.InitializeInventoryLevels(ShopifyStore.GetFilter(Code), Item, true);
    end;

    local procedure GetParameters(ParameterString: Text; var LastProcessedItemNo: Code[20]; var BatchSize: Integer; var StartOverOnFinish: Boolean; var SpfyStoreCode: Code[20])
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Parameters: JsonToken;
    begin
        if ParameterString <> '' then
            if Parameters.ReadFrom(ParameterString) then
                if Parameters.IsObject() then begin
#pragma warning disable AA0139
                    LastProcessedItemNo := JsonHelper.GetJText(Parameters, 'LastItemNo', StrLen(LastProcessedItemNo), false);
                    SpfyStoreCode := JsonHelper.GetJText(Parameters, 'Store', MaxStrLen(SpfyStoreCode), false);
#pragma warning restore AA0139
                    BatchSize := JsonHelper.GetJInteger(Parameters, 'BatchSize', false);
                    StartOverOnFinish := JsonHelper.GetJBoolean(Parameters, 'StartOverOnFinish', false);
                end;
        if BatchSize <= 0 then
            BatchSize := 100;
    end;

    local procedure SaveParameters(var JobQueueEntry: Record "Job Queue Entry"; LastProcessedItemNo: Code[20]; BatchSize: Integer; StartOverOnFinish: Boolean; SpfyStoreCode: Code[20])
    var
        Parameters: JsonObject;
    begin
        Parameters.Add('LastItemNo', LastProcessedItemNo);
        Parameters.Add('BatchSize', Format(BatchSize, 0, 9));
        Parameters.Add('StartOverOnFinish', Format(StartOverOnFinish, 0, 9));
        if SpfyStoreCode <> '' then
            Parameters.Add('Store', SpfyStoreCode);
#pragma warning disable AA0139
        Parameters.WriteTo(JobQueueEntry."Parameter String");
#pragma warning restore AA0139
        JobQueueEntry.Modify();
    end;
}
#endif