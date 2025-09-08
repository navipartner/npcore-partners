table 6151230 "NPR Job Queue Refresh Log"
{
    Access = Internal;
    Caption = 'Job Queue Refresh Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "JQ Runner User Name"; Code[50])
        {
            Caption = 'JQ Runner User Name';
            DataClassification = CustomerContent;
        }
        field(10; "Last Refreshed"; DateTime)
        {
            Caption = 'Last Refreshed';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "JQ Runner User Name")
        {
            Clustered = true;
        }
        key(Key1; "Last Refreshed")
        {
        }
    }
}
