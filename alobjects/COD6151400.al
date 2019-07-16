codeunit 6151400 "Magento Generic Setup Mgt."
{
    // MAG1.17/MHA /20150617  CASE 215910 Object created - includes functions to Init, Edit and Read Xml setup stored in BLOB field (Generic Setup)
    // MAG1.21/MHA /20151104  CASE 223835 Added Lookup functions
    //                                    LookupGenericSetup()
    //                                    LoadGenericSetupBuffer()
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.01/TR  /20161102  CASE 257315 Removed ':' in the DrawText Function
    // MAG2.02/TS  /20170125  CASE 262261 Fitlers was not appplied correctly when having & in value
    // MAG2.16/BHR /20180824  CASE 322752 Replace record Object to Allobj
    // MAG14.00.2.22/MHA/20190715  CASE 361942 Removed DotNet Graphics functionality


    trigger OnRun()
    begin
    end;

    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";

    procedure "--- Init"()
    begin
    end;

    local procedure AddElement(var XmlDoc: DotNet npNetXmlDocument; NodePath: Text; Name: Text[250]; var XmlElement: DotNet npNetXmlElement): Boolean
    var
        XmlElementParent: DotNet npNetXmlElement;
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

    procedure AddContainer(var XmlDoc: DotNet npNetXmlDocument; NodePath: Text; Name: Text[250])
    var
        XmlElement: DotNet npNetXmlElement;
    begin
        if not AddElement(XmlDoc, NodePath, Name, XmlElement) then
            exit;

        NpXmlDomMgt.AddAttribute(XmlElement, "AttributeName.ElementType", "ElementType.Container");
    end;

    procedure AddFieldInteger(var XmlDoc: DotNet npNetXmlDocument; NodePath: Text; Name: Text[250]; Value: Integer)
    var
        XmlElement: DotNet npNetXmlElement;
    begin
        if not AddElement(XmlDoc, NodePath, Name, XmlElement) then
            exit;

        NpXmlDomMgt.AddAttribute(XmlElement, "AttributeName.ElementType", "ElementType.Field");
        NpXmlDomMgt.AddAttribute(XmlElement, "AttributeName.FieldType", Format(GetDotNetType(Value)));
        XmlElement.InnerText := Format(Value, 0, 9);
    end;

    procedure AddFieldDecimal(var XmlDoc: DotNet npNetXmlDocument; NodePath: Text; Name: Text[250]; Value: Decimal)
    var
        XmlElement: DotNet npNetXmlElement;
    begin
        if not AddElement(XmlDoc, NodePath, Name, XmlElement) then
            exit;

        NpXmlDomMgt.AddAttribute(XmlElement, "AttributeName.ElementType", "ElementType.Field");
        NpXmlDomMgt.AddAttribute(XmlElement, "AttributeName.FieldType", Format(GetDotNetType(Value)));
        XmlElement.InnerText := Format(Value, 0, 9);
    end;

    procedure AddFieldText(var XmlDoc: DotNet npNetXmlDocument; NodePath: Text; Name: Text[250]; Value: Text[250])
    var
        XmlElement: DotNet npNetXmlElement;
    begin
        if not AddElement(XmlDoc, NodePath, Name, XmlElement) then
            exit;

        NpXmlDomMgt.AddAttribute(XmlElement, "AttributeName.ElementType", "ElementType.Field");
        NpXmlDomMgt.AddAttribute(XmlElement, "AttributeName.FieldType", Format(GetDotNetType(Value)));
        XmlElement.InnerText := Format(Value, 0, 9);
    end;

    procedure InitGenericMagentoSetup(var MagentoSetup: Record "Magento Setup")
    var
        TempBlob: Record TempBlob temporary;
        MagentoNpXmlSetupMgt: Codeunit "Magento NpXml Setup Mgt.";
    begin
        MagentoSetup.Get;
        if MagentoSetup."Generic Setup".HasValue then
            MagentoSetup.CalcFields("Generic Setup");

        TempBlob.Blob := MagentoSetup."Generic Setup";
        InitGenericSetup(TempBlob);
        InitGiftVoucherLayout(TempBlob);
        InitCreditVoucherLayout(TempBlob);
        //-MAG2.00
        MagentoNpXmlSetupMgt.InitNpXmlTemplateSetup(TempBlob);
        //+MAG2.00
        MagentoSetup."Generic Setup" := TempBlob.Blob;
        MagentoSetup.Modify;
    end;

    local procedure InitGenericSetup(var TempBlob: Record TempBlob temporary)
    var
        XmlDoc: DotNet npNetXmlDocument;
        OutStream: OutStream;
    begin
        if TempBlob.Blob.HasValue then
            exit;

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml('<?xml version="1.0" encoding="UTF-8"?>' +
                        '<generic_setup />');
        TempBlob.Blob.CreateOutStream(OutStream);
        XmlDoc.Save(OutStream);
    end;

    procedure "--- Edit"()
    begin
    end;

    local procedure AddGenericBufferElement(var XmlElement: DotNet npNetXmlElement; var LineNo: Integer; Level: Integer; ParentNodePath: Text[250]; var TempGenericSetupBuffer: Record "Magento Generic Setup Buffer" temporary)
    var
        XmlElement2: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
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
            XmlNodeList := XmlElement.ChildNodes;
            for i := 0 to XmlNodeList.Count - 1 do begin
                XmlElement2 := XmlNodeList.ItemOf(i);
                if XmlElement2.Name <> '#text' then
                    AddGenericBufferElement(XmlElement2, LineNo, Level + 1, ParentNodePath, TempGenericSetupBuffer);
            end;
        end;
    end;

    local procedure EditGenericSetup(var TempBlob: Record TempBlob temporary; NodePath: Text)
    var
        TempGenericSetupBuffer: Record "Magento Generic Setup Buffer" temporary;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        InStream: InStream;
        OutStream: OutStream;
        LineNo: Integer;
        i: Integer;
    begin
        TempGenericSetupBuffer.DeleteAll;
        if not LoadGenericSetup(TempBlob, XmlDoc) then
            exit;

        LineNo := 10000;
        XmlElement := XmlDoc.DocumentElement;
        if NodePath <> '' then
            XmlElement := XmlElement.SelectSingleNode(NodePath);
        if not NpXmlDomMgt.IsLeafNode(XmlElement) then begin
            XmlNodeList := XmlElement.ChildNodes;
            for i := 0 to XmlNodeList.Count - 1 do begin
                XmlElement2 := XmlNodeList.ItemOf(i);
                AddGenericBufferElement(XmlElement2, LineNo, 1, '', TempGenericSetupBuffer);
            end;
        end;
        TempGenericSetupBuffer.ModifyAll("Root Element", XmlElement.Name);

        PAGE.RunModal(PAGE::"Magento Generic Setup Buffer", TempGenericSetupBuffer);

        TempGenericSetupBuffer.SetRange(Container, false);
        if TempGenericSetupBuffer.FindSet then
            repeat
                XmlElement2 := XmlElement.SelectSingleNode(TempGenericSetupBuffer."Node Path");
                XmlElement2.InnerText := TempGenericSetupBuffer.Value;
            until TempGenericSetupBuffer.Next = 0;
        Clear(TempBlob.Blob);
        TempBlob.Blob.CreateOutStream(OutStream);
        XmlDoc.Save(OutStream);
    end;

    procedure EditGenericMagentoSetup(NodePath: Text)
    var
        MagentoSetup: Record "Magento Setup";
        TempBlob: Record TempBlob temporary;
    begin
        InitGenericMagentoSetup(MagentoSetup);
        Commit;
        TempBlob.Blob := MagentoSetup."Generic Setup";
        EditGenericSetup(TempBlob, NodePath);
        MagentoSetup."Generic Setup" := TempBlob.Blob;
        MagentoSetup.Modify(true);
    end;

    procedure "--- Lookup"()
    begin
    end;

    procedure LookupGenericSetup(var TempBlob: Record TempBlob temporary; RootNodePath: Text): Text
    var
        TempGenericSetupBuffer: Record "Magento Generic Setup Buffer" temporary;
        GenericSetupBuffer: Page "Magento Generic Setup Buffer";
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        InStream: InStream;
        OutStream: OutStream;
        LineNo: Integer;
        i: Integer;
    begin
        //-MAG1.21
        LoadGenericSetupBuffer(TempBlob, RootNodePath, TempGenericSetupBuffer);
        if PAGE.RunModal(PAGE::"Magento Generic Setup Buffer", TempGenericSetupBuffer) <> ACTION::LookupOK then
            exit('');

        exit(TempGenericSetupBuffer.Value);
        //+MAG1.21
    end;

    procedure "--- Get"()
    begin
    end;

    procedure GetValueInteger(var TempBlob: Record TempBlob temporary; NodePath: Text) Value: Integer
    var
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        InStream: InStream;
    begin
        TempBlob.Blob.CreateInStream(InStream);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(InStream);

        XmlElement := XmlDoc.DocumentElement;
        Evaluate(Value, NpXmlDomMgt.GetXmlText(XmlElement, NodePath, 250, true), 9);
        exit(Value);

        exit(0);
    end;

    procedure GetValueDecimal(var TempBlob: Record TempBlob temporary; NodePath: Text) Value: Decimal
    var
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        InStream: InStream;
    begin
        TempBlob.Blob.CreateInStream(InStream);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(InStream);

        XmlElement := XmlDoc.DocumentElement;
        Evaluate(Value, NpXmlDomMgt.GetXmlText(XmlElement, NodePath, 250, true), 9);
        exit(Value);

        exit(0);
    end;

    procedure GetValueText(var TempBlob: Record TempBlob temporary; NodePath: Text): Text[250]
    var
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        InStream: InStream;
    begin
        TempBlob.Blob.CreateInStream(InStream);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(InStream);

        XmlElement := XmlDoc.DocumentElement;
        exit(Format(NpXmlDomMgt.GetXmlText(XmlElement, NodePath, 250, true), 0, 9));

        exit('');
    end;

    procedure "--- Load"()
    begin
    end;

    procedure LoadGenericSetup(var TempBlob: Record TempBlob temporary; var XmlDoc: DotNet npNetXmlDocument): Boolean
    var
        InStream: InStream;
    begin
        if not TempBlob.Blob.HasValue then
            exit(false);

        TempBlob.Blob.CreateInStream(InStream);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(InStream);
        exit(true);
    end;

    procedure LoadGenericSetupBuffer(var TempBlob: Record TempBlob temporary; RootNodePath: Text; var TempGenericSetupBuffer: Record "Magento Generic Setup Buffer" temporary)
    var
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        i: Integer;
        LineNo: Integer;
    begin
        //-MAG1.21
        TempGenericSetupBuffer.DeleteAll;
        InitGenericSetup(TempBlob);
        if not LoadGenericSetup(TempBlob, XmlDoc) then
            exit;

        LineNo := 10000;
        XmlElement := XmlDoc.DocumentElement;
        if RootNodePath <> '' then
            XmlElement := XmlElement.SelectSingleNode(RootNodePath);
        if not NpXmlDomMgt.IsLeafNode(XmlElement) then begin
            XmlNodeList := XmlElement.ChildNodes;
            for i := 0 to XmlNodeList.Count - 1 do begin
                XmlElement2 := XmlNodeList.ItemOf(i);
                AddGenericBufferElement(XmlElement2, LineNo, 1, '', TempGenericSetupBuffer);
            end;
        end;
        TempGenericSetupBuffer.ModifyAll("Root Element", XmlElement.Name);
        //+MAG1.21
    end;

    procedure "--- Validate"()
    begin
    end;

    procedure ValidateValue(DataType: Text[50]; NewValue: Text[250]) Value: Text[250]
    var
        Decimal: Decimal;
        "Integer": Integer;
    begin
        if NewValue = '' then
            exit('');

        case DataType of
            Format(GetDotNetType(Integer)):
                begin
                    Evaluate(Integer, NewValue, 9);
                    exit(Format(Integer, 0, 9));
                end;
            Format(GetDotNetType(Decimal)):
                begin
                    Evaluate(Decimal, NewValue, 9);
                    exit(Format(Decimal, 0, 9));
                end;
        end;

        exit(Format(NewValue, 0, 9));
    end;

    procedure "--- FieldRef Mgt"()
    begin
    end;

    procedure GetFieldRefValue(var RecRef: RecordRef; FieldNo: Integer): Text
    var
        FieldRef: FieldRef;
    begin
        //-MAG1.21
        if not OpenFieldRef(RecRef, FieldNo, FieldRef) then
            exit('');

        if LowerCase(Format(FieldRef.Class)) = 'flowfield' then
            FieldRef.CalcField;

        exit(Format(FieldRef.Value));
        //+MAG1.21
    end;

    procedure OpenRecRef(TableNo: Integer; var RecRef: RecordRef) TableExists: Boolean
    var
        "Object": Record "Object";
        AllObj: Record AllObj;
    begin
        //-MAG1.21
        //-MAG2.16 [322752]
        //IF NOT Object.GET(Object.Type::Table,'',TableNo) THEN
        if not AllObj.Get(AllObj."Object Type"::Table, TableNo) then
            //+MAG2.16 [322752]
            exit(false);

        Clear(RecRef);
        RecRef.Open(TableNo);

        exit(true);
        //+MAG1.21
    end;

    procedure OpenFieldRef(var RecRef: RecordRef; FieldNo: Integer; var FieldRef: FieldRef) FieldExists: Boolean
    var
        "Field": Record "Field";
    begin
        //-MAG1.21
        if RecRef.Number <= 0 then
            exit(false);

        if not Field.Get(RecRef.Number, FieldNo) then
            exit(false);

        FieldRef := RecRef.Field(FieldNo);

        exit(true);
        //+MAG1.21
    end;

    procedure SetFieldRefFilter(var RecRef: RecordRef; FieldNo: Integer; FilterValue: Text) FieldExists: Boolean
    var
        FieldRef: FieldRef;
    begin
        //-MAG1.21
        if not OpenFieldRef(RecRef, FieldNo, FieldRef) then
            exit(false);
        //-MAG2.02
        // FieldRef.SETFILTER(FilterValue);
        FieldRef.SetFilter('=%1', FilterValue);
        //+MAG2.02
        exit(true);
        //+MAG1.21
    end;

    procedure "--- Variant Mgt."()
    begin
    end;

    procedure LookupVariantPictureDimension(): Text
    var
        MagentoSetup: Record "Magento Setup";
        TempBlob: Record TempBlob temporary;
        XmlDoc: DotNet npNetXmlDocument;
        OutStream: OutStream;
    begin
        //-MAG2.00
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

        TempBlob.Blob.CreateOutStream(OutStream);
        XmlDoc.Save(OutStream);
        exit(LookupGenericSetup(TempBlob, "ElementName.VariantDimension"));
        //+MAG2.00
    end;

    local procedure SetupDimensionBuffer(var XmlDoc: DotNet npNetXmlDocument): Boolean
    var
        TempBlob: Record TempBlob temporary;
    begin
        //-MAG2.00
        TempBlob.DeleteAll;
        InitGenericSetup(TempBlob);
        LoadGenericSetup(TempBlob, XmlDoc);
        AddContainer(XmlDoc, '', "ElementName.VariantDimension");
        //+MAG2.00
    end;

    local procedure SetupDimensionBufferVariety(var XmlDoc: DotNet npNetXmlDocument): Boolean
    var
        RecRef: RecordRef;
        VarietyTableNo: Integer;
        VarietyCodeFieldNo: Integer;
        VarietyDescriptionFieldNo: Integer;
        FieldRef: FieldRef;
        FieldRef2: FieldRef;
    begin
        //-MAG2.00
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
        //+MAG2.00
    end;

    local procedure "--- Voucher Init"()
    begin
    end;

    local procedure AddTextLayout(var XmlDoc: DotNet npNetXmlDocument; NodePath: Text; FontSize: Integer; XPosition: Integer; YPosition: Integer; Caption: Text[250])
    var
        GenericSetupMgt: Codeunit "Magento Generic Setup Mgt.";
    begin
        //-MAG2.00
        AddFieldText(XmlDoc, NodePath, "ElementName.Caption", Caption);
        AddFieldText(XmlDoc, NodePath, "ElementName.FontName", 'Segoe UI');
        AddFieldText(XmlDoc, NodePath, "ElementName.FontColor", 'Black');
        AddFieldText(XmlDoc, NodePath, "ElementName.FontStyle", 'Regular');
        AddFieldInteger(XmlDoc, NodePath, "ElementName.FontOpacity", 255);
        AddFieldInteger(XmlDoc, NodePath, "ElementName.FontSize", FontSize);
        AddFieldDecimal(XmlDoc, NodePath, "ElementName.XPosition", XPosition);
        AddFieldDecimal(XmlDoc, NodePath, "ElementName.YPosition", YPosition);
        //+MAG2.00
    end;

    local procedure AddBarcodeLayout(var XmlDoc: DotNet npNetXmlDocument; NodePath: Text; XPosition: Integer; YPosition: Integer; Width: Integer; Height: Integer)
    var
        GenericSetupMgt: Codeunit "Magento Generic Setup Mgt.";
    begin
        //-MAG2.00
        AddFieldDecimal(XmlDoc, NodePath, "ElementName.XPosition", XPosition);
        AddFieldDecimal(XmlDoc, NodePath, "ElementName.YPosition", YPosition);
        AddFieldDecimal(XmlDoc, NodePath, "ElementName.Width", Width);
        AddFieldDecimal(XmlDoc, NodePath, "ElementName.Height", Height);
        //+MAG2.00
    end;

    local procedure InitGiftVoucherLayout(var TempBlob: Record TempBlob temporary)
    var
        XmlDoc: DotNet npNetXmlDocument;
        OutStream: OutStream;
        NodePath: Text;
    begin
        LoadGenericSetup(TempBlob, XmlDoc);
        NodePath := '';
        AddContainer(XmlDoc, NodePath, "ElementName.GiftVoucherReport");

        NodePath := "ElementName.GiftVoucherReport";
        AddContainer(XmlDoc, NodePath, "ElementName.CustomerName");
        AddContainer(XmlDoc, NodePath, "ElementName.Amount");
        //-MAG1.19
        AddContainer(XmlDoc, NodePath, "ElementName.CurrencyCode");
        //-MAG1.19
        AddContainer(XmlDoc, NodePath, "ElementName.WebCode");
        AddContainer(XmlDoc, NodePath, "ElementName.ExpiryDate");
        AddContainer(XmlDoc, NodePath, "ElementName.Message");
        AddContainer(XmlDoc, NodePath, "ElementName.Barcode");

        NodePath := "ElementName.GiftVoucherReport" + '/' + "ElementName.Amount";
        AddTextLayout(XmlDoc, NodePath, 80, 1080, 1770, '');
        //-MAG1.19
        NodePath := "ElementName.GiftVoucherReport" + '/' + "ElementName.CurrencyCode";
        AddTextLayout(XmlDoc, NodePath, 80, 1300, 1770, '');
        //+MAG1.19
        NodePath := "ElementName.GiftVoucherReport" + '/' + "ElementName.CustomerName";
        AddTextLayout(XmlDoc, NodePath, 80, 200, 1200, '');
        NodePath := "ElementName.GiftVoucherReport" + '/' + "ElementName.WebCode";
        AddTextLayout(XmlDoc, NodePath, 80, 600, 2400, '');
        NodePath := "ElementName.GiftVoucherReport" + '/' + "ElementName.ExpiryDate";
        AddTextLayout(XmlDoc, NodePath, 40, 150, 2900, 'Valid until');
        NodePath := "ElementName.GiftVoucherReport" + '/' + "ElementName.Message";
        AddTextLayout(XmlDoc, NodePath, 40, 150, 2750, '');
        NodePath := "ElementName.GiftVoucherReport" + '/' + "ElementName.Barcode";
        AddBarcodeLayout(XmlDoc, NodePath, 900, 2600, 113 * 5, 30 * 5);

        Clear(TempBlob.Blob);
        TempBlob.Blob.CreateOutStream(OutStream);
        XmlDoc.Save(OutStream);
    end;

    local procedure InitCreditVoucherLayout(var TempBlob: Record TempBlob temporary)
    var
        XmlDoc: DotNet npNetXmlDocument;
        OutStream: OutStream;
        NodePath: Text;
    begin
        LoadGenericSetup(TempBlob, XmlDoc);

        NodePath := '';
        AddContainer(XmlDoc, NodePath, "ElementName.CreditVoucherReport");

        NodePath := "ElementName.CreditVoucherReport";
        AddContainer(XmlDoc, NodePath, "ElementName.CustomerName");
        AddContainer(XmlDoc, NodePath, "ElementName.Amount");
        //-MAG1.19
        AddContainer(XmlDoc, NodePath, "ElementName.CurrencyCode");
        //+MAG1.19
        AddContainer(XmlDoc, NodePath, "ElementName.WebCode");
        AddContainer(XmlDoc, NodePath, "ElementName.ExpiryDate");
        AddContainer(XmlDoc, NodePath, "ElementName.Barcode");

        NodePath := "ElementName.CreditVoucherReport" + '/' + "ElementName.Amount";
        AddTextLayout(XmlDoc, NodePath, 80, 1080, 1770, '');
        //-MAG1.19
        NodePath := "ElementName.CreditVoucherReport" + '/' + "ElementName.CurrencyCode";
        AddTextLayout(XmlDoc, NodePath, 80, 1300, 1770, '');
        //+MAG1.19
        NodePath := "ElementName.CreditVoucherReport" + '/' + "ElementName.CustomerName";
        AddTextLayout(XmlDoc, NodePath, 80, 200, 1200, '');
        NodePath := "ElementName.CreditVoucherReport" + '/' + "ElementName.WebCode";
        AddTextLayout(XmlDoc, NodePath, 80, 600, 2400, '');
        NodePath := "ElementName.CreditVoucherReport" + '/' + "ElementName.ExpiryDate";
        AddTextLayout(XmlDoc, NodePath, 40, 150, 2900, 'Valid until');
        NodePath := "ElementName.CreditVoucherReport" + '/' + "ElementName.Barcode";
        AddBarcodeLayout(XmlDoc, NodePath, 900, 2600, 113 * 5, 60 * 5);

        Clear(TempBlob.Blob);
        TempBlob.Blob.CreateOutStream(OutStream);
        XmlDoc.Save(OutStream);
    end;

    procedure "--- Voucher Drawing"()
    begin
    end;

    procedure DrawText(var TempBlob: Record TempBlob temporary; var Graphics: DotNet npNetGraphics; SetupPath: Text; Value: Text)
    begin
        //-MAG14.00.2.22 [361942]
        Error('Deprecated');
        //+MAG14.00.2.22 [361942]
    end;

    procedure DrawBarcode(var Graphics: DotNet npNetGraphics; var TempBlob: Record TempBlob temporary; SetupPath: Text; Value: Text; Bitmap: DotNet npNetBitmap; BitmapBarcode: DotNet npNetBitmap)
    begin
        //-MAG14.00.2.22 [361942]
        Error('Deprecated');
        //+MAG14.00.2.22 [361942]
    end;

    local procedure "--- Enum"()
    begin
    end;

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

    local procedure "--- Enum Voucher"()
    begin
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
        //-MAG1.21
        exit('variant_dimension');
        //+MAG1.21
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
}

