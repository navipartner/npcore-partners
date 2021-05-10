codeunit 6150903 "NPR HC Connector Web Service"
{
    procedure InsertAuditRoll(var auditrolllineimport: XMLport "NPR HC Audit Roll")
    var
        NaviConnectImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
    begin
        SelectLatestVersion();
        auditrolllineimport.Import();
        InsertImportEntry('InsertAuditRoll', 6150904, NaviConnectImportEntry);
        NaviConnectImportEntry."Document Name" := CopyStr('NCConnectorAuditRoll' + auditrolllineimport.GetSalesTicketNo(), 1, MaxStrLen(NaviConnectImportEntry."Document Name") - 4) + '.xml';
        NaviConnectImportEntry."Document Source".CreateOutStream(OutStr);
        auditrolllineimport.SetDestination(OutStr);
        auditrolllineimport.Export();
        NaviConnectImportEntry.Modify(true);
        Commit();

        NaviConnectSyncMgt.ProcessImportEntry(NaviConnectImportEntry);
    end;

    procedure InsertPOSEntry(var posentryimport: XMLport "NPR HC POS Entry")
    var
        NaviConnectImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
    begin
        SelectLatestVersion();
        posentryimport.Import();
        InsertImportEntry('InsertPOSEntry', 6150915, NaviConnectImportEntry);
        NaviConnectImportEntry."Document Name" := 'BCConnectorPOSEntry.xml';
        NaviConnectImportEntry."Document Source".CreateOutStream(OutStr);
        posentryimport.SetDestination(OutStr);
        posentryimport.Export();
        NaviConnectImportEntry.Modify(true);
        Commit();

        NaviConnectSyncMgt.ProcessImportEntry(NaviConnectImportEntry);
    end;

    procedure InsertSalesDocument(var salesdocumentimport: XMLport "NPR HC Sales Document")
    var
        NaviConnectImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
    begin
        SelectLatestVersion();
        salesdocumentimport.Import();
        InsertImportEntry('InsertSalesDocument', 6150906, NaviConnectImportEntry);
        NaviConnectImportEntry."Document Name" := 'HQConenctorSalesDocument.xml';
        NaviConnectImportEntry."Document Source".CreateOutStream(OutStr);
        salesdocumentimport.SetDestination(OutStr);
        salesdocumentimport.Export();
        NaviConnectImportEntry.Modify(true);
        Commit();

        NaviConnectSyncMgt.ProcessImportEntry(NaviConnectImportEntry);
    end;

    procedure InsertCustomer(var customerimport: XMLport "NPR HC Customer")
    var
        NaviConnectImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
    begin
        SelectLatestVersion();
        customerimport.Import();
        InsertImportEntry('InsertCustomer', 6150907, NaviConnectImportEntry);
        NaviConnectImportEntry."Document Name" := 'HQConnectorCustomer.xml';
        NaviConnectImportEntry."Document Source".CreateOutStream(OutStr);
        customerimport.SetDestination(OutStr);
        customerimport.Export();
        NaviConnectImportEntry.Modify(true);
        Commit();

        NaviConnectSyncMgt.ProcessImportEntry(NaviConnectImportEntry);
    end;

    procedure GetCustomerPrice(var customerPriceRequest: XMLport "NPR HC Customer Price Request")
    var
        NaviConnectImportEntry: Record "NPR Nc Import Entry";
        OutStr: OutStream;
        CustomerPriceManagement: Codeunit "NPR HC Customer Price Mgt.";
        TmpSalesHeader: Record "Sales Header" temporary;
        TmpSalesLine: Record "Sales Line" temporary;
    begin
        SelectLatestVersion();
        customerPriceRequest.Import();
        InsertImportEntry('GetCustomerPrice', 6150908, NaviConnectImportEntry);
        NaviConnectImportEntry."Document Name" := 'HQConnectorGetCustomerPrice.xml';

        // Store Request
        NaviConnectImportEntry."Document Source".CreateOutStream(OutStr);
        customerPriceRequest.SetDestination(OutStr);
        customerPriceRequest.Export();
        NaviConnectImportEntry.Modify(true);
        Commit();

        customerPriceRequest.GetRequest(TmpSalesHeader, TmpSalesLine);
        ClearLastError();
        if (not CustomerPriceManagement.TryProcessRequest(TmpSalesHeader, TmpSalesLine)) then begin
            customerPriceRequest.SetErrorResponse(StrSubstNo('<h3>HQ Connect Server:</h3><br>%1', GetLastErrorText));
            NaviConnectImportEntry.Imported := false;
            NaviConnectImportEntry."Runtime Error" := true;
        end else begin
            customerPriceRequest.SetResponse(TmpSalesHeader, TmpSalesLine);
            NaviConnectImportEntry.Imported := true;
            NaviConnectImportEntry."Runtime Error" := false;
        end;

        //Store Result
        NaviConnectImportEntry."Document Source".CreateOutStream(OutStr);
        customerPriceRequest.SetDestination(OutStr);
        customerPriceRequest.Export();
        NaviConnectImportEntry.Modify(true);
        Commit();
    end;

    procedure GenericWebRequest(var genericrequest: XMLport "NPR HC Generic Request")
    var
        NaviConnectImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        HCGenericWebReqManagement: Codeunit "NPR HC Generic Web Req. Mgt.";
        TmpHCGenericWebRequest: Record "NPR HC Generic Web Request" temporary;
    begin
        SelectLatestVersion();
        genericrequest.Import();
        InsertImportEntry('GenericWebRequest', 6150911, NaviConnectImportEntry);
        NaviConnectImportEntry."Document Name" := 'HQConnectorGenericRequest.xml';

        // Store Request
        NaviConnectImportEntry."Document Source".CreateOutStream(OutStr);
        genericrequest.SetDestination(OutStr);
        genericrequest.Export();
        NaviConnectImportEntry.Modify(true);
        Commit();

        genericrequest.GetRequest(TmpHCGenericWebRequest);
        ClearLastError();
        if (not HCGenericWebReqManagement.TryProcessRequest(TmpHCGenericWebRequest)) then begin
            genericrequest.SetErrorResponse(StrSubstNo('<h3>HQ Connect Server:</h3><br>%1', GetLastErrorText));
            NaviConnectImportEntry.Imported := false;
            NaviConnectImportEntry."Runtime Error" := true;
        end else begin
            genericrequest.SetResponse(TmpHCGenericWebRequest);
            NaviConnectImportEntry.Imported := true;
            NaviConnectImportEntry."Runtime Error" := false;
        end;

        //Store Result
        NaviConnectImportEntry."Document Source".CreateOutStream(OutStr);
        genericrequest.SetDestination(OutStr);
        genericrequest.Export();
        NaviConnectImportEntry.Modify(true);
        Commit();

        NaviConnectSyncMgt.ProcessImportEntry(NaviConnectImportEntry);
    end;

    local procedure InsertImportEntry(WebserviceFunction: Text; CodeunitID: Integer; var ImportEntry: Record "NPR Nc Import Entry")
    var
        NaviConnectSetupMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        ImportEntry.Init();
        ImportEntry."Entry No." := 0;
        if NaviConnectSetupMgt.GetImportTypeCode(CodeunitID, WebserviceFunction) = '' then
            InsertImportType(CodeunitID, WebserviceFunction);

        ImportEntry."Import Type" := NaviConnectSetupMgt.GetImportTypeCode(CodeunitID, WebserviceFunction);
        if ImportEntry."Import Type" = '' then
            ImportEntry."Import Type" := NaviConnectSetupMgt.GetImportTypeCode(CodeunitID, '');
        ImportEntry.Date := CurrentDateTime;
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := true;
        ImportEntry.Insert(true);
    end;

    local procedure InsertImportType(CodeunitNo: Integer; Webservicefunction: Text)
    var
        NcImportType: Record "NPR Nc Import Type";
    begin
        NcImportType.Init();
        NcImportType.Code := CopyStr(Webservicefunction, 1, MaxStrLen(NcImportType.Code));
        NcImportType.Description := CopyStr(Webservicefunction, 1, MaxStrLen(NcImportType.Description));
        NcImportType."Keep Import Entries for" := 7 * 24 * 60 * 60 * 1000; //7 days
        NcImportType."Import Codeunit ID" := CodeunitNo;
        NcImportType."Webservice Enabled" := true;
        NcImportType."Webservice Codeunit ID" := CodeunitNo;
        NcImportType."Webservice Function" := Webservicefunction;
        NcImportType.Insert(true);
    end;
}