tableextension 6014428 tableextension6014428 extends "Extended Text Header" 
{
    // NPR5.49/TJ  /20190218 CASE 345047 New field Event
    fields
    {
        field(6014400;"Event";Boolean)
        {
            AccessByPermission = TableData Job=R;
            Caption = 'Event';
            Description = 'NPR5.49';
            InitValue = true;
        }
    }
}

