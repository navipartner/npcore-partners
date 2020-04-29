codeunit 6151533 "Nc Coll. Req. WebService Mgr"
{
    // NC2.01/BR  /20160912  CASE 250447 NaviConnect: Object created
    // NC2.08/BR  /20171123  CASE 297355 Deleted unused variables

    TableNo = "Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: DotNet npNetXmlDocument;
        ImportType: Record "Nc Import Type";
        FunctionName: Text[100];
    begin

        if LoadXmlDoc (XmlDoc) then begin
          FunctionName := GetWebserviceFunction ("Import Type");
          case FunctionName of
            'Createcollectorrequest' : CreateCollectorRequests (XmlDoc,  "Entry No.", "Document ID");
            else
              Error (MISSING_CASE, "Import Type", FunctionName);
          end;

        end;
    end;

    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Initialized: Boolean;
        ITEM_NOT_FOUND: Label 'The sales item specified in external_id %1, was not found.';
        CHANGE_NOT_ALLOWED: Label 'Confirmed tickets can''t be changed.';
        TOKEN_NOT_FOUND: Label 'The token %1 was not found, or has incorrect state.';
        TOKEN_EXPIRED: Label 'The token %1 has expired. Use PreConfirm to re-reserve tickets.';
        TOKEN_INCORRECT_STATE: Label 'The token %1 can''t be changed when in the %1 state.';
        MISSING_CASE: Label 'No handler for %1 [%2].';
        VENDOR_NOT_FOUND: Label 'The Vendor %1 could not be found in the database.';

    local procedure CreateCollectorRequests(XmlDoc: DotNet npNetXmlDocument;RequestEntryNo: Integer;DocumentID: Text[100])
    var
        XmlElement: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        i: Integer;
        Token: Text[50];
    begin
        if IsNull(XmlDoc) then
          exit;
        XmlElement := XmlDoc.DocumentElement;
        if IsNull(XmlElement) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'Createcollectorrequest',XmlNodeList) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'Collectorrequestimport',XmlNodeList) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'insertcollectorrequest',XmlNodeList) then
          exit;

        XmlElement := XmlNodeList.ItemOf(0);

        SetImportParameters (XmlElement, Token) ;

        if not NpXmlDomMgt.FindNodes(XmlElement,'collectorrequest',XmlNodeList) then
          exit;

        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement := XmlNodeList.ItemOf(i);
          CreateCollectorRequest (XmlElement, Token, DocumentID);
        end;

        Commit;
    end;

    local procedure CreateCollectorRequest(XmlElement: DotNet npNetXmlElement;Token: Text[100];DocumentID: Text[100]) Imported: Boolean
    var
        XmlNodeList: DotNet npNetXmlNodeList;
        NcCollectorRequest: Record "Nc Collector Request";
        i: Integer;
    begin

        if IsNull(XmlElement) then
          exit(false);

        NcCollectorRequest.Init ();

        ReadCollectorRequest (XmlElement, Token, NcCollectorRequest);
          if NpXmlDomMgt.FindNodes(XmlElement,'collectorrequestfilter',XmlNodeList) then
            for i := 0 to XmlNodeList.Count - 1 do begin
              XmlElement := XmlNodeList.ItemOf(i);
              CreateCollectorRequestFilter (XmlElement, Token, DocumentID, NcCollectorRequest);
            end;
        //NcCollectorRequest.ProcessQuery;
        InsertCollectorRequests (NcCollectorRequest);


        exit(true);
    end;

    local procedure CreateCollectorRequestFilter(XmlElement: DotNet npNetXmlElement;Token: Text[100];DocumentID: Text[100];var NcCollectorRequest: Record "Nc Collector Request") Imported: Boolean
    var
        NcCollectorRequestFilter: Record "Nc Collector Request Filter";
    begin

        if IsNull(XmlElement) then
          exit(false);

        NcCollectorRequestFilter.Init ();

        ReadCollectorRequestFilter (XmlElement, Token, NcCollectorRequestFilter, NcCollectorRequest);
        InsertCollectorRequestFilters (NcCollectorRequestFilter);

        exit(true);
    end;

    local procedure "---Database"()
    begin
    end;

    local procedure InsertCollectorRequests(var NcCollectorRequest: Record "Nc Collector Request"): Boolean
    var
        ResponseMessage: Text;
        ResponseCode: Integer;
    begin

        NcCollectorRequest.Init ();
    end;

    local procedure ReadCollectorRequest(XmlElement: DotNet npNetXmlElement;Token: Text[100];var NcCollectorRequest: Record "Nc Collector Request")
    var
        VendorVATRegNo: Text;
        TempText: Text;
        TempDec: Decimal;
        TempBool: Boolean;
        TempInteger: Integer;
        TempDateFormula: DateFormula;
        TempDate: Date;
    begin

        Initialize;

        Clear (NcCollectorRequest);
        NcCollectorRequest.Init;
        NcCollectorRequest."Creation Date" := CurrentDateTime ();
        if NpXmlDomMgt.GetXmlText (XmlElement, 'no', MaxStrLen (NcCollectorRequest.Name),false) <> '' then
          Evaluate(NcCollectorRequest."External No.",NpXmlDomMgt.GetXmlText (XmlElement, 'no', MaxStrLen (NcCollectorRequest.Name),false),9);
        NcCollectorRequest.Name := NpXmlDomMgt.GetXmlText (XmlElement, 'name', MaxStrLen (NcCollectorRequest.Name),false);
        if NpXmlDomMgt.GetXmlText (XmlElement, 'tableno', MaxStrLen (NcCollectorRequest.Name),false) <> '' then
          Evaluate(NcCollectorRequest."Table No.",NpXmlDomMgt.GetXmlText (XmlElement, 'tableno', MaxStrLen (NcCollectorRequest.Name),false),9);
        NcCollectorRequest."Database Name" := NpXmlDomMgt.GetXmlText (XmlElement, 'senderdatabasename', MaxStrLen (NcCollectorRequest."Database Name" ),false);
        NcCollectorRequest."Company Name" := NpXmlDomMgt.GetXmlText (XmlElement, 'sendercompany', MaxStrLen (NcCollectorRequest."Company Name" ),false);
        NcCollectorRequest."User ID" := NpXmlDomMgt.GetXmlText (XmlElement, 'senderuserid', MaxStrLen (NcCollectorRequest."Company Name" ),false);
        if NpXmlDomMgt.GetXmlText (XmlElement, 'OnlyNewandmodified',0,false) = 'true' then
          NcCollectorRequest."Only New and Modified Records" :=true;
        NcCollectorRequest.Insert(true);
    end;

    local procedure InsertCollectorRequestFilters(var NcCollectorRequestFilter: Record "Nc Collector Request Filter"): Boolean
    var
        ResponseMessage: Text;
        ResponseCode: Integer;
    begin

        NcCollectorRequestFilter.Init ();
    end;

    local procedure ReadCollectorRequestFilter(XmlElement: DotNet npNetXmlElement;Token: Text[100];var NcCollectorRequestFilter: Record "Nc Collector Request Filter";var NcCollectorRequest: Record "Nc Collector Request")
    var
        TempText: Text;
        TempDec: Decimal;
        TempBool: Boolean;
        TempInteger: Integer;
        TempDateFormula: DateFormula;
        TempDate: Date;
    begin

        Initialize;

        Clear (NcCollectorRequestFilter);
        NcCollectorRequestFilter.Init;
        NcCollectorRequestFilter."Nc Collector Request No.":= NcCollectorRequest."No.";
        Evaluate(NcCollectorRequestFilter."Table No.",NpXmlDomMgt.GetXmlText (XmlElement, 'tableno', 0, false),9);
        Evaluate(NcCollectorRequestFilter."Field No.",NpXmlDomMgt.GetXmlText (XmlElement, 'fieldno', 0, false),9);
        NcCollectorRequestFilter."Filter Text" := NpXmlDomMgt.GetXmlText (XmlElement, 'filtertext', MaxStrLen (NcCollectorRequestFilter."Filter Text"),false);
        NcCollectorRequestFilter.Insert(true);
    end;

    local procedure SetImportParameters(XmlElement: DotNet npNetXmlElement;Token: Text[100])
    var
        TempText: Text;
    begin
    end;

    local procedure FindCollectorRequest(VendorNo: Code[20];VendorVATRegNo: Text;ItemNo: Code[20];var ItemWorksheetTemplateCode: Code[20];var ItemWorksheetCode: Code[20];var ItemWorksheetLineNo: Integer)
    var
        Vendor: Record Vendor;
    begin
    end;

    local procedure "--Utils"()
    begin
    end;

    [Scope('Personalization')]
    procedure Initialize()
    begin

        if not Initialized then begin
          Initialized := true;
        end;
    end;

    local procedure GetWebserviceFunction(ImportTypeCode: Code[20]) FunctionName: Text[100]
    var
        ImportType: Record "Nc Import Type";
    begin

        Clear (ImportType);
        ImportType.SetFilter (Code, '=%1', ImportTypeCode);
        if (ImportType.FindFirst ()) then ;

        exit (ImportType."Webservice Function");
    end;

    local procedure FindWorksheetVendorNio(VendorNo: Code[20])
    begin
    end;
}

