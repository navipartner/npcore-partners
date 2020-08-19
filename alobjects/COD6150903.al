codeunit 6150903 "HC Connector Web Service"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector Created Object
    // NPR5.38/BR  /20171030 CASE 295007 Added Orderfunction
    // NPR5.38/BR  /20171128 CASE 297946 Added Customer
    // NPR5.38/BR  /20171205 CASE 297946 Added generic web serivce
    // NPR5.39/BR  /20180222 CASE 295007 Added InsertPOSEntry
    // NPR5.44/MHA /20180704 CASE 318391 Added ProcessImportEntry() to Insert functions


    trigger OnRun()
    begin
    end;

        procedure InsertAuditRoll(var auditrolllineimport: XMLport "HC Audit Roll")
    var
        NaviConnectImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
    begin
        SelectLatestVersion;
        auditrolllineimport.Import;
        InsertImportEntry('InsertAuditRoll',6150904,NaviConnectImportEntry);
        //-NPR5.44 [318391]
        //NaviConnectImportEntry."Document Name" := 'BCConnectorAuditRoll.xml';
        NaviConnectImportEntry."Document Name" := CopyStr('NCConnectorAuditRoll' + auditrolllineimport.GetSalesTicketNo(),1,MaxStrLen(NaviConnectImportEntry."Document Name") - 4) + '.xml';
        //+NPR5.44 [318391]
        NaviConnectImportEntry."Document Source".CreateOutStream(OutStr);
        auditrolllineimport.SetDestination(OutStr);
        auditrolllineimport.Export;
        NaviConnectImportEntry.Modify(true);
        Commit;

        //-NPR5.44 [318391]
        NaviConnectSyncMgt.ProcessImportEntry(NaviConnectImportEntry);
        //+NPR5.44 [318391]
    end;

        procedure InsertPOSEntry(var posentryimport: XMLport "HC POS Entry")
    var
        NaviConnectImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
    begin
        //-NPR5.39 [295007]
        SelectLatestVersion;
        posentryimport.Import;
        InsertImportEntry('InsertPOSEntry',6150915,NaviConnectImportEntry);
        NaviConnectImportEntry."Document Name" := 'BCConnectorPOSEntry.xml';
        NaviConnectImportEntry."Document Source".CreateOutStream(OutStr);
        posentryimport.SetDestination(OutStr);
        posentryimport.Export;
        NaviConnectImportEntry.Modify(true);
        Commit;
        //+NPR5.39 [295007]

        //-NPR5.44 [318391]
        NaviConnectSyncMgt.ProcessImportEntry(NaviConnectImportEntry);
        //+NPR5.44 [318391]
    end;

        procedure InsertSalesDocument(var salesdocumentimport: XMLport "HC Sales Document")
    var
        NaviConnectImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
    begin
        //-NPR5.38 [295007]
        SelectLatestVersion;
        salesdocumentimport.Import;
        InsertImportEntry('InsertSalesDocument',6150906,NaviConnectImportEntry);
        NaviConnectImportEntry."Document Name" := 'HQConenctorSalesDocument.xml';
        NaviConnectImportEntry."Document Source".CreateOutStream(OutStr);
        salesdocumentimport.SetDestination(OutStr);
        salesdocumentimport.Export;
        NaviConnectImportEntry.Modify(true);
        Commit;
        //+NPR5.38 [295007]

        //-NPR5.44 [318391]
        NaviConnectSyncMgt.ProcessImportEntry(NaviConnectImportEntry);
        //+NPR5.44 [318391]
    end;

        procedure InsertCustomer(var customerimport: XMLport "HC Customer")
    var
        NaviConnectImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
    begin
        //-NPR5.38 [297946]
        SelectLatestVersion;
        customerimport.Import;
        InsertImportEntry('InsertCustomer',6150907,NaviConnectImportEntry);
        NaviConnectImportEntry."Document Name" := 'HQConnectorCustomer.xml';
        NaviConnectImportEntry."Document Source".CreateOutStream(OutStr);
        customerimport.SetDestination(OutStr);
        customerimport.Export;
        NaviConnectImportEntry.Modify(true);
        Commit;
        //+NPR5.38 [297946]

        //-NPR5.44 [318391]
        NaviConnectSyncMgt.ProcessImportEntry(NaviConnectImportEntry);
        //+NPR5.44 [318391]
    end;

        procedure GetCustomerPrice(var customerPriceRequest: XMLport "HC Customer Price Request")
    var
        NaviConnectImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        CustomerPriceManagement: Codeunit "HC Customer Price Management";
        TmpSalesHeader: Record "Sales Header" temporary;
        TmpSalesLine: Record "Sales Line" temporary;
    begin

        //-NPR5.38 [297859]
        SelectLatestVersion;
        customerPriceRequest.Import;
        InsertImportEntry ('GetCustomerPrice', 6150908, NaviConnectImportEntry);
        NaviConnectImportEntry."Document Name" := 'HQConnectorGetCustomerPrice.xml';

        // Store Request
        NaviConnectImportEntry."Document Source".CreateOutStream(OutStr);
        customerPriceRequest.SetDestination(OutStr);
        customerPriceRequest.Export;
        NaviConnectImportEntry.Modify(true);
        Commit;

        customerPriceRequest.GetRequest (TmpSalesHeader, TmpSalesLine);
        ClearLastError;
        if (not CustomerPriceManagement.TryProcessRequest (TmpSalesHeader, TmpSalesLine)) then begin
          customerPriceRequest.SetErrorResponse (StrSubstNo ('<h3>HQ Connect Server:</h3><br>%1', GetLastErrorText));
          NaviConnectImportEntry.Imported := false;
          NaviConnectImportEntry."Runtime Error" := true;
        end else begin
          customerPriceRequest.SetResponse (TmpSalesHeader, TmpSalesLine);
          NaviConnectImportEntry.Imported := true;
          NaviConnectImportEntry."Runtime Error" := false;
        end;
        asserterror Error (''); // rollback any changes to the database we did in TryProcessRequest()

        //Store Result
        NaviConnectImportEntry."Document Source".CreateOutStream(OutStr);
        customerPriceRequest.SetDestination(OutStr);
        customerPriceRequest.Export;
        NaviConnectImportEntry.Modify(true);
        Commit;

        //+NPR5.38 [297859]
    end;

        procedure GenericWebRequest(var genericrequest: XMLport "HC Generic Request")
    var
        NaviConnectImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        HCGenericWebReqManagement: Codeunit "HC Generic Web Req. Management";
        TmpHCGenericWebRequest: Record "HC Generic Web Request" temporary;
    begin
        //-NPR5.38 [297946]
        SelectLatestVersion;
        genericrequest.Import;
        InsertImportEntry ('GenericWebRequest', 6150911, NaviConnectImportEntry);
        NaviConnectImportEntry."Document Name" := 'HQConnectorGenericRequest.xml';

        // Store Request
        NaviConnectImportEntry."Document Source".CreateOutStream(OutStr);
        genericrequest.SetDestination(OutStr);
        genericrequest.Export;
        NaviConnectImportEntry.Modify(true);
        Commit;

        genericrequest.GetRequest (TmpHCGenericWebRequest);
        ClearLastError;
        if (not HCGenericWebReqManagement.TryProcessRequest (TmpHCGenericWebRequest)) then begin
          genericrequest.SetErrorResponse (StrSubstNo ('<h3>HQ Connect Server:</h3><br>%1', GetLastErrorText));
          NaviConnectImportEntry.Imported := false;
          NaviConnectImportEntry."Runtime Error" := true;
        end else begin
          genericrequest.SetResponse (TmpHCGenericWebRequest);
          NaviConnectImportEntry.Imported := true;
          NaviConnectImportEntry."Runtime Error" := false;
        end;
        asserterror Error (''); // rollback any changes to the database we did in TryProcessRequest()

        //Store Result
        NaviConnectImportEntry."Document Source".CreateOutStream(OutStr);
        genericrequest.SetDestination(OutStr);
        genericrequest.Export;
        NaviConnectImportEntry.Modify(true);
        Commit;
        //+NPR5.38 [297946]

        //-NPR5.44 [318391]
        NaviConnectSyncMgt.ProcessImportEntry(NaviConnectImportEntry);
        //+NPR5.44 [318391]
    end;

    local procedure InsertImportEntry(WebserviceFunction: Text;CodeunitID: Integer;var ImportEntry: Record "Nc Import Entry")
    var
        NaviConnectSetupMgt: Codeunit "Nc Setup Mgt.";
    begin
        ImportEntry.Init;
        ImportEntry."Entry No." := 0;
        if NaviConnectSetupMgt.GetImportTypeCode(CodeunitID,WebserviceFunction) = '' then
          InsertImportType(CodeunitID,WebserviceFunction);

        ImportEntry."Import Type" := NaviConnectSetupMgt.GetImportTypeCode(CodeunitID,WebserviceFunction);
        if ImportEntry."Import Type" = '' then
          ImportEntry."Import Type" := NaviConnectSetupMgt.GetImportTypeCode(CodeunitID,'');
        ImportEntry.Date := CurrentDateTime;
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := true;
        ImportEntry.Insert(true);
    end;

    local procedure InsertImportType(CodeunitNo: Integer;Webservicefunction: Text)
    var
        NcImportType: Record "Nc Import Type";
    begin
        NcImportType.Init;
        NcImportType.Code := CopyStr(Webservicefunction,1,MaxStrLen(NcImportType.Code));
        NcImportType.Description := CopyStr(Webservicefunction,1,MaxStrLen(NcImportType.Description));
        NcImportType."Keep Import Entries for" :=  7 * 24 * 60 * 60 * 1000; //7 days
        NcImportType."Import Codeunit ID" := CodeunitNo;
        NcImportType."Webservice Enabled" := true;
        NcImportType."Webservice Codeunit ID" :=  CodeunitNo;
        NcImportType."Webservice Function" := Webservicefunction;
        NcImportType.Insert(true);
    end;
}

