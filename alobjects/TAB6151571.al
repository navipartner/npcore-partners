table 6151571 "AF Test Objects"
{
    // NPR5.36/NPKNAV/20171003  CASE 269792 Transport NPR5.36 - 3 October 2017
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj fields 2,10

    Caption = 'AF Test Objects';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Object Type"; Option)
        {
            Caption = 'Object Type';
            DataClassification = CustomerContent;
            OptionCaption = 'TableData,Table,,Report,,Codeunit,XMLport,MenuSuite,Page,Query,System,FieldNumber';
            OptionMembers = TableData,"Table",,"Report",,"Codeunit","XMLport",MenuSuite,"Page","Query",System,FieldNumber;
        }
        field(2; "Object ID"; Integer)
        {
            Caption = 'Object ID';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = FIELD("Object Type"));
            //This property is currently not supported
            //TestTableRelation = true;
        }
        field(10; "Object Name"; Text[30])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Object ID")));
            Caption = 'Object Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Object Type", "Object ID")
        {
        }
    }

    fieldgroups
    {
    }
}

