table 6151445 "Magento Customer Mapping"
{
    // MAG2.22/MHA /20190710  CASE 360098 Object created

    Caption = 'Magento Customer Mapping';

    fields
    {
        field(1;"Country/Region Code";Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(5;"Post Code";Code[20])
        {
            Caption = 'Post Code';
            TableRelation = IF ("Country/Region Code"=CONST('')) "Post Code"
                            ELSE IF ("Country/Region Code"=FILTER(<>'')) "Post Code" WHERE ("Country/Region Code"=FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(10;"Customer Template Code";Code[10])
        {
            Caption = 'Customer Template Code';
            TableRelation = "Customer Template";
        }
        field(20;"Config. Template Code";Code[10])
        {
            Caption = 'Config. Template Code';
            TableRelation = "Config. Template Header".Code WHERE ("Table ID"=CONST(18));
        }
        field(95;"Country/Region Name";Text[50])
        {
            CalcFormula = Lookup("Country/Region".Name WHERE (Code=FIELD("Country/Region Code")));
            Caption = 'Country/Region Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100;City;Text[30])
        {
            CalcFormula = Min("Post Code".City WHERE (Code=FIELD("Post Code")));
            Caption = 'City';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Country/Region Code","Post Code")
        {
        }
    }

    fieldgroups
    {
    }
}

