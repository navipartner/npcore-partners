table 6150915 "NPR Entra App Permission"
{
    Caption = 'Entra App Permission';
    DataClassification = CustomerContent;
    TableType = Temporary;
    Access = Internal;
    Extensible = False;

    fields
    {
        field(1; "Permission Set ID"; Code[20])
        {
            Caption = 'Permission Set ID';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Aggregate Permission Set"."Role ID";
        }
        field(2; "Permission Set Name"; Text[30])
        {
            Caption = 'Permission Set Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Aggregate Permission Set".Name where("Role ID" = field("Permission Set ID")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Permission Set ID")
        {
            Clustered = true;
        }
    }
}