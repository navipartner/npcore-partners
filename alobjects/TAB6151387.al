table 6151387 "CS Devices"
{
    // NPR5.48/CLVA/20181227 CASE 247747 Object created
    // NPR5.50/CLVA/20190201 CASE 346068 Added field "Refresh Item Catalog" and Location
    //                                   Renamed fields:
    //                                   12: Last Tag DB Download > Last Download Timestamp
    //                                   13: Current Tag DB Download > Current Download Timestamp

    Caption = 'CS Devices';

    fields
    {
        field(1;"Device Id";Code[10])
        {
            Caption = 'Device Id';
        }
        field(10;Created;DateTime)
        {
            Caption = 'Created';
        }
        field(11;Heartbeat;DateTime)
        {
            Caption = 'Heartbeat';
        }
        field(12;"Last Download Timestamp";BigInteger)
        {
            Caption = 'Last Download Timestamp';
        }
        field(13;"Current Download Timestamp";BigInteger)
        {
            Caption = 'Current Download Timestamp';
        }
        field(14;"Current Tag Count";Integer)
        {
            Caption = 'Current Tag Count';
        }
        field(15;"Refresh Item Catalog";Boolean)
        {
            Caption = 'Refresh Item Catalog';
        }
        field(16;Location;Code[20])
        {
            Caption = 'Location';
        }
    }

    keys
    {
        key(Key1;"Device Id")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        Created := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        Heartbeat := CurrentDateTime;
    end;
}

