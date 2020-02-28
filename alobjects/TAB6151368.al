table 6151368 "CS Rfid Header"
{
    // NPR5.53/CLVA  /20191121  CASE 377563 Object created - NP Capture Service

    Caption = 'CS Rfid Data By Document';

    fields
    {
        field(1;Id;Guid)
        {
            Caption = 'Id';
            Editable = false;
        }
        field(2;"Table No.";Integer)
        {
            Caption = 'Table No.';
            Editable = false;
        }
        field(3;"Record Id";RecordID)
        {
            Caption = 'Record Id';
            Editable = false;
        }
        field(10;Created;DateTime)
        {
            Caption = 'Created';
            Editable = false;
        }
        field(11;"Created By";Code[20])
        {
            Caption = 'Created By';
            Editable = false;
        }
        field(12;"Predicted Qty.";Decimal)
        {
            Caption = 'Predicted Qty.';
            Editable = false;
        }
    }

    keys
    {
        key(Key1;Id)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        Created := CurrentDateTime;
        "Created By" := UserId;
    end;
}

