table 6150674 "NPR NPRE Assigned Flow Status"
{
    Caption = 'Assigned Flow Status';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(2; "Record ID"; RecordID)
        {
            Caption = 'Record ID';
            DataClassification = CustomerContent;
        }
        field(3; "Flow Status Object"; Option)
        {
            Caption = 'Flow Status Object';
            DataClassification = CustomerContent;
            OptionCaption = ',,WaiterPadLineMealFlow';
            OptionMembers = ,,WaiterPadLineMealFlow;
        }
        field(4; "Flow Status Code"; Code[10])
        {
            Caption = 'Flow Status Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = FIELD("Flow Status Object"));
        }
    }

    keys
    {
        key(Key1; "Table No.", "Record ID", "Flow Status Object", "Flow Status Code")
        {
        }
    }
}
