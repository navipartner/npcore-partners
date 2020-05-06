table 6151368 "CS Rfid Header"
{
    // NPR5.53/CLVA  /20191121  CASE 377563 Object created - NP Capture Service
    // NPR5.54/CLVA  /20200120  CASE 379709 Added fields Closed,Location,"Transferred To","Transferred to Doc","Transferred Date" and "Transferred By"

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
        field(13;Closed;DateTime)
        {
            Caption = 'Closed';
        }
        field(14;Location;Code[10])
        {
            Caption = 'Location';
        }
        field(15;"Transferred To";Option)
        {
            Caption = 'Transferred To';
            OptionCaption = ',Sales Order,Whse. Receipt,Transfer Order';
            OptionMembers = ,"Sales Order","Whse. Receipt","Transfer Order";
        }
        field(16;"Transferred to Doc";Code[20])
        {
            Caption = 'Transferred to Doc';
        }
        field(17;"Transferred Date";DateTime)
        {
            Caption = 'Transferred Date';
        }
        field(18;"Transferred By";Code[20])
        {
            Caption = 'Transferred By';
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

