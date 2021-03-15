table 6014514 "NPR Exchange Label Map"
{
    DataClassification = CustomerContent;
    Caption = 'Exchange Label Map';

    fields
    {

        field(1; "Table Id"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table Id';
        }
        field(2; "Table Record Id"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Table Record Id';
        }
        field(3; Barcode; Code[13])
        {
            DataClassification = CustomerContent;
            Caption = 'Barcode';
        }
    }

    keys
    {
        key(Key1; "Table Id", "Table Record Id")
        {
            Clustered = true;
        }
    }

    procedure CreateOrUpdateFromPurhaseLine(PurchaseLine: Record "Purchase Line"; _Barcode: Code[13]): Boolean
    begin
        if PurchaseLine.IsTemporary() then
            exit(false);

        if not Get(Database::"Purchase Line", PurchaseLine.SystemId) then begin
            Init();
            "Table Id" := Database::"Purchase Line";
            "Table Record Id" := PurchaseLine.SystemId;
            Insert();
        end;

        Barcode := _Barcode;
        Modify();

        exit(true);
    end;
}