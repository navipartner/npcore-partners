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
    procedure UpdateReferencedIds()
    var
        PriceListHeader: Record "Price List Header";
    begin
        if "Price List Code" = '' then begin
            Clear("NPR Price List Id");
            exit;
        end;

        if not PriceListHeader.Get(Rec."Price List Code") then
            exit;

        "NPR Price List Id" := PriceListHeader.SystemId;
    end;
}
