table 6151207 "NPR Change Tracker"
{
    Access = Internal;
    Caption = 'Change Tracker';
    DataClassification = SystemMetadata;

    fields
    {
        // One high-water mark per (Integration Type, Table No.) — NOT per store; per-store fan-out happens at task creation.
        field(1; "Integration Type"; Enum "NPR Integration Type")
        {
            Caption = 'Integration Type';
        }
        field(10; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(11; "Table Name"; Text[249])
        {
            Caption = 'Table Name';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table No.")));
        }
        field(20; "Processing Order"; Integer)
        {
            // 0 = trigger/source tables (polled first); derived/"send" tables get a higher value
            Caption = 'Processing Order';
            InitValue = 0;
        }
        field(30; "Last Row Version"; BigInteger)
        {
            Caption = 'Last Row Version';
        }
    }

    keys
    {
        key(PK; "Integration Type", "Table No.")
        {
            Clustered = true;
        }
        key(ByOrder; "Integration Type", "Processing Order", "Table No.")
        {
        }
    }
}
