#if not (BC17 or BC18 or BC19 or BC20)
report 6014570 "NPR Spfy Export POS Entries"
{
    Extensible = false;
    Caption = 'Export POS Entries to Shopify';
    UsageCategory = None;
    ProcessingOnly = true;
    Description = 'The batch job will initiate the export of customer POS sales transactions from Business Central to Shopify. The system will iterate through customers and their existing POS entries in Business Central and create transaction export requests for Shopify.';

    dataset
    {
        dataitem(ShopifyStoreDataItem; "NPR Spfy Store")
        {
            RequestFilterFields = Code;

            trigger OnAfterGetRecord()
            var
                SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
            begin
                if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"BC Customer Transactions", ShopifyStoreDataItem) then
                    TempSpfyExportPointerBuffer.Add(ShopifyStoreDataItem.Code, ShopifyStoreDataItem."Historical Data Cut-Off Date", 0);
            end;
        }
        dataitem(CustomerDataItem; Customer)
        {
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            var
                WindowDialogLbl1: Label 'Requesting export of POS Entries to Shopify...\\';
                WindowDialogLbl2: Label 'Customer No. #1##########\';
                WindowDialogLbl3: Label 'Processing POS entries @2@@@@@@@@@@';
            begin
                TempSpfyExportPointerBuffer.CheckIfScopeIsNotEmpty();

                if GuiAllowed() then
                    Window.Open(
                        WindowDialogLbl1 +
                        WindowDialogLbl2 +
                        WindowDialogLbl3);

                SpfyStoreFilter := TempSpfyExportPointerBuffer.GetSpfyStoreFilter();
            end;

            trigger OnAfterGetRecord()
            var
                POSEntry: Record "NPR POS Entry";
                SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
                SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
                RecNo: Integer;
                TotalRecNo: Integer;
            begin
                if GuiAllowed() then begin
                    Window.Update(1, CustomerDataItem."No.");
                    Window.Update(2, 0);
                    RecNo := 0;
                end;

                SpfyStoreCustomerLink.SetCurrentKey("Sync. to this Store");
                SpfyStoreCustomerLink.SetRange("Sync. to this Store", true);
                SpfyStoreCustomerLink.SetRange(Type, SpfyStoreCustomerLink.Type::Customer);
                SpfyStoreCustomerLink.SetRange("No.", CustomerDataItem."No.");
                SpfyStoreCustomerLink.SetFilter("Shopify Store Code", SpfyStoreFilter);
                if SpfyStoreCustomerLink.IsEmpty() then
                    CurrReport.Skip();

                POSEntry.SetCurrentKey("Customer No.");
                POSEntry.SetRange("Customer No.", CustomerDataItem."No.");
                if GuiAllowed() then
                    TotalRecNo := POSEntry.Count();
                if POSEntry.FindSet() then
                    repeat
                        SpfyPOSEntryExportMgt.ProcessPOSEntry(POSEntry, SpfyStoreCustomerLink, TempSpfyExportPointerBuffer);

                        if GuiAllowed() then begin
                            RecNo += 1;
                            Window.Update(2, Round(RecNo / TotalRecNo * 10000, 1));
                        end;
                    until POSEntry.Next() = 0;
            end;

            trigger OnPostDataItem()
            begin
                if GuiAllowed() then
                    Window.Close();
            end;
        }
    }

    trigger OnPreReport()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ConfirmQst: Label 'The batch job will initiate the export of customer POS sales transactions from Business Central to Shopify. The system will iterate through customers and their existing POS entries in Business Central and create transaction export requests for Shopify.';
    begin
        if not Confirm(ConfirmQst + '\' + SpfyIntegrationMgt.LongRunningProcessConfirmQst(), true) then
            CurrReport.Quit();
    end;

    var
        TempSpfyExportPointerBuffer: Record "NPR Spfy Export Pointer Buffer" temporary;
        Window: Dialog;
        SpfyStoreFilter: Text;
}
#endif