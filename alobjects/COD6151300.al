codeunit 6151300 "NpEc Webservice"
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Create Sales Order';
        Text001: Label 'Post Sales Order';
        Text002: Label 'Delete Sales Order';

    [Scope('Personalization')]
    procedure CreateSalesOrder(var sales_orders: XMLport "NpEc Sales Order Import")
    var
        ImportEntry: Record "Nc Import Entry";
        NcSyncMgt: Codeunit "Nc Sync. Mgt.";
        NcImportMgt: Codeunit "Nc Import Mgt.";
        OutStr: OutStream;
        NcImportType: Record "Nc Import Type";
    begin
        InitImportType('CreateSalesOrder','CREATE_SALES_ORDER',Text000,CODEUNIT::"NpEc S.Order Import (Create)",CODEUNIT::"NpEc S.Order Lookup",NcImportType);

        sales_orders.Import;
        InsertImportEntry(NcImportType,ImportEntry);
        ImportEntry."Document Name" := sales_orders.GetOrderNo() + '.xml';
        ImportEntry."Document Source".CreateOutStream(OutStr);
        sales_orders.SetDestination(OutStr);
        sales_orders.Export;
        ImportEntry.Modify(true);
        Commit;

        NcSyncMgt.ProcessImportEntry(ImportEntry);
        Commit;
        if ImportEntry.Find and not ImportEntry.Imported then
          Error(NcImportMgt.GetErrorMessage(ImportEntry,false));
    end;

    [Scope('Personalization')]
    procedure PostSalesOrder(var sales_orders: XMLport "NpEc Sales Order Import")
    var
        ImportEntry: Record "Nc Import Entry";
        NcSyncMgt: Codeunit "Nc Sync. Mgt.";
        NcImportMgt: Codeunit "Nc Import Mgt.";
        OutStr: OutStream;
        NcImportType: Record "Nc Import Type";
        NcSetupMgt: Codeunit "Nc Setup Mgt.";
    begin
        InitImportType('PostSalesOrder','POST_SALES_ORDER',Text001,CODEUNIT::"NpEc S.Order Import (Post)",CODEUNIT::"NpEc S.Order Lookup",NcImportType);

        sales_orders.Import;
        InsertImportEntry(NcImportType,ImportEntry);
        ImportEntry."Document Name" :=sales_orders.GetOrderNo() + '.xml';
        ImportEntry."Document Source".CreateOutStream(OutStr);
        sales_orders.SetDestination(OutStr);
        sales_orders.Export;
        ImportEntry.Modify(true);
        Commit;

        NcSyncMgt.ProcessImportEntry(ImportEntry);
        Commit;
        if ImportEntry.Find and not ImportEntry.Imported then
          Error(NcImportMgt.GetErrorMessage(ImportEntry,false));
    end;

    [Scope('Personalization')]
    procedure DeleteSalesOrder(var sales_orders: XMLport "NpEc Sales Order Import")
    var
        ImportEntry: Record "Nc Import Entry";
        NcSyncMgt: Codeunit "Nc Sync. Mgt.";
        NcImportMgt: Codeunit "Nc Import Mgt.";
        OutStr: OutStream;
        NcImportType: Record "Nc Import Type";
        NcSetupMgt: Codeunit "Nc Setup Mgt.";
    begin
        InitImportType('DeleteSalesOrder','DELETE_SALES_ORDER',Text002,CODEUNIT::"NpEc S.Order Import (Delete)",CODEUNIT::"NpEc S.Order Lookup",NcImportType);

        sales_orders.Import;
        InsertImportEntry(NcImportType,ImportEntry);
        ImportEntry."Document Name" := sales_orders.GetOrderNo() + '.xml';
        ImportEntry."Document Source".CreateOutStream(OutStr);
        sales_orders.SetDestination(OutStr);
        sales_orders.Export;
        ImportEntry.Modify(true);
        Commit;

        NcSyncMgt.ProcessImportEntry(ImportEntry);
        Commit;
        if ImportEntry.Find and not ImportEntry.Imported then
          Error(NcImportMgt.GetErrorMessage(ImportEntry,false));
    end;

    [Scope('Personalization')]
    procedure CreatePurchaseInvoice(var purchase_invoices: XMLport "NpEc Purch. Invoice Import")
    var
        ImportEntry: Record "Nc Import Entry";
        NcImportType: Record "Nc Import Type";
        NcSyncMgt: Codeunit "Nc Sync. Mgt.";
        NcImportMgt: Codeunit "Nc Import Mgt.";
        OutStr: OutStream;
    begin
        InitImportType('CreatePurchaseInvoice','CREATE_PURCH_ORDER',Text000,CODEUNIT::"NpEc P.Invoice Import (Create)",CODEUNIT::"NpEc P.Invoice Lookup",NcImportType);

        purchase_invoices.Import;
        InsertImportEntry(NcImportType,ImportEntry);
        ImportEntry."Document Name" := purchase_invoices.GetInvoiceNo() + '.xml';
        ImportEntry."Document Source".CreateOutStream(OutStr);
        purchase_invoices.SetDestination(OutStr);
        purchase_invoices.Export;
        ImportEntry.Modify(true);
        Commit;

        NcSyncMgt.ProcessImportEntry(ImportEntry);
        Commit;
        if ImportEntry.Find and not ImportEntry.Imported then
          Error(NcImportMgt.GetErrorMessage(ImportEntry,false));
    end;

    local procedure InsertImportEntry(NcImportType: Record "Nc Import Type";var ImportEntry: Record "Nc Import Entry")
    begin
        ImportEntry.Init;
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := NcImportType.Code;
        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := ImportEntry."Import Type" + '-' + Format(ImportEntry.Date,0,9) + '.xml';
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := true;
        ImportEntry.Insert(true);
    end;

    local procedure InitImportType(WebserviceFunction: Text;ImportTypeCode: Code[20];ImportTypeDescription: Text;ImportCodeunitID: Integer;LookupCodeunitID: Integer;var NcImportType: Record "Nc Import Type")
    var
        NcSetupMgt: Codeunit "Nc Setup Mgt.";
    begin
        NcImportType.Code := NcSetupMgt.GetImportTypeCode(CurrCodeunitId(),WebserviceFunction);
        if (NcImportType.Code <> '') and NcImportType.Find then
          exit;

        if NcImportType.Get(ImportTypeCode) then begin
          ImportTypeCode := ImportTypeCode + '1';
          while NcImportType.Get(ImportTypeCode) do
            ImportTypeCode := IncStr(ImportTypeCode);
        end;

        NcImportType.Init;
        NcImportType.Code := ImportTypeCode;
        NcImportType.Description := CopyStr(ImportTypeDescription,1,MaxStrLen(ImportTypeCode));
        NcImportType."Import Codeunit ID" := ImportCodeunitID;
        NcImportType."Lookup Codeunit ID" := LookupCodeunitID;
        NcImportType."Webservice Enabled" := true;
        NcImportType."Webservice Function" := WebserviceFunction;
        NcImportType."Webservice Codeunit ID" := CurrCodeunitId();
        NcImportType."Keep Import Entries for" := CreateDateTime(Today,0T) - CreateDateTime(CalcDate('<-90D>',Today),010000T);
        NcImportType.Insert(true);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpEc Webservice");
    end;
}

