codeunit 6059826 "NPR MPOS Data View NaviConnect" implements "NPR MPOS IDataViewType"
{
    Access = Internal;

    var
        ApplicableMsg: Label 'applicable', Locked = true;
        MessageMsg: Label 'message', Locked = true;
        NotApplicableMsg: Label 'N/A', Locked = true;
        DefaultFiltersMsg: Label 'Default Filters', Locked = true;

    procedure LookupCode(var Text: Text): Boolean
    var
        XmlTemplate: Record "NPR NpXml Template";
    begin
        if Page.RunModal(0, XmlTemplate) = Action::LookupOK then begin
            Text := XmlTemplate.Code;
            exit(true);
        end;
        exit(false);
    end;

    procedure IsActive(DataViewCode: Code[20]): Boolean
    var
        XmlTemplate: Record "NPR NpXml Template";
    begin
        XmlTemplate.SetRange(Code, DataViewCode);
        XmlTemplate.SetRange(Archived, false);
        exit(not XmlTemplate.IsEmpty());
    end;

    procedure ProcessView(DataViewCode: Code[20]; Request: JsonToken): JsonToken
    var
        XmlTemplate: Record "NPR NpXml Template";
        Item: Record Item;
        NpXmlMgt: Codeunit "NPR NpXml Mgt.";
        BarcodeLookup: Codeunit "NPR Barcode Lookup Mgt.";
        DataTypeMgt: Codeunit "Data Type Management";
        XmlTemplateResult: Codeunit "Temp Blob";
        RecRef: RecordRef;
        Result: JsonObject;
        InStr: Instream;
        Barcode: Text;
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        ItemNotFoundMsg: Label 'Item not found for Barcode %1', Comment = '%1=Barcode';
        BarcodeEmptyLbl: Label 'Barcode is empty';
    begin
        XmlTemplate.Get(DataViewCode);
        XmlTemplate.TestField(Archived, false);

        case true of
            Request.IsValue():
                begin
                    Barcode := Request.AsValue().AsText();
                end;
        end;
        if Barcode = '' then begin
            Result.Add(ApplicableMsg, NotApplicableMsg);
            Result.Add(MessageMsg, BarcodeEmptyLbl);
            exit(Result.AsToken());
        end;
        BarcodeLookup.TranslateBarcodeToItemVariant(Barcode, ItemNo, VariantCode, ResolvingTable, true);
        Item.SetRange("No.", ItemNo);
        Item.SetFilter("Variant Filter", VariantCode);
        if Item.IsEmpty() then begin
            Result.Add(ApplicableMsg, NotApplicableMsg);
            Result.Add(MessageMsg, StrSubstNo(ItemNotFoundMsg, Barcode));
            Result.Add(DefaultFiltersMsg, Item.GetFilters());
            exit(Result.AsToken());
        end;
        DataTypeMgt.GetRecordRef(Item, RecRef);
        NpXmlMgt.Initialize(XmlTemplate, RecRef, '', false);
        NpXmlMgt.CreateXml(XmlTemplateResult);
        XmlTemplateResult.CreateInStream(InStr);
        if not Result.ReadFrom(InStr) then begin
            Result.Add(ApplicableMsg, NotApplicableMsg);
            Result.Add(MessageMsg, StrSubstNo(ItemNotFoundMsg, Barcode));
            Result.Add(DefaultFiltersMsg, Item.GetFilters());
            exit(Result.AsToken());
        end;
        exit(Result.AsToken());
    end;

    procedure GetViews(): JsonToken
    var
        DataView: Record "NPR MPOS Data View";
        DataViewsResponse: JsonArray;
        DataViewResponse: JsonObject;
        DataViewsNotFoundMsg: Label 'Data views not found in %1', Comment = '%1=DataView.TableCaption()';
    begin
        DataView.SetRange("Data View Type", DataView."Data View Type"::NaviConnect);
        if not DataView.FindSet() then begin
            DataViewResponse.Add(ApplicableMsg, NotApplicableMsg);
            DataViewResponse.Add(MessageMsg, StrSubstNo(DataViewsNotFoundMsg, DataView.TableCaption()));
            exit(DataViewResponse.AsToken());
        end;

        repeat
            if IsActive(DataView."Data View Code") then begin
                clear(DataViewResponse);
                DataViewResponse.Add(DataView.FieldName("Data View Type"), Format(DataView."Data View Type"));
                DataViewResponse.Add(DataView.FieldName("Data View Category"), Format(DataView."Data View Category"));
                DataViewResponse.Add(DataView.FieldName("Data View Code"), Format(DataView."Data View Code"));
                DataViewResponse.Add(DataView.FieldName(Description), Format(DataView.Description));
                DataViewsResponse.Add(DataViewResponse);
            end;
        until DataView.next() = 0;
        exit(DataViewsResponse.AsToken());
    end;
}