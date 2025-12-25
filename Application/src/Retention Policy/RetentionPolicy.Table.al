#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
table 6151287 "NPR Retention Policy"
{
    Caption = 'NPR Retention Policy';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Retention Policy";
    LookupPageID = "NPR Retention Policy";
    Extensible = false;
    Access = Internal;


    fields
    {
        field(1; "Table Id"; Integer)
        {
            Caption = 'Table Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Table Name"; Text[30])
        {
            Caption = 'Table Name';
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table), "Object ID" = field("Table Id")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(3; "Table Caption"; Text[249])
        {
            Caption = 'Table Caption';
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table Id")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(5; Implementation; Enum "NPR Retention Policy")
        {
            Caption = 'Implementation';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Table Id")
        {
            Clustered = true;
        }
    }

    internal procedure DiscoverRetentionPolicyTables()
    var
        RetentionPolicy: Codeunit "NPR Retention Policy";
    begin
        RetentionPolicy.OnDiscoverRetentionPolicyTables();
    end;
}
#endif