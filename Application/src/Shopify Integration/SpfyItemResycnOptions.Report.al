#if not BC17
report 6014527 "NPR Spfy Item Re-sycn Options"
{
    Extensible = false;
    Caption = 'Item Re-sync Opitons';
    UsageCategory = None;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            var
#if not (BC18 or BC19)
                BatchProcessingTxt: Label 'Resyncing items for Shopify store %1.', Comment = '%1 - Shopify store code';
#endif
                ConfirmQst: Label 'This function will go through your selected items in BC and mark those already existing in your Shopify Store ''%1'' as ''Shopify Items''.';
                DialogText1Lbl: Label 'Updating items from Shopify Store ''%1''...\\';
                DialogText2Lbl: Label 'Item No. #1########\';
                DialogText3Lbl: Label 'Progress @2@@@@@@@@';
                NothingToDoErr: Label 'There is nothing to do (there are no items in the system).';
                StoreNotSelectedErr: Label 'You must select a Shopify Store Code.';
            begin
                if ShopifyStoreCode = '' then
                    Error(StoreNotSelectedErr);
                ShopifyStore.Get(ShopifyStoreCode);
                ShopifyStore.SetRecFilter();
                SpfyIntegrationMgt.CheckIsEnabled("NPR Spfy Integration Area"::" ", ShopifyStore.Code);
                Commit();

                if WithDialog then
                    if not Confirm(ConfirmQst + '\' + SpfyIntegrationMgt.LongRunningProcessConfirmQst(), true, ShopifyStore.Code) then
                        exit;
                TotalRecNo := Item.Count();
                if TotalRecNo = 0 then
                    Error(NothingToDoErr);

                Clear(SpfyUpdateItemIntState);
                SpfyUpdateItemIntState.SetProcessingOptions(ShopifyStore, not RegisterInDataLog, CreateAtShopify);

                if WithDialog then begin
#if not (BC18 or BC19)
                    if _ErrorMessageMgt.Activate(_ErrorMessageHandler) then
                        _ErrorMessageMgt.PushContext(_ErrorContextElement, Database::Item, 0, StrSubstNo(BatchProcessingTxt, ShopifyStore.Code));
#endif
                    Window.Open(
                        StrSubstNo(DialogText1Lbl, ShopifyStore.Code) +
                        DialogText2Lbl +
                        DialogText3Lbl);
                end;
            end;

            trigger OnAfterGetRecord()
            var
#if not (BC18 or BC19)
                ErrorContextElement: Codeunit "Error Context Element";
                ErrorMessageMgt: Codeunit "Error Message Management";
                ErrorMessage: Text;
#endif
                Success: Boolean;
#if not (BC18 or BC19)
                DefaultErrorMsg: Label 'An error occurred. No further information has been provided.';
                ProcessingMsg: Label 'Processing item %1.', Comment = '%1 - item number';
#endif
            begin
                if WithDialog then begin
                    Window.Update(1, Item."No.");
#if not (BC18 or BC19)                    
                    ErrorMessageMgt.PushContext(ErrorContextElement, Item.RecordId(), 0, StrSubstNo(ProcessingMsg, Item."No."));
#endif
                end;

                Success := SpfyUpdateItemIntState.Run(Item);
                if Success then
                    CounterProcessed += 1;

                if WithDialog then begin
#if not (BC18 or BC19)
                    if not Success then begin
                        ErrorMessage := GetLastErrorText();
                        if ErrorMessage = '' then
                            ErrorMessage := DefaultErrorMsg;
                        ErrorMessageMgt.LogError(Item, ErrorMessage, '');
                        ErrorMessageMgt.PopContext(ErrorContextElement);
                    end;
                    ClearLastError();
#endif
                    RecNo += 1;
                    Window.Update(2, Round(RecNo / TotalRecNo * 10000, 1));
                end;
            end;

            trigger OnPostDataItem()
            var
                DoneLbl: Label 'The operation completed successfully.';
                UpdateInventoryQst: Label 'You may need to recalculate inventory levels for all Shopify integrated items. Do you want to do it now?';
            begin
                if WithDialog then begin
                    Window.Close();
#if not (BC18 or BC19)
                    if CounterProcessed <> TotalRecNo then begin
                        _ErrorMessageHandler.InformAboutErrors(Enum::"Error Handling Options"::"Show Notification");
                        _ErrorMessageMgt.PopContext(_ErrorContextElement);
                    end;
#endif
                    if SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Inventory Levels") and not RegisterInDataLog then begin
                        if Confirm(DoneLbl + '\' + UpdateInventoryQst, true) then
                            Page.Run(Page::"NPR Spfy Inventory Levels");
                    end else
                        if CounterProcessed = TotalRecNo then
                            Message(DoneLbl);
                end;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(CreateShopifyProducts; CreateAtShopify)
                    {
                        Caption = 'Create Products in Shopify';
                        ToolTip = 'Specifies if you want to create products in Shopify.';
                        ApplicationArea = NPRShopify;

                        trigger OnValidate()
                        begin
                            if CreateAtShopify then
                                RegisterInDataLog := true;
                        end;
                    }
                    field(RegisterChangesInDataLog; RegisterInDataLog)
                    {
                        Caption = 'Register in Data Log';
                        ToolTip = 'Specifies whether you want the change to be recorded in the Data Log. This may result in a request to update the product data sent to Shopify (if item synchronization is enabled).';
                        ApplicationArea = NPRShopify;
                        Editable = not CreateAtShopify;

                        trigger OnValidate()
                        var
                            MustBeTrueErr: Label '"Register in Data Log" must be set to ''true'' when you have selected to create products in Shopify.';
                        begin
                            if not RegisterInDataLog and CreateAtShopify then
                                Error(MustBeTrueErr);
                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            RegisterInDataLog := true;
        end;
    }

    procedure SetOptions(ShopifyStoreCodeIn: Code[20]; WithDialogIn: Boolean)
    begin
        ShopifyStoreCode := ShopifyStoreCodeIn;
        WithDialog := WithDialogIn;
    end;

    var
        ShopifyStore: Record "NPR Spfy Store";
#if not (BC18 or BC19)
        _ErrorContextElement: Codeunit "Error Context Element";
        _ErrorMessageHandler: Codeunit "Error Message Handler";
        _ErrorMessageMgt: Codeunit "Error Message Management";
#endif
        SpfyUpdateItemIntState: Codeunit "NPR Spfy Update Item Int.State";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        Window: Dialog;
        CounterProcessed: Integer;
        RecNo: Integer;
        TotalRecNo: Integer;
        ShopifyStoreCode: Code[20];
        CreateAtShopify: Boolean;
        RegisterInDataLog: Boolean;
        WithDialog: Boolean;
}
#endif