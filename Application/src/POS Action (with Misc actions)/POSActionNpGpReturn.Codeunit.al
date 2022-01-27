codeunit 6151169 "NPR POS Action: NpGp Return"
{
    Access = Internal;
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
        NpGpCrossCompanySetup: Record "NPR NpGp Cross Company Setup";
        NoInterCompTradeErr: Label 'Inter company exchange is not set up between "%1" and "%2"';
        QuantityOverloadedErr: Label 'Quantity of items returned cannot exceed the original amount';
        ReadingErr: Label 'reading in %1';
        SettingScopeErr: Label 'setting scope in %1';

    local procedure ActionCode(): Code[20]
    begin
        exit('CROSS_REF_RETURN');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescriptionCaption,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('getReferenceNumber',
                'if (param.ReferenceBarcode === "")' +
                '{' +
                    'stringpad({title: labels.title,caption: labels.refprompt,notBlank: true}).cancel(abort);' +
                '}' +
                'else' +
                '{' +
                    'respond();' +
                '};');
            Sender.RegisterWorkflowStep('reasonReturn', 'context.PromptForReason && respond();');
            Sender.RegisterWorkflowStep('handle', 'respond();');
            Sender.RegisterWorkflow(true);

            Sender.RegisterBooleanParameter('ShowFullSale', false);
            Sender.RegisterTextParameter('ReferenceBarcode', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Context.SetContext('PromptForReason', true);

        FrontEnd.SetActionContext(ActionCode(), Context);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary;
        TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary;
        JSON: Codeunit "NPR POS JSON Management";
        ReturnReasonCode: Code[20];
        UseNormalReverseAction: Label 'This receipt is from the current company. Use the normal reversal action instead';
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        case WorkflowStep of
            'reasonReturn':
                begin
                    ReturnReasonCode := SelectReturnReason();
                    JSON.SetContext('ReturnReasonCode', ReturnReasonCode);
                    FrontEnd.SetActionContext(ActionCode(), JSON);
                end;
            'handle':
                begin
                    CheckSetup(POSSession);
                    FindReference(Context, FrontEnd, POSSession, TempNpGpPOSSalesLine, TempNpGpPOSSalesEntry);
                    if CompanyName = TempNpGpPOSSalesEntry."Original Company" then begin
                        Error(UseNormalReverseAction)
                    end else
                        CreateGlobalReverseSale(Context, POSSession, FrontEnd, TempNpGpPOSSalesLine, TempNpGpPOSSalesEntry);

                    POSSession.ChangeViewSale();
                    POSSession.RequestRefreshData();
                end;
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'title', TitleCaption);
        Captions.AddActionCaption(ActionCode(), 'refprompt', RefNoPromptCaption);
    end;

    local procedure SelectReturnReason(): Code[20]
    var
        ReturnReason: Record "Return Reason";
    begin
        if (PAGE.RunModal(PAGE::"NPR TouchScreen: Ret. Reasons", ReturnReason) = ACTION::LookupOK) then
            exit(ReturnReason.Code);

        Error(ReasonRequiredErr);
    end;

    local procedure FindReference(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary)
    var
        ReferenceNumber: Text;
    begin
        HandleReferenceNumber(Context, FrontEnd, ReferenceNumber);
        if (DelChr(ReferenceNumber, '<', ' ') = '') then
            Error(RefNoBlankErr);

        FindGlobalSaleByReferenceNo(FrontEnd, POSSession, Context, CopyStr(ReferenceNumber, 1, 50), TempNpGpPOSSalesLine, TempNpGpPOSSalesEntry);
    end;

    local procedure CheckSetup(POSSession: Codeunit "NPR POS Session"): Boolean
    var
        NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
        POSUnit: Record "NPR POS Unit";
        POSSetup: Codeunit "NPR POS Setup";
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
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        NpGpUserSaleReturn: Page "NPR NpGp User Sale Return";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        JSON: Codeunit "NPR POS JSON Management";
        XmlDoc: XmlDocument;
        Response: Text;
        ServiceName: Text;
        FirstNode: Text;
        SecondNode: Text;
        NameSpace: Text;
        FullSale: Boolean;
        InterCompSetup: Boolean;
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        ContextXMLText: Text;
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);

        POSUnit.TestField("Global POS Sales Setup");
        NpGpPOSSalesSetup.Get(POSUnit."Global POS Sales Setup");

        JSON.InitializeJObjectParser(Context, FrontEnd);

        FullSale := JSON.GetBooleanParameterOrFail('ShowFullSale', ActionCode());

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        ServiceName := GetServiceName(NpGpPOSSalesSetup."Service Url");

        RequestMessage.GetHeaders(RequestHeaders);

        NpGpPOSSalesSetup.SetRequestHeadersAuthorization(RequestHeaders);

        InitRequestBody(ServiceName, ReferenceNo, FullSale, XmlDoc);
        XmlDoc.WriteTo(ContextXMLText);
        RequestMessage.Content.WriteFrom(ContextXMLText);
        RequestMessage.Content.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'text/xml; charset=utf-8');
        ContentHeaders.Add('SOAPAction', 'GetGlobalSale');

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(NpGpPOSSalesSetup."Service Url");

        Client.Send(RequestMessage, ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode then
            Error(ResponseMessage.ReasonPhrase);

        ResponseMessage.Content.ReadAs(Response);

        //Object Metadata table is accessible only for OnPrem target
        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/global_pos_sales';
        FirstNode := 'sales_entries';
        SecondNode := 'tempnpgppossalesentry';

        if StrPos(Response, SecondNode) = 0 then
            Error(NoGlobalSaleErr);

        XmlDocument.ReadFrom('<' + FirstNode + ' xmlns="' + NameSpace + '">' +
                CopyStr(Response, StrPos(Response, '<' + SecondNode),
                StrPos(Response, '</npGpPOSEntries>') - StrPos(Response, '<' + SecondNode)) +
                '</' + FirstNode + '>',
            XmlDoc);

        GetRecordsFromXml(XmlDoc, TempNpGpPOSSalesLine, TempNpGpPOSSalesEntry);

        InterCompSetup := NpGpCrossCompanySetup.Get(TempNpGpPOSSalesEntry."Original Company");

        if not InterCompSetup then begin
            NpGpCrossCompanySetup.SetRange("Original Company", '');
            InterCompSetup := NpGpCrossCompanySetup.FindFirst();
        end;

        if (not InterCompSetup) and (CompanyName <> TempNpGpPOSSalesEntry."Original Company") then
            Error(NoInterCompTradeErr, CompanyName, TempNpGpPOSSalesEntry."Original Company");

        if not FullSale then
            exit;

        NpGpUserSaleReturn.SetTables(SalePOS, TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine);
        if not (NpGpUserSaleReturn.RunModal() = ACTION::OK) then
            Error('');
        NpGpUserSaleReturn.GetLines(TempNpGpPOSSalesLine);
    end;

    local procedure InitRequestBody(ServiceName: Text; ReferenceNo: Code[50]; FullSale: Boolean; var XmlDoc: XmlDocument)
    var
        NamespaceManager: XmlNamespaceManager;
        Element: XmlElement;
        Element2: XmlElement;
        RootElement: XmlElement;
        NodeList: XmlNodeList;
        Node1: XmlNode;
    begin
        Clear(XmlDoc);
        XmlDocument.ReadFrom('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                       '  <soapenv:Header />' +
                       '  <soapenv:Body>' +
                       '    <GetGlobalSale xmlns="urn:microsoft-dynamics-schemas/codeunit/' + ServiceName + '">' +
                       '       <referenceNumber />' +
                       '       <fullSale />' +
                       '       <npGpPOSEntries />' +
                       '    </GetGlobalSale>' +
                       '  </soapenv:Body>' +
                       '</soapenv:Envelope>', XmlDoc);

        XmlDoc.GetRoot(RootElement);
        NodeList := RootElement.GetChildElements();
        NodeList.Get(NodeList.Count, Node1); //.LastChild
        NodeList := Node1.AsXmlElement().GetChildElements();
        NodeList.Get(NodeList.Count, Node1); //.LastChild
        Element := Node1.AsXmlElement();

        NamespaceManager.NameTable := XmlDoc.NameTable;
        NamespaceManager.AddNamespace('ms', 'urn:microsoft-dynamics-schemas/codeunit/' + ServiceName);

        Element.SelectSingleNode('ms:referenceNumber', NamespaceManager, Node1);
        Element2 := Node1.AsXmlElement();
        Element2.ReplaceNodes(XmlText.Create(ReferenceNo));

        Element.SelectSingleNode('ms:fullSale', NamespaceManager, Node1);
        Element2 := Node1.AsXmlElement();
        Element2.ReplaceNodes(XmlText.Create(Format(FullSale, 0, 9)));
    end;

    local procedure GetServiceName(Url: Text) ServiceName: Text
    var
        NamePosition: Integer;
        TypeHelper: Codeunit "Type Helper";
        String: Text;
    begin
        String := TypeHelper.UrlDecode(Url);
        NamePosition := String.LastIndexOf('/') + 1;
        ServiceName := String.Substring(NamePosition, StrLen(String) - NamePosition);
    end;

    local procedure GetRecordsFromXml(XmlDoc: XmlDocument; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary;
        var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary)
    var
        NpGpPOSEntries: XMLport "NPR NpGp POS Entries";
        OutStm: OutStream;
        TempNpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry" temporary;
        TempBlob: Codeunit "Temp Blob";
        InStm: InStream;
    begin
        XmlDoc.WriteTo(OutStm);
        TempBlob.CreateInStream(InStm);
        CopyStream(OutStm, InStm);
        NpGpPOSEntries.SetSource(InStm);
        NpGpPOSEntries.Import();
        NpGpPOSEntries.GetSourceTables(TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine, TempNpGpPOSInfoPOSEntry);

        if TempNpGpPOSSalesLine.FindSet() then;
    end;

    local procedure CreateGlobalReverseSale(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry")
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSCrossRefMgt: Codeunit "NPR POS Cross Reference Mgt.";
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
        ReturnReasonCode := CopyStr(JSON.GetStringOrFail('ReturnReasonCode', StrSubstNo(ReadingErr, ActionCode())), 1, MaxStrLen(ReturnReasonCode));

        UpdateLineNos(SalePOS, TempNpGpPOSSalesLine);

        repeat
            SaleLinePOS.Init();
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
                Item.Get(TempNpGpPOSSalesLine."No.")
            else
                Item.Get(NpGpCrossCompanySetup."Generic Item No.");

            SaleLinePOS."No." := Item."No.";
            SaleLinePOS.Description := TempNpGpPOSSalesLine.Description;
            SaleLinePOS."Description 2" := TempNpGpPOSSalesLine."Description 2";
            if FullSale then
                SaleLinePOS.Validate(Quantity, TempNpGpPOSSalesLine.Quantity)
            else
                SaleLinePOS.Validate(Quantity, -1);
            SaleLinePOS.Validate("Unit Price", TempNpGpPOSSalesLine."Unit Price");
            SaleLinePOS."Unit of Measure Code" := TempNpGpPOSSalesLine."Unit of Measure Code";
            SaleLinePOS."Currency Code" := TempNpGpPOSSalesLine."Currency Code";
            SaleLinePOS.Cost := SaleLinePOS.Amount;
            SaleLinePOS."Location Code" := NpGpCrossCompanySetup."Location Code";
            SaleLinePOS."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
            SaleLinePOS."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
            SaleLinePOS."Return Sale Sales Ticket No." := TempNpGpPOSSalesEntry."Document No.";
            SaleLinePOS."Return Reason Code" := ReturnReasonCode;
            SaleLinePOS.Modify(true);

            POSCrossRefMgt.InitReference(SaleLinePOS.SystemId, TempNpGpPOSSalesLine."Global Reference", CopyStr(SaleLinePOS.TableName(), 1, 250), SaleLinePOS."Sales Ticket No." + '_' + Format(SaleLinePOS."Line No."));
        until not FullSale or (TempNpGpPOSSalesLine.Next() = 0);

        POSSaleLine.ResendAllOnAfterInsertPOSSaleLine();
        POSSale.RefreshCurrent();
    end;

    local procedure UpdateLineNos(SalePOS: Record "NPR POS Sale"; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TempNumber: Record "Integer" temporary;
        LineNo: Integer;
        i: Integer;
    begin
        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if not SaleLinePOS.FindLast() then
            exit;

        TempNpGpPOSSalesLine.FindLast();

        if SaleLinePOS."Line No." < TempNpGpPOSSalesLine."Line No." then
            LineNo += TempNpGpPOSSalesLine."Line No."
        else
            LineNo := SaleLinePOS."Line No.";

        for i := 1 to SaleLinePOS.Count() do begin
            LineNo += 10000;
            TempNumber.Number := LineNo;
            TempNumber.Insert();
        end;

        TempNumber.FindSet();
        repeat
            SaleLinePOS.FindFirst();
            SaleLinePOS.Rename(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", TempNumber.Number);
        until TempNumber.Next() = 0;

        TempNpGpPOSSalesLine.FindSet();
    end;

    local procedure TestQuantity(var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; SalePOS: Record "NPR POS Sale")
    var
        POSCrossReference: Record "NPR POS Cross Reference";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if TempNpGpPOSSalesLine.Quantity > 0 then begin
            SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");
            SaleLinePOS.SetFilter(Quantity, '<0');

            POSCrossReference.SetRange("Reference No.", TempNpGpPOSSalesLine."Global Reference");
            if POSCrossReference.FindSet() then
                repeat
                    SaleLinePOS.SetRange(SystemId, POSCrossReference.SystemId);
                    if SaleLinePOS.FindFirst() then
                        TempNpGpPOSSalesLine.Quantity += SaleLinePOS.Quantity;
                until POSCrossReference.Next() = 0;

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    begin
        if not EanBoxEvent.Get(EventCodeExchLabel()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeExchLabel();
            EanBoxEvent."Module Name" := ModuleNameCaption;
            EanBoxEvent.Description := EANDescriptionCaption;
            EanBoxEvent."Action Code" := CopyStr(ActionCode(), 1, MaxStrLen(EanBoxEvent."Action Code"));
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CODEUNIT::"NPR POS Action: NpGp Return";
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        if EanBoxEvent.Code = EventCodeExchLabel() then
            Sender.SetNonEditableParameterValues(EanBoxEvent, 'ReferenceBarcode', true, '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeGlobalExchLabel(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
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

