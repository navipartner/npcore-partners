table 6059863 "NPR M2 MSI Request"
{
    Access = Public;
    TableType = Temporary;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Variant Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Magento Source"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(4; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key("Primary Key"; "Item No.", "Variant Code", "Magento Source")
        {
        }
    }

    internal procedure SerializeToJson() Json: JsonObject
    var
        Sku: Text;
        BufInt: Integer;
    begin
        Sku := Rec."Item No.";
        if (Rec."Variant Code" <> '') then
            Sku += ('_' + Rec."Variant Code");

        if (Rec.Quantity < 0) then
            Rec.Quantity := 0;

        BufInt := Round(Rec.Quantity, 1, '<');

        Json.Add('sku', Sku);
        Json.Add('source_code', Rec."Magento Source");
        Json.Add('quantity', BufInt);
        if (Rec.Quantity > 0) then
            Json.Add('status', 1)
        else
            Json.Add('status', 0);
    end;
}