codeunit 6151391 "NPR RS Local. XML Mgt."
{
    Access = Internal;

    internal procedure CreateEPPPDVFormXML(TempVATEVEntry: Record "NPR VAT EV Entry" temporary; StartDate: Date; EndDate: Date; IsVATRefundRequired: Boolean) Result: Text
    var
        CompanyInformation: Record "Company Information";
        Document: XmlDocument;
        Calculations: XmlElement;
        Content: XmlElement;
        Envelop: XmlElement;
        RootElement: XmlElement;
        XmlWriteOpts: XmlWriteOptions;
    begin
        CompanyInformation.Get();

        Document := XmlDocument.Create('', '');
        Document.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'yes'));

        RootElement := XmlElement.Create('EPPPDV', 'urn:poreskauprava.gov.rs/zim');
        RootElement.Add(XmlAttribute.CreateNamespaceDeclaration('ns1', 'urn:poreskauprava.gov.rs/zim'));
        RootElement.Add(XmlAttribute.CreateNamespaceDeclaration('xsi', 'http://www.w3.org/2001/XMLSchema-instance'));

        Envelop := XmlElement.Create('envelopa');
        Envelop.SetAttribute('nacinPodnosenja', 'elektronski');
        Envelop.SetAttribute('timestamp', Format(CurrentDateTime(), 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2><Second dec>'));
        Envelop.SetAttribute('id', '');

        #region CONTENT SECTION

        Content := XmlElement.Create('sadrzaj');

        Content.Add(XmlElement.Create('OJ'));

        Content.Add(CreateXmlElement('PIB', CompanyInformation."VAT Registration No."));
        Content.Add(CreateXmlElement('Firma', CompanyInformation.Name));
        Content.Add(CreateXmlElement('Opstina', CompanyInformation.City));
        Content.Add(CreateXmlElement('Adresa', CompanyInformation.Address));
        Content.Add(CreateXmlElement('Od_Datum', Format(StartDate, 0, 9)));
        Content.Add(CreateXmlElement('Do_Datum', Format(EndDate, 0, 9)));
        Content.Add(CreateXmlElement('ElektronskaPosta', CompanyInformation."E-Mail"));
        Content.Add(CreateXmlElement('Mesto', CompanyInformation.City));
        Content.Add(CreateXmlElement('Datum_Prijave', Format(Today(), 0, 9)));
        Content.Add(CreateXmlElement('OdgovornoLice', CompanyInformation."Contact Person"));


        #region CONTENT TOTAL AMOUNTS

        Content.Add(CreateXmlElement('Iznos_001', FormatDecimalField(TempVATEVEntry."Field 1_5")));
        Content.Add(CreateXmlElement('Iznos_002', FormatDecimalField(TempVATEVEntry."Field 2_5")));

        Content.Add(CreateXmlElement('Iznos_003', FormatDecimalField(TempVATEVEntry."Field 5_1")));
        Content.Add(CreateXmlElement('Iznos_103', FormatDecimalField(TempVATEVEntry."Field 5_2")));

        Content.Add(CreateXmlElement('Iznos_004', FormatDecimalField(TempVATEVEntry."Field 5_4")));
        Content.Add(CreateXmlElement('Iznos_104', FormatDecimalField(TempVATEVEntry."Field 5_5")));

        Content.Add(CreateXmlElement('Iznos_005', FormatDecimalField(TempVATEVEntry."Field 5_6")));
        Content.Add(CreateXmlElement('Iznos_105', FormatDecimalField(TempVATEVEntry."Field 5_7")));

        Content.Add(CreateXmlElement('Iznos_006', FormatDecimalField(TempVATEVEntry."Field 6_3")));
        Content.Add(CreateXmlElement('Iznos_106', FormatDecimalField(TempVATEVEntry."Field 9a_1")));

        Content.Add(CreateXmlElement('Iznos_007', FormatDecimalField(TempVATEVEntry."Field 7_1_1")));
        Content.Add(CreateXmlElement('Iznos_107', FormatDecimalField(TempVATEVEntry."Field 7_4_2")));

        Content.Add(CreateXmlElement('Iznos_008', FormatDecimalField(TempVATEVEntry."Field 8dj")));
        Content.Add(CreateXmlElement('Iznos_108', FormatDecimalField(TempVATEVEntry."Field 8e_6")));

        Content.Add(CreateXmlElement('Iznos_009', FormatDecimalField(TempVATEVEntry."Field 9")));
        Content.Add(CreateXmlElement('Iznos_109', FormatDecimalField(TempVATEVEntry."Field 9a_4")));

        Content.Add(CreateXmlElement('Iznos_110', FormatDecimalField(TempVATEVEntry."Field 10"))); // 105 - 109

        #endregion

        Content.Add(CreateXmlElement('PovracajDA', Format(BoolToInt(IsVATRefundRequired))));
        Content.Add(CreateXmlElement('PovracajNE', Format(BoolToInt(not IsVATRefundRequired))));

        Content.Add(CreateXmlElement('PeriodPOB', '1'));
        Content.Add(CreateXmlElement('TipPodnosioca', '2'));
        Content.Add(CreateXmlElement('IzmenaPrijave', '0'));
        Content.Add(CreateXmlElement('IdentifikacioniBrojPrijaveKojaSeMenja', '0'));

        #endregion

        #region CALCULATIONS SECTION

        Calculations := XmlElement.Create('obracuni');

        Calculations.Add(CreateSectionByIdentificator('1', '_*', TempVATEVEntry));
        Calculations.Add(CreateSectionByIdentificator('2', '_*', TempVATEVEntry));
        Calculations.Add(CreateSectionByIdentificator('3', '_*', TempVATEVEntry));
        Calculations.Add(CreateSectionByIdentificator('3a', '_*', TempVATEVEntry));
        Calculations.Add(CreateSectionByIdentificator('4', '_*', TempVATEVEntry));
        Calculations.Add(CreateSectionByIdentificator('5', '_*', TempVATEVEntry));
        Calculations.Add(CreateSectionByIdentificator('6', '_*', TempVATEVEntry));
        Calculations.Add(CreateSectionByIdentificator('7', '_*', TempVATEVEntry));
        Calculations.Add(CreateSectionByIdentificator('8', '*', TempVATEVEntry));
        Calculations.Add(CreateSectionByIdentificator('9', '', TempVATEVEntry));
        Calculations.Add(CreateSectionByIdentificator('9a', '_*', TempVATEVEntry));
        Calculations.Add(CreateSectionByIdentificator('10', '', TempVATEVEntry));
        Calculations.Add(CreateSectionByIdentificator('11', '_*', TempVATEVEntry));

        #endregion

        Envelop.Add(Content);
        Envelop.Add(Calculations);
        RootElement.Add(Envelop);
        Document.Add(RootElement);

        XmlWriteOpts.PreserveWhitespace(true);
        Document.WriteTo(XmlWriteOpts, Result);
    end;

    local procedure CreateXmlElement(Name: Text; Content: Text) Element: XmlElement
    begin
        Element := XmlElement.Create(Name);
        Element.Add(XmlText.Create(Content));
    end;

    local procedure GetXmlElementByName(ElementName: Text; XmlElem: XmlElement): XmlElement
    var
        Node: XmlNode;
        Element: XmlElement;
        NodeList: XmlNodeList;
    begin
        NodeList := XmlElem.GetChildElements();
        foreach Node in NodeList do begin
            Element := Node.AsXmlElement();
            if Element.LocalName = ElementName then
                exit(Node.AsXmlElement());
        end;
    end;

    local procedure AreChildExistsInAnyElement(var NodeList: XmlNodeList): Boolean
    var
        Node: XmlNode;
        Element: XmlElement;
    begin
        foreach Node in NodeList do begin
            Element := Node.AsXmlElement();
            if Element.HasElements() then
                exit(true);
        end;
    end;

    local procedure CreateSectionByIdentificator(Identificator: Text; FilterExt: Text; var TempVATEVEntry: Record "NPR VAT EV Entry" temporary) Element: XmlElement
    var
        "Field": Record Field;
        RecRef: RecordRef;
        FldRef: FieldRef;
        FldValue: Decimal;
        ElementNameLbl: Label 'Iznos_%1', Comment = 'Specifies POPDV Identificator';
        FieldNameFilterLbl: Label 'Field %1%2', Comment = '%1 - specifies value of Identificator, %2 - specifies value of FilterExt', Locked = true;
        IdendificatorElemLbl: Label 'POPDV%1', Comment = '%1 - specifies Identificator parameter', Locked = true;
        ElementContent: Text;
        ElementName: Text;
    begin
        Element := XmlElement.Create(StrSubstNo(IdendificatorElemLbl, Identificator));

        RecRef.GetTable(TempVATEVEntry);
        "Field".SetRange(TableNo, Database::"NPR VAT EV Entry");
        "Field".SetRange(Type, "Field".Type::Decimal);
        "Field".SetFilter(FieldName, StrSubstNo(FieldNameFilterLbl, Identificator, FilterExt));

        if not "Field".FindSet() then
            exit;

        repeat
            Clear(FldValue);
            Clear(ElementName);
            FldRef := RecRef.Field("Field"."No.");
            FldValue := FldRef.Value();
            if FldValue <> 0 then begin
                ElementName := "Field".FieldName.Split(' ').Get(2);
                ElementName := DelChr(ElementName, '=', '_');
                ElementContent := FormatDecimalField(FldValue);
                Element.Add(CreateXmlElement(StrSubstNo(ElementNameLbl, ElementName), ElementContent));
            end;
        until "Field".Next() = 0;
    end;

    local procedure FormatDecimalField(Input: Decimal): Text
    begin
        exit(Format(Round(Input, 1, '='), 0, 9));
    end;

    local procedure BoolToInt(Input: Boolean): Integer
    begin
        if Input then
            exit(1)
        else
            exit(0);
    end;

    internal procedure ValidateXML(XmlDocTxt: Text): Boolean
    var
        TempErrorMessage: Record "Error Message" temporary;
    begin
        XmlValidation(XmlDocTxt, TempErrorMessage);
        if TempErrorMessage.HasErrors(false) then begin
            TempErrorMessage.ShowErrorMessages(false);
            exit;
        end;
        exit(true);
    end;

    internal procedure ExportXml(Result: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        Filename: Text;
        FilenameLbl: Label 'popdv_export.xml', Locked = true;
    begin
        Filename := FilenameLbl;
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteTExt(Result);
        TempBlob.CreateInStream(InStr);
        DownloadFromStream(InStr, '', '', '', Filename);
    end;

    local procedure XmlValidation(XmlDocTxt: Text; var TempErrorMessage: Record "Error Message" temporary)
    var
        NodeList: XmlNodeList;
        Calculations: XmlElement;
        XmlDoc: XmlDocument;
        RootElement: XmlNode;
        XmlNotValidErrLbl: Label 'XML provided is not valid.';
        EmptyXmlDocumentErrLbl: Label 'There is no elements in provided XML Document';
        EmptyCalculationsPartErrLbl: Label 'There is no elements in calculations part.';
        AmountsMissingErrLbl: Label 'There is no amounts in calculations part.';
    begin
        if not XmlDocument.ReadFrom(XmlDocTxt, XmlDoc) then begin
            TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, XmlNotValidErrLbl);
            exit;
        end;

        NodeList := XmlDoc.GetChildElements();

        if NodeList.Count() = 0 then begin
            TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, EmptyXmlDocumentErrLbl);
            exit;
        end;

        // Get envelop part
        NodeList.Get(1, RootElement);
        NodeList := RootElement.AsXmlElement().GetChildElements();
        NodeList.Get(1, RootElement);

        Calculations := GetXmlElementByName('obracuni', RootElement.AsXmlElement());

        if Calculations.GetChildNodes().Count() = 0 then begin
            TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, EmptyCalculationsPartErrLbl);
            exit;
        end;

        NodeList := Calculations.GetChildElements();

        if not AreChildExistsInAnyElement(NodeList) then begin
            TempErrorMessage.LogSimpleMessage(TempErrorMessage."Message Type"::Error, AmountsMissingErrLbl);
            exit;
        end;
    end;
}