table 6150713 "NPR POS Stargate Package"
{
    Access = Internal;
    Caption = 'POS Stargate Package';
    DataClassification = CustomerContent;
    DataPerCompany = false;
    DrillDownPageID = "NPR POS Stargate Packages";
    LookupPageID = "NPR POS Stargate Packages";
    ObsoleteState = Removed;
    ObsoleteTag = '2024-02-28';
    ObsoleteReason = 'Stargate is replaced by hardware connector';

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
            CalcFormula = Count("NPR POS Stargate Pckg. Method" WHERE("Package Name" = FIELD(Name)));
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
}
