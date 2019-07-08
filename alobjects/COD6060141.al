codeunit 6060141 "MM Loyalty WebService"
{
    // MM1.19/NPKNAV/20170525  CASE 274690 Transport MM1.20 - 25 May 2017
    // MM1.37/TSA /20190204 CASE 338215 Points for payment, RegisterSale(), ReservePoints()
    // MM130.1.37/TSA /20190110 CASE 353981 Changed property "Functional Visibility" to External
    // MM1.38/TSA /20190523 CASE 338215 Added Service GetLoyaltyConfiguration


    trigger OnRun()
    begin
    end;

    var
        SETUP_MISSING: Label 'Setup is missing for %1.';

    [Scope('Personalization')]
    procedure GetLoyaltyPoints(var GetLoyaltyPoints: XMLport "MM Get Loyalty Points")
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
    begin
        GetLoyaltyPoints.Import ();

        InsertImportEntry ('GetLoyaltyPoints', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('GetLoyaltyPoints-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetLoyaltyPoints.SetDestination (OutStr);
        GetLoyaltyPoints.Export;
        ImportEntry.Modify(true);
        Commit ();

        MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
        MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");

        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin
          GetLoyaltyPoints.ClearResponse ();

          MemberInfoCapture.FindFirst ();
          GetLoyaltyPoints.AddResponse (MemberInfoCapture."Membership Entry No.");

        end else begin
          GetLoyaltyPoints.AddErrorResponse (ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream (OutStr);
        GetLoyaltyPoints.SetDestination (OutStr);
        GetLoyaltyPoints.Export;
        ImportEntry.Modify(true);

        MemberInfoCapture.DeleteAll ();
    end;

    [Scope('Personalization')]
    procedure GetLoyaltyPointEntries(var GetLoyaltyStatement: XMLport "MM Get Loyalty Statement")
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
    begin
        GetLoyaltyStatement.Import ();

        InsertImportEntry ('GetLoyaltyPointEntries', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('GetLoyaltyPointEntries-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetLoyaltyStatement.SetDestination (OutStr);
        GetLoyaltyStatement.Export;
        ImportEntry.Modify(true);
        Commit ();

        MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
        MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");

        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin
          GetLoyaltyStatement.ClearResponse ();

          MemberInfoCapture.FindFirst ();
          GetLoyaltyStatement.AddResponse (MemberInfoCapture."Membership Entry No.");

        end else begin
          GetLoyaltyStatement.AddErrorResponse (ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream (OutStr);
        GetLoyaltyStatement.SetDestination (OutStr);
        GetLoyaltyStatement.Export;
        ImportEntry.Modify(true);

        MemberInfoCapture.DeleteAll ();
    end;

    local procedure "*** LoyaltyServerFunctions ***"()
    begin
    end;

    [Scope('Personalization')]
    procedure RegisterSale(var RegisterSale: XMLport "MM Register Sale")
    var
        TmpAuthorization: Record "MM Loyalty Ledger Entry (Srvr)" temporary;
        TmpSalesLines: Record "MM Register Sales Buffer" temporary;
        TmpPaymentLines: Record "MM Register Sales Buffer" temporary;
        TmpPointsResponse: Record "MM Loyalty Ledger Entry (Srvr)" temporary;
        ImportEntry: Record "Nc Import Entry";
        OutStr: OutStream;
        LoyaltyWebServiceMgr: Codeunit "MM Loyalty WebService Mgr";
        LoyaltyPointsMgrServer: Codeunit "MM Loyalty Points Mgr (Server)";
        ResponseMessage: Text;
        ResponseMessageId: Text;
    begin

        RegisterSale.Import ();

        InsertImportEntry ('RegisterSale', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('RegisterSale-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));
        ImportEntry.Modify (true);
        Commit ();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        RegisterSale.SetDestination (OutStr);
        RegisterSale.Export;
        ImportEntry.Modify(true);
        Commit ();

        // Process
        RegisterSale.SetDocumentId := ImportEntry."Document ID";
        RegisterSale.GetRequest (TmpAuthorization, TmpSalesLines, TmpPaymentLines);
        if (LoyaltyPointsMgrServer.RegisterSales (TmpAuthorization, TmpSalesLines, TmpPaymentLines, TmpPointsResponse, ResponseMessage, ResponseMessageId)) then begin
          RegisterSale.SetResponse (TmpPointsResponse);

          ImportEntry.Imported := true;
          ImportEntry."Runtime Error" := false;
        end else begin
          RegisterSale.SetErrorResponse (ResponseMessage, ResponseMessageId);

          ImportEntry.Imported := true;
          ImportEntry."Runtime Error" := true;
        end;

        ImportEntry."Document Source".CreateOutStream (OutStr);
        RegisterSale.SetDestination (OutStr);
        RegisterSale.Export;

        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;

        ImportEntry.Modify(true);
    end;

    [Scope('Personalization')]
    procedure ReservePoints(var ReservePoints: XMLport "MM Reserve Points")
    var
        TmpAuthorization: Record "MM Loyalty Ledger Entry (Srvr)" temporary;
        TmpPaymentLines: Record "MM Register Sales Buffer" temporary;
        TmpPointsResponse: Record "MM Loyalty Ledger Entry (Srvr)" temporary;
        ImportEntry: Record "Nc Import Entry";
        OutStr: OutStream;
        LoyaltyWebServiceMgr: Codeunit "MM Loyalty WebService Mgr";
        LoyaltyPointsMgrServer: Codeunit "MM Loyalty Points Mgr (Server)";
        ResponseMessage: Text;
        ResponseMessageId: Text;
    begin

        ReservePoints.Import ();

        InsertImportEntry ('ReservePoints', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('ReservePoints-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));
        ImportEntry.Modify (true);
        Commit ();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        ReservePoints.SetDestination (OutStr);
        ReservePoints.Export;
        ImportEntry.Modify(true);
        Commit ();

        // Process
        ReservePoints.SetDocumentId := ImportEntry."Document ID";
        ReservePoints.GetRequest (TmpAuthorization, TmpPaymentLines);
        if (LoyaltyPointsMgrServer.ReservePoints (TmpAuthorization, TmpPaymentLines, TmpPointsResponse, ResponseMessage, ResponseMessageId)) then begin
          ReservePoints.SetResponse (TmpPointsResponse);

          ImportEntry.Imported := true;
          ImportEntry."Runtime Error" := false;
        end else begin
          ReservePoints.SetErrorResponse (ResponseMessage, ResponseMessageId);

          ImportEntry.Imported := true;
          ImportEntry."Runtime Error" := true;
        end;

        ImportEntry."Document Source".CreateOutStream (OutStr);
        ReservePoints.SetDestination (OutStr);
        ReservePoints.Export;

        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;

        ImportEntry.Modify(true);
    end;

    local procedure ReleaseReservation()
    begin
    end;

    procedure GetLoyaltyConfiguration(var GetLoyaltyConfiguration: XMLport "MM Get Loyalty Configuration")
    var
        TmpAuthorization: Record "MM Loyalty Ledger Entry (Srvr)" temporary;
        TmpLoyaltySetup: Record "MM Loyalty Setup" temporary;
        ImportEntry: Record "Nc Import Entry";
        OutStr: OutStream;
        LoyaltyWebServiceMgr: Codeunit "MM Loyalty WebService Mgr";
        LoyaltyPointsMgrServer: Codeunit "MM Loyalty Points Mgr (Server)";
        ResponseMessage: Text;
        ResponseMessageId: Text;
    begin

        GetLoyaltyConfiguration.Import ();

        InsertImportEntry ('GetLoyaltyConfiguration', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('GetLoyaltyConfiguration-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));
        ImportEntry.Modify (true);
        Commit ();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetLoyaltyConfiguration.SetDestination (OutStr);
        GetLoyaltyConfiguration.Export;
        ImportEntry.Modify(true);
        Commit ();

        // Process
        GetLoyaltyConfiguration.SetDocumentId := ImportEntry."Document ID";
        GetLoyaltyConfiguration.GetRequest (TmpAuthorization);

        if (LoyaltyPointsMgrServer.GetLoyaltySetup (TmpAuthorization, TmpLoyaltySetup, ResponseMessage, ResponseMessageId)) then begin
          GetLoyaltyConfiguration.SetResponse (TmpLoyaltySetup);

          ImportEntry.Imported := true;
          ImportEntry."Runtime Error" := false;
        end else begin
          GetLoyaltyConfiguration.SetErrorResponse (ResponseMessage, ResponseMessageId);

          ImportEntry.Imported := true;
          ImportEntry."Runtime Error" := true;
        end;

        ImportEntry."Document Source".CreateOutStream (OutStr);
        GetLoyaltyConfiguration.SetDestination (OutStr);
        GetLoyaltyConfiguration.Export;

        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;

        ImportEntry.Modify(true);
    end;

    local procedure "--Locals"()
    begin
    end;

    local procedure InsertImportEntry(WebserviceFunction: Text;var ImportEntry: Record "Nc Import Entry")
    var
        NaviConnectSetupMgt: Codeunit "Nc Setup Mgt.";
    begin
        ImportEntry.Init;
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"MM Loyalty WebService", WebserviceFunction);
        if (ImportEntry."Import Type" = '') then begin
          IntegrationSetup ();
          ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"MM Loyalty WebService", WebserviceFunction);
          if (ImportEntry."Import Type" = '') then
            Error (SETUP_MISSING, WebserviceFunction);
        end;

        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := StrSubstNo('%1-%2.xml', ImportEntry."Import Type", Format(ImportEntry.Date,0,9));
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := false;
        ImportEntry.Insert(true);
    end;

    local procedure IntegrationSetup()
    var
        ImportType: Record "Nc Import Type";
    begin
        ImportType.SetFilter ("Webservice Codeunit ID", '=%1', CODEUNIT::"MM Loyalty WebService");
        if (not ImportType.IsEmpty ()) then
          ImportType.DeleteAll ();

        CreateImportType ('LOYALTY-01', 'LoyaltyManagement', 'GetLoyaltyPoints');
        CreateImportType ('LOYALTY-02', 'LoyaltyManagement', 'GetLoyaltyPointEntries');

        CreateImportType ('POINTS-01', 'PointManagement', 'RegisterSale');
        CreateImportType ('POINTS-02', 'PointManagement', 'ReservePoints');
        CreateImportType ('POINTS-03', 'PointManagement', 'GetLoyaltyConfiguration');

        Commit;
    end;

    local procedure CreateImportType("Code": Code[20];Description: Text[30];FunctionName: Text[30])
    var
        ImportType: Record "Nc Import Type";
    begin

        ImportType.Code := Code;
        ImportType.Description := Description;
        ImportType."Webservice Function" := FunctionName;

        ImportType."Webservice Enabled" := true;
        ImportType."Import Codeunit ID" := CODEUNIT::"MM Loyalty WebService Mgr";
        ImportType."Webservice Codeunit ID" := CODEUNIT::"MM Loyalty WebService";

        ImportType.Insert ();
    end;

    local procedure GetImportTypeCode(WebServiceCodeunitID: Integer;WebserviceFunction: Text): Code[10]
    var
        ImportType: Record "Nc Import Type";
    begin

        Clear(ImportType);
        ImportType.SetRange("Webservice Codeunit ID",WebServiceCodeunitID);
        ImportType.SetFilter("Webservice Function",'%1',CopyStr(WebserviceFunction,1,MaxStrLen(ImportType."Webservice Function")));

        if ImportType.FindFirst then
          exit(ImportType.Code);

        exit('');
    end;
}

