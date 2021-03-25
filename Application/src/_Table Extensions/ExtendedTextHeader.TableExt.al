tableextension 6014428 "NPR Extended Text Header" extends "Extended Text Header"
{
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