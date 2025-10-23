#if not BC17
report 6014571 "NPR Spfy Init Item Cat.MF Vals"
{
    Extensible = false;
    Caption = 'Initialize Item Category Item Metafield Values';
    UsageCategory = None;
    ProcessingOnly = true;
    Description = 'The batch job will initialize item metafield values based on the item categories currently assigned to items in Business Central.';

    dataset
    {
        dataitem(SpfyStoreDataItem; "NPR Spfy Store")
        {
            RequestFilterFields = Code;

            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
        dataitem(ItemDataItem; Item)
        {
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
    }

    trigger OnInitReport()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ConfirmQst: Label 'The batch job will set the values of item metafields according to the categories currently assigned to items in Business Central.\Please make sure you run the "Sync. Item Categories" batch job first to ensure that the list of item categories is properly synchronized with Shopify. This can reduce the time taken to initialize the metafield values.\You may also wish to run this batch job (report %1) in the background as a job queue rather than running it interactively.', Comment = '%1 - report "NPR Spfy Init Item Cat.MF Vals" number';
    begin
        if GuiAllowed then
            if not Confirm(ConfirmQst + '\' + SpfyIntegrationMgt.LongRunningProcessConfirmQst(), true, Report::"NPR Spfy Init Item Cat.MF Vals") then
                CurrReport.Quit();
    end;

    trigger OnPreReport()
    var
        Item: Record Item;
        SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
        SpfyStore: Record "NPR Spfy Store";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        SpfyMFHdlItemCateg: Codeunit "NPR Spfy M/F Hdl.-Item Categ.";
        SyncToSpfyStores: List of [Code[20]];
        Window: Dialog;
        ShopifyStoreCode: Code[20];
        NoItemFoundErr: Label 'No items found to process.';
        SpfyIntegrationNotEnabledErr: Label 'Either sending item categories as metafields is not enabled, or an item category metafield ID has not been assigned in any of your selected Shopify stores.';
        WindowDialogLbl1: Label 'Updating item category item metafield values...\\';
        WindowDialogLbl2: Label 'Shopify Store       #1##########\';
        WindowDialogLbl3: Label 'Metafield ID        #2##########\';
        WindowDialogLbl4: Label 'Processing Item No. #3##########';
    begin
        SpfyStore.CopyFilters(SpfyStoreDataItem);
        if SpfyStore.FindSet() then
            repeat
                if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Item Categories", SpfyStore.Code) then
                    if SpfyStore.ItemCategoryMetafieldID() <> '' then
                        SyncToSpfyStores.Add(SpfyStore.Code);
            until SpfyStore.Next() = 0;
        if SyncToSpfyStores.Count() = 0 then
            Error(SpfyIntegrationNotEnabledErr);

        Item.CopyFilters(ItemDataItem);
        if Item.IsEmpty() then
            Error(NoItemFoundErr);
        Item.SetLoadFields("No.", "Item Category Code");

        if GuiAllowed() then
            Window.Open(
                WindowDialogLbl1 +
                WindowDialogLbl2 +
                WindowDialogLbl3 +
                WindowDialogLbl4);

        foreach ShopifyStoreCode in SyncToSpfyStores do begin
            if GuiAllowed() then begin
                Window.Update(1, ShopifyStoreCode);
                Window.Update(2, '');
                Window.Update(3, '');
            end;

            SpfyMetafieldMgt.FilterMetafieldMapping(Database::"NPR Spfy Store", SpfyStore.FieldNo("Item Category as Metafield"), ShopifyStoreCode, SpfyMetafieldMapping."Owner Type"::PRODUCT, SpfyMetafieldMapping);
            if SpfyMetafieldMapping.FindFirst() then begin
                if GuiAllowed() then
                    Window.Update(2, SpfyMetafieldMapping."Metafield ID");
                Item.FindSet();
                repeat
                    if GuiAllowed() then
                        Window.Update(3, Item."No.");
                    SpfyMFHdlItemCateg.ProcessItemCategoryChange(Item, SpfyMetafieldMapping, false);
                until Item.Next() = 0;
            end;
        end;

        if GuiAllowed() then
            Window.Close();
    end;
}
#endif