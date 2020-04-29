table 6151389 "CS Temp Data"
{
    // NPR5.50/CLVA/20190309  CASE 332844 Object created

    Caption = 'CS Temp Data';

    fields
    {
        field(1;Id;Code[10])
        {
            Caption = 'Id';
        }
        field(2;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;"Decription 1";Text[250])
        {
            Caption = 'Decription 1';
        }
        field(11;"Decription 2";Text[250])
        {
            Caption = 'Decription 2';
        }
        field(12;"Decription 3";Text[250])
        {
            Caption = 'Decription 3';
        }
        field(13;"Number 1";Decimal)
        {
            Caption = 'Number 1';
        }
        field(14;"Number 2";Decimal)
        {
            Caption = 'Number 2';
        }
        field(15;"Number 3";Decimal)
        {
            Caption = 'Number 3';
        }
        field(100;"Table No.";Integer)
        {
            Caption = 'Table No.';
        }
        field(101;"Record Id";RecordID)
        {
            Caption = 'Record Id';
        }
        field(102;Handled;Boolean)
        {
            Caption = 'Handled';
        }
        field(103;Created;DateTime)
        {
            Caption = 'Created';
        }
        field(104;"Created By";Code[20])
        {
            Caption = 'Created By';
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
}

