#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248658 "NPR API Retail Print" implements "NPR API Request Handler"
{
    Access = Internal;
    SingleInstance = true;
    EventSubscriberInstance = Manual;

    var
        CapturedPrintJob: Text;

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    begin
        case true of
            Request.Match('POST', '/retailprint/pricelabel'):
                exit(PrintPriceLabel(Request));
        end;
    end;

    local procedure PrintPriceLabel(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        TempRetailJournalLine: Record "NPR Retail Journal Line" temporary;
        RPTemplateHeader: Record "NPR RP Template Header";
        JsonHelper: Codeunit "NPR Json Helper";
        Body: JsonToken;
        ItemsToken: JsonToken;
        ItemsArray: JsonArray;
        ItemToken: JsonToken;
        TempRetailJnlNo: Code[40];
        LayoutType: Text;
        Layout: Text;
        LineNo: Integer;
        CodeunitId: Integer;
        ErrorMsg: Text;
    begin
        Body := Request.BodyJson();

        LayoutType := JsonHelper.GetJText(Body, 'layoutType', true);
        Layout := JsonHelper.GetJText(Body, 'layout', true);

        case LayoutType of
            'PrintTemplate':
                if not RPTemplateHeader.Get(CopyStr(Layout, 1, 20)) then
                    exit(Response.RespondBadRequest(StrSubstNo('Print template not found: %1', Layout)));
            'Codeunit':
                if not Evaluate(CodeunitId, Layout) then
                    exit(Response.RespondBadRequest(StrSubstNo('Invalid codeunit ID: %1', Layout)));
            else
                exit(Response.RespondBadRequest('Invalid layoutType. Must be either PrintTemplate or Codeunit'));
        end;

        if not Body.SelectToken('items', ItemsToken) then
            exit(Response.RespondBadRequest('Missing required field: items'));

        if not ItemsToken.IsArray() then
            exit(Response.RespondBadRequest('Field "items" must be an array'));

        ItemsArray := ItemsToken.AsArray();

        if ItemsArray.Count() = 0 then
            exit(Response.RespondBadRequest('Items array cannot be empty'));

        Evaluate(TempRetailJnlNo, CreateGuid());

        LineNo := 10000;
        foreach ItemToken in ItemsArray do begin
            if not CreateRetailJournalLineFromItemToken(ItemToken, TempRetailJnlNo, LineNo, TempRetailJournalLine, ErrorMsg) then
                exit(Response.RespondBadRequest(ErrorMsg));

            LineNo += 10000;
        end;

        exit(Response.RespondOK(BuildSuccessResponse(TempRetailJournalLine, LayoutType, Layout, RPTemplateHeader)));
    end;

    local procedure CreateRetailJournalLineFromItemToken(ItemToken: JsonToken; RetailJnlNo: Code[40]; LineNo: Integer; var TempRetailJournalLine: Record "NPR Retail Journal Line" temporary; var ErrorMsg: Text): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
        ItemNo: Code[20];
        VariantCode: Code[10];
        Ean: Code[50];
        Qty: Integer;
        HasEan: Boolean;
        HasItemNo: Boolean;
    begin
        // Get quantity (required for all items)
        Qty := JsonHelper.GetJInteger(ItemToken, 'qty', true);

        if Qty <= 0 then begin
            ErrorMsg := StrSubstNo('Invalid quantity: %1. Quantity must be greater than 0', Qty);
            exit(false);
        end;

        // Check which identification method is used
        HasEan := JsonHelper.TokenExists(ItemToken, 'ean');
        HasItemNo := JsonHelper.TokenExists(ItemToken, 'itemNo');

        // Validate that only one method is provided
        if HasEan and HasItemNo then begin
            ErrorMsg := 'Cannot specify both "ean" and "itemNo" for the same item. Please use only one identification method.';
            exit(false);
        end;

        if not HasEan and not HasItemNo then begin
            ErrorMsg := 'Missing item identification. Please provide either "ean" or "itemNo".';
            exit(false);
        end;

        if HasEan then begin
            Ean := CopyStr(JsonHelper.GetJText(ItemToken, 'ean', true), 1, MaxStrLen(Ean));
            exit(InsertRetailJournalLine(RetailJnlNo, LineNo, Qty, Ean, TempRetailJournalLine, ErrorMsg));
        end else begin
            ItemNo := CopyStr(JsonHelper.GetJText(ItemToken, 'itemNo', true), 1, MaxStrLen(ItemNo));
            VariantCode := CopyStr(JsonHelper.GetJText(ItemToken, 'variantCode', false), 1, MaxStrLen(VariantCode));
            exit(InsertRetailJournalLine(RetailJnlNo, LineNo, Qty, ItemNo, VariantCode, TempRetailJournalLine, ErrorMsg));
        end;
    end;

    local procedure InsertRetailJournalLine(RetailJnlNo: Code[40]; LineNo: Integer; Qty: Integer; Barcode: Code[50]; var TempRetailJournalLine: Record "NPR Retail Journal Line" temporary; var ErrorMsg: Text): Boolean
    begin
        InitRetailJournalLine(RetailJnlNo, LineNo, TempRetailJournalLine);

        if not FillRetailJournalLineFromBarcode(Barcode, Qty, TempRetailJournalLine, ErrorMsg) then
            exit(false);

        TempRetailJournalLine.Insert(true);
        exit(true);
    end;

    local procedure InsertRetailJournalLine(RetailJnlNo: Code[40]; LineNo: Integer; Qty: Integer; ItemNo: Code[20]; VariantCode: Code[10]; var TempRetailJournalLine: Record "NPR Retail Journal Line" temporary; var ErrorMsg: Text): Boolean
    begin
        InitRetailJournalLine(RetailJnlNo, LineNo, TempRetailJournalLine);

        if not FillRetailJournalLineFromItemNo(ItemNo, VariantCode, Qty, TempRetailJournalLine, ErrorMsg) then
            exit(false);

        TempRetailJournalLine.Insert(true);
        exit(true);
    end;

    local procedure InitRetailJournalLine(RetailJnlNo: Code[40]; LineNo: Integer; var TempRetailJournalLine: Record "NPR Retail Journal Line" temporary)
    begin
        TempRetailJournalLine.Init();
        TempRetailJournalLine."No." := RetailJnlNo;
        TempRetailJournalLine."Line No." := LineNo;
    end;

    local procedure FillRetailJournalLineFromBarcode(Barcode: Code[50]; Qty: Integer; var TempRetailJournalLine: Record "NPR Retail Journal Line" temporary; var ErrorMsg: Text): Boolean
    begin
        // Validate Barcode - this will automatically populate Item No. and Variant Code
        TempRetailJournalLine.Validate(Barcode, Barcode);

        // Check if item was found
        if TempRetailJournalLine."Item No." = '' then begin
            ErrorMsg := StrSubstNo('Item not found for EAN: %1', Barcode);
            exit(false);
        end;

        TempRetailJournalLine.Validate("Quantity to Print", Qty);
        exit(true);
    end;

    local procedure FillRetailJournalLineFromItemNo(ItemNo: Code[20]; VariantCode: Code[10]; Qty: Integer; var TempRetailJournalLine: Record "NPR Retail Journal Line" temporary; var ErrorMsg: Text): Boolean
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        // Validate that the Item exists
        if not Item.Get(ItemNo) then begin
            ErrorMsg := StrSubstNo('Item not found: %1', ItemNo);
            exit(false);
        end;

        // Validate Variant Code if provided
        if VariantCode <> '' then
            if not ItemVariant.Get(ItemNo, VariantCode) then begin
                ErrorMsg := StrSubstNo('Variant Code "%1" not found for Item No. "%2"', VariantCode, ItemNo);
                exit(false);
            end;

        // Set Item No. and Variant Code directly
        TempRetailJournalLine.Validate("Item No.", ItemNo);
        if VariantCode <> '' then
            TempRetailJournalLine.Validate("Variant Code", VariantCode);

        TempRetailJournalLine.Validate("Quantity to Print", Qty);
        exit(true);
    end;

    local procedure BuildSuccessResponse(var TempRetailJournalLine: Record "NPR Retail Journal Line" temporary; LayoutType: Text; Layout: Text; RPTemplateHeader: Record "NPR RP Template Header") Json: JsonObject
    var
        PrintJob: Text;
    begin
        case LayoutType of
            'PrintTemplate':
                PrintJob := GeneratePrintJobFromTemplate(TempRetailJournalLine, Layout);
            'Codeunit':
                PrintJob := GeneratePrintJobFromCodeunit(TempRetailJournalLine, Layout);
        end;

        if LayoutType = 'PrintTemplate' then begin
            Json.Add('printerType', GetPrinterTypeValue(RPTemplateHeader));
            Json.Add('device', GetDeviceEnumValue(RPTemplateHeader));
        end;
        Json.Add('type', 'raw');
        Json.Add('printJob', PrintJob);
    end;

    local procedure GeneratePrintJobFromTemplate(var TempRetailJournalLine: Record "NPR Retail Journal Line" temporary; TemplateCode: Text) PrintJob: Text
    var
        RPTemplateHeader: Record "NPR RP Template Header";
        TemplateMgt: Codeunit "NPR RP Template Mgt.";
        RecRef: RecordRef;
    begin
        // Template existence already validated in PrintPriceLabel
        RPTemplateHeader.Get(CopyStr(TemplateCode, 1, 20));

        TempRetailJournalLine.Reset();
        TempRetailJournalLine.FindFirst();

        RecRef.GetTable(TempRetailJournalLine);

        BindSubscription(this);
        CapturedPrintJob := '';

        // Process the template - this will trigger our event subscriber
        TemplateMgt.PrintTemplate(RPTemplateHeader.Code, RecRef, TempRetailJournalLine.FieldNo("Quantity to Print"));

        UnbindSubscription(this);

        PrintJob := CapturedPrintJob;
    end;

    local procedure GeneratePrintJobFromCodeunit(var TempRetailJournalLine: Record "NPR Retail Journal Line" temporary; CodeunitIdText: Text) PrintJob: Text
    var
        RecRef: RecordRef;
        RecVariant: Variant;
        CodeunitId: Integer;
    begin
        // Codeunit ID already validated in PrintPriceLabel
        Evaluate(CodeunitId, CodeunitIdText);

        TempRetailJournalLine.Reset();
        TempRetailJournalLine.FindFirst();

        RecRef.GetTable(TempRetailJournalLine);
        RecVariant := RecRef;

        BindSubscription(this);
        CapturedPrintJob := '';

        // Run the codeunit - if it prints through ObjectOutputMgt, we'll capture it
        if CodeunitId > 0 then
            Codeunit.Run(CodeunitId, RecVariant);

        UnbindSubscription(this);

        PrintJob := CapturedPrintJob;
    end;

    local procedure GetPrinterTypeValue(RPTemplateHeader: Record "NPR RP Template Header") PrinterType: Text
    begin
        case RPTemplateHeader."Printer Type" of
            RPTemplateHeader."Printer Type"::Matrix:
                PrinterType := 'Matrix';
            RPTemplateHeader."Printer Type"::Line:
                PrinterType := 'Line';
        end;
    end;

    local procedure GetDeviceEnumValue(RPTemplateHeader: Record "NPR RP Template Header") Device: Text
    begin
        case RPTemplateHeader."Printer Type" of
            RPTemplateHeader."Printer Type"::Line:
                begin
                    Device := RPTemplateHeader."Line Device".Names.Get(RPTemplateHeader."Line Device".Ordinals.IndexOf(RPTemplateHeader."Line Device".AsInteger()));
                end;
            RPTemplateHeader."Printer Type"::Matrix:
                begin
                    Device := RPTemplateHeader."Matrix Device".Names.Get(RPTemplateHeader."Matrix Device".Ordinals.IndexOf(RPTemplateHeader."Matrix Device".AsInteger()));
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Object Output Mgt.", 'OnBeforeSendLinePrint', '', false, false)]
    local procedure OnBeforeSendLinePrint(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Interface "NPR ILine Printer"; NoOfPrints: Integer; var Skip: Boolean)
    begin
        // Capture the print buffer
        CapturedPrintJob := Printer.GetPrintBufferAsBase64();
        // Skip actual printing
        Skip := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Object Output Mgt.", 'OnBeforeSendMatrixPrint', '', false, false)]
    local procedure OnBeforeSendMatrixPrint(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Interface "NPR IMatrix Printer"; NoOfPrints: Integer; var Skip: Boolean)
    begin
        // Capture the print buffer
        CapturedPrintJob := Printer.GetPrintBufferAsBase64();
        // Skip actual printing
        Skip := true;
    end;
}
#endif
