table 6150713 "POS Stargate Package"
{
    Caption = 'POS Stargate Package';
    DataClassification = CustomerContent;
    DataPerCompany = false;
    DrillDownPageID = "POS Stargate Packages";
    LookupPageID = "POS Stargate Packages";

    fields
    {
        field(1; Name; Text[80])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(2; Version; Text[30])
        {
            Caption = 'Version';
            DataClassification = CustomerContent;
        }
        field(3; JSON; BLOB)
        {
            Caption = 'JSON';
            DataClassification = CustomerContent;
        }
        field(4; Methods; Integer)
        {
            CalcFormula = Count ("POS Stargate Package Method" WHERE("Package Name" = FIELD(Name)));
            Caption = 'Methods';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; Name)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        StargatePackageMethod: Record "POS Stargate Package Method";
    begin
        StargatePackageMethod.SetRange("Package Name", Name);
        StargatePackageMethod.DeleteAll;
    end;
}

