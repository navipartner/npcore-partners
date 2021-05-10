codeunit 6014647 "NPR BTF JSON Response" implements "NPR BTF IFormatResponse"
{
    var
        NoBodyReturnedLbl: Label 'No body returned';
        ServiceAPI: Codeunit "NPR BTF Service API";

    procedure FormatInternalError(ErrorCode: Text; ErrorDescription: Text; var Result: Codeunit "Temp Blob")
    var
        JObject: JsonObject;
        Json: Text;
        OutStr: OutStream;
    begin
        JObject.Add('error', ErrorCode);
        JObject.Add('error_description', ErrorDescription);
        JObject.WriteTo(Json);
        Result.CreateOutStream(OutStr);
        OutStr.WriteText(Json);
    end;

    procedure FoundErrorInResponse(Response: Codeunit "Temp Blob"; StatusCode: Integer): Boolean;
    var
        JObject: JsonObject;
        JToken: JsonToken;
        InStr: InStream;
        Json: Text;
    begin
        if StatusCode = 200 then
            exit;
        Response.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit(true);
        if (JObject.Contains('error') or JObject.Contains('Error')) then
            exit(true);
        if JObject.Contains('exceptionMessage') then
            exit(true);
        if JObject.Get('message', JTOken) then
            exit(JToken.IsObject());
        if JObject.Get('Message', JTOken) then
            exit(JToken.IsObject());
    end;

    procedure GetErrorDescription(Response: Codeunit "Temp Blob"): Text
    var
        JObject: JsonObject;
        JToken: JsonToken;
        InStr: InStream;
        Json: Text;
    begin
        Response.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit(NoBodyReturnedLbl);
        if JObject.Get('exceptionMessage', JToken) then
            exit(JToken.AsValue().AsText());
        if JObject.Get('error_description', JToken) then
            exit(JToken.AsValue().AsText());
        if JObject.Get('message', JToken) then
            exit(JToken.AsValue().AsText());
    end;

    [NonDebuggable]
    procedure GetToken(Response: Codeunit "Temp Blob"): Text
    var
        JObject: JsonObject;
        JToken: JsonToken;
        InStr: InStream;
        Json: Text;
    begin
        Response.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit;
        if not JObject.Get('access_token', JToken) then
            exit;
        exit(JToken.AsValue().AsText());
    end;

    [NonDebuggable]
    procedure FoundToken(Response: Codeunit "Temp Blob"): Boolean
    var
        JObject: JsonObject;
        InStr: InStream;
        Json: Text;
    begin
        Response.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit;
        exit(JObject.Contains('access_token'));
    end;

    procedure GetFileExtension(): Text
    begin
        exit('json');
    end;

    procedure GetOrder(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean
    var
        Customer: Record Customer;
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        AttributeID: Record "NPR Attribute ID";
        AttributeMgt: Codeunit "NPR Attribute Management";
        JObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        InStr: InStream;
        Json, JPath, DocumentType, LineParameter, CurrencyCode, Size, Color, MessageId : Text;
    begin
        if (not SalesHeader.IsTemporary()) or (not SalesLine.IsTemporary()) then
            exit;
        SalesHeader.DeleteAll();
        SalesLine.DeleteAll();

        Content.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit;

        JPath := '$.order.orderType';
        if not JObject.SelectToken(JPath, JToken) then
            exit;
        if JToken.AsValue().AsText() <> 'PRE_ORDER' then
            exit;

        JPath := '$.order.currency';
        if JObject.SelectToken(JPath, JToken) then
            CurrencyCode := JToken.AsValue().AsText();

        JPath := '$.order.messageId';
        if JObject.SelectToken(JPath, JToken) then
            MessageId := JToken.AsValue().AsText();

        if MessageId = '' then
            MessageId := 'B24_MsgId';

        DocumentType := 'BuyerOrder';
        JPath := '$.order.documentReference[?(@.documentType==''' + DocumentType + ''')].id';
        JObject.SelectToken(JPath, JToken);

        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := JToken.AsValue().AsText();
        SalesHeader.Init();
        SalesHeader.Insert(true);
        SalesHeader."External Document No." := JToken.AsValue().AsText();
        SalesHeader."Currency Code" := CurrencyCode;
        SalesHeader."Your Reference" := MessageId;

        JPath := '$.order.documentReference.date';
        if JObject.SelectToken(JPath, JToken) then
            evaluate(SalesHeader."Posting Date", JToken.AsValue().AsText(), 9);

        JPath := '$.order.buyer.gln';
        JObject.SelectToken(JPath, JToken);
        Customer.SetRange(GLN, JToken.AsValue().AsText());
        if Customer.FindFirst() then;
        SalesHeader."Sell-to Customer No." := Customer."No.";
        SalesHeader.Modify();

        JPath := '$.order.item';
        if not JObject.SelectToken(JPath, JToken) then
            exit;
        JArray := JToken.AsArray();
        GLSetup.Get();
        if (SalesHeader."Currency Code" <> '') and (SalesHeader."Currency Code" <> GLSetup."LCY Code") then begin
            Currency.Get(SalesHeader."Currency Code");
            Currency.TestField("Unit-Amount Rounding Precision");
        end;
        foreach JToken in JArray do begin
            JObject := JToken.AsObject();

            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." += 10000;
            SalesLine.Init();
            SalesLine.Type := SalesLine.Type::Item;

            JObject.Get('id', JToken);
            SalesLine."No." := JToken.AsValue().AsText();

            JObject.Get('quantity', JToken);
            evaluate(SalesLine.Quantity, JToken.AsValue().AsText(), 9);

            if JObject.Get('deliveryDate', JToken) then
                evaluate(SalesLine."Shipment Date", JToken.AsValue().AsText(), 9);

            LineParameter := 'unitOfMeasure';
            JPath := '$.order.item[?(@.id==''' + SalesLine."No." + ''')].property[?(@.name==''' + LineParameter + ''')].data';
            JObject.SelectToken(JPath, JToken);
            SalesLine."Unit of Measure Code" := JToken.AsValue().AsText();

            LineParameter := 'EAN13';
            JPath := '$.order.item[?(@.id==''' + SalesLine."No." + ''')].itemReference[?(@.coding==''' + LineParameter + ''')].data';
            if JObject.SelectToken(JPath, JToken) then begin
                SalesLine."Item Reference Type" := SalesLine."Item Reference Type"::"Bar Code";
                SalesLine."Item Reference No." := JToken.AsValue().AsText();
            end;

            LineParameter := 'grossPrice';
            JPath := '$.order.item[?(@.id==''' + SalesLine."No." + ''')].price[?(@.type==''' + LineParameter + ''')].value';
            if JObject.SelectToken(JPath, JToken) then begin
                evaluate(SalesLine."Unit Price", JToken.AsValue().AsText(), 9);

                LineParameter := 'currency';
                JPath := '$.order.item[?(@.id==''' + SalesLine."No." + ''')].price[?(@.type==''' + LineParameter + ''')].value';
                if JObject.SelectToken(JPath, JToken) then
                    CurrencyCode := JToken.AsValue().AsText();

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
            JPath := '$.order.item[?(@.id==''' + SalesLine."No." + ''')].price[?(@.type==''' + LineParameter + ''')].value';
            if JObject.SelectToken(JPath, JToken) then
                evaluate(SalesLine."Line Discount %", JToken.AsValue().AsText(), 9);

            LineParameter := 'size';
            JPath := '$.order.item[?(@.id==''' + SalesLine."No." + ''')].dimension[?(@.type==''' + LineParameter + ''')]';
            if JObject.SelectToken(JPath, JToken) then begin
                clear(AttributeID);
                Size := JToken.AsValue().AsText();
                if Size <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"Sales Line", 1, AttributeID) then
                        AttributeMgt.SetDocumentLineAttributeValue(DATABASE::"Sales Line", 1, SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", Size);
            end;

            LineParameter := 'color';
            JPath := '$.order.item[?(@.id==''' + SalesLine."No." + ''')].dimension[?(@.type==''' + LineParameter + ''')]';
            if JObject.SelectToken(JPath, JToken) then begin
                clear(AttributeID);
                Color := JToken.AsValue().AsText();
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
        JObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        InStr: InStream;
        Json, JPath, LineParameter, CurrencyCode, MessageId, Size, Color, Weight : Text;
    begin
        if (not SalesHeader.IsTemporary()) or (not SalesLine.IsTemporary()) then
            exit;
        SalesHeader.DeleteAll();
        SalesLine.DeleteAll();

        Content.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit;

        JPath := '$.invoice.currency';
        if JObject.SelectToken(JPath, JToken) then
            CurrencyCode := JToken.AsValue().AsText();

        JPath := '$.invoice.messageId';
        if JObject.SelectToken(JPath, JToken) then
            MessageId := JToken.AsValue().AsText();

        if MessageId = '' then
            MessageId := 'B24_MsgId';

        JPath := '$.invoice.invoiceNumber';
        JObject.SelectToken(JPath, JToken);

        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader."No." := JToken.AsValue().AsText();
        SalesHeader.Init();
        SalesHeader.Insert(true);
        SalesHeader."External Document No." := JToken.AsValue().AsText();
        SalesHeader."Currency Code" := CurrencyCode;
        SalesHeader."Your Reference" := MessageId;

        JPath := '$.invoice.documentReference.date';
        if JObject.SelectToken(JPath, JToken) then
            evaluate(SalesHeader."Posting Date", JToken.AsValue().AsText(), 9);

        JPath := '$.invoice.buyer.gln';
        JObject.SelectToken(JPath, JToken);
        Customer.SetRange(GLN, JToken.AsValue().AsText());
        if Customer.FindFirst() then;
        SalesHeader."Sell-to Customer No." := Customer."No.";
        SalesHeader.Modify();

        JPath := '$.invoice.item';
        if not JObject.SelectToken(JPath, JToken) then
            exit;
        JArray := JToken.AsArray();
        GLSetup.Get();
        if (SalesHeader."Currency Code" <> '') and (SalesHeader."Currency Code" <> GLSetup."LCY Code") then begin
            Currency.Get(SalesHeader."Currency Code");
            Currency.TestField("Unit-Amount Rounding Precision");
        end;
        foreach JToken in JArray do begin
            CurrencyCode := '';
            Size := '';
            Color := '';
            Weight := '';

            JObject := JToken.AsObject();

            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." += 10000;
            SalesLine.Init();
            SalesLine.Type := SalesLine.Type::Item;

            JObject.Get('id', JToken);
            SalesLine."No." := JToken.AsValue().AsText();

            JObject.Get('quantity', JToken);
            evaluate(SalesLine.Quantity, JToken.AsValue().AsText(), 9);

            JObject.Get('unitOfMeasure', JToken);
            SalesLine."Unit of Measure Code" := JToken.AsValue().AsText();

            LineParameter := 'EAN13';
            JPath := '$.invoice.item[?(@.id==''' + SalesLine."No." + ''')].itemReference[?(@.coding==''' + LineParameter + ''')].data';
            if JObject.SelectToken(JPath, JToken) then begin
                SalesLine."Item Reference Type" := SalesLine."Item Reference Type"::"Bar Code";
                SalesLine."Item Reference No." := JToken.AsValue().AsText();
            end;

            LineParameter := 'grossWeight';
            JPath := '$.invoice.item[?(@.id==''' + SalesLine."No." + ''')].property[@name==''' + LineParameter + ''']';
            if JObject.SelectToken(JPath, JToken) then
                evaluate(SalesLine."Gross Weight", JToken.AsValue().AsText());

            LineParameter := 'unitGrossAmount';
            JPath := '$.invoice.item[?(@.id==''' + SalesLine."No." + ''')].price[?(@.type==''' + LineParameter + ''')].value';
            if JObject.SelectToken(JPath, JToken) then begin
                evaluate(SalesLine."Unit Price", JToken.AsValue().AsText(), 9);

                LineParameter := 'currency';
                JPath := '$.invoice.item[?(@.id==''' + SalesLine."No." + ''')].price[?(@.type==''' + LineParameter + ''')].value';
                if JObject.SelectToken(JPath, JToken) then
                    CurrencyCode := JToken.AsValue().AsText();

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

            LineParameter := 'allowancePercent';
            JPath := '$.invoice.item[?(@.id==''' + SalesLine."No." + ''')].price[?(@.type==''' + LineParameter + ''')].value';
            if JObject.SelectToken(JPath, JToken) then
                evaluate(SalesLine."Line Discount %", JToken.AsValue().AsText(), 9);

            LineParameter := 'size';
            JPath := '$.invoice.item[?(@.id==''' + SalesLine."No." + ''')].dimension[?(@.type==''' + LineParameter + ''')]';
            if JObject.SelectToken(JPath, JToken) then begin
                clear(AttributeID);
                Size := JToken.AsValue().AsText();
                if Size <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"Sales Line", 1, AttributeID) then
                        AttributeMgt.SetDocumentLineAttributeValue(DATABASE::"Sales Line", 1, SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", Size);
            end;

            LineParameter := 'color';
            JPath := '$.invoice.item[?(@.id==''' + SalesLine."No." + ''')].dimension[?(@.type==''' + LineParameter + ''')]';
            if JObject.SelectToken(JPath, JToken) then begin
                clear(AttributeID);
                Color := JToken.AsValue().AsText();
                if Color <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"Sales Line", 2, AttributeID) then
                        AttributeMgt.SetDocumentLineAttributeValue(DATABASE::"Sales Line", 2, SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", Color);
            end;

            LineParameter := 'weight';
            JPath := '$.invoice.item[?(@.id==''' + SalesLine."No." + ''')].dimension[?(@.type==''' + LineParameter + ''')]';
            if JObject.SelectToken(JPath, JToken) then begin
                clear(AttributeID);
                weight := JToken.AsValue().AsText();
                if weight <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"Sales Line", 3, AttributeID) then
                        AttributeMgt.SetDocumentLineAttributeValue(DATABASE::"Sales Line", 2, SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", weight);
            end;

            SalesLine.Insert();
        end;
    end;

    procedure GetOrderResp(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean
    var
        Customer: Record Customer;
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        AttributeID: Record "NPR Attribute ID";
        AttributeMgt: Codeunit "NPR Attribute Management";
        JObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        InStr: InStream;
        Json, JPath, DocumentType, LineParameter, CurrencyCode, Size, Color, MessageId : Text;
    begin
        if (not SalesHeader.IsTemporary()) or (not SalesLine.IsTemporary()) then
            exit;
        SalesHeader.DeleteAll();
        SalesLine.DeleteAll();

        Content.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit;

        JPath := '$.orderResponse.currency';
        if JObject.SelectToken(JPath, JToken) then
            CurrencyCode := JToken.AsValue().AsText();

        JPath := '$.orderResponse.messageId';
        if JObject.SelectToken(JPath, JToken) then
            MessageId := JToken.AsValue().AsText();

        if MessageId = '' then
            MessageId := 'B24_MsgId';

        DocumentType := 'BuyerOrder';
        JPath := '$.orderResponse.documentReference[?(@.documentType==''' + DocumentType + ''')].id';
        JObject.SelectToken(JPath, JToken);

        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := JToken.AsValue().AsText();
        SalesHeader.Init();
        SalesHeader.Insert(true);
        SalesHeader."External Document No." := JToken.AsValue().AsText();
        SalesHeader."Currency Code" := CurrencyCode;
        SalesHeader."Your Reference" := MessageId;

        JPath := '$.orderResponse.documentReference.date';
        if JObject.SelectToken(JPath, JToken) then
            evaluate(SalesHeader."Posting Date", JToken.AsValue().AsText(), 9);

        JPath := '$.orderResponse.buyer.gln';
        JObject.SelectToken(JPath, JToken);
        Customer.SetRange(GLN, JToken.AsValue().AsText());
        if Customer.FindFirst() then;
        SalesHeader."Sell-to Customer No." := Customer."No.";
        SalesHeader.Modify();

        JPath := '$.orderResponse.item';
        if not JObject.SelectToken(JPath, JToken) then
            exit;
        JArray := JToken.AsArray();

        GLSetup.Get();
        if (SalesHeader."Currency Code" <> '') and (SalesHeader."Currency Code" <> GLSetup."LCY Code") then begin
            Currency.Get(SalesHeader."Currency Code");
            Currency.TestField("Unit-Amount Rounding Precision");
        end;

        foreach JToken in JArray do begin
            CurrencyCode := '';
            Size := '';
            Color := '';

            JObject := JToken.AsObject();

            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." += 10000;
            SalesLine.Init();
            SalesLine.Type := SalesLine.Type::Item;

            JObject.Get('id', JToken);
            SalesLine."No." := JToken.AsValue().AsText();

            JObject.Get('quantity', JToken);
            evaluate(SalesLine.Quantity, JToken.AsValue().AsText(), 9);

            JObject.Get('shippingDate', JToken);
            evaluate(SalesLine."Shipment Date", JToken.AsValue().AsText(), 9);

            LineParameter := 'unitOfMeasure';
            JPath := '$.orderResponse.item[?(@.id==''' + SalesLine."No." + ''')].property[?(@.name==''' + LineParameter + ''')].data';
            JObject.SelectToken(JPath, JToken);
            SalesLine."Unit of Measure Code" := JToken.AsValue().AsText();

            LineParameter := 'EAN13';
            JPath := '$.orderResponse.item[?(@.id==''' + SalesLine."No." + ''')].itemReference[?(@.coding==''' + LineParameter + ''')].data';
            if JObject.SelectToken(JPath, JToken) then begin
                SalesLine."Item Reference Type" := SalesLine."Item Reference Type"::"Bar Code";
                SalesLine."Item Reference No." := JToken.AsValue().AsText();
            end;

            LineParameter := 'grossPrice';
            JPath := '$.orderResponse.item[?(@.id==''' + SalesLine."No." + ''')].price[?(@.type==''' + LineParameter + ''')].value';
            if JObject.SelectToken(JPath, JToken) then begin
                evaluate(SalesLine."Unit Price", JToken.AsValue().AsText(), 9);

                LineParameter := 'currency';
                JPath := '$.orderResponse.item[?(@.id==''' + SalesLine."No." + ''')].price[?(@.type==''' + LineParameter + ''')].value';
                if JObject.SelectToken(JPath, JToken) then
                    CurrencyCode := JToken.AsValue().AsText();

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
            JPath := '$.orderResponse.item[?(@.id==''' + SalesLine."No." + ''')].price[?(@.type==''' + LineParameter + ''')].value';
            if JObject.SelectToken(JPath, JToken) then
                evaluate(SalesLine."Line Discount %", JToken.AsValue().AsText(), 9);

            LineParameter := 'size';
            JPath := '$.orderResponse.item[?(@.id==''' + SalesLine."No." + ''')].dimension[?(@.type==''' + LineParameter + ''')]';
            if JObject.SelectToken(JPath, JToken) then begin
                clear(AttributeID);
                Size := JToken.AsValue().AsText();
                if Size <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"Sales Line", 1, AttributeID) then
                        AttributeMgt.SetDocumentLineAttributeValue(DATABASE::"Sales Line", 1, SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", Size);
            end;

            LineParameter := 'color';
            JPath := '$.orderResponse.item[?(@.id==''' + SalesLine."No." + ''')].dimension[?(@.type==''' + LineParameter + ''')]';
            if JObject.SelectToken(JPath, JToken) then begin
                clear(AttributeID);
                Color := JToken.AsValue().AsText();
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
        ServiceAPI: Codeunit "NPR BTF Service API";
        JObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        InStr: InStream;
        Json, JPath, MessageId, ItemWrksTemplate, ItemWrksName, CurrencyCode, VendorNoGLN, B24Action, LineParameter, ItemCategoryDesc : Text;
        AttrText: array[10] of Text;
        ValidFrom, ValidTo : DateTime;
    begin
        if (not ItemWrks.IsTemporary()) or (not ItemWrksLine.IsTemporary()) then
            exit;
        ItemWrks.DeleteAll();
        ItemWrksLine.DeleteAll();

        Content.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit;

        JPath := '$.pricat.text';
        if not JObject.SelectToken(JPath, JToken) then
            exit;

        ItemWrksTemplate := ServiceAPI.GetIntegrationPrefix();
        ItemWrksName := JToken.AsValue().AsText();
        ItemWrksName := CopyStr(ItemWrksName, 1, MaxStrLen(ItemWrks.Description));

        JPath := '$.pricat.messageId';
        if JObject.SelectToken(JPath, JToken) then
            MessageId := JToken.AsValue().AsText();

        if MessageId = '' then
            MessageId := 'B24_MsgId';

        JPath := '$.pricat.currency';
        if JObject.SelectToken(JPath, JToken) then
            CurrencyCode := JToken.AsValue().AsText();

        JPath := '$.pricat.gln';
        JObject.SelectToken(JPath, JToken);
        VendorNoGLN := JToken.AsValue().AsText();
        Vendor.Setrange(GLN, VendorNoGLN);
        if Vendor.FindFirst() then;

        ItemWrks."Item Template Name" := ItemWrksTemplate;
        ItemWrks.Name := MessageId;
        ItemWrks.Init();
        ItemWrks.Insert();
        ItemWrks.Description := ItemWrksName;
        ItemWrks."Vendor No." := Vendor."No.";
        ItemWrks."Currency Code" := CurrencyCode;
        ItemWrks.Modify();

        JPath := '$.pricat.validFrom';
        if JObject.SelectToken(JPath, JToken) then
            evaluate(ValidFrom, JToken.AsValue().AsText(), 9);

        JPath := '$.pricat.validTo';
        if JObject.SelectToken(JPath, JToken) then
            evaluate(ValidTo, JToken.AsValue().AsText(), 9);

        JPath := '$.pricat.item';
        if not JObject.SelectToken(JPath, JToken) then
            exit;

        JArray := JToken.AsArray();
        foreach JToken in JArray do begin
            ItemCategoryDesc := '';
            clear(AttrText);

            JObject := JToken.AsObject();

            ItemWrksLine."Worksheet Template Name" := ItemWrks."Item Template Name";
            ItemWrksLine."Worksheet Name" := ItemWrks.Name;
            ItemWrksLine."Line No." += 10000;
            ItemWrksLine.Init();

            JObject.Get('id', JToken);
            ItemWrksLine."Item No." := JToken.AsValue().AsText();

            JObject.Get('action', JToken);
            B24Action := JToken.AsValue().AsText();

            case Uppercase(B24Action) of
                'ADD':
                    ItemWrksLine.Action := ItemWrksLine.Action::CreateNew;
                'CHANGE':
                    ItemWrksLine.Action := ItemWrksLine.Action::UpdateOnly;
                'DELETE':
                    ItemWrksLine.Action := ItemWrksLine.Action::Skip;
            end;
            ItemWrksLine."Vendor No." := ItemWrks."Vendor No.";
            ItemWrksLine."Currency Code" := CurrencyCode;

            LineParameter := 'name';
            JPath := '$.pricat.item[?(@.id==''' + ItemWrksLine."Item No." + ''')].property[?(@.name==''' + LineParameter + ''')].data';
            if JObject.SelectToken(JPath, JToken) then
                ItemWrksLine.Description := Copystr(JToken.AsValue().AsText(), 1, MaxStrLen(ItemWrksLine.Description));

            LineParameter := 'category';
            JPath := '$.pricat.item[?(@.id==''' + ItemWrksLine."Item No." + ''')].property[?(@.name==''' + LineParameter + ''')].data';
            if JObject.SelectToken(JPath, JToken) then
                ItemCategoryDesc := Copystr(JToken.AsValue().AsText(), 1, MaxStrLen(ItemWrksLine.Description));

            JPath := '$.pricat.item[?(@.id==''' + ItemWrksLine."Item No." + ''')].property[?(@.name==''' + LineParameter + ''')].code';
            if JObject.SelectToken(JPath, JToken) then
                ItemWrksLine."Item Category Code" := JToken.AsValue().AsText();

            LineParameter := 'unitOfMeasure';
            JPath := '$.pricat.item[?(@.id==''' + ItemWrksLine."Item No." + ''')].property[?(@.name==''' + LineParameter + ''')].data';
            if JObject.SelectToken(JPath, JToken) then
                ItemWrksLine."Base Unit of Measure" := JToken.AsValue().AsText();

            LineParameter := 'countryOfOrigin';
            JPath := '$.pricat.item[?(@.id==''' + ItemWrksLine."Item No." + ''')].property[?(@.name==''' + LineParameter + ''')].data';
            if JObject.SelectToken(JPath, JToken) then
                ItemWrksLine."Country/Region of Origin Code" := JToken.AsValue().AsText();

            LineParameter := 'size';
            JPath := '$.pricat.item[?(@.id==''' + ItemWrksLine."Item No." + ''')].dimension[?(@.type==''' + LineParameter + ''')].data';
            if JObject.SelectToken(JPath, JToken) then begin
                Clear(AttributeID);
                AttrText[1] := JToken.AsValue().AsText();
                if AttrText[1] <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"NPR Item Worksheet Line", 1, AttributeID) then
                        AttributeMgt.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 1, ItemWrksLine."Worksheet Template Name", ItemWrksLine."Worksheet Name", ItemWrksLine."Line No.", AttrText[1]);
            end;

            LineParameter := 'size';
            JPath := '$.pricat.item[?(@.id==''' + ItemWrksLine."Item No." + ''')].dimension[?(@.type==''' + LineParameter + ''')].set';
            if JObject.SelectToken(JPath, JToken) then begin
                Clear(AttributeID);
                AttrText[2] := JToken.AsValue().AsText();
                if AttrText[2] <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"NPR Item Worksheet Line", 2, AttributeID) then
                        AttributeMgt.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 2, ItemWrksLine."Worksheet Template Name", ItemWrksLine."Worksheet Name", ItemWrksLine."Line No.", AttrText[2]);
            end;

            LineParameter := 'color';
            JPath := '$.pricat.item[?(@.id==''' + ItemWrksLine."Item No." + ''')].dimension[?(@.type==''' + LineParameter + ''')].data';
            if JObject.SelectToken(JPath, JToken) then begin
                Clear(AttributeID);
                AttrText[3] := JToken.AsValue().AsText();
                if AttrText[3] <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"NPR Item Worksheet Line", 3, AttributeID) then
                        AttributeMgt.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 3, ItemWrksLine."Worksheet Template Name", ItemWrksLine."Worksheet Name", ItemWrksLine."Line No.", AttrText[3]);
            end;

            LineParameter := 'color';
            JPath := '$.pricat.item[?(@.id==''' + ItemWrksLine."Item No." + ''')].dimension[?(@.type==''' + LineParameter + ''')].code';
            if JObject.SelectToken(JPath, JToken) then begin
                Clear(AttributeID);
                AttrText[4] := JToken.AsValue().AsText();
                if AttrText[4] <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"NPR Item Worksheet Line", 4, AttributeID) then
                        AttributeMgt.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 4, ItemWrksLine."Worksheet Template Name", ItemWrksLine."Worksheet Name", ItemWrksLine."Line No.", AttrText[4]);
            end;

            LineParameter := 'weight';
            JPath := '$.pricat.item[?(@.id==''' + ItemWrksLine."Item No." + ''')].dimension[?(@.type==''' + LineParameter + ''')].data';
            if JObject.SelectToken(JPath, JToken) then begin
                Clear(AttributeID);
                AttrText[5] := JToken.AsValue().AsText();
                if AttrText[5] <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"NPR Item Worksheet Line", 5, AttributeID) then
                        AttributeMgt.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 5, ItemWrksLine."Worksheet Template Name", ItemWrksLine."Worksheet Name", ItemWrksLine."Line No.", AttrText[5]);
            end;

            LineParameter := 'volume';
            JPath := '$.pricat.item[?(@.id==''' + ItemWrksLine."Item No." + ''')].dimension[?(@.type==''' + LineParameter + ''')].data';
            if JObject.SelectToken(JPath, JToken) then begin
                Clear(AttributeID);
                AttrText[6] := JToken.AsValue().AsText();
                if AttrText[6] <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"NPR Item Worksheet Line", 6, AttributeID) then
                        AttributeMgt.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 6, ItemWrksLine."Worksheet Template Name", ItemWrksLine."Worksheet Name", ItemWrksLine."Line No.", AttrText[6]);
            end;

            LineParameter := 'width';
            JPath := '$.pricat.item[?(@.id==''' + ItemWrksLine."Item No." + ''')].dimension[?(@.type==''' + LineParameter + ''')].data';
            if JObject.SelectToken(JPath, JToken) then begin
                Clear(AttributeID);
                AttrText[7] := JToken.AsValue().AsText();
                if AttrText[7] <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"NPR Item Worksheet Line", 7, AttributeID) then
                        AttributeMgt.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 7, ItemWrksLine."Worksheet Template Name", ItemWrksLine."Worksheet Name", ItemWrksLine."Line No.", AttrText[7]);
            end;

            LineParameter := 'modelNo';
            JPath := '$.pricat.item[?(@.id==''' + ItemWrksLine."Item No." + ''')].property[?(@.name==''' + LineParameter + ''')].data';
            if JObject.SelectToken(JPath, JToken) then begin
                Clear(AttributeID);
                AttrText[8] := JToken.AsValue().AsText();
                if AttrText[8] <> '' then
                    if AttributeMgt.GetAttributeShortcut(DATABASE::"NPR Item Worksheet Line", 8, AttributeID) then
                        AttributeMgt.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", 8, ItemWrksLine."Worksheet Template Name", ItemWrksLine."Worksheet Name", ItemWrksLine."Line No.", AttrText[8]);
            end;

            LineParameter := 'EAN13';
            JPath := '$.pricat.item[?(@.id==''' + ItemWrksLine."Item No." + ''')].dimension[?(@.type==''' + LineParameter + ''')].data';
            JObject.SelectToken(JPath, JToken);
            ItemWrksLine."Vendors Bar Code" := JToken.AsValue().AsText();

            LineParameter := 'UPCA';
            JPath := '$.pricat.item[?(@.id==''' + ItemWrksLine."Item No." + ''')].dimension[?(@.type==''' + LineParameter + ''')].data';
            if JObject.SelectToken(JPath, JToken) then
                ItemWrksLine."Internal Bar Code" := JToken.AsValue().AsText();

            LineParameter := 'grossPrice';
            JPath := '$.pricat.item[?(@.id==''' + ItemWrksLine."Item No." + ''')].price[?(@.type==''' + LineParameter + ''' and @currency==''' + ItemWrksLine."Currency Code" + '''].value';
            if JObject.SelectToken(JPath, JToken) then
                evaluate(ItemWrksLine."Sales Price", JToken.AsValue().AsText());

            ItemWrksLine."Price Includes VAT" := ItemWrksLine."Price Includes VAT"::Yes;
            ItemWrksLine.Insert(true);
        end;
    end;
}