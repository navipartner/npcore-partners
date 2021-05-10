codeunit 6014646 "NPR BTF XML Response" implements "NPR BTF IFormatResponse"
{
    var
        NoBodyReturnedLbl: Label 'No body returned';

    procedure FormatInternalError(ErrorCode: Text; ErrorDescription: Text; var Result: Codeunit "Temp Blob")
    var
        Document: XmlDocument;
        Node: XmlNode;
        ChildNode: XmlNode;
        Xml: Text;
        OutStr: OutStream;
    begin
        Document := XmlDocument.Create();
        Document.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'yes'));
        Node := XmlElement.Create('root').AsXmlNode();
        Document.Add(Node);

        ChildNode := XmlElement.Create('error', '', ErrorCode).AsXmlNode();
        Node.AsXmlElement().Add(ChildNode);

        ChildNode := XmlElement.Create('error_description', '', ErrorDescription).AsXmlNode();
        Node.AsXmlElement().Add(ChildNode);

        Document.WriteTo(Xml);

        Result.CreateOutStream(OutStr);
        OutStr.WriteText(Xml);
    end;

    procedure FoundErrorInResponse(Response: Codeunit "Temp Blob"; StatusCode: Integer): Boolean;
    var
        Document: XmlDocument;
        Node: XmlNode;
        InStr: InStream;
    begin
        if StatusCode = 200 then
            exit;
        Response.CreateInStream(InStr);
        if not XmlDocument.ReadFrom(InStr, Document) then
            exit(true);
        if (Document.SelectSingleNode('.//error', Node)) or (Document.SelectSingleNode('.//Error', Node)) then
            exit(true);
        if Document.SelectSingleNode('.//exceptionMessage', Node) then
            exit(true);
    end;

    procedure GetErrorDescription(Response: Codeunit "Temp Blob"): Text
    var
        Document: XmlDocument;
        Node: XmlNode;
        InStr: InStream;
    begin
        Response.CreateInStream(InStr);
        if not XmlDocument.ReadFrom(InStr, Document) then
            exit(NoBodyReturnedLbl);
        if Document.SelectSingleNode('.//exceptionMessage', Node) then
            exit(Node.AsXmlElement().InnerText());
        if Document.SelectSingleNode('.//error_description', Node) then
            exit(Node.AsXmlElement().InnerText());
        if Node.AsXmlElement().SelectSingleNode('.//message', Node) then
            exit(Node.AsXmlElement().InnerText());
        if Node.AsXmlElement().SelectSingleNode('.//Message', Node) then
            exit(Node.AsXmlElement().InnerText());
    end;


    [NonDebuggable]
    procedure GetToken(Response: Codeunit "Temp Blob"): Text
    var
        Document: XmlDocument;
        Element: XmlElement;
        Node: XmlNode;
        InStr: InStream;
    begin
        Response.CreateInStream(InStr);
        if not XmlDocument.ReadFrom(InStr, Document) then
            exit;
        if not Document.GetRoot(Element) then
            exit;
        if not Element.SelectSingleNode('.//access_token', Node) then
            exit;
        exit(Node.AsXmlElement().InnerText());
    end;

    procedure FoundToken(Response: Codeunit "Temp Blob"): Boolean
    var
        Document: XmlDocument;
        Element: XmlElement;
        Node: XmlNode;
        InStr: InStream;
    begin
        Response.CreateInStream(InStr);
        if not XmlDocument.ReadFrom(InStr, Document) then
            exit;
        if not Document.GetRoot(Element) then
            exit;
        exit(Element.SelectSingleNode('.//access_token', Node));
    end;

    procedure GetFileExtension(): Text
    begin
        exit('xml');
    end;

    procedure GetOrder(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean
    var
        Customer: Record Customer;
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        AttributeID: Record "NPR Attribute ID";
        AttributeMgt: Codeunit "NPR Attribute Management";
        XmlDomMgt: Codeunit "XML DOM Management";
        Document: XmlDocument;
        Node, Node2 : XmlNode;
        NodeList: XmlNodeList;
        Element: XmlElement;
        InStr: InStream;
        DocumentSource, XPath, DocumentType, OrderType, CurrencyCode, LineParameter, Size, Color, MessageId : Text;
    begin
        if (not SalesHeader.IsTemporary()) or (not SalesLine.IsTemporary()) then
            exit;
        SalesHeader.DeleteAll();
        SalesLine.DeleteAll();

        Content.CreateInStream(InStr);
        if not XmlDocument.ReadFrom(InStr, Document) then
            exit;

        Document.WriteTo(DocumentSource);
        DocumentSource := XmlDomMgt.RemoveNamespaces(DocumentSource);
        XmlDocument.ReadFrom(DocumentSource, Document);

        XPath := '//order/@orderType';
        if not Document.SelectSingleNode(XPath, Node) then
            exit;
        OrderType := Node.AsXmlAttribute().Value();
        if OrderType <> 'PRE_ORDER' then
            exit;

        XPath := '//order/@currency';
        if Document.SelectSingleNode(XPath, Node) then
            CurrencyCode := Node.AsXmlAttribute().Value();

        XPath := '//order/@messageId';
        if Document.SelectSingleNode(XPath, Node) then
            MessageId := Node.AsXmlAttribute().Value();

        if MessageId = '' then
            MessageId := 'B24_MsgId';

        DocumentType := 'BuyerOrder';
        XPath := '//order/documentReference[@documentType=''' + DocumentType + ''']/@id';
        Document.SelectSingleNode(XPath, Node);

        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := Node.AsXmlAttribute().Value();
        SalesHeader.Init();
        SalesHeader.Insert(true);
        SalesHeader."External Document No." := Node.AsXmlAttribute().Value();
        SalesHeader."Currency Code" := CurrencyCode;
        SalesHeader."Your Reference" := MessageId;

        XPath := '//order/documentReference[@documentType=''' + DocumentType + ''']/@date';
        if Document.SelectSingleNode(XPath, Node) then
            if evaluate(SalesHeader."Posting Date", Node.AsXmlAttribute().Value(), 9) then;

        XPath := '//order/buyer/@gln';
        Document.SelectSingleNode(XPath, Node);
        Customer.SetRange(GLN, Node.AsXmlAttribute().Value());
        if Customer.FindFirst() then;
        SalesHeader."Sell-to Customer No." := Customer."No.";
        SalesHeader.Modify();

        XPath := '//order/item';
        if not Document.SelectNodes(XPath, NodeList) then
            exit;

        GLSetup.Get();
        if (SalesHeader."Currency Code" <> '') and (SalesHeader."Currency Code" <> GLSetup."LCY Code") then begin
            Currency.Get(SalesHeader."Currency Code");
            Currency.TestField("Unit-Amount Rounding Precision");
        end;

        foreach Node in NodeList do begin
            CurrencyCode := '';
            Size := '';
            Color := '';
            Element := Node.AsXmlElement();

            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." += 10000;
            SalesLine.Init();
            SalesLine.Type := SalesLine.Type::Item;

            Element.SelectSingleNode('.//@id', Node2);
            SalesLine."No." := Node2.AsXmlAttribute().Value();

            Element.SelectSingleNode('.//@quantity', Node2);
            evaluate(SalesLine.Quantity, Node2.AsXmlAttribute().Value(), 9);

            if Element.SelectSingleNode('.//@deliveryDate', Node2) then
                evaluate(SalesLine."Shipment Date", Node2.AsXmlAttribute().Value(), 9);

            LineParameter := 'unitOfMeasure';
            XPath := './/property[@name=''' + LineParameter + ''']';
            Element.SelectSingleNode(XPath, Node2);
            SalesLine."Unit of Measure Code" := Node2.AsXmlElement().InnerText();

            LineParameter := 'EAN13';
            XPath := './/itemReference[@coding=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then begin
                SalesLine."Item Reference Type" := SalesLine."Item Reference Type"::"Bar Code";
                SalesLine."Item Reference No." := Node2.AsXmlElement().InnerText();
            end;

            LineParameter := 'grossPrice';
            XPath := './/price[@type=''' + LineParameter + ''']/@value';
            if Element.SelectSingleNode(XPath, Node2) then begin
                evaluate(SalesLine."Unit Price", Node2.AsXmlAttribute().Value(), 9);

                XPath := './/price[@type=''' + LineParameter + ''']/@currency';
                if Element.SelectSingleNode(XPath, Node2) then
                    CurrencyCode := Node2.AsXmlAttribute().Value();

                if (SalesLine."Unit Price" <> 0) and (CurrencyCode <> SalesHeader."Currency Code") then begin
                    SalesLine."Unit Price" := Round(
                                                CurrExchRate.ExchangeAmtLCYToFCY(
                                                    SalesHeader."Posting Date",
                                                    SalesHeader."Currency Code", SalesLine."Unit Price",
                                                    CurrExchRate.ExchangeRate(
                                                    SalesHeader."Posting Date", SalesHeader."Currency Code")),
                                                Currency."Unit-Amount Rounding Precision");
                end;
            end;

            LineParameter := 'discountPercentage';
            XPath := './/price[@type=''' + LineParameter + ''']/@value';
            if Element.SelectSingleNode(XPath, Node2) then
                evaluate(SalesLine."Line Discount %", Node2.AsXmlAttribute().Value(), 9);

            LineParameter := 'size';
            XPath := './/dimension[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then begin
                clear(AttributeID);
                Size := Node2.AsXmlElement().InnerText();
                if Size <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"Sales Line", 1, AttributeID) then
                        AttributeMgt.SetDocumentLineAttributeValue(DATABASE::"Sales Line", 1, SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", Size);
            end;

            LineParameter := 'color';
            XPath := './/dimension[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then begin
                clear(AttributeID);
                Color := Node2.AsXmlElement().InnerText();
                if Color <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"Sales Line", 2, AttributeID) then
                        AttributeMgt.SetDocumentLineAttributeValue(DATABASE::"Sales Line", 2, SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", Color);
            end;

            SalesLine.Insert();
        end;
    end;

    procedure GetInvoice(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean
    var
        Customer: Record Customer;
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        AttributeID: Record "NPR Attribute ID";
        AttributeMgt: Codeunit "NPR Attribute Management";
        XmlDomMgt: Codeunit "XML DOM Management";
        Document: XmlDocument;
        Node, Node2 : XmlNode;
        NodeList: XmlNodeList;
        Element: XmlElement;
        InStr: InStream;
        DocumentSource, XPath, LineParameter, CurrencyCode, MessageId, Size, Color, Weight : Text;
    begin
        if (not SalesHeader.IsTemporary()) or (not SalesLine.IsTemporary()) then
            exit;
        SalesHeader.DeleteAll();
        SalesLine.DeleteAll();

        Content.CreateInStream(InStr);
        if not XmlDocument.ReadFrom(InStr, Document) then
            exit;

        Document.WriteTo(DocumentSource);
        DocumentSource := XmlDomMgt.RemoveNamespaces(DocumentSource);
        XmlDocument.ReadFrom(DocumentSource, Document);

        XPath := '//invoice/@currency';
        if Document.SelectSingleNode(XPath, Node) then
            CurrencyCode := Node.AsXmlAttribute().Value();

        XPath := '//invoice/@messageId';
        if Document.SelectSingleNode(XPath, Node) then
            MessageId := Node.AsXmlAttribute().Value();

        if MessageId = '' then
            MessageId := 'B24_MsgId';

        XPath := '//invoice/@invoiceNumber';
        Document.SelectSingleNode(XPath, Node);

        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader."No." := Node.AsXmlAttribute().Value();
        SalesHeader.Init();
        SalesHeader.Insert(true);
        SalesHeader."External Document No." := Node.AsXmlAttribute().Value();
        SalesHeader."Currency Code" := CurrencyCode;
        SalesHeader."Your Reference" := MessageId;

        XPath := '//invoice/@invoiceDate';
        if Document.SelectSingleNode(XPath, Node) then
            evaluate(SalesHeader."Posting Date", Node.AsXmlAttribute().Value());

        XPath := '//invoice/buyer/@gln';
        Document.SelectSingleNode(XPath, Node);
        Customer.SetRange(GLN, Node.AsXmlAttribute().Value());
        if Customer.FindFirst() then;
        SalesHeader."Sell-to Customer No." := Customer."No.";
        SalesHeader.Modify();

        XPath := '//invoice/item';
        if not Document.SelectNodes(XPath, NodeList) then
            exit;

        GLSetup.Get();
        if (SalesHeader."Currency Code" <> '') and (SalesHeader."Currency Code" <> GLSetup."LCY Code") then begin
            Currency.Get(SalesHeader."Currency Code");
            Currency.TestField("Unit-Amount Rounding Precision");
        end;
        foreach Node in NodeList do begin
            CurrencyCode := '';
            Size := '';
            Color := '';
            Weight := '';

            Element := Node.AsXmlElement();

            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." += 10000;
            SalesLine.Init();
            SalesLine.Type := SalesLine.Type::Item;

            Element.SelectSingleNode('.//@id', Node2);
            SalesLine."No." := Node2.AsXmlAttribute().Value();

            Element.SelectSingleNode('.//@quantity', Node2);
            evaluate(SalesLine.Quantity, Node2.AsXmlAttribute().Value(), 9);

            if Element.SelectSingleNode('.//@unitOfMeasure', Node2) then
                SalesLine."Unit of Measure Code" := Node2.AsXmlAttribute().Value();

            LineParameter := 'EAN13';
            XPath := './/itemReference[@coding=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then begin
                SalesLine."Item Reference Type" := SalesLine."Item Reference Type"::"Bar Code";
                SalesLine."Item Reference No." := Node2.AsXmlElement().InnerText();
            end;

            LineParameter := 'grossWeight';
            XPath := './/property[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then
                evaluate(SalesLine."Gross Weight", Node2.AsXmlElement().InnerText());

            XPath := './/price/@unitGrossAmount';
            if Element.SelectSingleNode(XPath, Node2) then begin
                evaluate(SalesLine."Unit Price", Node2.AsXmlAttribute().Value(), 9);

                XPath := './/price/@currency';
                if Element.SelectSingleNode(XPath, Node2) then
                    CurrencyCode := Node2.AsXmlAttribute().Value();

                if (SalesLine."Unit Price" <> 0) and (CurrencyCode <> SalesHeader."Currency Code") then begin
                    SalesLine."Unit Price" := Round(
                                                CurrExchRate.ExchangeAmtLCYToFCY(
                                                    SalesHeader."Posting Date",
                                                    SalesHeader."Currency Code", SalesLine."Unit Price",
                                                    CurrExchRate.ExchangeRate(
                                                    SalesHeader."Posting Date", SalesHeader."Currency Code")),
                                                Currency."Unit-Amount Rounding Precision");
                end;
            end;

            XPath := './/price/@allowancePercent';
            if Element.SelectSingleNode(XPath, Node2) then
                evaluate(SalesLine."Line Discount %", Node2.AsXmlAttribute().Value(), 9);

            LineParameter := 'size';
            XPath := './/dimension[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then begin
                clear(AttributeID);
                Size := Node2.AsXmlElement().InnerText();
                if Size <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"Sales Line", 1, AttributeID) then
                        AttributeMgt.SetDocumentLineAttributeValue(DATABASE::"Sales Line", 1, SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", Size);
            end;

            LineParameter := 'color';
            XPath := './/dimension[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then begin
                clear(AttributeID);
                Color := Node2.AsXmlElement().InnerText();
                if Color <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"Sales Line", 2, AttributeID) then
                        AttributeMgt.SetDocumentLineAttributeValue(DATABASE::"Sales Line", 2, SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", Color);
            end;

            LineParameter := 'weight';
            XPath := './/dimension[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then begin
                clear(AttributeID);
                Weight := Node2.AsXmlElement().InnerText();
                if Weight <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"Sales Line", 3, AttributeID) then
                        AttributeMgt.SetDocumentLineAttributeValue(DATABASE::"Sales Line", 3, SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", Weight);
            end;

            SalesLine.Insert();
        end;
    end;

    procedure GetOrderResp(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean
    var
        Customer: Record Customer;
        CurrExchRate: Record "Currency Exchange Rate";
        AttributeID: Record "NPR Attribute ID";
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        AttributeMgt: Codeunit "NPR Attribute Management";
        XmlDomMgt: Codeunit "XML DOM Management";
        Document: XmlDocument;
        Node, Node2 : XmlNode;
        NodeList: XmlNodeList;
        Element: XmlElement;
        InStr: InStream;
        DocumentSource, XPath, DocumentType, CurrencyCode, LineParameter, Size, Color, MessageId : Text;
    begin
        if (not SalesHeader.IsTemporary()) or (not SalesLine.IsTemporary()) then
            exit;
        SalesHeader.DeleteAll();
        SalesLine.DeleteAll();

        Content.CreateInStream(InStr);
        if not XmlDocument.ReadFrom(InStr, Document) then
            exit;

        Document.WriteTo(DocumentSource);
        DocumentSource := XmlDomMgt.RemoveNamespaces(DocumentSource);
        XmlDocument.ReadFrom(DocumentSource, Document);

        XPath := '//orderResponse/@currency';
        if Document.SelectSingleNode(XPath, Node) then
            CurrencyCode := Node.AsXmlAttribute().Value();

        XPath := '//orderResponse/@messageId';
        if Document.SelectSingleNode(XPath, Node) then
            MessageId := Node.AsXmlAttribute().Value();

        if MessageId = '' then
            MessageId := 'B24_MsgId';

        DocumentType := 'BuyerOrder';
        XPath := '//orderResponse/documentReference[@documentType=''' + DocumentType + ''']/@id';
        Document.SelectSingleNode(XPath, Node);

        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := Node.AsXmlAttribute().Value();
        SalesHeader.Init();
        SalesHeader.Insert(true);
        SalesHeader."External Document No." := Node.AsXmlAttribute().Value();
        SalesHeader."Currency Code" := CurrencyCode;
        SalesHeader."Your Reference" := MessageId;

        XPath := '//orderResponse/documentReference[@documentType=''' + DocumentType + ''']/@date';
        if Document.SelectSingleNode(XPath, Node) then
            if evaluate(SalesHeader."Posting Date", Node.AsXmlAttribute().Value(), 9) then;

        XPath := '//orderResponse/buyer/@gln';
        Document.SelectSingleNode(XPath, Node);
        Customer.SetRange(GLN, Node.AsXmlAttribute().Value());
        if Customer.FindFirst() then;
        SalesHeader."Sell-to Customer No." := Customer."No.";
        SalesHeader.Modify();

        XPath := '//orderResponse/item';
        if not Document.SelectNodes(XPath, NodeList) then
            exit;

        GLSetup.Get();
        if (SalesHeader."Currency Code" <> '') and (SalesHeader."Currency Code" <> GLSetup."LCY Code") then begin
            Currency.Get(SalesHeader."Currency Code");
            Currency.TestField("Unit-Amount Rounding Precision");
        end;

        foreach Node in NodeList do begin
            CurrencyCode := '';
            Color := '';
            Size := '';

            Element := Node.AsXmlElement();

            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." += 10000;
            SalesLine.Init();
            SalesLine.Type := SalesLine.Type::Item;

            Element.SelectSingleNode('.//@id', Node2);
            SalesLine."No." := Node2.AsXmlAttribute().Value();

            Element.SelectSingleNode('.//@quantity', Node2);
            evaluate(SalesLine.Quantity, Node2.AsXmlAttribute().Value(), 9);

            if Element.SelectSingleNode('.//@shippingDate', Node2) then
                evaluate(SalesLine."Shipment Date", Node2.AsXmlAttribute().Value(), 9);

            LineParameter := 'unitOfMeasure';
            XPath := './/property[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then
                SalesLine."Unit of Measure Code" := Node2.AsXmlElement().InnerText();

            LineParameter := 'EAN13';
            XPath := './/itemReference[@coding=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then begin
                SalesLine."Item Reference Type" := SalesLine."Item Reference Type"::"Bar Code";
                SalesLine."Item Reference No." := Node2.AsXmlElement().InnerText();
            end;

            LineParameter := 'grossPrice';
            XPath := './/price[@type=''' + LineParameter + ''']/@value';
            if Element.SelectSingleNode(XPath, Node2) then begin
                evaluate(SalesLine."Unit Price", Node2.AsXmlAttribute().Value(), 9);

                XPath := './/price[@type=''' + LineParameter + ''']/@currency';
                if Element.SelectSingleNode(XPath, Node2) then
                    CurrencyCode := Node2.AsXmlAttribute().Value();

                if (SalesLine."Unit Price" <> 0) and (CurrencyCode <> SalesHeader."Currency Code") then begin
                    SalesLine."Unit Price" := Round(
                                                CurrExchRate.ExchangeAmtLCYToFCY(
                                                    SalesHeader."Posting Date",
                                                    SalesHeader."Currency Code", SalesLine."Unit Price",
                                                    CurrExchRate.ExchangeRate(
                                                    SalesHeader."Posting Date", SalesHeader."Currency Code")),
                                                Currency."Unit-Amount Rounding Precision");
                end;
            end;

            LineParameter := 'discountPercentage';
            XPath := './/price[@type=''' + LineParameter + ''']/@value';
            if Element.SelectSingleNode(XPath, Node2) then
                evaluate(SalesLine."Line Discount %", Node2.AsXmlAttribute().Value(), 9);

            LineParameter := 'size';
            XPath := './/dimension[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then begin
                clear(AttributeID);
                Size := Node2.AsXmlElement().InnerText();
                if Size <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"Sales Line", 1, AttributeID) then
                        AttributeMgt.SetDocumentLineAttributeValue(DATABASE::"Sales Line", 1, SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", Size);
            end;

            LineParameter := 'color';
            XPath := './/dimension[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then begin
                clear(AttributeID);
                Color := Node2.AsXmlElement().InnerText();
                if Color <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"Sales Line", 2, AttributeID) then
                        AttributeMgt.SetDocumentLineAttributeValue(DATABASE::"Sales Line", 2, SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", Color);
            end;

            SalesLine.Insert();
        end;
    end;

    procedure GetPriceCat(Content: Codeunit "Temp Blob"; var ItemWrks: Record "NPR Item Worksheet"; var ItemWrksLine: Record "NPR Item Worksheet Line"): Boolean
    var
        Vendor: Record Vendor;
        AttributeID: Record "NPR Attribute ID";
        AttributeMgt: Codeunit "NPR Attribute Management";
        XmlDomMgt: Codeunit "XML DOM Management";
        ServiceAPI: Codeunit "NPR BTF Service API";
        Document: XmlDocument;
        Node, Node2 : XmlNode;
        NodeList: XmlNodeList;
        Element: XmlElement;
        NamespaceManager: XmlNamespaceManager;
        InStr: InStream;
        DocumentSource, XPath, MessageId, ItemWrksTemplate, ItemWrksName, CurrencyCode, VendorGLN, B24Action, LineParameter, ItemCategoryDesc : Text;
        AttrText: array[10] of Text;
        ValidFrom, ValidTo : DateTime;
    begin
        if (not ItemWrks.IsTemporary()) or (not ItemWrksLine.IsTemporary()) then
            exit;
        ItemWrks.DeleteAll();
        ItemWrksLine.DeleteAll();

        Content.CreateInStream(InStr);
        if not XmlDocument.ReadFrom(InStr, Document) then
            exit;

        Document.WriteTo(DocumentSource);
        DocumentSource := XmlDomMgt.RemoveNamespaces(DocumentSource);
        XmlDocument.ReadFrom(DocumentSource, Document);

        XPath := '//pricat/@text';
        Document.SelectSingleNode(XPath, Node);

        ItemWrksTemplate := ServiceAPI.GetIntegrationPrefix();
        ItemWrksName := Node.AsXmlAttribute().Value();
        ItemWrksName := CopyStr(ItemWrksName, 1, MaxStrLen(ItemWrks.Description));

        XPath := '//pricat/@messageId';
        if Document.SelectSingleNode(XPath, Node) then
            MessageId := Node.AsXmlAttribute().Value();

        if MessageId = '' then
            MessageId := 'B24_MsgId';

        XPath := '//pricat/@currency';
        if Document.SelectSingleNode(XPath, Node) then
            CurrencyCode := Node.AsXmlAttribute().Value();

        XPath := '//pricat/supplier/@gln';
        Document.SelectSingleNode(XPath, Node);
        Vendor.Setrange(GLN, Node.AsXmlAttribute().Value());
        if Vendor.FindFirst() then;

        ItemWrks."Item Template Name" := ItemWrksTemplate;
        ItemWrks.Name := MessageId;
        ItemWrks.Init();
        ItemWrks.Insert();
        ItemWrks.Description := ItemWrksName;
        ItemWrks."Vendor No." := Vendor."No.";
        ItemWrks."Currency Code" := CurrencyCode;
        ItemWrks.Modify();

        if Document.SelectSingleNode('//pricat/@validFrom', Node) then
            evaluate(ValidFrom, Node.AsXmlAttribute().Value(), 9);

        if Document.SelectSingleNode('//pricat/@validTo', Node) then
            evaluate(ValidTo, Node.AsXmlAttribute().Value(), 9);

        XPath := '//pricat/item';
        if not Document.SelectNodes(XPath, NodeList) then
            exit;

        foreach Node in NodeList do begin
            ItemCategoryDesc := '';
            clear(AttrText);

            Element := Node.AsXmlElement();

            ItemWrksLine."Worksheet Template Name" := ItemWrks."Item Template Name";
            ItemWrksLine."Worksheet Name" := ItemWrks.Name;
            ItemWrksLine."Line No." += 10000;
            ItemWrksLine.Init();

            Element.SelectSingleNode('.//@id', Node2);
            ItemWrksLine."Item No." := Node2.AsXmlAttribute().Value();

            Element.SelectSingleNode('.//@action', Node2);
            B24Action := Node2.AsXmlAttribute().Value();

            case Uppercase(B24Action) of
                'ADD':
                    ItemWrksLine.Action := ItemWrksLine.Action::CreateNew;
                'CHANGE':
                    ItemWrksLine.Action := ItemWrksLine.Action::UpdateOnly;
                'DELETE':
                    ItemWrksLine.Action := ItemWrksLine.Action::Skip;
            end;
            ItemWrksLine."Vendor No." := ItemWrks."Vendor No.";
            ItemWrksLine."Currency Code" := ItemWrks."Currency Code";

            LineParameter := 'name';
            XPath := './/property[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then
                ItemWrksLine.Description := Copystr(Node2.AsXmlElement().InnerText(), 1, MaxStrLen(ItemWrksLine.Description));

            LineParameter := 'category';
            XPath := './/property[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then
                ItemCategoryDesc := Copystr(Node2.AsXmlElement().InnerText(), 1, MaxStrLen(ItemWrksLine.Description));

            XPath := './/property[@name=''' + LineParameter + ''']/@code';
            if Element.SelectSingleNode(XPath, Node2) then
                ItemWrksLine."Item Category Code" := Node2.AsXmlAttribute().Value();

            LineParameter := 'unitOfMeasure';
            XPath := './/property[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then
                ItemWrksLine."Base Unit of Measure" := Node2.AsXmlElement().InnerText();

            LineParameter := 'countryOfOrigin';
            XPath := './/property[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then
                ItemWrksLine."Country/Region of Origin Code" := Node2.AsXmlElement().InnerText();

            LineParameter := 'size';
            XPath := './/dimension[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then begin
                clear(AttributeID);
                AttrText[1] := Node2.AsXmlElement().InnerText();
                if AttrText[1] <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"NPR Item Worksheet Line", 1, AttributeID) then
                        AttributeMgt.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 1, ItemWrksLine."Worksheet Template Name", ItemWrksLine."Worksheet Name", ItemWrksLine."Line No.", AttrText[1]);
            end;

            LineParameter := 'size';
            XPath := './/dimension[@name=''' + LineParameter + ''']/@set';
            if Element.SelectSingleNode(XPath, Node2) then begin
                Clear(AttributeID);
                AttrText[2] := Node2.AsXmlAttribute().Value();
                if AttrText[2] <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"NPR Item Worksheet Line", 2, AttributeID) then
                        AttributeMgt.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 2, ItemWrksLine."Worksheet Template Name", ItemWrksLine."Worksheet Name", ItemWrksLine."Line No.", AttrText[2]);
            end;

            LineParameter := 'color';
            XPath := './/dimension[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then begin
                clear(AttributeID);
                AttrText[3] := Node2.AsXmlElement().InnerText();
                if AttrText[3] <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"NPR Item Worksheet Line", 3, AttributeID) then
                        AttributeMgt.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 3, ItemWrksLine."Worksheet Template Name", ItemWrksLine."Worksheet Name", ItemWrksLine."Line No.", AttrText[3]);
            end;

            LineParameter := 'color';
            XPath := './/dimension[@name=''' + LineParameter + ''']/@code';
            if Element.SelectSingleNode(XPath, Node2) then begin
                clear(AttributeID);
                AttrText[4] := Node2.AsXmlAttribute().Value();
                if AttrText[4] <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"NPR Item Worksheet Line", 4, AttributeID) then
                        AttributeMgt.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 4, ItemWrksLine."Worksheet Template Name", ItemWrksLine."Worksheet Name", ItemWrksLine."Line No.", AttrText[4]);
            end;

            LineParameter := 'weight';
            XPath := './/dimension[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then begin
                clear(AttributeID);
                AttrText[5] := Node2.AsXmlElement().InnerText();
                if AttrText[5] <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"NPR Item Worksheet Line", 5, AttributeID) then
                        AttributeMgt.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 5, ItemWrksLine."Worksheet Template Name", ItemWrksLine."Worksheet Name", ItemWrksLine."Line No.", AttrText[5]);
            end;

            LineParameter := 'volume';
            XPath := './/dimension[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then begin
                Clear(AttributeID);
                AttrText[6] := Node2.AsXmlElement().InnerText();
                if AttrText[6] <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"NPR Item Worksheet Line", 6, AttributeID) then
                        AttributeMgt.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 6, ItemWrksLine."Worksheet Template Name", ItemWrksLine."Worksheet Name", ItemWrksLine."Line No.", AttrText[6]);
            end;

            LineParameter := 'width';
            XPath := './/dimension[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then begin
                clear(AttributeID);
                AttrText[7] := Node2.AsXmlElement().InnerText();
                if AttrText[7] <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"NPR Item Worksheet Line", 7, AttributeID) then
                        AttributeMgt.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 7, ItemWrksLine."Worksheet Template Name", ItemWrksLine."Worksheet Name", ItemWrksLine."Line No.", AttrText[7]);
            end;

            LineParameter := 'modelNo';
            XPath := './/property[@name=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then begin
                clear(AttributeID);
                AttrText[8] := Node2.AsXmlElement().InnerText();
                if AttrText[8] <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"NPR Item Worksheet Line", 8, AttributeID) then
                        AttributeMgt.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 8, ItemWrksLine."Worksheet Template Name", ItemWrksLine."Worksheet Name", ItemWrksLine."Line No.", AttrText[8]);
            end;

            LineParameter := 'EAN13';
            XPath := './/itemReference[@coding=''' + LineParameter + ''']';
            Element.SelectSingleNode(XPath, Node2);
            ItemWrksLine."Vendors Bar Code" := Node2.AsXmlElement().InnerText();

            LineParameter := 'UPCA';
            XPath := './/itemReference[@coding=''' + LineParameter + ''']';
            if Element.SelectSingleNode(XPath, Node2) then
                ItemWrksLine."Internal Bar Code" := Node2.AsXmlElement().InnerText();

            LineParameter := 'grossPrice';
            XPath := './/priceBase/price[@type=''' + LineParameter + ''' and @currency=''' + ItemWrksLine."Currency Code" + ''']/@value';
            if Element.SelectSingleNode(XPath, Node2) then
                evaluate(ItemWrksLine."Sales Price", Node2.AsXmlAttribute().Value());

            ItemWrksLine."Price Includes VAT" := ItemWrksLine."Price Includes VAT"::Yes;
            ItemWrksLine.Insert(true);
        end;
    end;
}