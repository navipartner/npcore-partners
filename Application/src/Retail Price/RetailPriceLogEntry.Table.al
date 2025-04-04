﻿table 6014476 "NPR Retail Price Log Entry"
{
    Access = Internal;
    // NPR5.40/MHA /20180316  CASE 304031 Object created

    Caption = 'Retail Price Log Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; "Date and Time"; DateTime)
        {
            Caption = 'Date and Time';
            DataClassification = CustomerContent;
        }
        field(5; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(10; "Time"; Time)
        {
            Caption = 'Time';
            DataClassification = CustomerContent;
        }
        field(15; "User ID"; Code[50])
        {
            Caption = 'User ID';
            TableRelation = User."User Name";
            DataClassification = EndUserIdentifiableInformation;

        }
        field(20; "Change Log Entry No."; BigInteger)
        {
            Caption = 'Change Log Entry No.';
            DataClassification = CustomerContent;
        }
        field(25; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table),
                                                                 "Object ID" = FILTER(27 | 7002 | 7004 | 6014414));
            DataClassification = CustomerContent;
        }
        field(27; "Table Caption"; Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Table No.")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30; "Field No."; Integer)
        {
            Caption = 'Field No.';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));
            DataClassification = CustomerContent;
        }
        field(35; "Field Caption"; Text[80])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE(TableNo = FIELD("Table No."),
                                                              "No." = FIELD("Field No.")));
            Caption = 'Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(55; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
            DataClassification = CustomerContent;
        }
        field(100; "Old Value"; Decimal)
        {
            Caption = 'Old Value';
            DataClassification = CustomerContent;
        }
        field(105; "New Value"; Decimal)
        {
            Caption = 'New Value';
            DataClassification = CustomerContent;
        }
        field(110; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Change Log Entry No.")
        {
        }
        key(Key3; "Date and Time")
        {
        }
        key(Key4; "Item No.", "Variant Code")
        {
        }
        key(Key5; "Table No.", "Field No.", "Change Log Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

