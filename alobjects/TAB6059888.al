table 6059888 "Npm Page"
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager
    // NPR5.38/MHA /20180104  CASE 301054 Removed hidden property, Volatile, from Field 50 and 55

    Caption = 'Npm Page';
    DataPerCompany = false;
    DrillDownPageID = "Npm Pages";
    LookupPageID = "Npm Pages";

    fields
    {
        field(1;"Page ID";Integer)
        {
            Caption = 'Page ID';
            MinValue = 1;
        }
        field(5;"Page Name";Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Page),
                                                             "Object ID"=FIELD("Page ID")));
            Caption = 'Page Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10;"Source Table No.";Integer)
        {
            Caption = 'Source Table No.';
        }
        field(15;"Source Table Name";Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Table),
                                                             "Object ID"=FIELD("Source Table No.")));
            Caption = 'Source Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50;"Original Metadata";BLOB)
        {
            Caption = 'Original Metadata';
            Description = 'NPR5.38';
        }
        field(55;"Latest Metadata";BLOB)
        {
            Caption = 'Latest Metadata';
            Description = 'NPR5.38';
        }
        field(100;"Npm Enabled";Boolean)
        {
            CalcFormula = Exist("Npm Page View" WHERE ("Page ID"=FIELD("Page ID")));
            Caption = 'Npm Enabled';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Page ID")
        {
        }
    }

    fieldgroups
    {
    }
}

