table 6150891 "NPR Store Ship. Profile Line"
{
    DataClassification = CustomerContent;
    Access = Internal;
    Caption = 'Store Shipment Profile Line';
    LookupPageId = "NPR Store Shipment Methods";
    DrillDownPageId = "NPR Store Shipment Methods";

    fields
    {
        field(1; "Profile Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Profile Code';
            tablerelation = "NPR Store Ship. Profile Header".Code;

        }
        field(2; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(3; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipment Method";
        }
        field(4; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent";
        }
        field(5; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));
        }
        field(6; "Shipment Fee Type"; Enum "NPR Mag. Shipment Fee Type")
        {
            Caption = 'Shipment Fee Type';
            DataClassification = CustomerContent;
            ValuesAllowed = 0, 1;
        }
        field(7; "Shipment Fee No."; Code[20])
        {
            Caption = 'Shipment Fee No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Shipment Fee Type" = CONST("G/L Account")) "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                                                               "Account Type" = CONST(Posting),
                                                                                               Blocked = CONST(false))
            ELSE
            IF ("Shipment Fee Type" = CONST(Item)) Item
            ELSE
            IF ("Shipment Fee Type" = CONST(Resource)) Resource
            ELSE
            IF ("Shipment Fee Type" = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF ("Shipment Fee Type" = CONST("Charge (Item)")) "Item Charge";

            trigger OnValidate()
            begin
                PopulateDescription(Rec);
            end;
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(9; "Shipment Fee Amount"; Decimal)
        {
            Caption = 'Shipment Fee Amount';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(Key1; "Profile Code", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Profile Code", "Shipment Method Code", "Shipping Agent Code", "Shipping Agent Service Code", "Shipment Fee Type", "Shipment Fee No.")
        {

        }
    }

    local procedure PopulateDescription(var StoreShipProfileLine: Record "NPR Store Ship. Profile Line")
    var
        GLAccount: Record "G/L Account";
        Item: Record Item;
        Resource: Record Resource;
        FixedAsset: Record "Fixed Asset";
        ItemCharge: Record "Item Charge";
        ShipmentDescription: Text;
    begin
        if StoreShipProfileLine.Description <> '' then
            exit;

        Case StoreShipProfileLine."Shipment Fee Type" of
            StoreShipProfileLine."Shipment Fee Type"::"G/L Account":
                begin
                    if not GLAccount.Get(StoreShipProfileLine."Shipment Fee No.") then
                        exit;

                    if GLAccount.Name = '' then
                        exit;

                    if GLAccount.Name = StoreShipProfileLine.Description then
                        exit;

                    ShipmentDescription := GLAccount.Name;
                end;
            StoreShipProfileLine."Shipment Fee Type"::Item:
                begin
                    if not Item.Get(StoreShipProfileLine."Shipment Fee No.") then
                        exit;

                    if Item.Description = '' then
                        exit;

                    if Item.Description = StoreShipProfileLine.Description then
                        exit;

                    ShipmentDescription := Item.Description;
                end;
            StoreShipProfileLine."Shipment Fee Type"::Resource:
                begin
                    if not Resource.Get(StoreShipProfileLine."Shipment Fee No.") then
                        exit;

                    if Resource.Name = '' then
                        exit;

                    if Resource.Name = StoreShipProfileLine.Description then
                        exit;

                    ShipmentDescription := Resource.Name;
                end;
            StoreShipProfileLine."Shipment Fee Type"::"Fixed Asset":
                begin
                    if not FixedAsset.Get(StoreShipProfileLine."Shipment Fee No.") then
                        exit;

                    if FixedAsset.Description = '' then
                        exit;

                    if FixedAsset.Description = StoreShipProfileLine.Description then
                        exit;

                    ShipmentDescription := FixedAsset.Description;
                end;
            StoreShipProfileLine."Shipment Fee Type"::"Charge (Item)":
                begin
                    if not ItemCharge.Get(StoreShipProfileLine."Shipment Fee No.") then
                        exit;

                    if ItemCharge.Description = '' then
                        exit;

                    if ItemCharge.Description = StoreShipProfileLine.Description then
                        exit;

                    ShipmentDescription := ItemCharge.Description;
                end;
        end;

        StoreShipProfileLine.Description := Copystr(ShipmentDescription, 1, MaxStrLen(StoreShipProfileLine.Description));
    end;
}