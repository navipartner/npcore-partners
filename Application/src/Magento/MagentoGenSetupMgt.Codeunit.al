codeunit 6151400 "NPR Magento Gen. Setup Mgt."
{
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";

    #region Init
    [Obsolete('Use native Business Central objects instead of dotnet.')]
    local procedure AddElement(var XmlDoc: DotNet "NPRNetXmlDocument"; NodePath: Text; Name: Text[250]; var XmlElement: DotNet NPRNetXmlElement): Boolean
    var
        XmlElementParent: DotNet NPRNetXmlElement;
    begin
        if IsNull(XmlDoc) then
            exit(false);

        XmlElementParent := XmlDoc.DocumentElement;
        if IsNull(XmlElementParent) then
            exit(false);

        if NodePath <> '' then begin
            NodePath := LowerCase(NodePath);
            if not NpXmlDomMgt.FindNode(XmlElementParent, NodePath, XmlElementParent) then
                exit(false);
        end;

        if NpXmlDomMgt.FindNode(XmlElementParent, Name, XmlElement) then
            exit(false);

        NpXmlDomMgt.AddElement(XmlElementParent, Name, XmlElement);
        exit(not IsNull(XmlElement));
    end;

    local procedure AddElement(var XmlDoc: XmlDocument; NodePath: Text; Name: Text[250]; var XDataElement: XmlElement): Boolean
    var
        XRootElement: XmlElement;
        XNodeParent: XmlNode;
        XNode: XmlNode;
    begin
        XmlDoc.GetRoot(XRootElement);
        if XRootElement.IsEmpty then
            exit(false);

        if NodePath <> '' then begin
            NodePath := LowerCase(NodePath);
            if not XRootElement.SelectSingleNode(NodePath, XNodeParent) then
                exit(false)
            else
                XRootElement := XNodeParent.AsXmlElement();
        end;

        if XRootElement.SelectSingleNode(Name, XNodeParent) then
            exit(false);

        XDataElement := XmlElement.Create(Name);
        XRootElement.Add(XDataElement);
        exit(not XDataElement.IsEmpty);
    end;

    [Obsolete('Use native Business Central objects instead of dotnet.')]
    procedure AddContainer(var XmlDoc: DotNet "NPRNetXmlDocument"; NodePath: Text; Name: Text[250])
    var
        XmlElement: DotNet NPRNetXmlElement;
    begin
        if not AddElement(XmlDoc, NodePath, Name, XmlElement) then
            exit;

        NpXmlDomMgt.AddAttribute(XmlElement, "AttributeName.ElementType", "ElementType.Container");
    end;

    procedure AddContainer(var XmlDoc: XmlDocument; NodePath: Text; Name: Text[250])
    var
        XElement: XmlElement;
    begin
        if not AddElement(XmlDoc, NodePath, Name, XElement) then
            exit;

        XElement.SetAttribute("AttributeName.ElementType"(), "ElementType.Container"());
    end;

    procedure AddFieldInteger(var XmlDoc: XmlDocument; NodePath: Text; Name: Text[250]; Value: Integer)
    var
        XElement: XmlElement;
    begin
        if not AddElement(XmlDoc, NodePath, Name, XElement) then
            exit;

        XElement.SetAttribute("AttributeName.ElementType"(), "ElementType.Field"());
        XElement.SetAttribute("AttributeName.FieldType"(), 'System.Int32');

        XElement.Add(Format(Value, 0, 9));
    end;

    procedure AddFieldDecimal(var XmlDoc: XmlDocument; NodePath: Text; Name: Text[250]; Value: Decimal)
    var
        XElement: XmlElement;
    begin
        if not AddElement(XmlDoc, NodePath, Name, XElement) then
            exit;

        XElement.SetAttribute("AttributeName.ElementType"(), "ElementType.Field"());
        XElement.SetAttribute("AttributeName.FieldType"(), 'System.Decimal');

        XElement.Add(Format(Value, 0, 9));
    end;

    [Obsolete('Use native Business Central objects instead of dotnet.')]
    procedure AddFieldText(var XmlDoc: DotNet "NPRNetXmlDocument"; NodePath: Text; Name: Text[250]; Value: Text[250])
    var
        XmlElement: DotNet NPRNetXmlElement;
    begin
        if not AddElement(XmlDoc, NodePath, Name, XmlElement) then
            exit;

        NpXmlDomMgt.AddAttribute(XmlElement, "AttributeName.ElementType", "ElementType.Field");
        NpXmlDomMgt.AddAttribute(XmlElement, "AttributeName.FieldType", Format(GetDotNetType(Value)));
        XmlElement.InnerText := Format(Value, 0, 9);
    end;

    procedure AddFieldText(var XmlDoc: XmlDocument; NodePath: Text; Name: Text[250]; Value: Text[250])
    var
        XElement: XmlElement;
    begin
        if not AddElement(XmlDoc, NodePath, Name, XElement) then
            exit;

        XElement.SetAttribute("AttributeName.ElementType"(), "ElementType.Field"());
        XElement.SetAttribute("AttributeName.FieldType"(), 'System.String');

        XElement.Add(Format(Value, 0, 9));
    end;

    procedure InitGenericMagentoSetup(var MagentoSetup: Record "NPR Magento Setup")
    var
        TempBlob: Codeunit "Temp Blob";
        MagentoNpXmlSetupMgt: Codeunit "NPR Magento NpXml Setup Mgt";
        RecRef: RecordRef;
    begin
        MagentoSetup.Get;
        if MagentoSetup."Generic Setup".HasValue then
            MagentoSetup.CalcFields("Generic Setup");

        TempBlob.FromRecord(MagentoSetup, MagentoSetup.FieldNo("Generic Setup"));
        InitGenericSetup(TempBlob);
        MagentoNpXmlSetupMgt.InitNpXmlTemplateSetup(TempBlob);

        RecRef.GetTable(MagentoSetup);
        TempBlob.ToRecordRef(RecRef, MagentoSetup.FieldNo("Generic Setup"));
        RecRef.SetTable(MagentoSetup);

        MagentoSetup.Modify;
    end;

    local procedure InitGenericSetup(var TempBlob: Codeunit "Temp Blob")
    var
        XmlDoc: XmlDocument;
        OutStream: OutStream;
    begin
        if TempBlob.HasValue then
            exit;

        XmlDocument.ReadFrom('<?xml version="1.0" encoding="UTF-8"?>' +
                        '<generic_setup />', XmlDoc);

        TempBlob.CreateOutStream(OutStream);
        XmlDoc.WriteTo(OutStream);
    end;
    #endregion

    #region Edit
    local procedure AddGenericBufferElement(var XmlElement: XmlElement; var LineNo: Integer; Level: Integer; ParentNodePath: Text[250]; var TempGenericSetupBuffer: Record "NPR Magento Gen. Setup Buffer" temporary)
    var
        XElement2: XmlElement;
        XNodeList: XmlNodeList;
        XNode: XmlNode;
        i: Integer;
    begin
        LineNo += 10000;
        TempGenericSetupBuffer.Init;
        TempGenericSetupBuffer."Line No." := LineNo;
        TempGenericSetupBuffer.Name := XmlElement.Name;
        TempGenericSetupBuffer."Node Path" := TempGenericSetupBuffer.Name;
        if ParentNodePath <> '' then
            TempGenericSetupBuffer."Node Path" := ParentNodePath + '/' + TempGenericSetupBuffer."Node Path";
        TempGenericSetupBuffer.Container := NpXmlDomMgt.GetXmlAttributeText(XmlElement, "AttributeName.ElementType", false) = "ElementType.Container";
        if not TempGenericSetupBuffer.Container then begin
            TempGenericSetupBuffer."Data Type" := NpXmlDomMgt.GetXmlAttributeText(XmlElement, "AttributeName.FieldType", false);
            TempGenericSetupBuffer.Value := XmlElement.InnerText;
        end;

        TempGenericSetupBuffer.Level := Level;
        TempGenericSetupBuffer.Insert;

        ParentNodePath := TempGenericSetupBuffer."Node Path";
        if TempGenericSetupBuffer.Container then begin
            XmlElement.SelectNodes('child::*', XNodeList);
            foreach XNode in XNodeList do begin
                XElement2 := XNode.AsXmlElement();
                if XElement2.Name <> '#text' then
                    AddGenericBufferElement(XElement2, LineNo, Level + 1, ParentNodePath, TempGenericSetupBuffer);
            end;
        end;
    end;

    local procedure EditGenericSetup(var TempBlob: Codeunit "Temp Blob"; NodePath: Text)
    var
        TempGenericSetupBuffer: Record "NPR Magento Gen. Setup Buffer" temporary;
        XmlDoc: XmlDocument;
        XNodeRoot: XmlNode;
        XNode: XmlNode;
        XNodeList: XmlNodeList;
        XElement: XmlElement;
        InStream: InStream;
        OutStream: OutStream;
        LineNo: Integer;
        i: Integer;
    begin
        TempGenericSetupBuffer.DeleteAll;
        if not LoadGenericSetup(TempBlob, XmlDoc) then
            exit;

        LineNo := 10000;
        if NodePath <> '' then
            XmlDoc.SelectSingleNode(NodePath, XNodeRoot);
        if not IsLeafNode(XNodeRoot) then begin
            XNodeRoot.SelectNodes('child::*', XNodeList);
            foreach XNode in XNodeList do begin
                XElement := XNode.AsXmlElement();
                AddGenericBufferElement(XElement, LineNo, 1, '', TempGenericSetupBuffer);
            end;
        end;
        TempGenericSetupBuffer.ModifyAll("Root Element", XNodeRoot.AsXmlElement().Name);

        PAGE.RunModal(PAGE::"NPR Magento Gen. Setup Buffer", TempGenericSetupBuffer);

        TempGenericSetupBuffer.SetRange(Container, false);
        if TempGenericSetupBuffer.FindSet then
            repeat
                XNodeRoot.SelectSingleNode(TempGenericSetupBuffer."Node Path", XNode); //xPath must be used.
                XNode.AsXmlElement().Add(TempGenericSetupBuffer.Value);
            until TempGenericSetupBuffer.Next = 0;
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        XmlDoc.WriteTo(OutStream);
    end;

    procedure EditGenericMagentoSetup(NodePath: Text)
    var
        MagentoSetup: Record "NPR Magento Setup";
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
    begin
        InitGenericMagentoSetup(MagentoSetup);
        Commit;
        TempBlob.FromRecord(MagentoSetup, MagentoSetup.FieldNo("Generic Setup"));
        EditGenericSetup(TempBlob, NodePath);

        RecRef.GetTable(MagentoSetup);
        TempBlob.ToRecordRef(RecRef, MagentoSetup.FieldNo("Generic Setup"));
        RecRef.SetTable(MagentoSetup);

        MagentoSetup.Modify(true);
    end;
    #endregion

    procedure LookupGenericSetup(var TempBlob: Codeunit "Temp Blob"; RootNodePath: Text): Text
    var
        TempGenericSetupBuffer: Record "NPR Magento Gen. Setup Buffer" temporary;
        GenericSetupBuffer: Page "NPR Magento Gen. Setup Buffer";
    begin
        LoadGenericSetupBuffer(TempBlob, RootNodePath, TempGenericSetupBuffer);
        if PAGE.RunModal(PAGE::"NPR Magento Gen. Setup Buffer", TempGenericSetupBuffer) <> ACTION::LookupOK then
            exit('');

        exit(TempGenericSetupBuffer.Value);
    end;

    procedure GetValueInteger(var TempBlob: Codeunit "Temp Blob"; NodePath: Text) Value: Integer
    var
        XmlDoc: XmlDocument;
        XElement: XmlElement;
        InStream: InStream;
    begin
        TempBlob.CreateInStream(InStream);
        XmlDocument.ReadFrom(InStream, XmlDoc);

        XmlDoc.GetRoot(XElement);
        Evaluate(Value, NpXmlDomMgt.GetXmlText(XElement, NodePath, 250, true), 9);
        exit(Value);

        exit(0);
    end;

    procedure GetValueDecimal(var TempBlob: Codeunit "Temp Blob"; NodePath: Text) Value: Decimal
    var
        XmlDoc: XmlDocument;
        XElement: XmlElement;
        InStream: InStream;
    begin
        TempBlob.CreateInStream(InStream);
        XmlDocument.ReadFrom(InStream, XmlDoc);

        XmlDoc.GetRoot(XElement);
        Evaluate(Value, NpXmlDomMgt.GetXmlText(XElement, NodePath, 250, true), 9);
        exit(Value);

        exit(0);
    end;

    procedure GetValueText(var TempBlob: Codeunit "Temp Blob"; NodePath: Text): Text[250]
    var
        XmlDoc: XmlDocument;
        XElement: XmlElement;
        InStream: InStream;
    begin
        TempBlob.CreateInStream(InStream);
        XmlDocument.ReadFrom(InStream, XmlDoc);

        XmlDoc.GetRoot(XElement);
        exit(Format(NpXmlDomMgt.GetXmlText(XElement, NodePath, 250, true), 0, 9));

        exit('');
    end;

    [Obsolete('Use native Business Central objects instead of dotnet.')]
    procedure LoadGenericSetup(var TempBlob: Codeunit "Temp Blob"; var XmlDoc: DotNet "NPRNetXmlDocument"): Boolean
    var
        InStream: InStream;
    begin
        if not TempBlob.HasValue then
            exit(false);

        TempBlob.CreateInStream(InStream);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(InStream);
        exit(true);
    end;

    procedure LoadGenericSetup(var TempBlob: Codeunit "Temp Blob"; var XmlDoc: XmlDocument): Boolean
    var
        InStream: InStream;
    begin
        if not TempBlob.HasValue then
            exit(false);

        TempBlob.CreateInStream(InStream);
        XmlDocument.ReadFrom(InStream, XmlDoc);
        exit(true);
    end;

    procedure LoadGenericSetupBuffer(var TempBlob: Codeunit "Temp Blob"; RootNodePath: Text; var TempGenericSetupBuffer: Record "NPR Magento Gen. Setup Buffer" temporary)
    var
        XmlDoc: XmlDocument;
        XNodeRoot: XmlNode;
        XNode: XmlNode;
        XNodeList: XmlNodeList;
        XElement: XmlElement;
        i: Integer;
        LineNo: Integer;
    begin
        TempGenericSetupBuffer.DeleteAll;
        InitGenericSetup(TempBlob);
        if not LoadGenericSetup(TempBlob, XmlDoc) then
            exit;

        LineNo := 10000;
        if RootNodePath <> '' then
            XmlDoc.SelectSingleNode(RootNodePath, XNodeRoot);
        if not IsLeafNode(XNodeRoot) then begin
            XNodeRoot.SelectNodes('child::*', XNodeList);
            foreach XNode in XNodeList do begin
                XElement := XNode.AsXmlElement();
                AddGenericBufferElement(XElement, LineNo, 1, '', TempGenericSetupBuffer);
            end;
        end;
        TempGenericSetupBuffer.ModifyAll("Root Element", XNodeRoot.AsXmlElement().Name);
    end;

    procedure ValidateValue(DataType: Text[50]; NewValue: Text[250]) Value: Text[250]
    var
        Decimal: Decimal;
        "Integer": Integer;
    begin
        if NewValue = '' then
            exit('');

        case DataType of
            'System.Int32':
                begin
                    Evaluate(Integer, NewValue, 9);
                    exit(Format(Integer, 0, 9));
                end;
            'System.Decimal':
                begin
                    Evaluate(Decimal, NewValue, 9);
                    exit(Format(Decimal, 0, 9));
                end;
        end;

        exit(Format(NewValue, 0, 9));
    end;

    procedure GetFieldRefValue(var RecRef: RecordRef; FieldNo: Integer): Text
    var
        FieldRef: FieldRef;
    begin
        if not OpenFieldRef(RecRef, FieldNo, FieldRef) then
            exit('');

        if LowerCase(Format(FieldRef.Class)) = 'flowfield' then
            FieldRef.CalcField;

        exit(Format(FieldRef.Value));
    end;

    procedure OpenRecRef(TableNo: Integer; var RecRef: RecordRef) TableExists: Boolean
    var
        AllObj: Record AllObj;
    begin
        if not AllObj.Get(AllObj."Object Type"::Table, TableNo) then
            exit(false);

        Clear(RecRef);
        RecRef.Open(TableNo);

        exit(true);
    end;

    procedure OpenFieldRef(var RecRef: RecordRef; FieldNo: Integer; var FieldRef: FieldRef) FieldExists: Boolean
    var
        "Field": Record "Field";
    begin
        if RecRef.Number <= 0 then
            exit(false);

        if not Field.Get(RecRef.Number, FieldNo) then
            exit(false);

        FieldRef := RecRef.Field(FieldNo);

        exit(true);
    end;

    procedure SetFieldRefFilter(var RecRef: RecordRef; FieldNo: Integer; FilterValue: Text) FieldExists: Boolean
    var
        FieldRef: FieldRef;
    begin
        if not OpenFieldRef(RecRef, FieldNo, FieldRef) then
            exit(false);
        FieldRef.SetFilter('=%1', FilterValue);
        exit(true);
    end;

    procedure IsLeafNode(XNode: XmlNode): Boolean
    var
        XElement: XmlElement;
        XNodeList: XmlNodeList;
        i: Integer;
    begin
        if not XNode.SelectNodes('child::*', XNodeList) then
            exit(true);

        foreach XNode in XNodeList do begin
            XElement := XNode.AsXmlElement();
            if XElement.Name <> '#text' then
                exit(false);
        end;
        exit(true);
    end;

    #region Variant Mgt.
    procedure LookupVariantPictureDimension(): Text
    var
        MagentoSetup: Record "NPR Magento Setup";
        TempBlob: Codeunit "Temp Blob";
        XmlDoc: XmlDocument;
        OutStream: OutStream;
    begin
        if not (MagentoSetup.Get and (MagentoSetup."Variant System" in [MagentoSetup."Variant System"::Variety])) then
            exit('');

        SetupDimensionBuffer(XmlDoc);
        case MagentoSetup."Variant System" of
            MagentoSetup."Variant System"::Variety:
                begin
                    if not SetupDimensionBufferVariety(XmlDoc) then
                        exit('');
                end;
        end;

        TempBlob.CreateOutStream(OutStream);
        XmlDoc.WriteTo(OutStream);
        exit(LookupGenericSetup(TempBlob, "ElementName.VariantDimension"));
    end;

    local procedure SetupDimensionBuffer(var XmlDoc: XmlDocument): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        InitGenericSetup(TempBlob);
        LoadGenericSetup(TempBlob, XmlDoc);
        AddContainer(XmlDoc, '', "ElementName.VariantDimension");
    end;

    local procedure SetupDimensionBufferVariety(var XmlDoc: XmlDocument): Boolean
    var
        RecRef: RecordRef;
        VarietyTableNo: Integer;
        VarietyCodeFieldNo: Integer;
        VarietyDescriptionFieldNo: Integer;
        FieldRef: FieldRef;
        FieldRef2: FieldRef;
    begin
        VarietyTableNo := 6059971;
        if not OpenRecRef(VarietyTableNo, RecRef) then
            exit(false);

        if not RecRef.FindSet then
            exit(false);

        VarietyDescriptionFieldNo := 10;
        VarietyCodeFieldNo := 1;
        repeat
            if OpenFieldRef(RecRef, VarietyDescriptionFieldNo, FieldRef) and OpenFieldRef(RecRef, VarietyCodeFieldNo, FieldRef2) then
                if (Format(FieldRef.Value) <> '') and (Format(FieldRef2.Value) <> '') then
                    AddFieldText(XmlDoc, "ElementName.VariantDimension", Format(FieldRef.Value), Format(FieldRef2.Value));
        until RecRef.Next = 0;

        exit(true);
    end;
    #endregion

    #region Enum
    local procedure "AttributeName.ElementType"(): Text
    begin
        exit('element_type');
    end;

    local procedure "AttributeName.FieldType"(): Text
    begin
        exit('field_type');
    end;

    local procedure "ElementType.Container"(): Text
    begin
        exit('container');
    end;

    local procedure "ElementType.Field"(): Text
    begin
        exit('field');
    end;

    procedure "ElementName.Amount"(): Text
    begin
        exit('amount');
    end;

    procedure "ElementName.Barcode"(): Text
    begin
        exit('barcode');
    end;

    local procedure "ElementName.Caption"(): Text
    begin
        exit('caption');
    end;

    procedure "ElementName.CreditVoucherReport"(): Text
    begin
        exit('credit_voucher_report');
    end;

    procedure "ElementName.CurrencyCode"(): Text
    begin
        exit('currency_code');
    end;

    procedure "ElementName.CustomerName"(): Text
    begin
        exit('customer_name');
    end;

    procedure "ElementName.ExpiryDate"(): Text
    begin
        exit('expiry_date');
    end;

    local procedure "ElementName.FontColor"(): Text
    begin
        exit('font_color');
    end;

    local procedure "ElementName.FontName"(): Text
    begin
        exit('font_name');
    end;

    local procedure "ElementName.FontSize"(): Text
    begin
        exit('font_size');
    end;

    local procedure "ElementName.FontStyle"(): Text
    begin
        exit('font_style');
    end;

    local procedure "ElementName.FontOpacity"(): Text
    begin
        exit('font_opacity');
    end;

    procedure "ElementName.GiftVoucherReport"(): Text
    begin
        exit('gift_voucher_report');
    end;

    local procedure "ElementName.Height"(): Text
    begin
        exit('height');
    end;

    procedure "ElementName.Message"(): Text
    begin
        exit('message');
    end;

    procedure "ElementName.VariantDimension"(): Text
    begin
        exit('variant_dimension');
    end;

    procedure "ElementName.WebCode"(): Text
    begin
        exit('web_code');
    end;

    procedure "ElementName.Width"(): Text
    begin
        exit('width');
    end;

    local procedure "ElementName.XPosition"(): Text
    begin
        exit('x_position');
    end;

    local procedure "ElementName.YPosition"(): Text
    begin
        exit('y_position');
    end;
    #endregion
}