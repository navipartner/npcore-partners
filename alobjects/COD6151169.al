codeunit 6151169 "POS Action - NpGp Return"
{
    // NPR5.51/ALST/20190628 CASE 337539 New Object


    trigger OnRun()
    begin
    end;

    var
        TitleCaption: Label 'Return Item by Reference';
        RefNoPromptCaption: Label 'Cross Reference No.';
        ActionDescriptionCaption: Label 'Return item based on its global cross reference number';
        MissmatchCompanyNameCaption: Label 'There may be a missmatch between %1 and the value in the URL in the %2 table, do you wish to continue?';
        ReasonRequiredErr: Label 'You must choose a return reason';
        RefNoBlankErr: Label 'The reference number can not be blank or empty';
        EmptyFieldErr: Label 'The %1 in %2 can not be blank or empty';
        NoGlobalSaleErr: Label 'Could not find record of sale';
        WebSrvErr: Label 'An error has occurred while processing the web request, error message: %1';
        NpGpCrossCompanySetup: Record "NpGp Cross Company Setup";
        NoInterCompTradeErr: Label 'Inter company exchange is not set up between "%1" and "%2"';
        NotFoundErr: Label 'Return receipt reference number %1 not found.';
        ServicePasswordErr: Label 'Please check there is a password set up in %1';
        QuantityOverloadedErr: Label 'Quantity of items returned cannot exceed the original amount';

    local procedure ActionCode(): Text
    begin
        exit ('CROSS_REF_RETURN');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode,
            ActionDescriptionCaption,
            ActionVersion,
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep('getReferenceNumber','{stringpad({title: labels.title,caption: labels.refprompt,notBlank: true}).cancel(abort)};');
            RegisterWorkflowStep('reasonReturn','context.PromptForReason && respond();');
            RegisterWorkflowStep('handle','respond();');
            RegisterWorkflow(true);

            RegisterBooleanParameter('ShowFullSale',false);
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";Parameters: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        RetailSetup: Record "Retail Setup";
        Context: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        RetailSetup.Get;
        Context.SetContext('PromptForReason',RetailSetup."Reason for Return Mandatory");

        FrontEnd.SetActionContext(ActionCode,Context);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        TempNpGpPOSSalesLine: Record "NpGp POS Sales Line" temporary;
        TempNpGpPOSSalesEntry: Record "NpGp POS Sales Entry" temporary;
        JSON: Codeunit "POS JSON Management";
        ReturnReasonCode: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);

        case WorkflowStep of
          'reasonReturn':
            begin
              ReturnReasonCode := SelectReturnReason(Context,POSSession,FrontEnd);
              JSON.SetContext('ReturnReasonCode',ReturnReasonCode);
              FrontEnd.SetActionContext(ActionCode,JSON);
            end;
          'handle':
            begin
              CheckSetup;
              FindReference(Context,FrontEnd,POSSession,TempNpGpPOSSalesLine,TempNpGpPOSSalesEntry);
              if CompanyName = TempNpGpPOSSalesEntry."Original Company" then begin
                VerifyReceiptForReversal(Context,FrontEnd,TempNpGpPOSSalesEntry."Document No.");
                CreateNormalReverseSale(Context,POSSession,FrontEnd,TempNpGpPOSSalesEntry,TempNpGpPOSSalesLine);
              end else
                CreateGlobalReverseSale(Context,POSSession,FrontEnd,TempNpGpPOSSalesLine,TempNpGpPOSSalesEntry);

              POSSession.ChangeViewSale;
              POSSession.RequestRefreshData;
            end;
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode,'title',TitleCaption);
        Captions.AddActionCaption(ActionCode,'refprompt',RefNoPromptCaption);
    end;

    local procedure "--- Auxiliary"()
    begin
    end;

    local procedure SelectReturnReason(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management"): Code[20]
    var
        RetailSetup: Record "Retail Setup";
        ReturnReason: Record "Return Reason";
    begin
        if (PAGE.RunModal(PAGE::"Touch Screen - Return Reasons",ReturnReason) = ACTION::LookupOK) then
          exit(ReturnReason.Code);

        Error(ReasonRequiredErr);
    end;

    local procedure FindReference(Context: DotNet npNetJObject;FrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session";var TempNpGpPOSSalesLine: Record "NpGp POS Sales Line" temporary;var TempNpGpPOSSalesEntry: Record "NpGp POS Sales Entry" temporary)
    var
        JSON: Codeunit "POS JSON Management";
        ReferenceNumber: Code[50];
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);

        JSON.SetScope('$getReferenceNumber', true);
        ReferenceNumber := JSON.GetString('numpad', true);
        if (DelChr(ReferenceNumber,'<',' ') = '') then
          Error(RefNoBlankErr);

        FindGlobalSaleByReferenceNo(FrontEnd,POSSession,Context,JSON,ReferenceNumber,TempNpGpPOSSalesLine,TempNpGpPOSSalesEntry);
    end;

    local procedure CheckSetup(): Boolean
    var
        Company: Record Company;
        NpGpPOSSalesSetup: Record "NpGp POS Sales Setup";
        NPRetailSetup: Record "NP Retail Setup";
        HttpUtility: DotNet npNetHttpUtility;
    begin
        NpGpPOSSalesSetup.FindFirst;

        NPRetailSetup.Get;
        NPRetailSetup.TestField("Global POS Sales Setup",NpGpPOSSalesSetup.Code);

        if DelChr(NpGpPOSSalesSetup."Company Name",'<',' ') = '' then
          Error(EmptyFieldErr,NpGpPOSSalesSetup.FieldName("Company Name"),NpGpPOSSalesSetup.TableName);

        if DelChr(NpGpPOSSalesSetup."Service Url",'<',' ') = '' then
          Error(EmptyFieldErr,NpGpPOSSalesSetup.FieldName("Service Url"),NpGpPOSSalesSetup.TableName);

        if StrPos(HttpUtility.UrlDecode(NpGpPOSSalesSetup."Service Url"),NpGpPOSSalesSetup."Company Name") = 0 then
          if not Confirm(MissmatchCompanyNameCaption,true,NpGpPOSSalesSetup.FieldName("Company Name"),NpGpPOSSalesSetup.TableName) then
            Error('');
    end;

    local procedure FindGlobalSaleByReferenceNo(FrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session";Context: DotNet npNetJObject;JSON: Codeunit "POS JSON Management";ReferenceNo: Code[50];var TempNpGpPOSSalesLine: Record "NpGp POS Sales Line" temporary;var TempNpGpPOSSalesEntry: Record "NpGp POS Sales Entry" temporary)
    var
        NpGpPOSSalesSetup: Record "NpGp POS Sales Setup";
        RetailCrossReference: Record "Retail Cross Reference";
        ObjectMetadata: Record "Object Metadata";
        ServicePassword: Record "Service Password";
        SalePOS: Record "Sale POS";
        NpGpUserSaleReturn: Page "NpGp User Sale Return";
        NpGpPOSSalesSetupCard: Page "NpGp POS Sales Setup Card";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        POSSale: Codeunit "POS Sale";
        HttpWebRequest: DotNet npNetHttpWebRequest;
        Credential: DotNet npNetNetworkCredential;
        XmlNamespaceManager: DotNet npNetXmlNamespaceManager;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        MemoryStream: DotNet npNetMemoryStream;
        Stream: DotNet npNetStream;
        StreamReader: DotNet npNetStreamReader;
        WebException: DotNet npNetWebException;
        Response: Text;
        ServiceName: Text;
        FirstNode: Text;
        SecondNode: Text;
        NameSpace: Text;
        FullSale: Boolean;
    begin
        NpGpPOSSalesSetup.FindFirst;

        JSON.InitializeJObjectParser(Context,FrontEnd);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        Clear(HttpWebRequest);
        HttpWebRequest := HttpWebRequest.Create(NpGpPOSSalesSetup."Service Url");
        HttpWebRequest.Timeout := 5000;

        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        ServicePassword.SetRange(Key,NpGpPOSSalesSetup."Service Password");
        if not ServicePassword.FindFirst then
          Error(ServicePasswordErr,NpGpPOSSalesSetupCard.Caption);

        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(NpGpPOSSalesSetup."Service Username",ServicePassword.GetPassword);
        HttpWebRequest.Credentials(Credential);

        ServiceName := GetServiceName(NpGpPOSSalesSetup."Service Url");

        Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                       '  <soapenv:Header />' +
                       '  <soapenv:Body>' +
                       '    <GetGlobalSale xmlns="urn:microsoft-dynamics-schemas/codeunit/' + ServiceName + '">' +
                       '       <referenceNumber />' +
                       '       <fullSale />' +
                       '       <npGpPOSEntries />' +
                       '    </GetGlobalSale>' +
                       '  </soapenv:Body>' +
                       '</soapenv:Envelope>');

        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction','GetGlobalSale');
        XmlElement := XmlDoc.DocumentElement.LastChild.LastChild;

        XmlNamespaceManager := XmlNamespaceManager.XmlNamespaceManager(XmlDoc.NameTable);
        XmlNamespaceManager.AddNamespace('ms','urn:microsoft-dynamics-schemas/codeunit/' + ServiceName);

        XmlElement2 := XmlElement.SelectSingleNode('ms:referenceNumber',XmlNamespaceManager);
        XmlElement2.InnerText := Format(ReferenceNo);

        FullSale := JSON.GetBooleanParameter('ShowFullSale',true);

        XmlElement2 := XmlElement.SelectSingleNode('ms:fullSale',XmlNamespaceManager);
        XmlElement2.InnerText := Format(FullSale,0,9);

        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then
          Error(WebSrvErr,WebException.InnerException.Message);

        Stream := HttpWebResponse.GetResponseStream;
        StreamReader := StreamReader.StreamReader(Stream);
        Response := StreamReader.ReadToEnd;
        Stream.Flush;
        Stream.Close;
        HttpWebResponse.Close;

        NameSpace := GetObjectInfoByTag(ObjectMetadata."Object Type"::XMLport,XMLPORT::"NpGp POS Entries",'DefaultNamespace',1);
        FirstNode := GetObjectInfoByTag(ObjectMetadata."Object Type"::XMLport,XMLPORT::"NpGp POS Entries",'NodeName',1);
        SecondNode := GetObjectInfoByTag(ObjectMetadata."Object Type"::XMLport,XMLPORT::"NpGp POS Entries",'NodeName',2);

        if StrPos(Response,SecondNode) = 0 then
          Error(NoGlobalSaleErr);

        XmlDoc.LoadXml('<' + FirstNode + ' xmlns="' + NameSpace + '">' +
                      CopyStr(Response,StrPos(Response,'<' + SecondNode),
                      StrPos(Response,'</npGpPOSEntries>') - StrPos(Response,'<' + SecondNode)) +
                      '</' + FirstNode + '>');

        GetRecordsFromXml(XmlDoc,TempNpGpPOSSalesLine,TempNpGpPOSSalesEntry);

        if not NpGpCrossCompanySetup.Get(TempNpGpPOSSalesEntry."Original Company") and
          (CompanyName <> TempNpGpPOSSalesEntry."Original Company") then
          Error(NoInterCompTradeErr,CompanyName,TempNpGpPOSSalesEntry."Original Company");

        if not FullSale then
          exit;

        NpGpUserSaleReturn.SetTables(SalePOS,TempNpGpPOSSalesEntry,TempNpGpPOSSalesLine);
        if not (NpGpUserSaleReturn.RunModal = ACTION::OK) then
          Error('');
        NpGpUserSaleReturn.GetLines(TempNpGpPOSSalesLine);
    end;

    local procedure GetServiceName(Url: Text) ServiceName: Text
    var
        NamePosition: Integer;
        HttpUtility: DotNet npNetHttpUtility;
        String: DotNet npNetString;
    begin
        String := HttpUtility.UrlDecode(Url);
        NamePosition := String.LastIndexOf('/') + 1;
        ServiceName := String.Substring(NamePosition,String.Length - NamePosition);
    end;

    local procedure GetRecordsFromXml(XmlDoc: DotNet npNetXmlDocument;var TempNpGpPOSSalesLine: Record "NpGp POS Sales Line" temporary;var TempNpGpPOSSalesEntry: Record "NpGp POS Sales Entry" temporary)
    var
        NpGpPOSEntries: XMLport "NpGp POS Entries";
        IOStream: DotNet npNetMemoryStream;
        TempNpGpPOSInfoPOSEntry: Record "NpGp POS Info POS Entry" temporary;
    begin
        IOStream := IOStream.MemoryStream;

        XmlDoc.Save(IOStream);

        NpGpPOSEntries.SetSource(IOStream);
        NpGpPOSEntries.Import;
        NpGpPOSEntries.GetSourceTables(TempNpGpPOSSalesEntry,TempNpGpPOSSalesLine,TempNpGpPOSInfoPOSEntry);

        if TempNpGpPOSSalesEntry.FindFirst and
          TempNpGpPOSSalesLine.FindSet then;
    end;

    local procedure GetObjectInfoByTag(Type: Integer;Id: Integer;Tag: Text;NodeNumber: Integer) Property: Text
    var
        ObjectMetadata: Record "Object Metadata";
        i: Integer;
        ServerFileName: Text;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        IOStream: OutStream;
    begin
        ObjectMetadata.SetRange("Object Type",Type);
        ObjectMetadata.SetRange("Object ID",Id);
        ObjectMetadata.FindFirst;
        ObjectMetadata.CalcFields(Metadata);

        ObjectMetadata.Metadata.CreateOutStream(IOStream);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(IOStream);
          foreach XmlElement in XmlDoc.GetElementsByTagName(Tag) do begin
            i += 1;
            if i = NodeNumber then begin
              Property := XmlElement.InnerText;
            end;
          end;
    end;

    local procedure CreateGlobalReverseSale(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var TempNpGpPOSSalesLine: Record "NpGp POS Sales Line" temporary;var TempNpGpPOSSalesEntry: Record "NpGp POS Sales Entry")
    var
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        RetailSetup: Record "Retail Setup";
        RetailCrossReference: Record "Retail Cross Reference";
        Item: Record Item;
        JSON: Codeunit "POS JSON Management";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        ReturnReasonCode: Code[20];
        FullSale: Boolean;
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        FullSale := JSON.GetBooleanParameter('ShowFullSale',true);

        if not FullSale then
          TestQuantity(TempNpGpPOSSalesLine,SalePOS)
        else begin
          TempNpGpPOSSalesLine.SetFilter(Quantity,'<0');
          if TempNpGpPOSSalesLine.IsEmpty then
            exit;
        end;

        POSSession.GetSaleLine(POSSaleLine);

        RetailSetup.Get;
        if (RetailSetup."Reason for Return Mandatory") then begin
          JSON.SetScope('/',true);
          ReturnReasonCode := JSON.GetString('ReturnReasonCode',true);
        end;

        UpdateLineNos(SalePOS,TempNpGpPOSSalesLine);

        with TempNpGpPOSSalesLine do
          repeat
            SaleLinePOS.Init;
            SaleLinePOS.Validate("Register No.",SalePOS."Register No.");
            SaleLinePOS.Validate("Sales Ticket No.",SalePOS."Sales Ticket No.");

            SaleLinePOS."Line No." := TempNpGpPOSSalesLine."Line No.";
            SaleLinePOS.Validate("Sale Type",SalePOS."Sale type");
            SaleLinePOS.Date := SalePOS.Date;
            SaleLinePOS.Insert(true);

            SaleLinePOS.Type := SaleLinePOS.Type::Item;
            SaleLinePOS."VAT Bus. Posting Group" := SalePOS."VAT Bus. Posting Group";
            SaleLinePOS."Gen. Bus. Posting Group" := NpGpCrossCompanySetup."Gen. Bus. Posting Group";

            if NpGpCrossCompanySetup."Use Original Item No." then
              Item.Get("No.")
            else
              Item.Get(NpGpCrossCompanySetup."Generic Item No.");

            SaleLinePOS."No." := Item."No.";
            SaleLinePOS.Description := Description;
            SaleLinePOS."Description 2" := "Description 2";
            if FullSale then
              SaleLinePOS.Validate(Quantity,Quantity)
            else
              SaleLinePOS.Validate(Quantity,-1);
            SaleLinePOS.Validate("Unit Price","Unit Price");
            SaleLinePOS."Unit of Measure Code" := "Unit of Measure Code";
            SaleLinePOS."Currency Code" := "Currency Code";
            SaleLinePOS.Cost := SaleLinePOS.Amount;
            SaleLinePOS."Location Code" := NpGpCrossCompanySetup."Location Code";
            SaleLinePOS."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
            SaleLinePOS."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
            SaleLinePOS."Return Sale No." := SalePOS."Sales Ticket No.";
            SaleLinePOS."Return Sale Register No." := SalePOS."Register No.";
            SaleLinePOS."Return Sale Sales Ticket No." := TempNpGpPOSSalesEntry."Document No.";
            SaleLinePOS."Return Sales Sales Type" := SalePOS."Sale type";
            SaleLinePOS."Return Reason Code" := ReturnReasonCode;
            SaleLinePOS."Retail ID" := CreateGuid;

            SaleLinePOS.Modify(true);

            RetailCrossReference."Retail ID" := SaleLinePOS."Retail ID";
            RetailCrossReference.Insert;

            RetailCrossReference."Reference No." := TempNpGpPOSSalesLine."Global Reference";
            RetailCrossReference."Table ID" := DATABASE::"Sale Line POS";
            RetailCrossReference."Record Value" := SaleLinePOS."Sales Ticket No." + '_' + Format(SaleLinePOS."Line No.");
            RetailCrossReference.Modify;
          until not FullSale or (TempNpGpPOSSalesLine.Next = 0);

        POSSaleLine.ResendAllOnAfterInsertPOSSaleLine;
        POSSale.RefreshCurrent;
    end;

    local procedure UpdateLineNos(SalePOS: Record "Sale POS";var TempNpGpPOSSalesLine: Record "NpGp POS Sales Line" temporary)
    var
        SaleLinePOS: Record "Sale Line POS";
        TempNumber: Record "Integer" temporary;
        LineNo: Integer;
        i: Integer;
    begin
        SaleLinePOS.SetCurrentKey("Register No.","Sales Ticket No.","Line No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if not SaleLinePOS.FindLast then
          exit;

        TempNpGpPOSSalesLine.FindLast;

        if SaleLinePOS."Line No." < TempNpGpPOSSalesLine."Line No." then
          LineNo += TempNpGpPOSSalesLine."Line No."
        else
          LineNo := SaleLinePOS."Line No.";

        for i := 1 to SaleLinePOS.Count do begin
          LineNo += 10000;
          TempNumber.Number := LineNo;
          TempNumber.Insert;
        end;

        TempNumber.FindSet;
        repeat
          SaleLinePOS.FindFirst;
          SaleLinePOS.Rename(SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.",SaleLinePOS.Date,SaleLinePOS."Sale Type",TempNumber.Number);
        until TempNumber.Next = 0;

        TempNpGpPOSSalesLine.FindSet;
    end;

    local procedure VerifyReceiptForReversal(Context: DotNet npNetJObject;FrontEnd: Codeunit "POS Front End Management";SalesTicketNo: Code[20])
    var
        JSON: Codeunit "POS JSON Management";
        AuditRoll: Record "Audit Roll";
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);

        JSON.SetScope('/',true);
        JSON.SetScope('$getReferenceNumber',true);

        AuditRoll.SetRange("Sales Ticket No.",SalesTicketNo);
        if not AuditRoll.FindFirst then
          Error(NotFoundErr,JSON.GetString('numpad',true));
    end;

    local procedure CreateNormalReverseSale(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var TempNpGpPOSSalesEntry: Record "NpGp POS Sales Entry" temporary;var TempNpGpPOSSalesLine: Record "NpGp POS Sales Line" temporary)
    var
        JSON: Codeunit "POS JSON Management";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        RetailSetup: Record "Retail Setup";
        ReturnReasonCode: Code[20];
        FullSale: Boolean;
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        FullSale := JSON.GetBooleanParameter('ShowFullSale',true);

        if not FullSale then
          TestQuantity(TempNpGpPOSSalesLine,SalePOS)
        else begin
          TempNpGpPOSSalesLine.SetFilter(Quantity,'<0');
          if TempNpGpPOSSalesLine.IsEmpty then
            exit;
        end;

        POSSession.GetSaleLine(POSSaleLine);

        SetCustomerOnReverseSale(SalePOS,TempNpGpPOSSalesEntry);

        UpdateLineNos(SalePOS,TempNpGpPOSSalesLine);

        RetailSetup.Get;
        if (RetailSetup."Reason for Return Mandatory") then begin
          JSON.SetScope('/',true);
          ReturnReasonCode := JSON.GetString('ReturnReasonCode',true);
        end;

        ReverseLocalSale(SalePOS,TempNpGpPOSSalesLine,TempNpGpPOSSalesEntry,ReturnReasonCode,FullSale);

        POSSaleLine.ResendAllOnAfterInsertPOSSaleLine;
        POSSale.RefreshCurrent;
    end;

    local procedure SetCustomerOnReverseSale(var SalePOS: Record "Sale POS";var TempNpGpPOSSalesEntry: Record "NpGp POS Sales Entry" temporary)
    var
        AuditRoll: Record "Audit Roll";
        POSSale: Codeunit "POS Sale";
        Customer: Record Customer;
        Contact: Record Contact;
    begin
        AuditRoll.SetRange("Register No.",TempNpGpPOSSalesEntry."POS Unit No.");
        AuditRoll.SetRange("Sales Ticket No.",TempNpGpPOSSalesEntry."Document No.");
        AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Sale);
        AuditRoll.SetRange(Type,AuditRoll.Type::Item);
        AuditRoll.SetRange("Customer No.",'>%1','');

        if not AuditRoll.FindFirst then
          exit;

        if Customer.Get(AuditRoll."Customer No.") then begin
          SalePOS.Validate("Customer No.", Customer."No.");
        end else begin
          if not Contact.Get(AuditRoll."Customer No.") then
            exit;

          SalePOS.Validate("Customer Type",SalePOS."Customer Type"::Cash);
          SalePOS.Validate("Customer No.",Contact."No.");
        end;

        SalePOS.Modify(true);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true,false);
    end;

    local procedure ReverseLocalSale(var SalePOS: Record "Sale POS";var TempNpGpPOSSalesLine: Record "NpGp POS Sales Line" temporary;var TempNpGpPOSSalesEntry: Record "NpGp POS Sales Entry" temporary;ReturnReason: Code[10];FullSale: Boolean)
    var
        AuditRoll: Record "Audit Roll";
        SaleLinePOS: Record "Sale Line POS";
        RetailCrossReference: Record "Retail Cross Reference";
        RetailSalesCode: Codeunit "Retail Sales Code";
    begin
        AuditRoll.SetRange("Register No.",TempNpGpPOSSalesEntry."POS Unit No.");
        AuditRoll.SetRange("Sales Ticket No.",TempNpGpPOSSalesEntry."Document No.");
        AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Sale);
        AuditRoll.SetRange(Type,AuditRoll.Type::Item);
        AuditRoll.SetFilter(Quantity,'>0');

        repeat
          AuditRoll.SetRange("Line No.",TempNpGpPOSSalesLine."Line No.");
          AuditRoll.SetRange("No.",TempNpGpPOSSalesLine."No.");
          if AuditRoll.FindFirst then begin
            SaleLinePOS.Init;
            SaleLinePOS."Register No." := SalePOS."Register No.";
            SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
            SaleLinePOS.Date := SalePOS.Date;
            SaleLinePOS.Type := SaleLinePOS.Type::Item;
            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
            SaleLinePOS."Line No." := AuditRoll."Line No.";
            SaleLinePOS.Insert(true);

            RetailSalesCode.ReverseAuditInfoToSalesLine(SaleLinePOS,AuditRoll);

            if FullSale then
              SaleLinePOS.Validate(Quantity,TempNpGpPOSSalesLine.Quantity)
            else
              SaleLinePOS.Validate(Quantity,-1);

            SaleLinePOS."Retail ID" := CreateGuid;
            SaleLinePOS."Return Sale No." := SalePOS."Sales Ticket No.";
            SaleLinePOS."Return Sale Register No." := SalePOS."Register No.";
            SaleLinePOS."Return Sale Sales Ticket No." := TempNpGpPOSSalesEntry."Document No.";
            SaleLinePOS."Return Sales Sales Type" := SalePOS."Sale type";
            SaleLinePOS."Return Reason Code" := ReturnReason;

            SaleLinePOS.UpdateAmounts(SaleLinePOS);

            SaleLinePOS.Modify(true);

            RetailCrossReference."Retail ID" := SaleLinePOS."Retail ID";
            RetailCrossReference.Insert;

            RetailCrossReference."Reference No." := TempNpGpPOSSalesLine."Global Reference";
            RetailCrossReference."Table ID" := DATABASE::"Sale Line POS";
            RetailCrossReference."Record Value" := SaleLinePOS."Sales Ticket No." + '_' + Format(SaleLinePOS."Line No.");
            RetailCrossReference.Modify;
          end;
        until not FullSale or (TempNpGpPOSSalesLine.Next = 0);
    end;

    local procedure TestQuantity(var TempNpGpPOSSalesLine: Record "NpGp POS Sales Line" temporary;SalePOS: Record "Sale POS")
    var
        RetailCrossReference: Record "Retail Cross Reference";
        SaleLinePOS: Record "Sale Line POS";
    begin
        if TempNpGpPOSSalesLine.Quantity > 0 then
          with SaleLinePOS do begin
            SetRange("Register No.",SalePOS."Register No.");
            SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
            SetRange("Sale Type",SalePOS."Sale type");
            SetFilter(Quantity,'<0');

            RetailCrossReference.SetRange("Reference No.",TempNpGpPOSSalesLine."Global Reference");
            if RetailCrossReference.FindSet then
              repeat
                SetRange("Retail ID",RetailCrossReference."Retail ID");
                if FindFirst then
                  TempNpGpPOSSalesLine.Quantity += Quantity;
              until RetailCrossReference.Next = 0;

            if TempNpGpPOSSalesLine.Quantity > 0 then
              exit;
          end;

        Error(QuantityOverloadedErr);
    end;
}

