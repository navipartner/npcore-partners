codeunit 6151169 "NPR POS Action: NpGp Return"
{
    var
        TitleCaption: Label 'Return Item by Reference';
        RefNoPromptCaption: Label 'Cross Reference No.';
        ActionDescriptionCaption: Label 'Return item based on its global cross reference number';
        EANDescriptionCaption: Label 'Handles return of global exchange label';
        ModuleNameCaption: Label 'Global exchange';
        ReasonRequiredErr: Label 'You must choose a return reason';
        RefNoBlankErr: Label 'The reference number can not be blank or empty';
        EmptyFieldErr: Label 'The %1 in %2 can not be blank or empty';
        NoGlobalSaleErr: Label 'Could not find record of sale';
        WebSrvErr: Label 'An error has occurred while processing the web request, error message: %1';
        NpGpCrossCompanySetup: Record "NPR NpGp Cross Company Setup";
        NoInterCompTradeErr: Label 'Inter company exchange is not set up between "%1" and "%2"';
        NotFoundErr: Label 'Return receipt reference number %1 not found.';
        ServicePasswordErr: Label 'Please check there is a password set up in %1';
        QuantityOverloadedErr: Label 'Quantity of items returned cannot exceed the original amount';
        ReadingErr: Label 'reading in %1';
        SettingScopeErr: Label 'setting scope in %1';

    local procedure ActionCode(): Text
    begin
        exit('CROSS_REF_RETURN');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescriptionCaption,
              ActionVersion,
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('getReferenceNumber',
                    'if (param.ReferenceBarcode === "")' +
                    '{' +
                        'stringpad({title: labels.title,caption: labels.refprompt,notBlank: true}).cancel(abort);' +
                    '}' +
                    'else' +
                    '{' +
                        'respond();' +
                    '};');
                RegisterWorkflowStep('reasonReturn', 'context.PromptForReason && respond();');
                RegisterWorkflowStep('handle', 'respond();');
                RegisterWorkflow(true);

                RegisterBooleanParameter('ShowFullSale', false);
                RegisterTextParameter('ReferenceBarcode', '');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Context.SetContext('PromptForReason', true);

        FrontEnd.SetActionContext(ActionCode, Context);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary;
        TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary;
        JSON: Codeunit "NPR POS JSON Management";
        ReturnReasonCode: Code[20];
        UseNormalReverseAction: Label 'This receipt is from the current company. Use the normal reversal action instead';
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        case WorkflowStep of
            'reasonReturn':
                begin
                    ReturnReasonCode := SelectReturnReason(Context, POSSession, FrontEnd);
                    JSON.SetContext('ReturnReasonCode', ReturnReasonCode);
                    FrontEnd.SetActionContext(ActionCode, JSON);
                end;
            'handle':
                begin
                    CheckSetup(POSSession);
                    FindReference(Context, FrontEnd, POSSession, TempNpGpPOSSalesLine, TempNpGpPOSSalesEntry);
                    if CompanyName = TempNpGpPOSSalesEntry."Original Company" then begin
                        Error(UseNormalReverseAction)
                    end else
                        CreateGlobalReverseSale(Context, POSSession, FrontEnd, TempNpGpPOSSalesLine, TempNpGpPOSSalesEntry);

                    POSSession.ChangeViewSale;
                    POSSession.RequestRefreshData;
                end;
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'title', TitleCaption);
        Captions.AddActionCaption(ActionCode, 'refprompt', RefNoPromptCaption);
    end;

    local procedure SelectReturnReason(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"): Code[20]
    var
        ReturnReason: Record "Return Reason";
    begin
        if (PAGE.RunModal(PAGE::"NPR TouchScreen: Ret. Reasons", ReturnReason) = ACTION::LookupOK) then
            exit(ReturnReason.Code);

        Error(ReasonRequiredErr);
    end;

    local procedure FindReference(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary)
    var
        JSON: Codeunit "NPR POS JSON Management";
        ReferenceNumber: Text;
    begin
        HandleReferenceNumber(Context, FrontEnd, ReferenceNumber);
        if (DelChr(ReferenceNumber, '<', ' ') = '') then
            Error(RefNoBlankErr);

        FindGlobalSaleByReferenceNo(FrontEnd, POSSession, Context, ReferenceNumber, TempNpGpPOSSalesLine, TempNpGpPOSSalesEntry);
    end;

    local procedure CheckSetup(POSSession: Codeunit "NPR POS Session"): Boolean
    var
        Company: Record Company;
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
        POSUnit: Record "NPR POS Unit";
        POSSetup: Codeunit "NPR POS Setup";
        HttpUtility: DotNet NPRNetHttpUtility;
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);

        POSUnit.TestField("Global POS Sales Setup");
        NpGpPOSSalesSetup.Get(POSUnit."Global POS Sales Setup");

        if DelChr(NpGpPOSSalesSetup."Company Name", '<', ' ') = '' then
            Error(EmptyFieldErr, NpGpPOSSalesSetup.FieldName("Company Name"), NpGpPOSSalesSetup.TableName);

        if DelChr(NpGpPOSSalesSetup."Service Url", '<', ' ') = '' then
            Error(EmptyFieldErr, NpGpPOSSalesSetup.FieldName("Service Url"), NpGpPOSSalesSetup.TableName);
    end;

    local procedure FindGlobalSaleByReferenceNo(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; Context: JsonObject; ReferenceNo: Code[50]; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary)
    var
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
        RetailCrossReference: Record "NPR Retail Cross Reference";
        ObjectMetadata: Record "Object Metadata";
        POSUnit: Record "NPR POS Unit";
        ServicePassword: Text;
        SalePOS: Record "NPR Sale POS";
        NpGpUserSaleReturn: Page "NPR NpGp User Sale Return";
        NpGpPOSSalesSetupCard: Page "NPR NpGp POS Sales Setup Card";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        JSON: Codeunit "NPR POS JSON Management";
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        Credential: DotNet NPRNetNetworkCredential;
        XmlNamespaceManager: DotNet NPRNetXmlNamespaceManager;
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
        XmlElement2: DotNet NPRNetXmlElement;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        MemoryStream: DotNet NPRNetMemoryStream;
        Stream: DotNet NPRNetStream;
        StreamReader: DotNet NPRNetStreamReader;
        WebException: DotNet NPRNetWebException;
        Response: Text;
        ServiceName: Text;
        FirstNode: Text;
        SecondNode: Text;
        NameSpace: Text;
        FullSale: Boolean;
        InterCompSetup: Boolean;
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);

        POSUnit.TestField("Global POS Sales Setup");
        NpGpPOSSalesSetup.Get(POSUnit."Global POS Sales Setup");

        JSON.InitializeJObjectParser(Context, FrontEnd);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        Clear(HttpWebRequest);
        HttpWebRequest := HttpWebRequest.Create(NpGpPOSSalesSetup."Service Url");
        HttpWebRequest.Timeout := 5000;

        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if not IsolatedStorage.Get(NpGpPOSSalesSetup."Service Password", DataScope::Company, ServicePassword) then
            Error(ServicePasswordErr, NpGpPOSSalesSetupCard.Caption);

        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(NpGpPOSSalesSetup."Service Username", ServicePassword);
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
        HttpWebRequest.Headers.Add('SOAPAction', 'GetGlobalSale');
        XmlElement := XmlDoc.DocumentElement.LastChild.LastChild;

        XmlNamespaceManager := XmlNamespaceManager.XmlNamespaceManager(XmlDoc.NameTable);
        XmlNamespaceManager.AddNamespace('ms', 'urn:microsoft-dynamics-schemas/codeunit/' + ServiceName);

        XmlElement2 := XmlElement.SelectSingleNode('ms:referenceNumber', XmlNamespaceManager);
        XmlElement2.InnerText := Format(ReferenceNo);

        FullSale := JSON.GetBooleanParameterOrFail('ShowFullSale', ActionCode());

        XmlElement2 := XmlElement.SelectSingleNode('ms:fullSale', XmlNamespaceManager);
        XmlElement2.InnerText := Format(FullSale, 0, 9);

        if not NpXmlDomMgt.SendWebRequest(XmlDoc, HttpWebRequest, HttpWebResponse, WebException) then
            Error(WebSrvErr, WebException.InnerException.Message);

        Stream := HttpWebResponse.GetResponseStream;
        StreamReader := StreamReader.StreamReader(Stream);
        Response := StreamReader.ReadToEnd;
        Stream.Flush;
        Stream.Close;
        HttpWebResponse.Close;

        NameSpace := GetObjectInfoByTag(ObjectMetadata."Object Type"::XMLport, XMLPORT::"NPR NpGp POS Entries", 'DefaultNamespace', 1);
        FirstNode := GetObjectInfoByTag(ObjectMetadata."Object Type"::XMLport, XMLPORT::"NPR NpGp POS Entries", 'NodeName', 1);
        SecondNode := GetObjectInfoByTag(ObjectMetadata."Object Type"::XMLport, XMLPORT::"NPR NpGp POS Entries", 'NodeName', 2);

        if StrPos(Response, SecondNode) = 0 then
            Error(NoGlobalSaleErr);

        XmlDoc.LoadXml('<' + FirstNode + ' xmlns="' + NameSpace + '">' +
                      CopyStr(Response, StrPos(Response, '<' + SecondNode),
                      StrPos(Response, '</npGpPOSEntries>') - StrPos(Response, '<' + SecondNode)) +
                      '</' + FirstNode + '>');

        GetRecordsFromXml(XmlDoc, TempNpGpPOSSalesLine, TempNpGpPOSSalesEntry);

        InterCompSetup := NpGpCrossCompanySetup.Get(TempNpGpPOSSalesEntry."Original Company");

        if not InterCompSetup then begin
            NpGpCrossCompanySetup.SetRange("Original Company", '');
            InterCompSetup := NpGpCrossCompanySetup.FindFirst;
        end;

        if (not InterCompSetup) and (CompanyName <> TempNpGpPOSSalesEntry."Original Company") then
            Error(NoInterCompTradeErr, CompanyName, TempNpGpPOSSalesEntry."Original Company");

        if not FullSale then
            exit;

        NpGpUserSaleReturn.SetTables(SalePOS, TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine);
        if not (NpGpUserSaleReturn.RunModal = ACTION::OK) then
            Error('');
        NpGpUserSaleReturn.GetLines(TempNpGpPOSSalesLine);
    end;

    local procedure GetServiceName(Url: Text) ServiceName: Text
    var
        NamePosition: Integer;
        HttpUtility: DotNet NPRNetHttpUtility;
        String: DotNet NPRNetString;
    begin
        String := HttpUtility.UrlDecode(Url);
        NamePosition := String.LastIndexOf('/') + 1;
        ServiceName := String.Substring(NamePosition, String.Length - NamePosition);
    end;

    local procedure GetRecordsFromXml(XmlDoc: DotNet "NPRNetXmlDocument"; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary)
    var
        NpGpPOSEntries: XMLport "NPR NpGp POS Entries";
        IOStream: DotNet NPRNetMemoryStream;
        TempNpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry" temporary;
        IOStreamVariant: Variant;
    begin
        IOStream := IOStream.MemoryStream;

        XmlDoc.Save(IOStream);

        IOStreamVariant := IOStream;
        NpGpPOSEntries.SetSource(IOStreamVariant);
        NpGpPOSEntries.Import;
        NpGpPOSEntries.GetSourceTables(TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine, TempNpGpPOSInfoPOSEntry);

        if TempNpGpPOSSalesEntry.FindFirst and
          TempNpGpPOSSalesLine.FindSet then
            ;
    end;

    local procedure GetObjectInfoByTag(Type: Integer; Id: Integer; Tag: Text; NodeNumber: Integer) Property: Text
    var
        ObjectMetadata: Record "Object Metadata";
        i: Integer;
        ServerFileName: Text;
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        IOStream: OutStream;
    begin
        ObjectMetadata.SetRange("Object Type", Type);
        ObjectMetadata.SetRange("Object ID", Id);
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

    local procedure CreateGlobalReverseSale(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry")
    var
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        RetailCrossReference: Record "NPR Retail Cross Reference";
        Item: Record Item;
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        ReturnReasonCode: Code[10];
        FullSale: Boolean;
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        FullSale := JSON.GetBooleanParameterOrFail('ShowFullSale', ActionCode());

        if not FullSale then
            TestQuantity(TempNpGpPOSSalesLine, SalePOS)
        else begin
            TempNpGpPOSSalesLine.SetFilter(Quantity, '<0');
            if TempNpGpPOSSalesLine.IsEmpty then
                exit;
        end;

        POSSession.GetSaleLine(POSSaleLine);

        JSON.SetScopeRoot();
        ReturnReasonCode := JSON.GetStringOrFail('ReturnReasonCode', StrSubstNo(ReadingErr, ActionCode()));

        UpdateLineNos(SalePOS, TempNpGpPOSSalesLine);

        with TempNpGpPOSSalesLine do
            repeat
                SaleLinePOS.Init;
                SaleLinePOS.Validate("Register No.", SalePOS."Register No.");
                SaleLinePOS.Validate("Sales Ticket No.", SalePOS."Sales Ticket No.");

                SaleLinePOS."Line No." := TempNpGpPOSSalesLine."Line No.";
                SaleLinePOS.Validate("Sale Type", SalePOS."Sale type");
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
                    SaleLinePOS.Validate(Quantity, Quantity)
                else
                    SaleLinePOS.Validate(Quantity, -1);
                SaleLinePOS.Validate("Unit Price", "Unit Price");
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
                SaleLinePOS.Modify(true);

                RetailCrossReference."Retail ID" := SaleLinePOS."Retail ID";
                RetailCrossReference.Insert;

                RetailCrossReference."Reference No." := TempNpGpPOSSalesLine."Global Reference";
                RetailCrossReference."Table ID" := DATABASE::"NPR Sale Line POS";
                RetailCrossReference."Record Value" := SaleLinePOS."Sales Ticket No." + '_' + Format(SaleLinePOS."Line No.");
                RetailCrossReference.Modify;
            until not FullSale or (TempNpGpPOSSalesLine.Next = 0);

        POSSaleLine.ResendAllOnAfterInsertPOSSaleLine;
        POSSale.RefreshCurrent;
    end;

    local procedure UpdateLineNos(SalePOS: Record "NPR Sale POS"; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        TempNumber: Record "Integer" temporary;
        LineNo: Integer;
        i: Integer;
    begin
        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
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
            SaleLinePOS.Rename(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", TempNumber.Number);
        until TempNumber.Next = 0;

        TempNpGpPOSSalesLine.FindSet;
    end;

    local procedure VerifyReceiptForReversal(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"; SalesTicketNo: Code[20])
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSEntry: Record "NPR POS Entry";
        ReferenceNumber: Text;
    begin
        HandleReferenceNumber(Context, FrontEnd, ReferenceNumber);

        POSEntry.SetRange("Document No.", SalesTicketNo);
        if not POSEntry.FindFirst then
            Error(NotFoundErr, ReferenceNumber);
    end;

    local procedure SetCustomerOnReverseSale(var SalePOS: Record "NPR Sale POS"; var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary)
    var
        POSSale: Codeunit "NPR POS Sale";
        Customer: Record Customer;
        Contact: Record Contact;
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Sales Line";
    begin
        POSEntry.SetRange("POS Unit No.", TempNpGpPOSSalesEntry."POS Unit No.");
        POSEntry.SetRange("Document No.", TempNpGpPOSSalesEntry."Document No.");
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        POSEntry.SetRange("Customer No.", '<>%1', '');
        if not POSEntry.FindFirst() then
            exit;

        if Customer.Get(POSEntry."Customer No.") then begin
            SalePOS.Validate("Customer No.", Customer."No.");
        end else begin
            if not Contact.Get(POSEntry."Customer No.") then
                exit;

            SalePOS.Validate("Customer Type", SalePOS."Customer Type"::Cash);
            SalePOS.Validate("Customer No.", Contact."No.");
        end;

        SalePOS.Modify(true);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);
    end;

    local procedure TestQuantity(var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; SalePOS: Record "NPR Sale POS")
    var
        RetailCrossReference: Record "NPR Retail Cross Reference";
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        if TempNpGpPOSSalesLine.Quantity > 0 then
            with SaleLinePOS do begin
                SetRange("Register No.", SalePOS."Register No.");
                SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
                SetRange("Sale Type", SalePOS."Sale type");
                SetFilter(Quantity, '<0');

                RetailCrossReference.SetRange("Reference No.", TempNpGpPOSSalesLine."Global Reference");
                if RetailCrossReference.FindSet then
                    repeat
                        SetRange("Retail ID", RetailCrossReference."Retail ID");
                        if FindFirst then
                            TempNpGpPOSSalesLine.Quantity += Quantity;
                    until RetailCrossReference.Next = 0;

                if TempNpGpPOSSalesLine.Quantity > 0 then
                    exit;
            end;

        Error(QuantityOverloadedErr);
    end;

    local procedure HandleReferenceNumber(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"; var ReferenceNumber: Text)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        ReferenceNumber := JSON.GetStringParameterOrFail('ReferenceBarcode', ActionCode());
        if ReferenceNumber = '' then begin
            JSON.SetScope('$getReferenceNumber', StrSubstNo(SettingScopeErr, ActionCode()));
            ReferenceNumber := JSON.GetStringOrFail('numpad', StrSubstNo(ReadingErr, ActionCode()));
        end;

        if CopyStr(ReferenceNumber, StrLen(ReferenceNumber) - 1) = 'XX' then
            ReferenceNumber := CopyStr(ReferenceNumber, 1, StrLen(ReferenceNumber) - 2);
    end;

    local procedure "--- Ean Box Event Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        ExchangeLabel: Record "NPR Exchange Label";
    begin
        if not EanBoxEvent.Get(EventCodeExchLabel()) then begin
            EanBoxEvent.Init;
            EanBoxEvent.Code := EventCodeExchLabel();
            EanBoxEvent."Module Name" := ModuleNameCaption;
            EanBoxEvent.Description := EANDescriptionCaption;
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CODEUNIT::"NPR POS Action: NpGp Return";
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        if EanBoxEvent.Code = EventCodeExchLabel() then
            Sender.SetNonEditableParameterValues(EanBoxEvent, 'ReferenceBarcode', true, '');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeGlobalExchLabel(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        ExchangeLabel: Record "NPR Exchange Label";
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeExchLabel() then
            exit;

        InScope := (CopyStr(EanBoxValue, StrLen(EanBoxValue) - 1, 2) = 'XX') and (StrLen(EanBoxValue) > 2);
    end;

    local procedure EventCodeExchLabel(): Code[20]
    begin
        exit('GLOBAL_EXCHANGE');
    end;
}

