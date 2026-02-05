codeunit 6060016 "NPR OIOUBL Document Management"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;

    var
        DocNameSpaceCBCLbl: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2', Locked = true;
        DocNameSpaceCACLbl: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2', Locked = true;


    procedure GetDefaultFilename(RecRef: RecordRef) Filename: Text[250]
    var
        OIOUBLSetup: Record "NPR OIOUBL Setup";
        CompanyInformation: Record "Company Information";
        FilenamePatternLbl: Label '%1-%2%3.xml', Locked = true;
        InvalidTableErr: Label 'Table %1 can''t be used to assign OIOUBL filenames.';
        DocumentType: Text;
    begin
        case RecRef.Number of
            Database::"Sales Invoice Header":
                DocumentType := 'Inv';
            Database::"Sales Cr.Memo Header":
                DocumentType := 'Cr';
            Database::"Service Invoice Header":
                DocumentType := 'SerInv';
            Database::"Service Cr.Memo Header":
                DocumentType := 'SerCr';
            else
                Error(InvalidTableErr, RecRef.Caption);
        end;

        OIOUBLSetup.Get();

        if OIOUBLSetup."Filename Pattern" <> '' then
            Filename := CopyStr(StrSubstNo(OIOUBLSetup."Filename Pattern", RecRef.Field(3).Value, DocumentType), 1, MaxStrLen(Filename))
        else begin
            CompanyInformation.Get();
            Filename := CopyStr(StrSubstNo(FilenamePatternLbl, CompanyInformation.GetVATRegistrationNumber(), DocumentType, RecRef.Field(3).Value), 1, MaxStrLen(Filename));
        end;

    end;

    [TryFunction]
    procedure UpdateOIOUBLContent(var TempBlob: Codeunit "Temp Blob"; SourceTableRecRef: RecordRef)
    begin
        if not TempBlob.HasValue() then
            exit;
        case SourceTableRecRef.Number of
            Database::"Sales Invoice Header":
                UpdateInvoiceContent(TempBlob, SourceTableRecRef);
            Database::"Sales Cr.Memo Header":
                UpdateCrMemoContent(TempBlob, SourceTableRecRef);
            Database::"Service Invoice Header":
                UpdateServiceInvoiceContent(TempBlob, SourceTableRecRef);
            Database::"Service Cr.Memo Header":
                UpdateServiceCrMemoContent(TempBlob, SourceTableRecRef);
            else
                exit;
        end;
    end;

    local procedure UpdateInvoiceContent(var SourceTempBlob: Codeunit "Temp Blob"; SourceTableRecRef: RecordRef)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        OIOUBLSetup: Record "NPR OIOUBL Setup";
        ReportSelections: Record "Report Selections";
        TempReportSelections: Record "Report Selections" temporary;
        ReportLayoutSelection: Record "Report Layout Selection";
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        NodeList: XmlNodeList;
        Node: XmlNode;
        PriceNode: XmlNode;
        Element: XmlElement;
        AdditionalDocumentReferenceElement: XmlElement;
        AttributeCollection: XmlAttributeCollection;
        Attribute: XmlAttribute;
        UnitCodeList: List of [Text];
        IStream: InStream;
        OStream: OutStream;
        ReportOutStream: OutStream;
        Id: Code[35];
        NodeCounter: Integer;
        PreviousElementFound: Boolean;
        LineExtensionAmount: Decimal;
        OrgPriceAmount: Decimal;
        PriceAmount: Decimal;
        BaseQuantity: Decimal;
        InvoicedQuantity: Decimal;
        XmlChanged: Boolean;
        BadXmlErr: Label 'Bad xml. Element "%1" not found.', Comment = '%1 - Element name';
    begin
        OIOUBLSetup.Get();
        SourceTempBlob.CreateInStream(IStream, TextEncoding::UTF8);
        XmlDocument.ReadFrom(IStream, Document);
        NamespaceManager.AddNamespace('inv2', 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2');
        NamespaceManager.AddNamespace('cbc', DocNameSpaceCBCLbl);
        NamespaceManager.AddNamespace('cac', DocNameSpaceCACLbl);

        if OIOUBLSetup."Include PDF Invoice" then begin
            SourceTableRecRef.SetTable(SalesInvoiceHeader);
            Id := '000';
            Document.SelectSingleNode('inv2:Invoice', NamespaceManager, Node);
            NodeList := Node.AsXmlElement().GetChildElements();
            for NodeCounter := 1 to NodeList.Count do begin
                NodeList.Get(NodeCounter, Node);
                if Node.AsXmlElement().LocalName in ['Signature', 'AccountingSupplierParty'] then begin
                    NodeList.Get(NodeCounter - 1, Node);
                    Element := Node.AsXmlElement();
                    PreviousElementFound := true;
                    NodeCounter := NodeList.Count();
                end;
            end;
            if not PreviousElementFound then
                Error(BadXmlErr, 'AccountingSupplierParty');
            ReportSelections.FindReportUsageForCust("Report Selection Usage"::"S.Invoice", SalesInvoiceHeader."Bill-to Customer No.", TempReportSelections);
            if TempReportSelections.FindSet() then begin
                RecRef.GetTable(SalesInvoiceHeader);
                RecRef.SetRecFilter();
                repeat
                    Id := IncStr(Id);
                    TempBlob.CreateOutStream(ReportOutStream);
                    ReportLayoutSelection.SetTempLayoutSelected(TempReportSelections."Custom Report Layout Code");
                    if Report.SaveAs(TempReportSelections."Report ID", '', ReportFormat::Pdf, ReportOutStream, RecRef) then begin
                        GenerateAdditionalDocumentReference(AdditionalDocumentReferenceElement, TempBlob, Id, 'application/pdf', DocNameSpaceCBCLbl, DocNameSpaceCACLbl);
                        Element.AddAfterSelf(AdditionalDocumentReferenceElement);
                    end;
                    ReportLayoutSelection.SetTempLayoutSelected('');
                    XmlChanged := true;
                until TempReportSelections.Next() = 0;
            end;
        end;

        Document.SelectNodes('/inv2:Invoice/cac:InvoiceLine/cbc:InvoicedQuantity/@unitCode', NamespaceManager, NodeList);
        foreach Node in NodeList do begin
            Attribute := Node.AsXmlAttribute();
            if not UnitCodeList.Contains(Attribute.Value) then
                UnitCodeList.Add(Attribute.Value);
        end;
        Document.SelectNodes('/inv2:Invoice/cac:InvoiceLine/cac:Price/cbc:BaseQuantity/@unitCode', NamespaceManager, NodeList);
        foreach Node in NodeList do begin
            Attribute := Node.AsXmlAttribute();
            if not UnitCodeList.Contains(Attribute.Value) then
                UnitCodeList.Add(Attribute.Value);
        end;
        ValidateUnitCodes(UnitCodeList);

        Document.SelectNodes('/inv2:Invoice/cac:InvoiceLine', NamespaceManager, NodeList);
        foreach Node in NodeList do begin
            BaseQuantity := GetDecimalValue(Node, 'cac:Price/cbc:BaseQuantity', NamespaceManager);
            OrgPriceAmount := GetDecimalValue(Node, 'cac:Price/cbc:PriceAmount', NamespaceManager);
            if (BaseQuantity <> 0) then begin
                LineExtensionAmount := GetDecimalValue(Node, 'cbc:LineExtensionAmount', NamespaceManager);
                InvoicedQuantity := GetDecimalValue(Node, 'cbc:InvoicedQuantity', NamespaceManager);
                if InvoicedQuantity <> 0 then
                    if Abs(LineExtensionAmount - (InvoicedQuantity * PriceAmount / BaseQuantity)) > 0.01 then begin
                        PriceAmount := Round((LineExtensionAmount / InvoicedQuantity) * BaseQuantity, 0.000000001);
                        if Abs(LineExtensionAmount - (InvoicedQuantity * PriceAmount / BaseQuantity)) > 0.01 then
                            PriceAmount := 0;
                        if OrgPriceAmount <> PriceAmount then
                            if Node.SelectSingleNode('cac:Price/cbc:PriceAmount', NamespaceManager, PriceNode) then begin
                                Element := PriceNode.AsXmlElement();
                                AttributeCollection := Element.Attributes();
                                Element.ReplaceWith(XmlElement.Create('PriceAmount', DocNameSpaceCBCLbl, AttributeCollection, Format(PriceAmount, 0, 9)));
                                XmlChanged := true;
                            end;
                    end;
            end;
        end;
        if XmlChanged then begin
            Clear(SourceTempBlob);
            SourceTempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
            Document.WriteTo(OStream);
        end;
    end;

    local procedure UpdateCrMemoContent(var SourceTempBlob: Codeunit "Temp Blob"; SourceTableRecRef: RecordRef)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        OIOUBLSetup: Record "NPR OIOUBL Setup";
        ReportSelections: Record "Report Selections";
        TempReportSelections: Record "Report Selections" temporary;
        ReportLayoutSelection: Record "Report Layout Selection";
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        NodeList: XmlNodeList;
        Node: XmlNode;
        PriceNode: XmlNode;
        Element: XmlElement;
        AdditionalDocumentReferenceElement: XmlElement;
        AttributeCollection: XmlAttributeCollection;
        Attribute: XmlAttribute;
        UnitCodeList: List of [Text];
        IStream: InStream;
        OStream: OutStream;
        ReportOutStream: OutStream;
        Id: Code[35];
        NodeCounter: Integer;
        PreviousElementFound: Boolean;
        LineExtensionAmount: Decimal;
        OrgPriceAmount: Decimal;
        PriceAmount: Decimal;
        BaseQuantity: Decimal;
        CreditedQuantity: Decimal;
        XmlChanged: Boolean;
        BadXmlErr: Label 'Bad xml. Element "%1" not found.', Comment = '%1 - Element name';

    begin
        OIOUBLSetup.Get();
        SourceTempBlob.CreateInStream(IStream, TextEncoding::UTF8);
        XmlDocument.ReadFrom(IStream, Document);
        NamespaceManager.AddNamespace('cr2', 'urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2');
        NamespaceManager.AddNamespace('cbc', DocNameSpaceCBCLbl);
        NamespaceManager.AddNamespace('cac', DocNameSpaceCACLbl);

        if OIOUBLSetup."Include PDF Cr. Memo" then begin
            SourceTableRecRef.SetTable(SalesCrMemoHeader);
            Id := '000';
            Document.SelectSingleNode('cr2:CreditNote', NamespaceManager, Node);
            NodeList := Node.AsXmlElement().GetChildElements();
            for NodeCounter := 1 to NodeList.Count do begin
                NodeList.Get(NodeCounter, Node);
                if Node.AsXmlElement().LocalName in ['Signature', 'AccountingSupplierParty'] then begin
                    NodeList.Get(NodeCounter - 1, Node);
                    Element := Node.AsXmlElement();
                    PreviousElementFound := true;
                    NodeCounter := NodeList.Count();
                end;
            end;
            if not PreviousElementFound then
                Error(BadXmlErr, 'AccountingSupplierParty');
            ReportSelections.FindReportUsageForCust("Report Selection Usage"::"S.Cr.Memo", SalesCrMemoHeader."Bill-to Customer No.", TempReportSelections);
            if TempReportSelections.FindSet() then begin
                RecRef.GetTable(SalesCrMemoHeader);
                RecRef.SetRecFilter();
                repeat
                    Id := IncStr(Id);
                    TempBlob.CreateOutStream(ReportOutStream);
                    ReportLayoutSelection.SetTempLayoutSelected(TempReportSelections."Custom Report Layout Code");
                    if Report.SaveAs(TempReportSelections."Report ID", '', ReportFormat::Pdf, ReportOutStream, RecRef) then begin
                        GenerateAdditionalDocumentReference(AdditionalDocumentReferenceElement, TempBlob, Id, 'application/pdf', DocNameSpaceCBCLbl, DocNameSpaceCACLbl);
                        Element.AddAfterSelf(AdditionalDocumentReferenceElement);
                    end;
                    ReportLayoutSelection.SetTempLayoutSelected('');
                    XmlChanged := true;
                until TempReportSelections.Next() = 0;
            end;
        end;

        Document.SelectNodes('/cr2:CreditNote/cac:CreditNoteLine/cbc:CreditedQuantity/@unitCode', NamespaceManager, NodeList);
        foreach Node in NodeList do begin
            Attribute := Node.AsXmlAttribute();
            if not UnitCodeList.Contains(Attribute.Value) then
                UnitCodeList.Add(Attribute.Value);
        end;
        Document.SelectNodes('/cr2:CreditNote/cac:CreditNoteLine/cac:Price/cbc:BaseQuantity/@unitCode', NamespaceManager, NodeList);
        foreach Node in NodeList do begin
            Attribute := Node.AsXmlAttribute();
            if not UnitCodeList.Contains(Attribute.Value) then
                UnitCodeList.Add(Attribute.Value);
        end;
        ValidateUnitCodes(UnitCodeList);

        Document.SelectNodes('/cr2:CreditNote/cac:CreditNoteLine', NamespaceManager, NodeList);
        foreach Node in NodeList do begin
            BaseQuantity := GetDecimalValue(Node, 'cac:Price/cbc:BaseQuantity', NamespaceManager);
            OrgPriceAmount := GetDecimalValue(Node, 'cac:Price/cbc:PriceAmount', NamespaceManager);
            if (BaseQuantity <> 0) then begin
                LineExtensionAmount := GetDecimalValue(Node, 'cbc:LineExtensionAmount', NamespaceManager);
                CreditedQuantity := GetDecimalValue(Node, 'cbc:CreditedQuantity', NamespaceManager);
                if CreditedQuantity <> 0 then
                    if Abs(LineExtensionAmount - (CreditedQuantity * PriceAmount / BaseQuantity)) > 0.01 then begin
                        PriceAmount := Round((LineExtensionAmount / CreditedQuantity) * BaseQuantity, 0.000000001);
                        if Abs(LineExtensionAmount - (CreditedQuantity * PriceAmount / BaseQuantity)) > 0.01 then
                            PriceAmount := 0;
                        if OrgPriceAmount <> PriceAmount then
                            if Node.SelectSingleNode('cac:Price/cbc:PriceAmount', NamespaceManager, PriceNode) then begin
                                Element := PriceNode.AsXmlElement();
                                AttributeCollection := Element.Attributes();
                                Element.ReplaceWith(XmlElement.Create('PriceAmount', DocNameSpaceCBCLbl, AttributeCollection, Format(PriceAmount, 0, 9)));
                                XmlChanged := true;
                            end;
                    end;
            end;
        end;
        if XmlChanged then begin
            Clear(SourceTempBlob);
            SourceTempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
            Document.WriteTo(OStream);
        end;

    end;

    local procedure UpdateServiceInvoiceContent(var SourceTempBlob: Codeunit "Temp Blob"; SourceTableRecRef: RecordRef)
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        OIOUBLSetup: Record "NPR OIOUBL Setup";
        ReportSelections: Record "Report Selections";
        TempReportSelections: Record "Report Selections" temporary;
        ReportLayoutSelection: Record "Report Layout Selection";
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        NodeList: XmlNodeList;
        Node: XmlNode;
        PriceNode: XmlNode;
        Element: XmlElement;
        AdditionalDocumentReferenceElement: XmlElement;
        AttributeCollection: XmlAttributeCollection;
        Attribute: XmlAttribute;
        UnitCodeList: List of [Text];
        IStream: InStream;
        OStream: OutStream;
        ReportOutStream: OutStream;
        Id: Code[35];
        NodeCounter: Integer;
        PreviousElementFound: Boolean;
        LineExtensionAmount: Decimal;
        OrgPriceAmount: Decimal;
        PriceAmount: Decimal;
        BaseQuantity: Decimal;
        InvoicedQuantity: Decimal;
        XmlChanged: Boolean;
        BadXmlErr: Label 'Bad xml. Element "%1" not found.', Comment = '%1 - Element name';
    begin
        OIOUBLSetup.Get();
        SourceTempBlob.CreateInStream(IStream, TextEncoding::UTF8);
        XmlDocument.ReadFrom(IStream, Document);
        NamespaceManager.AddNamespace('inv2', 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2');
        NamespaceManager.AddNamespace('cbc', DocNameSpaceCBCLbl);
        NamespaceManager.AddNamespace('cac', DocNameSpaceCACLbl);

        if OIOUBLSetup."Include PDF Invoice" then begin
            SourceTableRecRef.SetTable(ServiceInvoiceHeader);
            Id := '000';
            Document.SelectSingleNode('inv2:Invoice', NamespaceManager, Node);
            NodeList := Node.AsXmlElement().GetChildElements();
            for NodeCounter := 1 to NodeList.Count do begin
                NodeList.Get(NodeCounter, Node);
                if Node.AsXmlElement().LocalName in ['Signature', 'AccountingSupplierParty'] then begin
                    NodeList.Get(NodeCounter - 1, Node);
                    Element := Node.AsXmlElement();
                    PreviousElementFound := true;
                    NodeCounter := NodeList.Count();
                end;
            end;
            if not PreviousElementFound then
                Error(BadXmlErr, 'AccountingSupplierParty');
            ReportSelections.FindReportUsageForCust("Report Selection Usage"::"SM.Invoice", ServiceInvoiceHeader."Bill-to Customer No.", TempReportSelections);
            if TempReportSelections.FindSet() then begin
                RecRef.GetTable(ServiceInvoiceHeader);
                RecRef.SetRecFilter();
                repeat
                    Id := IncStr(Id);
                    TempBlob.CreateOutStream(ReportOutStream);
                    ReportLayoutSelection.SetTempLayoutSelected(TempReportSelections."Custom Report Layout Code");
                    if Report.SaveAs(TempReportSelections."Report ID", '', ReportFormat::Pdf, ReportOutStream, RecRef) then begin
                        GenerateAdditionalDocumentReference(AdditionalDocumentReferenceElement, TempBlob, Id, 'application/pdf', DocNameSpaceCBCLbl, DocNameSpaceCACLbl);
                        Element.AddAfterSelf(AdditionalDocumentReferenceElement);
                    end;
                    ReportLayoutSelection.SetTempLayoutSelected('');
                    XmlChanged := true;
                until TempReportSelections.Next() = 0;
            end;
        end;

        Document.SelectNodes('/inv2:Invoice/cac:InvoiceLine/cbc:InvoicedQuantity/@unitCode', NamespaceManager, NodeList);
        foreach Node in NodeList do begin
            Attribute := Node.AsXmlAttribute();
            if not UnitCodeList.Contains(Attribute.Value) then
                UnitCodeList.Add(Attribute.Value);
        end;
        Document.SelectNodes('/inv2:Invoice/cac:InvoiceLine/cac:Price/cbc:BaseQuantity/@unitCode', NamespaceManager, NodeList);
        foreach Node in NodeList do begin
            Attribute := Node.AsXmlAttribute();
            if not UnitCodeList.Contains(Attribute.Value) then
                UnitCodeList.Add(Attribute.Value);
        end;
        ValidateUnitCodes(UnitCodeList);

        Document.SelectNodes('/inv2:Invoice/cac:InvoiceLine', NamespaceManager, NodeList);
        foreach Node in NodeList do begin
            BaseQuantity := GetDecimalValue(Node, 'cac:Price/cbc:BaseQuantity', NamespaceManager);
            OrgPriceAmount := GetDecimalValue(Node, 'cac:Price/cbc:PriceAmount', NamespaceManager);
            if (BaseQuantity <> 0) then begin
                LineExtensionAmount := GetDecimalValue(Node, 'cbc:LineExtensionAmount', NamespaceManager);
                InvoicedQuantity := GetDecimalValue(Node, 'cbc:InvoicedQuantity', NamespaceManager);
                if InvoicedQuantity <> 0 then
                    if Abs(LineExtensionAmount - (InvoicedQuantity * PriceAmount / BaseQuantity)) > 0.01 then begin
                        PriceAmount := Round((LineExtensionAmount / InvoicedQuantity) * BaseQuantity, 0.000000001);
                        if Abs(LineExtensionAmount - (InvoicedQuantity * PriceAmount / BaseQuantity)) > 0.01 then
                            PriceAmount := 0;
                        if OrgPriceAmount <> PriceAmount then
                            if Node.SelectSingleNode('cac:Price/cbc:PriceAmount', NamespaceManager, PriceNode) then begin
                                Element := PriceNode.AsXmlElement();
                                AttributeCollection := Element.Attributes();
                                Element.ReplaceWith(XmlElement.Create('PriceAmount', DocNameSpaceCBCLbl, AttributeCollection, Format(PriceAmount, 0, 9)));
                                XmlChanged := true;
                            end;
                    end;
            end;
        end;
        if XmlChanged then begin
            Clear(SourceTempBlob);
            SourceTempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
            Document.WriteTo(OStream);
        end;

    end;

    local procedure UpdateServiceCrMemoContent(var SourceTempBlob: Codeunit "Temp Blob"; SourceTableRecRef: RecordRef)
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        OIOUBLSetup: Record "NPR OIOUBL Setup";
        ReportSelections: Record "Report Selections";
        TempReportSelections: Record "Report Selections" temporary;
        ReportLayoutSelection: Record "Report Layout Selection";
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        NodeList: XmlNodeList;
        Node: XmlNode;
        PriceNode: XmlNode;
        Element: XmlElement;
        AdditionalDocumentReferenceElement: XmlElement;
        AttributeCollection: XmlAttributeCollection;
        Attribute: XmlAttribute;
        UnitCodeList: List of [Text];
        IStream: InStream;
        OStream: OutStream;
        ReportOutStream: OutStream;
        Id: Code[35];
        NodeCounter: Integer;
        PreviousElementFound: Boolean;
        LineExtensionAmount: Decimal;
        OrgPriceAmount: Decimal;
        PriceAmount: Decimal;
        BaseQuantity: Decimal;
        CreditedQuantity: Decimal;
        XmlChanged: Boolean;
        BadXmlErr: Label 'Bad xml. Element "%1" not found.', Comment = '%1 - Element name';

    begin
        OIOUBLSetup.Get();
        SourceTempBlob.CreateInStream(IStream, TextEncoding::UTF8);
        XmlDocument.ReadFrom(IStream, Document);
        NamespaceManager.AddNamespace('cr2', 'urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2');
        NamespaceManager.AddNamespace('cbc', DocNameSpaceCBCLbl);
        NamespaceManager.AddNamespace('cac', DocNameSpaceCACLbl);

        if OIOUBLSetup."Include PDF Cr. Memo" then begin
            SourceTableRecRef.SetTable(ServiceCrMemoHeader);
            Id := '000';
            Document.SelectSingleNode('cr2:CreditNote', NamespaceManager, Node);
            NodeList := Node.AsXmlElement().GetChildElements();
            for NodeCounter := 1 to NodeList.Count do begin
                NodeList.Get(NodeCounter, Node);
                if Node.AsXmlElement().LocalName in ['Signature', 'AccountingSupplierParty'] then begin
                    NodeList.Get(NodeCounter - 1, Node);
                    Element := Node.AsXmlElement();
                    PreviousElementFound := true;
                    NodeCounter := NodeList.Count();
                end;
            end;
            if not PreviousElementFound then
                Error(BadXmlErr, 'AccountingSupplierParty');
            ReportSelections.FindReportUsageForCust("Report Selection Usage"::"SM.Credit Memo", ServiceCrMemoHeader."Bill-to Customer No.", TempReportSelections);
            if TempReportSelections.FindSet() then begin
                RecRef.GetTable(ServiceCrMemoHeader);
                RecRef.SetRecFilter();
                repeat
                    Id := IncStr(Id);
                    TempBlob.CreateOutStream(ReportOutStream);
                    ReportLayoutSelection.SetTempLayoutSelected(TempReportSelections."Custom Report Layout Code");
                    if Report.SaveAs(TempReportSelections."Report ID", '', ReportFormat::Pdf, ReportOutStream, RecRef) then begin
                        GenerateAdditionalDocumentReference(AdditionalDocumentReferenceElement, TempBlob, Id, 'application/pdf', DocNameSpaceCBCLbl, DocNameSpaceCACLbl);
                        Element.AddAfterSelf(AdditionalDocumentReferenceElement);
                    end;
                    ReportLayoutSelection.SetTempLayoutSelected('');
                    XmlChanged := true;
                until TempReportSelections.Next() = 0;
            end;
        end;

        Document.SelectNodes('/cr2:CreditNote/cac:CreditNoteLine/cbc:CreditedQuantity/@unitCode', NamespaceManager, NodeList);
        foreach Node in NodeList do begin
            Attribute := Node.AsXmlAttribute();
            if not UnitCodeList.Contains(Attribute.Value) then
                UnitCodeList.Add(Attribute.Value);
        end;
        Document.SelectNodes('/cr2:CreditNote/cac:CreditNoteLine/cac:Price/cbc:BaseQuantity/@unitCode', NamespaceManager, NodeList);
        foreach Node in NodeList do begin
            Attribute := Node.AsXmlAttribute();
            if not UnitCodeList.Contains(Attribute.Value) then
                UnitCodeList.Add(Attribute.Value);
        end;
        ValidateUnitCodes(UnitCodeList);

        Document.SelectNodes('/cr2:CreditNote/cac:CreditNoteLine', NamespaceManager, NodeList);
        foreach Node in NodeList do begin
            BaseQuantity := GetDecimalValue(Node, 'cac:Price/cbc:BaseQuantity', NamespaceManager);
            OrgPriceAmount := GetDecimalValue(Node, 'cac:Price/cbc:PriceAmount', NamespaceManager);
            if (BaseQuantity <> 0) then begin
                LineExtensionAmount := GetDecimalValue(Node, 'cbc:LineExtensionAmount', NamespaceManager);
                CreditedQuantity := GetDecimalValue(Node, 'cbc:CreditedQuantity', NamespaceManager);
                if CreditedQuantity <> 0 then
                    if Abs(LineExtensionAmount - (CreditedQuantity * PriceAmount / BaseQuantity)) > 0.01 then begin
                        PriceAmount := Round((LineExtensionAmount / CreditedQuantity) * BaseQuantity, 0.000000001);
                        if Abs(LineExtensionAmount - (CreditedQuantity * PriceAmount / BaseQuantity)) > 0.01 then
                            PriceAmount := 0;
                        if OrgPriceAmount <> PriceAmount then
                            if Node.SelectSingleNode('cac:Price/cbc:PriceAmount', NamespaceManager, PriceNode) then begin
                                Element := PriceNode.AsXmlElement();
                                AttributeCollection := Element.Attributes();
                                Element.ReplaceWith(XmlElement.Create('PriceAmount', DocNameSpaceCBCLbl, AttributeCollection, Format(PriceAmount, 0, 9)));
                                XmlChanged := true;
                            end;
                    end;
            end;
        end;
        if XmlChanged then begin
            Clear(SourceTempBlob);
            SourceTempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
            Document.WriteTo(OStream);
        end;
    end;

    local procedure GenerateAdditionalDocumentReference(var AdditionalDocumentReferenceElement: XmlElement; var Tempblob: Codeunit "Temp Blob"; ID: Code[35]; DocumentType: Text; DocNameSpaceCBC: Text[250]; DocNameSpaceCAC: Text[250]);
    var
        base64: Codeunit "Base64 Convert";
        IStream: InStream;
        Base64String: Text;
    begin
        Tempblob.CreateInStream(IStream);
        Base64String := base64.ToBase64(IStream);
        if Base64String = '' then
            exit;

        AdditionalDocumentReferenceElement := XmlElement.Create('AdditionalDocumentReference', DocNameSpaceCAC);

        AdditionalDocumentReferenceElement.Add(XmlElement.Create('ID', DocNameSpaceCBC, ID));
        AdditionalDocumentReferenceElement.Add(XmlElement.Create('DocumentType', DocNameSpaceCBC, DocumentType));
        InsertAttachment(AdditionalDocumentReferenceElement, Base64String, 'application/pdf', DocNameSpaceCBC, DocNameSpaceCAC);
    end;

    local procedure InsertAttachment(var AdditionalDocumentReferenceElement: XmlElement; Base64String: Text; MimeCode: Text; DocNameSpaceCBC: Text[250]; DocNameSpaceCAC: Text[250]);
    var
        AttachmentElement: XmlElement;
    begin
        AttachmentElement := XmlElement.Create('Attachment', DocNameSpaceCAC);
        AttachmentElement.Add(
          XmlElement.Create('EmbeddedDocumentBinaryObject', DocNameSpaceCBC,
            XmlAttribute.Create('encodingCode', 'base64'),
            XmlAttribute.Create('mimeCode', MimeCode),
            Base64String));
        AdditionalDocumentReferenceElement.Add(AttachmentElement);
    end;

    local procedure GetDecimalValue(Node: XmlNode; XPath: Text; NamespaceManager: XmlNamespaceManager): Decimal
    var
        ValueNode: XmlNode;
        DecimalValue: Decimal;
    begin
        if Node.SelectSingleNode(XPath, NamespaceManager, ValueNode) then
            if Evaluate(DecimalValue, ValueNode.AsXmlElement().InnerText, 9) then
                exit(DecimalValue);
        exit(0);
    end;

    local procedure ValidateUnitCodes(UnitCodes: List of [Text])
    var
        UnitOfMeasureInternatCode: Codeunit "NPR OIOUBL Unit Of Measure Mgt";
        UnitofMeasure: Record "Unit of Measure";
        ValidCodes: List of [Text];
        InValidCodes: List of [Text];
        InvalidUnitCodeErr: Label 'Following unitCodes are not valid for OIOUBL: %1\\Update %2 on corresponding %3.';
    begin
        UnitOfMeasureInternatCode.ValideUnitCodes(UnitCodes, ValidCodes, InValidCodes);
        if InValidCodes.Count > 0 then
            Error(InvalidUnitCodeErr, JoinList(InValidCodes, ', '), UnitofMeasure.FieldCaption("International Standard Code"), UnitofMeasure.TableCaption);
    end;

    local procedure JoinList(ListofText: List of [Text]; TextSeparator: Text): Text
    var
        TextValue: Text;
        Result: Text;
    begin
        foreach TextValue in ListofText do
            Result += TextValue + TextSeparator;
        Result := Result.TrimEnd(TextSeparator);
        exit(Result);
    end;
}


