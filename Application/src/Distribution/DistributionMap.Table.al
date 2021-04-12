table 6014526 "NPR Distribution Map"
{
    DataClassification = CustomerContent;
    Caption = 'Distribution Map';

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
        field(3; "Distribution Id"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table Id';
            TableRelation = "NPR Distribution Headers"."Distribution Id";
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
            TableRelation = Item."No.";
        }
        field(5; "Variant Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
        }
        field(6; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
            TableRelation = Location.Code;
        }
        field(7; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity';
        }
    }

    keys
    {
        key(Key1; "Table Id", "Table Record Id")
        {
            Clustered = true;
        }
        key(Key2; "Item No.", "Variant Code", "Location Code")
        {
            SumIndexFields = Quantity;
        }
    }

    procedure CreateFromPurchaseLine(DistributionId: Integer; PurchaseLine: Record "Purchase Line")
    begin
        if PurchaseLine.IsTemporary() then
            exit;

        PurchaseLine.TestField(Type, PurchaseLine.Type::Item);
        PurchaseLine.TestField("No.");

        Init();
        "Table Id" := Database::"Purchase Line";
        "Table Record Id" := PurchaseLine.SystemId;
        "Distribution Id" := DistributionId;
        "Item No." := PurchaseLine."No.";
        "Variant Code" := PurchaseLine."Variant Code";
        "Location Code" := PurchaseLine."Location Code";
        Quantity := PurchaseLine."Outstanding Quantity";
        Insert();
    end;

    procedure CreateFromTransferLine(DistributionId: Integer; TransferLine: Record "Transfer Line")
    begin
        if TransferLine.IsTemporary() then
            exit;

        TransferLine.TestField("Item No.");

        Init();
        "Table Id" := Database::"Transfer Line";
        "Table Record Id" := TransferLine.SystemId;
        "Distribution Id" := DistributionId;
        "Item No." := TransferLine."Item No.";
        "Variant Code" := TransferLine."Variant Code";
        "Location Code" := TransferLine."Transfer-from Code";
        Quantity := TransferLine."Outstanding Quantity";
        Insert();
    end;
}