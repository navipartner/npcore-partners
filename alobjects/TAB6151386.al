table 6151386 "CS Rfid Data"
{
    // NPR5.47/NPKNAV/20181026  CASE 318296 Transport NPR5.47 - 26 October 2018
    // NPR5.48/TJ    /20181103  CASE 331261 Length property of field Item Group Description changed from 30 to 50
    // NPR5.48/JDH /20181109 CASE 334163 Added caption to field Combined key and the object
    // NPR5.48/CLVA/20181227 CASE 247747 Renamed object from "CS Rfid Offline Data" to "CS Rfid Data"
    // NPR5.48/BHR /20190111  CASE 341967  Add missing caption

    Caption = 'CS Rfid Data';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Key"; Text[30])
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
        }
        field(11; "Cross-Reference Item No."; Code[20])
        {
            Caption = 'Cross-Reference Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";

            trigger OnValidate()
            begin
                Validate("Cross-Reference Variant Code", '');
                Validate("Item Group Code", '');
            end;
        }
        field(12; "Cross-Reference Variant Code"; Code[10])
        {
            Caption = 'Cross-Reference Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Cross-Reference Item No."));
        }
        field(13; "Item Description"; Text[50])
        {
            CalcFormula = Lookup (Item.Description WHERE("No." = FIELD("Cross-Reference Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Variant Description"; Text[50])
        {
            CalcFormula = Lookup ("Item Variant".Description WHERE(Code = FIELD("Cross-Reference Variant Code"),
                                                                   "Item No." = FIELD("Cross-Reference Item No.")));
            Caption = 'Variant Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Item Group Code"; Code[10])
        {
            Caption = 'Item Group Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Group";
        }
        field(16; "Item Group Description"; Text[50])
        {
            CalcFormula = Lookup ("Item Group".Description WHERE("No." = FIELD("Item Group Code")));
            Caption = 'Item Group Description';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
            end;
        }
        field(17; "Combined key"; Code[30])
        {
            Caption = 'Combined key';
            DataClassification = CustomerContent;
        }
        field(18; "Image Url"; Text[250])
        {
            Caption = 'Image Url';
            DataClassification = CustomerContent;
        }
        field(19; "Time Stamp"; BigInteger)
        {
            Caption = 'Time Stamp';
            DataClassification = CustomerContent;
            SQLTimestamp = true;
        }
        field(20; "Cross-Reference UoM"; Code[10])
        {
            Caption = 'Cross-Reference UoM';
            DataClassification = CustomerContent;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Cross-Reference Item No."));
        }
        field(21; "Cross-Reference Description"; Text[50])
        {
            Caption = 'Cross-Reference Description';
            DataClassification = CustomerContent;
        }
        field(22; "Cross-Reference Discontinue"; Boolean)
        {
            Caption = 'Cross-Reference Discontinue';
            DataClassification = CustomerContent;
        }
        field(23; "Last Known Store Location"; Code[10])
        {
            Caption = 'Last Known Store Location';
            DataClassification = CustomerContent;
            TableRelation = "POS Store".Code;
        }
        field(24; Created; DateTime)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
        }
        field(25; Heartbeat; DateTime)
        {
            Caption = 'Heartbeat';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Key")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        Created := CurrentDateTime;
        if "Cross-Reference Variant Code" <> '' then
            "Combined key" := "Cross-Reference Item No." + '-' + "Cross-Reference Variant Code"
        else
            "Combined key" := "Cross-Reference Item No.";
    end;

    trigger OnModify()
    begin
        Heartbeat := CurrentDateTime;
        if "Cross-Reference Variant Code" <> '' then
            "Combined key" := "Cross-Reference Item No." + '-' + "Cross-Reference Variant Code"
        else
            "Combined key" := "Cross-Reference Item No.";
    end;
}

