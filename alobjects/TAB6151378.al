table 6151378 "CS Field Defaults"
{
    // NPR5.41/NPKNAV/20180427  CASE 306407 Transport NPR5.41 - 27 April 2018
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018

    Caption = 'CS Field Defaults';

    fields
    {
        field(1;Id;Code[10])
        {
            Caption = 'Id';
        }
        field(2;"Use Case Code";Code[20])
        {
            Caption = 'Use Case Code';
        }
        field(3;"Field No";Integer)
        {
            Caption = 'Field No';
        }
        field(10;Value;Text[250])
        {
            Caption = 'Value';
        }
    }

    keys
    {
        key(Key1;Id,"Use Case Code","Field No")
        {
        }
    }

    fieldgroups
    {
    }
}

