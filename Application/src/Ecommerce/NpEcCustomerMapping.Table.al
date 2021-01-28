table 6151305 "NPR NpEc Customer Mapping"
{
    Caption = 'Customer Mapping';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpEc Customer Mapping";
    LookupPageID = "NPR NpEc Customer Mapping";
    fields
    {
        field(1; "Store Code"; Code[20])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR NpEc Store";
        }
        field(5; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }
        field(10; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code" ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code" WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            ValidateTableRelation = false;
        }
        field(30; "Config. Template Code"; Code[10])
        {
            Caption = 'Config. Template Code';
            DataClassification = CustomerContent;
            TableRelation = "Config. Template Header".Code WHERE("Table ID" = CONST(18));
        }
        field(40; "Country/Region Name"; Text[50])
        {
            CalcFormula = Lookup("Country/Region".Name WHERE(Code = FIELD("Country/Region Code")));
            Caption = 'Country/Region Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50; City; Text[30])
        {
            CalcFormula = Min("Post Code".City WHERE(Code = FIELD("Post Code")));
            Caption = 'City';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Store Code", "Country/Region Code", "Post Code")
        {
        }
    }

    fieldgroups
    {
    }
}

