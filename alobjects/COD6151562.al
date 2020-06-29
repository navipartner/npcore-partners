codeunit 6151562 "NpXml Xml Value Subscribers"
{
    // NC2.00/MHA /20161018 CASE 2425550 Object created - contains functions for returning Xml Value during NpXml Export
    // NC2.01/MHA /20161110  CASE 242550 NaviConnect
    // NC2.24/MHA /20191122  CASE 373950 Added function GetStockQty()


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151555, 'OnGetXmlValue', '', true, true)]
    local procedure GetBase64(RecRef: RecordRef; NpXmlElement: Record "NpXml Element"; FieldNo: Integer; var XmlValue: Text; var Handled: Boolean)
    var
        TempBlob: Codeunit "Temp Blob";
        BinaryReader: DotNet npNetBinaryReader;
        Convert: DotNet npNetConvert;
        Encoding: DotNet npNetEncoding;
        MemoryStream: DotNet npNetMemoryStream;
        FieldRef: FieldRef;
        InStr: InStream;
    begin
        if Handled then
            exit;
        if not IsSubscriber(NpXmlElement, 'GetBase64') then
            exit;

        Handled := true;
        XmlValue := '';

        FieldRef := RecRef.Field(FieldNo);
        if LowerCase(Format(FieldRef.Type)) <> 'blob' then begin
            XmlValue := Convert.ToBase64String(Encoding.UTF8.GetBytes(Format(FieldRef.Value)));
            exit;
        end;

        FieldRef.CalcField;
        Clear(TempBlob);
        TempBlob.FromFieldRef(FieldRef);
        TempBlob.CreateInStream(InStr);
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(InStr);
        XmlValue := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151555, 'OnGetXmlValue', '', true, true)]
    local procedure GetStockQty(RecRef: RecordRef; NpXmlElement: Record "NpXml Element"; FieldNo: Integer; var XmlValue: Text; var Handled: Boolean)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        StockkeepingUnit: Record "Stockkeeping Unit";
        Stock: Decimal;
    begin
        //-NC2.24 [373950]
        if Handled then
            exit;
        if not IsSubscriber(NpXmlElement, 'GetStockQty') then
            exit;

        Handled := true;

        case RecRef.Number of
            DATABASE::Item:
                begin
                    RecRef.SetTable(Item);
                    Item.CalcFields(Inventory, "Qty. on Sales Order");
                    Stock := Item.Inventory - Item."Qty. on Sales Order";
                end;
            DATABASE::"Item Variant":
                begin
                    RecRef.SetTable(ItemVariant);
                    if Item.Get(ItemVariant."Item No.") then begin
                        Item.SetRange("Variant Filter", ItemVariant.Code);
                        Item.CalcFields(Inventory, "Qty. on Sales Order");
                        Stock := Item.Inventory - Item."Qty. on Sales Order";
                    end;
                end;
            DATABASE::"Stockkeeping Unit":
                begin
                    RecRef.SetTable(StockkeepingUnit);
                    if Item.Get(StockkeepingUnit."Item No.") then begin
                        Item.SetRange("Variant Filter", StockkeepingUnit."Variant Code");
                        Item.SetRange("Location Filter", StockkeepingUnit."Location Code");
                        Item.CalcFields(Inventory, "Qty. on Sales Order");
                        Stock := Item.Inventory - Item."Qty. on Sales Order";
                    end;
                end;
        end;

        XmlValue := Format(Stock, 0, 9);
        //+NC2.24 [373950]
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure IsSubscriber(NpXmlElement: Record "NpXml Element"; XmlValueFunction: Text): Boolean
    begin
        if NpXmlElement."Xml Value Codeunit ID" <> CODEUNIT::"NpXml Xml Value Subscribers" then
            exit(false);
        if NpXmlElement."Xml Value Function" <> XmlValueFunction then
            exit(false);

        exit(true);
    end;
}

