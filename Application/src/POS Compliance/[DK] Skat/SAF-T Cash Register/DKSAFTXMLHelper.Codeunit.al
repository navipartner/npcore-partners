codeunit 6184674 "NPR DK SAF-T XML Helper"
{
    Access = Internal;

    var
        Depth: Integer;
        InsertElementErr: Label 'Not possible to insert element %1', Comment = '%1 - element name';
        NoFileGeneratedErr: Label 'No file generated';
        SAFTNameSpaceTxt: Label 'urn:StandardAuditFile-Taxation-CashRegister:DK', Locked = true;
        NamespaceFullName: Text;
        XMLDoc: XmlDocument;
        CurrXMLElement: array[100] of XmlElement;
        SavedXMLElement: XmlElement;

    internal procedure Initialize()
    begin
        Clear(XMLDoc);
        Clear(CurrXMLElement);
        Depth := 0;
        SetNamespace(SAFTNameSpaceTxt);
        CreateRootWithNamespace('auditfile');
    end;

    internal procedure SetNamespace(NewNamespace: Text)
    begin
        NamespaceFullName := NewNamespace;
    end;

    internal procedure CreateRootWithNamespace(RootNodeName: Text)
    begin
        Depth += 1;
        CurrXMLElement[Depth] := XmlElement.Create(RootNodeName, NamespaceFullName);
        XMLDoc.Add(CurrXMLElement[Depth]);
        XMLDoc.GetRoot(CurrXMLElement[Depth]);
    end;

    internal procedure AddNewXMLNode(Name: Text; NodeText: Text)
    var
        NewXMLElement: XmlElement;
    begin
        PrepareNodeTextForXML(NodeText);
        InsertXMLNode(NewXMLElement, Name, NodeText);
        Depth += 1;
        CurrXMLElement[Depth] := NewXMLElement;
    end;

    internal procedure AppendXMLNode(Name: Text; NodeText: Text)
    var
        NewXMLElement: XmlElement;
    begin
        PrepareNodeTextForXML(NodeText);
        if NodeText = '' then
            exit;
        InsertXMLNode(NewXMLElement, Name, NodeText);
    end;

    internal procedure AppendToSavedXMLNode(Name: Text; NodeText: Text)
    var
        NewXMLElement: XmlElement;
    begin
        PrepareNodeTextForXML(NodeText);
        if NodeText = '' then
            exit;

        NewXMLElement := XmlElement.Create(Name, NamespaceFullName, NodeText);
        if (not SavedXMLElement.AddFirst(NewXMLElement)) then
            Error(InsertElementErr, NodeText);
    end;

    internal procedure SaveCurrXmlElement()
    begin
        SavedXMLElement := CurrXMLElement[Depth];
    end;

    internal procedure FinalizeXMLNode()
    var
        IncorrectXMLStructureErr: Label 'Incorrect XML structure';
    begin
        Depth -= 1;
        if Depth < 0 then
            Error(IncorrectXMLStructureErr);
    end;

    local procedure InsertXMLNode(var NewXMLElement: XmlElement; Name: Text; NodeText: Text)
    begin
        PrepareNodeTextForXML(NodeText);
        NewXMLElement := XmlElement.Create(Name, NamespaceFullName, NodeText);
        if (not CurrXMLElement[Depth].Add(NewXMLElement)) then
            Error(InsertElementErr, NodeText);
    end;

    internal procedure ExportXMLDocument(var SAFTExportLine: Record "NPR DK SAF-T Cash Export Line"; SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header")
    var
        FileOutStream: OutStream;
    begin
        SAFTExportLine."SAF-T File".CreateOutStream(FileOutStream, TextEncoding::UTF8);
        XMLDoc.WriteTo(FileOutStream);
    end;

    internal procedure ExportSAFTExportLineBlobToFile(SAFTExportLine: Record "NPR DK SAF-T Cash Export Line"; FilePath: Text[512])
    var
        EntryTempBlob: Codeunit "Temp Blob";
        SAFTCashExportFile: Record "NPR DK SAF-T Cash Export File";
        SAFTCashExportMgt: Codeunit "NPR DK SAF-T Cash Export Mgt.";
        OutStr: OutStream;
        InStr: InStream;
    begin
        SAFTExportLine.CalcFields("SAF-T File");
        if not SAFTExportLine."SAF-T File".HasValue() then
            Error(NoFileGeneratedErr);
        EntryTempBlob.FromRecord(SAFTExportLine, SAFTExportLine.FieldNo("SAF-T File"));
        EntryTempBlob.CreateInStream(InStr);
        SAFTCashExportMgt.InitExportFile(SAFTCashExportFile, SAFTExportLine.ID);
        SAFTCashExportFile."File Name" := FilePath;
        SAFTCashExportFile."SAF-T File".CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
        SAFTCashExportFile.Insert();
    end;

    internal procedure GetFilePath(VATRegistrationNo: Text[20]; CreatedDateTime: DateTime; NumberOfFile: Integer; TotalNumberOfFiles: Integer): Text[512];
    var
        SAFTXMLFileNameLbl: Label 'SAF-T Cash Register_%1_%2_%3_%4.xml', Comment = '%1 - VAT Registration No., %2 - Date and Time of creation, %3 - No. of file, %4 - Total number of files';
        FileName: Text;
    begin
        FileName := StrSubstNo(SAFTXMLFileNameLbl, VATRegistrationNo, DateTimeOfFileCreation(CreatedDateTime), NumberOfFile, TotalNumberOfFiles);
        exit(CopyStr(FileName, 1, 512));
    end;

    local procedure DateTimeOfFileCreation(CreatedDateTime: DateTime): Text
    begin
        exit(Format(CreatedDateTime, 0, '<Year4><Month,2><Day,2><Hours24><Minutes,2><Seconds,2>'));
    end;

    local procedure PrepareNodeTextForXML(var RawXmlText: Text)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
    begin
#if BC17
        ClearUTF8BOMSymbols(RawXmlText);
#endif
        RawXmlText := XMLDOMManagement.XMLEscape(RawXmlText);
    end;

#if BC17
    local procedure ClearUTF8BOMSymbols(var XmlText: Text)
    var
        UTF8Encoding: DotNet UTF8Encoding;
        ByteOrderMarkUtf8: Text;
    begin
        UTF8Encoding := UTF8Encoding.UTF8Encoding();
        ByteOrderMarkUtf8 := UTF8Encoding.GetString(UTF8Encoding.GetPreamble());
        if StrPos(XmlText, ByteOrderMarkUtf8) = 1 then
            XmlText := DelStr(XmlText, 1, StrLen(ByteOrderMarkUtf8));
    end;
#endif
}
