table 6184893 "Storage Operation Parameter"
{
    // NPR5.54/ALST/20200311 CASE 394895 Object created

    Caption = 'Storage Operation Parameters';

    fields
    {
        field(1;"Storage Type";Text[24])
        {
            Caption = 'Storage Type';
        }
        field(10;"Operation Code";Code[20])
        {
            Caption = 'Operation Code';
        }
        field(20;"Parameter Key";Integer)
        {
            Caption = 'Key';
        }
        field(30;"Parameter Name";Text[30])
        {
            Caption = 'Name';
        }
        field(40;"Parameter Value";Text[250])
        {
            Caption = 'Parametr Value';
        }
        field(50;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(60;"Mandatory For Job Queue";Boolean)
        {
            Caption = 'Mandatory For Job Queue';
        }
    }

    keys
    {
        key(Key1;"Storage Type","Operation Code","Parameter Key")
        {
        }
    }

    fieldgroups
    {
    }
}

