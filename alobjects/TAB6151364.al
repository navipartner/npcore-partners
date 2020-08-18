table 6151364 "CS Transfer Handling Rfid"
{
    // NPR5.55/CLVA/20200507  CASE 379709 Object created - NP Capture Service

    Caption = 'CS Transfer Handling Rfid';

    fields
    {
        field(1;Id;Guid)
        {
            Caption = 'Id';
        }
        field(10;"Rfid Header Id";Guid)
        {
            Caption = 'Rfid Header Id';
        }
        field(11;"Batch Id";Guid)
        {
            Caption = 'Batch Id';
        }
        field(12;"Request Data";BLOB)
        {
            Caption = 'Request Data';
        }
        field(14;"Response Data";BLOB)
        {
            Caption = 'Response Data';
        }
        field(15;"Batch No.";Integer)
        {
            Caption = 'Batch No.';
        }
        field(16;"Device Id";Code[10])
        {
            Caption = 'Device Id';
        }
        field(19;Tags;Integer)
        {
            Caption = 'Tags';
        }
        field(20;Handled;Boolean)
        {
            Caption = 'Handled';
        }
        field(21;Created;DateTime)
        {
            Caption = 'Created';
        }
        field(22;"Created By";Code[20])
        {
            Caption = 'Created By';
        }
        field(24;"Posting Started";DateTime)
        {
            Caption = 'Posting Started';
        }
        field(25;"Posting Ended";DateTime)
        {
            Caption = 'Posting Ended';
        }
        field(28;"Area";Option)
        {
            Caption = 'Area';
            OptionCaption = 'Shipping,Receiving';
            OptionMembers = Shipping,Receiving;
        }
    }

    keys
    {
        key(Key1;Id)
        {
        }
        key(Key2;Created)
        {
        }
    }

    fieldgroups
    {
    }
}

