codeunit 6059996 "NPR Scanner Service WS"
{
    // NPR5.29/NPKNAV/20170127  CASE 252352 Transport NPR5.29 - 27 januar 2017
    // NPR5.32/CLVA/20170508 CASE 252352 Change barcode verification
    // NPR5.38/CLVA/20171009 CASE 292601 Added Item Picture
    // NPR5.40/THRO/20180309 CASE 307571 Set Variant filter when calculating Inventory in GetItem()
    // NPR5.40/MHA /20180316 CASE 308377 Deleted unused Automation variables in Get_BoolFromNode() and Get_DecimalFromNode()


    trigger OnRun()
    var
        webservices: Record "Web Service";
        TmpRequest: BigText;
    begin
        Clear(webservices);

        if not webservices.Get(webservices."Object Type"::Codeunit, 'scanner_service') then begin
            webservices.Init;
            webservices."Object Type" := webservices."Object Type"::Codeunit;
            webservices."Service Name" := 'scanner_service';
            webservices."Object ID" := 6059996;
            webservices.Published := true;
            webservices.Insert;
        end;
    end;

    var
        NormalCaseMode: Boolean;
        Text000: Label 'Could not create element %1.';
        Text001: Label 'Could not create attribute %1.';
        ScannerServiceFunctions: Codeunit "NPR Scanner Service Func.";
        ScannerServiceLog: Record "NPR Scanner Service Log";
        IsInternal: Boolean;
        InternalCallId: Guid;
        ErrorReport: Text;
        ItemNotFoundError: Label 'Item with barcode %1 doesn''t exist';
        ItemNotAddedError: Label 'No items added';
        ItemNoIsMissingError: Label 'Item No. is missing ';
        ItemQtyIsMissingError: Label 'Item Qty. is missing ';
        InvalidItemQtyError: Label 'Item Qty. format is invalid: %1';
        InvalidDatetimeError: Label 'Timestamp format is invalid: %1';
        ScannerServiceSetup: Record "NPR Scanner Service Setup";
        JournalIsMissingError: Label 'Journal is missing ';
        JournalNotFoundError: Label 'Journal %1 doesn''t exist';
        BarcodeNotFoundError: Label 'Barcode %1 doesn''t exist';
        ItemImageNotFoundError: Label 'No Image for itemno';

    procedure Process(var Request: BigText)
    var
        xmlrootnode: DotNet NPRNetXmlNode;
        XMLdocIn: DotNet "NPRNetXmlDocument";
        txtLocalName: Text;
    begin
        ScannerServiceSetup.Get;
        if ScannerServiceSetup."Log Request" then begin
            ScannerServiceLog.Init;
            //ScannerServiceFunctions.CreateLogEntry(ScannerServiceLog,Request);
        end;

        ConvertBigTextToXml(XMLdocIn, Request);

        xmlrootnode := XMLdocIn.DocumentElement;
        case xmlrootnode.LocalName of
            'scanneditem':
                GetItem(0, Request, XMLdocIn);
            'statusitem':
                PutStatusItem(Request, XMLdocIn);
            'journalitem':
                GetItem(1, Request, XMLdocIn);
            'showscanneditemimage':
                GetItem(2, Request, XMLdocIn);
            else
                Error(StrSubstNo('METHOD %1 NOT FOUND', xmlrootnode.LocalName));
        end;

        if ScannerServiceSetup."Log Request" then
            ScannerServiceFunctions.UpdateLogEntry(ScannerServiceLog, xmlrootnode.LocalName, IsInternal, InternalCallId, Request);
    end;

    local procedure PutStatusItem(var Request: BigText; XMLdocIn: DotNet "NPRNetXmlDocument")
    var
        XMLNodeList: DotNet NPRNetXmlNodeList;
        i: Integer;
        XMLNode: DotNet NPRNetXmlNode;
        Header: Text[1000];
        XMLCurrNode: DotNet NPRNetXmlNode;
        XMLNewChild: DotNet NPRNetXmlNode;
        XMLdocOut: DotNet "NPRNetXmlDocument";
        XMLRootNode: DotNet NPRNetXmlNode;
        StockTakeWorkSheetName: Record "NPR Stock-Take Worksheet";
        StockTakeMgr: Codeunit "NPR Stock-Take Manager";
        StockTakeWorksheet: Record "NPR Stock-Take Worksheet";
        JournalCode: Code[20];
        BatchName: Code[20];
        LineNo: Integer;
        StockTakeWorkSheetLine: Record "NPR Stock-Take Worksheet Line";
        NewStockTakeWorksheetLine: Record "NPR Stock-Take Worksheet Line";
        ScannedItemCode: Text[30];
        Quantity: Text[10];
        Shelf: Code[10];
        SessionName: Text[40];
        Timestamp: Text;
        TimestampDate: Date;
        DataError: Boolean;
        Item: Record Item;
        tmpInt: Integer;
        BarcodeLibrary: Codeunit "NPR Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
    begin
        XMLdocOut := XMLdocOut.XmlDocument();
        Header := '<?xml version="1.0" encoding="utf-8" ?><statusitemadded/>';
        XMLdocOut.LoadXml(Header);
        XMLCurrNode := XMLdocOut.DocumentElement;

        ScannerServiceSetup.TestField("Stock-Take Config Code");
        JournalCode := ScannerServiceSetup."Stock-Take Config Code";

        XMLNodeList := XMLdocIn.SelectNodes('/statusitem');
        if XMLNodeList.Count > 0 then begin
            for i := 0 to XMLNodeList.Count() - 1 do begin
                XMLNode := XMLNodeList.ItemOf(i);

                DataError := false;

                Shelf := Get_TextFromNode(XMLNode, 'shelfcode');

                BatchName := Get_TextFromNode(XMLNode, 'journal');
                if BatchName = '' then begin
                    Add_Element(XMLCurrNode, 'error', JournalIsMissingError, '', XMLNewChild, '');
                    DataError := true;
                end else begin
                    if not StockTakeWorksheet.Get(JournalCode, BatchName) then begin
                        Add_Element(XMLCurrNode, 'error', StrSubstNo(JournalNotFoundError, BatchName), '', XMLNewChild, '');
                        DataError := true;
                    end;
                end;

                ScannedItemCode := Get_TextFromNode(XMLNode, 'itemnumber');
                if ScannedItemCode = '' then begin
                    Add_Element(XMLCurrNode, 'error', ItemNoIsMissingError, '', XMLNewChild, '');
                    DataError := true;
                end else begin
                    //-NPR5.32
                    if BarcodeLibrary.TranslateBarcodeToItemVariant(ScannedItemCode, ItemNo, VariantCode, ResolvingTable, true) then begin
                        if not Item.Get(ItemNo) then begin
                            Add_Element(XMLCurrNode, 'error', StrSubstNo(ItemNotFoundError, ScannedItemCode), '', XMLNewChild, '');
                            DataError := true;
                        end;
                    end else begin
                        Add_Element(XMLCurrNode, 'error', StrSubstNo(BarcodeNotFoundError, ScannedItemCode), '', XMLNewChild, '');
                        DataError := true;
                    end;
                    //+NPR5.32
                end;

                Quantity := Get_TextFromNode(XMLNode, 'quantity');
                if Quantity = '' then begin
                    Add_Element(XMLCurrNode, 'error', ItemQtyIsMissingError, '', XMLNewChild, '');
                    DataError := true;
                end else begin
                    if not Evaluate(tmpInt, Quantity) then begin
                        Add_Element(XMLCurrNode, 'error', StrSubstNo(InvalidItemQtyError, Quantity), '', XMLNewChild, '');
                        DataError := true;
                    end;
                end;

                Timestamp := Get_TextFromNode(XMLNode, 'timestamp');
                if not DateTimeTryBlock(Timestamp, TimestampDate) then begin
                    Add_Element(XMLCurrNode, 'error', StrSubstNo(InvalidDatetimeError, Timestamp), '', XMLNewChild, '');
                    DataError := true;
                end;

                if not DataError then begin

                    StockTakeWorksheet.Get(JournalCode, BatchName);

                    SessionName := Format(CurrentDateTime(), 0, 9);

                    StockTakeMgr.ImportPreHandler(StockTakeWorksheet);

                    Clear(NewStockTakeWorksheetLine);
                    NewStockTakeWorksheetLine.SetRange("Stock-Take Config Code", JournalCode);
                    NewStockTakeWorksheetLine.SetRange("Worksheet Name", BatchName);
                    LineNo := 0;
                    if NewStockTakeWorksheetLine.FindLast then
                        LineNo := NewStockTakeWorksheetLine."Line No." + 1000
                    else
                        LineNo := 1000;

                    Clear(StockTakeWorkSheetLine);
                    StockTakeWorkSheetLine."Stock-Take Config Code" := JournalCode;
                    StockTakeWorkSheetLine."Worksheet Name" := BatchName;
                    StockTakeWorkSheetLine."Line No." := LineNo;
                    StockTakeWorkSheetLine.Validate(Barcode, ScannedItemCode);
                    StockTakeWorkSheetLine."Shelf  No." := Shelf;
                    Evaluate(StockTakeWorkSheetLine."Qty. (Counted)", Quantity);
                    StockTakeWorkSheetLine."Session Name" := SessionName;
                    StockTakeWorkSheetLine."Date of Inventory" := TimestampDate;
                    StockTakeWorkSheetLine.Insert(true);

                    StockTakeMgr.ImportPostHandler(StockTakeWorksheet);

                    Add_Element(XMLCurrNode, 'error', '', '', XMLNewChild, '');
                end;
            end;
        end else begin
            Add_Element(XMLCurrNode, 'error', ItemNotAddedError, '', XMLNewChild, '');
        end;

        ConvertXmlToBigText(XMLdocOut, Request);
    end;

    local procedure GetItem(RecUsage: Option Item,Journal; var Request: BigText; XMLdocIn: DotNet "NPRNetXmlDocument")
    var
        XMLRecID: Code[50];
        Header: Text[1000];
        XMLCurrNode: DotNet NPRNetXmlNode;
        XMLNewChild: DotNet NPRNetXmlNode;
        XMLdocOut: DotNet "NPRNetXmlDocument";
        Item: Record Item;
        StockTakeWorksheet: Record "NPR Stock-Take Worksheet";
        BarcodeLibrary: Codeunit "NPR Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        Base64String: Text;
    begin
        XMLdocOut := XMLdocOut.XmlDocument;
        Header := '<?xml version="1.0" encoding="utf-8" ?><Item />';
        XMLdocOut.LoadXml(Header);
        XMLCurrNode := XMLdocOut.DocumentElement;

        Message(XMLRecID);

        case RecUsage of
            0:
                begin

                    XMLRecID := Get_TextFromNode(XMLdocIn, '/scanneditem/scannedcode');

                    if (XMLRecID = '') then
                        exit;

                    //-NPR5.32
                    if BarcodeLibrary.TranslateBarcodeToItemVariant(XMLRecID, ItemNo, VariantCode, ResolvingTable, true) then begin
                        //MESSAGE(ItemNo);
                        if Item.Get(ItemNo) then begin
                            //-NPR5.40 [307571]
                            if VariantCode <> '' then
                                Item.SetFilter("Variant Filter", VariantCode);
                            //+NPR5.40 [307571]
                            Item.CalcFields(Inventory);
                            Add_Element(XMLCurrNode, 'itemnumber', ScannerServiceFunctions.RemoveInvalidXmlChars(Item."No."), '', XMLNewChild, '');
                            Add_Element(XMLCurrNode, 'description', ScannerServiceFunctions.RemoveInvalidXmlChars(Item.Description), '', XMLNewChild, '');
                            Add_Element(XMLCurrNode, 'inventory', ScannerServiceFunctions.RemoveInvalidXmlChars(Format(Item.Inventory)), '', XMLNewChild, '');
                            Add_Element(XMLCurrNode, 'error', '', '', XMLNewChild, '');
                        end else begin
                            Add_Element(XMLCurrNode, 'itemnumber', '', '', XMLNewChild, '');
                            Add_Element(XMLCurrNode, 'description', '', '', XMLNewChild, '');
                            Add_Element(XMLCurrNode, 'inventory', '', '', XMLNewChild, '');
                            Add_Element(XMLCurrNode, 'error', StrSubstNo(ItemNotFoundError, XMLRecID), '', XMLNewChild, '');
                        end;
                    end else begin
                        Add_Element(XMLCurrNode, 'itemnumber', '', '', XMLNewChild, '');
                        Add_Element(XMLCurrNode, 'description', '', '', XMLNewChild, '');
                        Add_Element(XMLCurrNode, 'inventory', '', '', XMLNewChild, '');
                        Add_Element(XMLCurrNode, 'error', StrSubstNo(ItemNotFoundError, XMLRecID), '', XMLNewChild, '');
                    end;
                    //+NPR5.32
                end;
            1:
                begin
                    StockTakeWorksheet.SetRange(Status, StockTakeWorksheet.Status::OPEN);
                    if StockTakeWorksheet.FindSet then begin
                        repeat
                            Add_Element(XMLCurrNode, 'name', ScannerServiceFunctions.RemoveInvalidXmlChars(StockTakeWorksheet.Name), '', XMLNewChild, '');
                        until StockTakeWorksheet.Next = 0;
                    end;
                end;
            2:
                begin
                    //NPR5.38-

                    XMLRecID := Get_TextFromNode(XMLdocIn, '/showscanneditemimage/scannedcode');

                    if (XMLRecID = '') then
                        exit;

                    if BarcodeLibrary.TranslateBarcodeToItemVariant(XMLRecID, ItemNo, VariantCode, ResolvingTable, true) then begin
                        //  MESSAGE(ItemNo);
                        if Item.Get(ItemNo) then begin
                            Base64String := GetItemImageCropped(Item);
                            Add_Element(XMLCurrNode, 'imagebase64', Base64String, '', XMLNewChild, '');
                            if Base64String <> '' then
                                Add_Element(XMLCurrNode, 'error', '', '', XMLNewChild, '')
                            else
                                Add_Element(XMLCurrNode, 'error', ItemImageNotFoundError, '', XMLNewChild, '');
                        end else begin
                            Add_Element(XMLCurrNode, 'imagebase64', '', '', XMLNewChild, '');
                            Add_Element(XMLCurrNode, 'error', StrSubstNo(ItemNotFoundError, XMLRecID), '', XMLNewChild, '');
                        end;
                    end else begin
                        Add_Element(XMLCurrNode, 'imagebase64', '', '', XMLNewChild, '');
                        Add_Element(XMLCurrNode, 'error', StrSubstNo(ItemNotFoundError, XMLRecID), '', XMLNewChild, '');
                    end;
                end;
        //NPR5.38+
        end;

        ConvertXmlToBigText(XMLdocOut, Request);
    end;

    local procedure "--- Helpers ---"()
    begin
    end;

    local procedure Add_Element(var XMLNode: DotNet "NPRNetXmlDocument"; NodeName: Text[250]; NodeText: Text; NameSpace: Text[1000]; var CreatedXMLNode: DotNet NPRNetXmlNode; prefix: Text[30])
    var
        NewChildNode: DotNet NPRNetXmlNode;
    begin
        if not NormalCaseMode then
            if prefix <> '' then
                NodeName := prefix + ':' + NodeName;

        NewChildNode := XMLNode.OwnerDocument.CreateNode('element', NodeName, NameSpace);

        if IsNull(NewChildNode) then
            Error(Text000, NodeName);

        if NodeText <> '' then
            NewChildNode.InnerText := NodeText;

        XMLNode.AppendChild(NewChildNode);
        CreatedXMLNode := NewChildNode;
    end;

    local procedure Add_CdataElement(var XMLNode: DotNet "NPRNetXmlDocument"; NodeText: Text[1024])
    var
        NewChildNode: DotNet NPRNetXmlNode;
    begin
        NewChildNode := XMLNode.OwnerDocument.CreateCDataSection(NodeText);
        XMLNode.AppendChild(NewChildNode);
    end;

    local procedure Add_Attribute(var XMLNode: DotNet NPRNetXmlNode; Name: Text[260]; NodeValue: Text[260])
    var
        XMLNewAttributeNode: DotNet NPRNetXmlNode;
    begin
        XMLNewAttributeNode := XMLNode.OwnerDocument.CreateAttribute(Name);

        if IsNull(XMLNewAttributeNode) then
            Error(Text001, Name);

        if NodeValue <> '' then
            XMLNewAttributeNode.InnerText := NodeValue;

        XMLNode.Attributes.SetNamedItem(XMLNewAttributeNode);
    end;

    local procedure SetNormalCase()
    begin
        NormalCaseMode := true;
    end;

    local procedure Add_Field(var XMLNode: DotNet NPRNetXmlNode; "Field": Text[1024]; Value: Text[1024])
    var
        XmlNewChild: DotNet NPRNetXmlNode;
    begin
        Add_Element(XMLNode, 'column', '', '', XmlNewChild, '');
        Add_Attribute(XmlNewChild, 'columnName', Field);
        Add_CdataElement(XmlNewChild, Value);
        XmlNewChild := XmlNewChild.ParentNode;
    end;

    local procedure ConvertXmlToBigText(XMLdoc: DotNet "NPRNetXmlDocument"; var bigtext: BigText)
    begin
        Clear(bigtext);
        bigtext.AddText(XMLdoc.InnerXml);
    end;

    local procedure ConvertBigTextToXml(var XMLdoc: DotNet "NPRNetXmlDocument"; var bigtext: BigText)
    begin
        if IsNull(XMLdoc) then
            XMLdoc := XMLdoc.XmlDocument;

        XMLdoc.LoadXml(Format(bigtext));
    end;

    local procedure Get_TextFromNode(XMLnode: DotNet NPRNetXmlNode; xpath: Text[1024]): Text[1024]
    var
        SelectedXMLnode: DotNet NPRNetXmlNode;
    begin
        SelectedXMLnode := XMLnode.SelectSingleNode(xpath);
        if not IsNull(SelectedXMLnode) then
            exit(SelectedXMLnode.InnerText)
        else
            exit('');
    end;

    local procedure Get_DecimalFromNode(XMLnode: DotNet NPRNetXmlNode; xpath: Text[1024]): Decimal
    var
        tempdecimal: Decimal;
    begin
        if not Evaluate(tempdecimal, Get_TextFromNode(XMLnode, xpath)) then
            exit(0);
        exit(tempdecimal);
    end;

    local procedure Get_BoolFromNode(XMLnode: DotNet NPRNetXmlNode; xpath: Text[1024]): Boolean
    var
        tempbool: Boolean;
    begin
        if not Evaluate(tempbool, Get_TextFromNode(XMLnode, xpath)) then
            exit(false);
        exit(tempbool);
    end;

    procedure IsInternalCall(LocalIsInternal: Boolean; LocalId: Guid)
    begin
        IsInternal := LocalIsInternal;
        InternalCallId := LocalId;
    end;

    [TryFunction]
    local procedure DateTimeTryBlock(DateTimeTxt: Text; var DateTimeOut: Date)
    var
        CultureInfoDotNet: DotNet NPRNetCultureInfo;
        DateTimeDotNet: DotNet NPRNetDateTime;
    begin
        if DateTimeTxt = '' then begin
            DateTimeOut := DT2Date(CurrentDateTime);
            exit;
        end;

        if Evaluate(DateTimeOut, DateTimeTxt) then
            exit;

        DateTimeDotNet := DateTimeDotNet.ParseExact(DateTimeTxt, 'dd-MM-yy hh:mm:ss', CultureInfoDotNet.InvariantCulture);
        DateTimeOut := DT2Date(DateTimeDotNet);
    end;

    local procedure GetItemImage(var Item: Record Item) Base64String: Text
    var
        BinaryReader: DotNet NPRNetBinaryReader;
        MemoryStream: DotNet NPRNetMemoryStream;
        Convert: DotNet NPRNetConvert;
        InStr: InStream;
    begin
        //-NPR5.38
        Error('Function Discontinued in NAV 2017');
        /*
        //+NPR5.38
        
        Item.CALCFIELDS(Picture);
        
        IF NOT Item.Picture.HASVALUE THEN
          EXIT(Base64String);
        
        Item.Picture.CREATEINSTREAM(InStr);
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(InStr);
        
        Base64String := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));
        
        MemoryStream.Dispose;
        CLEAR(MemoryStream);
        
        EXIT(Base64String);
        */ //NPR5.38

    end;

    local procedure GetItemImageCropped(var Item: Record Item) Base64String: Text
    var
        BinaryReader: DotNet NPRNetBinaryReader;
        MemoryStream: DotNet NPRNetMemoryStream;
        Convert: DotNet NPRNetConvert;
        InStr: InStream;
        imgToResize: DotNet NPRNetImage;
        destinationSize: DotNet NPRNetSize;
        bitmap: DotNet NPRNetBitmap;
        Image: DotNet NPRNetImage;
        originalWidth: Integer;
        originalHeight: Integer;
        hRatio: Decimal;
        wRatio: Decimal;
        Math: DotNet NPRNetMath;
        ratio: Decimal;
        hScale: Integer;
        wScale: Integer;
        startX: Integer;
        startY: Integer;
        sourceRectangle: DotNet NPRNetRectangle;
        destinationRectangle: DotNet NPRNetRectangle;
        g: DotNet NPRNetGraphics;
        InterpolationModeENUM: DotNet NPRNetInterpolationMode;
        GraphicsUnitENUM: DotNet NPRNetGraphicsUnit;
        Graphics: DotNet NPRNetGraphics;
        ms: DotNet NPRNetMemoryStream;
        ImageFormatENUM: DotNet NPRNetImageFormat;
        Bytes: DotNet NPRNetArray;
        OutStr: OutStream;
    begin
        //-NPR5.38
        Error('Function Discontinued in NAV 2017');
        /*
        
        Item.CALCFIELDS(Picture);
        
        IF NOT Item.Picture.HASVALUE THEN
          EXIT(Base64String);
        
        Item.Picture.CREATEINSTREAM(InStr);
        MemoryStream := InStr;
        
        imgToResize := Image.FromStream(MemoryStream);
        
        originalWidth := imgToResize.Width;
        originalHeight := imgToResize.Height;
        
        destinationSize := destinationSize.Size(240,300);
        hRatio := originalHeight / destinationSize.Height;
        wRatio := originalWidth / destinationSize.Width;
        
        ratio := Math.Min(hRatio, wRatio);
        
        hScale := Convert.ToInt32(destinationSize.Height * ratio);
        wScale := Convert.ToInt32(destinationSize.Width * ratio);
        
        startX := Convert.ToInt32((originalWidth - wScale) / 2);
        startY := Convert.ToInt32((originalHeight - hScale) / 2);
        
        sourceRectangle := sourceRectangle.Rectangle(startX, startY, wScale, hScale);
        
        bitmap := bitmap.Bitmap(destinationSize.Width, destinationSize.Height);
        
        destinationRectangle := destinationRectangle.Rectangle(0, 0, bitmap.Width, bitmap.Height);
        
        g := Graphics.FromImage(bitmap);
        g.InterpolationMode := InterpolationModeENUM.HighQualityBicubic;
        g.DrawImage(imgToResize, destinationRectangle, sourceRectangle, GraphicsUnitENUM.Pixel);
        
        ms := ms.MemoryStream();
        bitmap.Save(ms, ImageFormatENUM.Jpeg);
        
        Base64String := Convert.ToBase64String(ms.GetBuffer());
        
        MemoryStream.Dispose;
        CLEAR(MemoryStream);
        
        ms.Dispose;
        CLEAR(ms);
        
        //Debug>>
        // Bytes := Convert.FromBase64String(Base64String);
        // Item.Picture.CREATEOUTSTREAM(OutStr);
        // MemoryStream := MemoryStream.MemoryStream(Bytes);
        // MemoryStream.WriteTo(OutStr);
        // Item.MODIFY(TRUE);
        //
        // MemoryStream.Dispose;
        // CLEAR(MemoryStream);
        //Debug<<
        
        EXIT(Base64String);
        */ //NPR5.38

    end;
}

