codeunit 6151562 "NPR NpXml Xml Value Sub."
{
    Access = Internal;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpXml Value Mgt.", 'OnGetXmlValue', '', true, true)]
    local procedure GetBase64(RecRef: RecordRef; NpXmlElement: Record "NPR NpXml Element"; FieldNo: Integer; var XmlValue: Text; var Handled: Boolean)
    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        FieldRef: FieldRef;
        InStr: InStream;
        ByteText: Text;
    begin
        if Handled then
            exit;
        if not IsSubscriber(NpXmlElement, 'GetBase64') then
            exit;

        Handled := true;
        XmlValue := '';

        FieldRef := RecRef.Field(FieldNo);
        if LowerCase(Format(FieldRef.Type)) <> 'blob' then begin
            XmlValue := Base64Convert.ToBase64((Format(FieldRef.Value)), TextEncoding::UTF8);
            exit;
        end;

        FieldRef.CalcField();
        Clear(TempBlob);
        TempBlob.FromFieldRef(FieldRef);
        TempBlob.CreateInStream(InStr);
        InStr.Read(ByteText);
        XmlValue := Base64Convert.ToBase64(ByteText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpXml Value Mgt.", 'OnGetXmlValue', '', true, true)]
    local procedure GetStockQty(RecRef: RecordRef; NpXmlElement: Record "NPR NpXml Element"; FieldNo: Integer; var XmlValue: Text; var Handled: Boolean)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        StockkeepingUnit: Record "Stockkeeping Unit";
        Stock: Decimal;
    begin
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
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpXml Value Mgt.", 'OnGetXmlValue', '', true, true)]
    local procedure GetCurrentDateAndTime(RecRef: RecordRef; NpXmlElement: Record "NPR NpXml Element"; FieldNo: Integer; var XmlValue: Text; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsSubscriber(NpXmlElement, 'GetCurrentDateAndTime') then
            exit;

        Handled := true;

        XmlValue := Format(CurrentDateTime, 0, 9);
    end;

    local procedure IsSubscriber(NpXmlElement: Record "NPR NpXml Element"; XmlValueFunction: Text): Boolean
    begin
        if NpXmlElement."Xml Value Codeunit ID" <> CODEUNIT::"NPR NpXml Xml Value Sub." then
            exit(false);
        if NpXmlElement."Xml Value Function" <> XmlValueFunction then
            exit(false);

        exit(true);
    end;
}

