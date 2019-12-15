table 6150713 "POS Stargate Package"
{
    Caption = 'POS Stargate Package';
    DataPerCompany = false;
    DrillDownPageID = "POS Stargate Packages";
    LookupPageID = "POS Stargate Packages";

    fields
    {
        field(1;Name;Text[80])
        {
            Caption = 'Name';
        }
        field(2;Version;Text[30])
        {
            Caption = 'Version';
        }
        field(3;JSON;BLOB)
        {
            Caption = 'JSON';
        }
        field(4;Methods;Integer)
        {
            CalcFormula = Count("POS Stargate Package Method" WHERE ("Package Name"=FIELD(Name)));
            Caption = 'Methods';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;Name)
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

