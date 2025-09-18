#if not BC17
report 6014568 "NPR Spfy Cust. Re-sync Options"
{
    Extensible = false;
    Caption = 'Customer Re-sync Options';
    UsageCategory = None;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            var
#if not (BC18 or BC19)
                BatchProcessingTxt: Label 'Resyncing customers for Shopify store %1.', Comment = '%1 - Shopify store code';
#endif
                ConfirmQst: Label 'This function will go through your selected customers in BC and mark those already existing in your Shopify Store ''%1'' as ''Shopify Customers''.';
                DialogText1Lbl: Label 'Updating customers from Shopify Store ''%1''...\\';
                DialogText2Lbl: Label 'Customer No. #1########\';
                DialogText3Lbl: Label 'Progress @2@@@@@@@@';
                NothingToDoErr: Label 'There is nothing to do (there are no customers in the system).';
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
                TotalRecNo := Customer.Count();
                if TotalRecNo = 0 then
                    Error(NothingToDoErr);

                Clear(SpfyUpdateCustIntState);
                SpfyUpdateCustIntState.SetProcessingOptions(ShopifyStore, not RegisterInDataLog, CreateAtShopify);

                if WithDialog then begin
#if not (BC18 or BC19)
                    if _ErrorMessageMgt.Activate(_ErrorMessageHandler) then
                        _ErrorMessageMgt.PushContext(_ErrorContextElement, Database::Customer, 0, StrSubstNo(BatchProcessingTxt, ShopifyStore.Code));
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
                ProcessingMsg: Label 'Processing Customer %1.', Comment = '%1 - Customer number';
#endif
            begin
                if WithDialog then begin
                    Window.Update(1, Customer."No.");
#if not (BC18 or BC19)                    
                    ErrorMessageMgt.PushContext(ErrorContextElement, Customer.RecordId(), 0, StrSubstNo(ProcessingMsg, Customer."No."));
#endif
                end;

                Success := SpfyUpdateCustIntState.Run(Customer);
                if Success then
                    CounterProcessed += 1;

                if WithDialog then begin
#if not (BC18 or BC19)
                    if not Success then begin
                        ErrorMessage := GetLastErrorText();
                        if ErrorMessage = '' then
                            ErrorMessage := DefaultErrorMsg;
                        ErrorMessageMgt.LogError(Customer, ErrorMessage, '');
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
            begin
                if WithDialog then begin
                    Window.Close();
#if not (BC18 or BC19)
                    if CounterProcessed <> TotalRecNo then begin
                        _ErrorMessageHandler.InformAboutErrors(Enum::"Error Handling Options"::"Show Notification");
                        _ErrorMessageMgt.PopContext(_ErrorContextElement);
                    end;
#endif
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
                    field(CreateShopifyCustomers; CreateAtShopify)
                    {
                        Caption = 'Create Customers in Shopify';
                        ToolTip = 'Specifies if you want to create customers in Shopify.';
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
                        ToolTip = 'Specifies whether you want the change to be recorded in the Data Log. This may result in a request to update the customer data sent to Shopify (if customer synchronization is enabled).';
                        ApplicationArea = NPRShopify;
                        Editable = not CreateAtShopify;

                        trigger OnValidate()
                        var
                            MustBeTrueErr: Label '"Register in Data Log" must be set to ''true'' when you have selected to create customers in Shopify.';
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
        SpfyUpdateCustIntState: Codeunit "NPR Spfy Update Cust.Int.State";
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