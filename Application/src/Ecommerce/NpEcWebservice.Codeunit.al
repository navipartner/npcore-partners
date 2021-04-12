codeunit 6151300 "NPR NpEc Webservice"
{
    var
        CreateSalesOrderDescLbl: Label 'Create Sales Order';
        CreatePurchOrderDescLbl: Label 'Create Purchase Order';
        PostSalesOrderDescLbl: Label 'Post Sales Order';
        DeleteSalesOrderDescLbl: Label 'Delete Sales Order';

    procedure CreateSalesOrder(var sales_orders: XMLport "NPR NpEc Sales Order Import")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NcImportType: Record "NPR Nc Import Type";
        OutStr: OutStream;
    begin
        InitImportType('CreateSalesOrder', 'CREATE_SALES_ORDER', CreateSalesOrderDescLbl, CODEUNIT::"NPR NpEc S.Order Import Create", CODEUNIT::"NPR NpEc S.Order Lookup", NcImportType);

        InsertImportEntry(NcImportType, ImportEntry);
        sales_orders.Import();
        ImportEntry."Document Name" := sales_orders.GetOrderNo() + '.xml';
        ImportEntry."Document Source".CreateOutStream(OutStr);
        sales_orders.SetDestination(OutStr);
        sales_orders.Export();
        ImportEntry.Modify(true);
        Commit();

        ProcessImportEntry(ImportEntry);
    end;

    procedure ProcessImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    var
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        NcImportMgt: Codeunit "NPR Nc Import Mgt.";
    begin
        NcSyncMgt.ProcessImportEntry(ImportEntry);
        Commit();
        if ImportEntry.Find() and not ImportEntry.Imported then
            Error(NcImportMgt.GetErrorMessage(ImportEntry, false));
    end;

    procedure PostSalesOrder(var sales_orders: XMLport "NPR NpEc Sales Order Import")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NcImportType: Record "NPR Nc Import Type";
        OutStr: OutStream;
    begin
        InitImportType('PostSalesOrder', 'POST_SALES_ORDER', PostSalesOrderDescLbl, CODEUNIT::"NPR NpEc S.Order Import (Post)", CODEUNIT::"NPR NpEc S.Order Lookup", NcImportType);

        sales_orders.Import();
        InsertImportEntry(NcImportType, ImportEntry);
        ImportEntry."Document Name" := sales_orders.GetOrderNo() + '.xml';
        ImportEntry."Document Source".CreateOutStream(OutStr);
        sales_orders.SetDestination(OutStr);
        sales_orders.Export();
        ImportEntry.Modify(true);
        Commit();

        ProcessImportEntry(ImportEntry);
    end;

    procedure DeleteSalesOrder(var sales_orders: XMLport "NPR NpEc Sales Order Import")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NcImportType: Record "NPR Nc Import Type";
        OutStr: OutStream;
    begin
        InitImportType('DeleteSalesOrder', 'DELETE_SALES_ORDER', DeleteSalesOrderDescLbl, CODEUNIT::"NPR NpEc S.Order Imp. Delete", CODEUNIT::"NPR NpEc S.Order Lookup", NcImportType);

        sales_orders.Import();
        InsertImportEntry(NcImportType, ImportEntry);
        ImportEntry."Document Name" := sales_orders.GetOrderNo() + '.xml';
        ImportEntry."Document Source".CreateOutStream(OutStr);
        sales_orders.SetDestination(OutStr);
        sales_orders.Export();
        ImportEntry.Modify(true);
        Commit();

        ProcessImportEntry(ImportEntry);
    end;

    procedure CreatePurchaseInvoice(var purchase_invoices: XMLport "NPR NpEc Purch. Invoice Import")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NcImportType: Record "NPR Nc Import Type";
        OutStr: OutStream;
    begin
        InitImportType('CreatePurchaseInvoice', 'CREATE_PURCH_ORDER', CreatePurchOrderDescLbl, CODEUNIT::"NPR NpEc P.Invoice Imp. Create", CODEUNIT::"NPR NpEc P.Invoice Look.", NcImportType);

        purchase_invoices.Import();
        InsertImportEntry(NcImportType, ImportEntry);
        ImportEntry."Document Name" := purchase_invoices.GetInvoiceNo() + '.xml';
        ImportEntry."Document Source".CreateOutStream(OutStr);
        purchase_invoices.SetDestination(OutStr);
        purchase_invoices.Export();
        ImportEntry.Modify(true);
        Commit();

        ProcessImportEntry(ImportEntry);
    end;

    procedure InsertImportEntry(NcImportType: Record "NPR Nc Import Type"; var ImportEntry: Record "NPR Nc Import Entry")
    begin
        ImportEntry.Init();
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := NcImportType.Code;
        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := ImportEntry."Import Type" + '-' + Format(ImportEntry.Date, 0, 9) + '.xml';
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := true;
        ImportEntry.Insert(true);
    end;

    procedure InitImportType(WebserviceFunction: Text; ImportTypeCode: Code[20]; ImportTypeDescription: Text; ImportCodeunitID: Integer; LookupCodeunitID: Integer; var NcImportType: Record "NPR Nc Import Type")
    var
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        NcImportType.Code := NcSetupMgt.GetImportTypeCode(CurrCodeunitId(), WebserviceFunction);
        if (NcImportType.Code <> '') and NcImportType.Find() then
            exit;

        if NcImportType.Get(ImportTypeCode) then begin
            ImportTypeCode := ImportTypeCode + '1';
            while NcImportType.Get(ImportTypeCode) do
                ImportTypeCode := IncStr(ImportTypeCode);
        end;

        NcImportType.Init();
        NcImportType.Code := ImportTypeCode;
        NcImportType.Description := CopyStr(ImportTypeDescription, 1, MaxStrLen(ImportTypeCode));
        NcImportType."Import Codeunit ID" := ImportCodeunitID;
        NcImportType."Lookup Codeunit ID" := LookupCodeunitID;
        NcImportType."Webservice Enabled" := true;
        NcImportType."Webservice Function" := WebserviceFunction;
        NcImportType."Webservice Codeunit ID" := CurrCodeunitId();
        NcImportType."Keep Import Entries for" := CreateDateTime(Today, 0T) - CreateDateTime(CalcDate('<-90D>', Today), 010000T);
        NcImportType.Insert(true);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpEc Webservice");
    end;
}

