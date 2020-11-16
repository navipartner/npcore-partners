tableextension 6014428 "NPR Extended Text Header" extends "Extended Text Header"
{
    // NPR5.49/TJ  /20190218 CASE 345047 New field Event
    fields
    {
        field(6014400; "NPR Event"; Boolean)
        {
            AccessByPermission = TableData Job = R;
            Caption = 'Event';
            DataClassification = CustomerContent;
            Description = 'NPR5.49';
            InitValue = true;
        }
    }
}

