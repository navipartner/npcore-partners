codeunit 6014673 "Endpoint Query WebService Mgr"
{
    // NPR5.25\BR \20160802 CASE 234602 Object Created
    // NPR5.33/ANEN/20170427 CASE 273989 Removed variable not used

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
            'Createendpointquery' : CreateEndpointQueries (XmlDoc,  "Entry No.", "Document ID");
            else
              Error (MISSING_CASE, "Import Type", FunctionName);
          end;

        end;
    end;

    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        ItemWshtImpExpMgt: Codeunit "Item Wsht. Imp. Exp. Mgt.";
        Initialized: Boolean;
        ITEM_NOT_FOUND: Label 'The sales item specified in external_id %1, was not found.';
        CHANGE_NOT_ALLOWED: Label 'Confirmed tickets can''t be changed.';
        TOKEN_NOT_FOUND: Label 'The token %1 was not found, or has incorrect state.';
        TOKEN_EXPIRED: Label 'The token %1 has expired. Use PreConfirm to re-reserve tickets.';
        TOKEN_INCORRECT_STATE: Label 'The token %1 can''t be changed when in the %1 state.';
        MISSING_CASE: Label 'No handler for %1 [%2].';
        ImportOption: Option "Replace lines","Add lines";
        CombineVarieties: Boolean;
        ActionIfVariantUnknown: Option Skip,Create;
        ActionIfVarietyUnknown: Option Skip,Create;
        VENDOR_NOT_FOUND: Label 'The Vendor %1 could not be found in the database.';
        LastItemWorksheetLine: Record "Item Worksheet Line";

    local procedure CreateEndpointQueries(XmlDoc: DotNet npNetXmlDocument;RequestEntryNo: Integer;DocumentID: Text[100])
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
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

        if not NpXmlDomMgt.FindNodes(XmlElement,'Createendpointquery',XmlNodeList) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'endpointqueryimport',XmlNodeList) then
          exit;

        if not NpXmlDomMgt.FindNodes(XmlElement,'insertendpointquery',XmlNodeList) then
          exit;

        XmlElement := XmlNodeList.ItemOf(0);

        SetImportParameters (XmlElement, Token) ;

        if not NpXmlDomMgt.FindNodes(XmlElement,'endpointquery',XmlNodeList) then
          exit;

        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement := XmlNodeList.ItemOf(i);
          CreateEndpointQuery (XmlElement, Token, DocumentID);
        end;

        Commit;
    end;

    local procedure CreateEndpointQuery(XmlElement: DotNet npNetXmlElement;Token: Text[100];DocumentID: Text[100]) Imported: Boolean
    var
        XmlNodeList: DotNet npNetXmlNodeList;
        EndpointQuery: Record "Endpoint Query";
        i: Integer;
    begin

        if IsNull(XmlElement) then
          exit(false);

        EndpointQuery.Init ();

        ReadEndpointQuery (XmlElement, Token, EndpointQuery);
          if NpXmlDomMgt.FindNodes(XmlElement,'endpointqueryfilter',XmlNodeList) then
            for i := 0 to XmlNodeList.Count - 1 do begin
              XmlElement := XmlNodeList.ItemOf(i);
              CreateEndpointQueryFilter (XmlElement, Token, DocumentID, EndpointQuery);
            end;
        EndpointQuery.ProcessQuery;
        InsertEndpointQueries (EndpointQuery);


        exit(true);
    end;

    local procedure CreateEndpointQueryFilter(XmlElement: DotNet npNetXmlElement;Token: Text[100];DocumentID: Text[100];var EndpointQuery: Record "Endpoint Query") Imported: Boolean
    var
        EndpointQueryFilter: Record "Endpoint Query Filter";
    begin

        if IsNull(XmlElement) then
          exit(false);

        EndpointQueryFilter.Init ();

        ReadEndpointQueryFilter (XmlElement, Token, EndpointQueryFilter, EndpointQuery);
        InsertEndpointQueryFilters (EndpointQueryFilter);

        exit(true);
    end;

    local procedure "---Database"()
    begin
    end;

    local procedure InsertEndpointQueries(var EndpointQuery: Record "Endpoint Query"): Boolean
    var
        TicketReservationResponse: Record "TM Ticket Reservation Response";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        ResponseMessage: Text;
        ResponseCode: Integer;
    begin

        EndpointQuery.Init ();
    end;

    local procedure ReadEndpointQuery(XmlElement: DotNet npNetXmlElement;Token: Text[100];var EndpointQuery: Record "Endpoint Query")
    var
        ItemWorksheetVariantLine: Record "Item Worksheet Variant Line";
        VarietyValue: Record "Variety Value";
        VendorVATRegNo: Text;
        TempText: Text;
        TempDec: Decimal;
        TempBool: Boolean;
        TempInteger: Integer;
        TempDateFormula: DateFormula;
        TempDate: Date;
        ItemWkshCheckLine: Codeunit "Item Wsht.-Check Line";
    begin

        Initialize;

        Clear (EndpointQuery);
        EndpointQuery.Init;
        EndpointQuery."Creation Date" := CurrentDateTime ();
        if NpXmlDomMgt.GetXmlText (XmlElement, 'no', MaxStrLen (EndpointQuery.Name),false) <> '' then
          Evaluate(EndpointQuery."External No.",NpXmlDomMgt.GetXmlText (XmlElement, 'no', MaxStrLen (EndpointQuery.Name),false),9);
        EndpointQuery.Name := NpXmlDomMgt.GetXmlText (XmlElement, 'name', MaxStrLen (EndpointQuery.Name),false);
        if NpXmlDomMgt.GetXmlText (XmlElement, 'tableno', MaxStrLen (EndpointQuery.Name),false) <> '' then
          Evaluate(EndpointQuery."Table No.",NpXmlDomMgt.GetXmlText (XmlElement, 'tableno', MaxStrLen (EndpointQuery.Name),false),9);
        EndpointQuery."Database Name" := NpXmlDomMgt.GetXmlText (XmlElement, 'senderdatabasename', MaxStrLen (EndpointQuery."Database Name" ),false);
        EndpointQuery."Company Name" := NpXmlDomMgt.GetXmlText (XmlElement, 'sendercompany', MaxStrLen (EndpointQuery."Company Name" ),false);
        EndpointQuery."User ID" := NpXmlDomMgt.GetXmlText (XmlElement, 'senderuserid', MaxStrLen (EndpointQuery."Company Name" ),false);
        if NpXmlDomMgt.GetXmlText (XmlElement, 'OnlyNewandmodified',0,false) = 'true' then
          EndpointQuery."Only New and Modified Records" :=true;
        EndpointQuery.Insert(true);



        //-NPR5.23 [242498]
        //ItemWshtImpExpMgt.OnAfterImportWorksheetLine(ItemWorksheetLine);
        //+NPR5.23 [242498]
    end;

    local procedure InsertEndpointQueryFilters(var EndpointQueryFilter: Record "Endpoint Query Filter"): Boolean
    var
        TicketReservationResponse: Record "TM Ticket Reservation Response";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        ResponseMessage: Text;
        ResponseCode: Integer;
    begin

        EndpointQueryFilter.Init ();
    end;

    local procedure ReadEndpointQueryFilter(XmlElement: DotNet npNetXmlElement;Token: Text[100];var EndpointQueryFilter: Record "Endpoint Query Filter";var EndpointQuery: Record "Endpoint Query")
    var
        ItemWorksheetVariantLine: Record "Item Worksheet Variant Line";
        VarietyValue: Record "Variety Value";
        VendorVATRegNo: Text;
        TempText: Text;
        TempDec: Decimal;
        TempBool: Boolean;
        TempInteger: Integer;
        TempDateFormula: DateFormula;
        TempDate: Date;
        ItemWkshCheckLine: Codeunit "Item Wsht.-Check Line";
    begin

        Initialize;

        Clear (EndpointQueryFilter);
        EndpointQueryFilter.Init;
        EndpointQueryFilter."Endpoint Query No.":= EndpointQuery."No.";
        Evaluate(EndpointQueryFilter."Table No.",NpXmlDomMgt.GetXmlText (XmlElement, 'tableno', 0, false),9);
        Evaluate(EndpointQueryFilter."Field No.",NpXmlDomMgt.GetXmlText (XmlElement, 'fieldno', 0, false),9);
        EndpointQueryFilter."Filter Text" := NpXmlDomMgt.GetXmlText (XmlElement, 'filtertext', MaxStrLen (EndpointQueryFilter."Filter Text"),false);
        EndpointQueryFilter.Insert(true);
    end;

    local procedure SetImportParameters(XmlElement: DotNet npNetXmlElement;Token: Text[100])
    var
        TempText: Text;
    begin
    end;

    local procedure FindEndpointQuery(VendorNo: Code[20];VendorVATRegNo: Text;ItemNo: Code[20];var ItemWorksheetTemplateCode: Code[20];var ItemWorksheetCode: Code[20];var ItemWorksheetLineNo: Integer)
    var
        Vendor: Record Vendor;
        ItemWorksheetTemplate: Record "Item Worksheet Template";
        ItemWorksheetTemplate2: Record "Item Worksheet Template";
        ItemWorksheet: Record "Item Worksheet";
        ItemWorksheetLine: Record "Item Worksheet Line";
    begin
    end;

    local procedure "--Utils"()
    begin
    end;

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

