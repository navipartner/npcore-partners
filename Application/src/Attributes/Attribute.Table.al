table 6014552 "NPR Attribute"
{
    // NPRx.xx/TSA/22-04-15  CASE 209946 - Entity and Shortcut Attributes
    // NPR5.35/ANEN/20170608 CASE 276486 Support for lookup from table
    // NPR5.39/BR  /20180215 CASE 295322 Added field Import File Column No.
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj fiels 24,25
    // NPR5.48/TSA /20181102 CASE 334651 Changed optionstring words that resembles keywords to none-keywords

    Caption = 'Attribute';
    DrillDownPageID = "NPR Attributes";
    LookupPageID = "NPR Attributes";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; Name; Text[30])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(11; "Code Caption"; Text[30])
        {
            Caption = 'Code Caption';
            DataClassification = CustomerContent;
        }
        field(12; "Filter Caption"; Text[30])
        {
            Caption = 'Filter Caption';
            DataClassification = CustomerContent;
        }
        field(13; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(14; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(15; Global; Boolean)
        {
            Caption = 'Global';
            DataClassification = CustomerContent;
        }
        field(20; "Value Datatype"; Option)
        {
            Caption = 'Value Datatype';
            OptionCaption = 'Text,Code,Date,Datetime,Decimal,Integer,Boolean';
            OptionMembers = DT_TEXT,DT_CODE,DT_DATE,DT_DATETIME,DT_DECIMAL,DT_INTEGER,DT_BOOLEAN;
            DataClassification = CustomerContent;
        }
        field(21; "On Validate"; Option)
        {
            Caption = 'On Validate';
            OptionCaption = 'Datatype,Lookup';
            OptionMembers = DATATYPE,VALUE_LOOKUP;
            DataClassification = CustomerContent;
        }
        field(22; "On Format"; Option)
        {
            Caption = 'On Format';
            OptionCaption = 'Native,User''s Culture,Custom';
            OptionMembers = NATIVE,USER,CUSTOM;
            DataClassification = CustomerContent;
        }
        field(23; "LookUp Table"; Boolean)
        {
            Caption = 'LookUp Table';
            DataClassification = CustomerContent;
        }
        field(24; "LookUp Table Id"; Integer)
        {
            Caption = 'LookUp Table Id';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = CustomerContent;
        }
        field(25; "LookUp Table Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("LookUp Table Id")));
            Caption = 'LookUp Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(26; "LookUp Value Field Id"; Integer)
        {
            Caption = 'LookUp Value Field Id';
            TableRelation = Field."No." WHERE(TableNo = FIELD("LookUp Table Id"));
            DataClassification = CustomerContent;
        }
        field(27; "LookUp Value Field Name"; Text[30])
        {
            CalcFormula = Lookup(Field.FieldName WHERE(TableNo = FIELD("LookUp Table Id"),
                                                        "No." = FIELD("LookUp Value Field Id")));
            Caption = 'LookUp Value Field Name';
            FieldClass = FlowField;
        }
        field(28; "LookUp Description Field Id"; Integer)
        {
            Caption = 'LookUp Description Field Id';
            TableRelation = Field."No." WHERE(TableNo = FIELD("LookUp Table Id"));
            DataClassification = CustomerContent;
        }
        field(29; "LookUp Description Field Name"; Text[30])
        {
            CalcFormula = Lookup(Field.FieldName WHERE(TableNo = FIELD("LookUp Table Id"),
                                                        "No." = FIELD("LookUp Description Field Id")));
            Caption = 'LookUp Description Field Name';
            FieldClass = FlowField;
        }
        field(40; "Import File Column No."; Integer)
        {
            Caption = 'Import File Column No.';
            Description = 'NPR5.39';
            DataClassification = CustomerContent;
        }

        field(6151479; "Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }

        key(Key2; "Replication Counter")
        {
        }
    }

    fieldgroups
    {
    }

}

