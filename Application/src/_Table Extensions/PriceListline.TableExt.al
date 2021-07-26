tableextension 6014459 "NPR Price List line" extends "Price List Line"
{
    fields
    {
        field(6151479; "NPR Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
        }

        field(6014400; "NPR Price List Id"; GUID)
        {
            Caption = 'Price List Id';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key("NPR Key1"; "NPR Replication Counter")
        {
        }

    }

    trigger OnInsert()
    var
        PriceListHeader: Record "Price List Header";
    begin
        if "Price List Code" <> '' then
            if PriceListHeader.Get("Price List Code") then begin
                "NPR Price List Id" := PriceListHeader.SystemId;
                exit;
            end;

        if not IsNullGuid("NPR Price List Id") then
            if PriceListHeader.GetBySystemId("NPR Price List Id") then
                "Price List Code" := PriceListHeader.Code;
    end;

    trigger OnRename()
    var
        PriceListHeader: Record "Price List Header";
    begin
        if "Price List Code" <> '' then
            if PriceListHeader.Get("Price List Code") then
                "NPR Price List Id" := PriceListHeader.SystemId;
    end;

    trigger OnModify()
    var
        PriceListHeader: Record "Price List Header";
    begin
        if not IsNullGuid("NPR Price List Id") then
            if PriceListHeader.GetBySystemId("NPR Price List Id") then
                Rename(PriceListHeader.Code, "Line No.");
    end;
}
