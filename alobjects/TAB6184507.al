table 6184507 "EFT Shopper Recognition"
{
    // NPR5.49/MMV /20190401 CASE 345188 Created object

    Caption = 'EFT Shopper Recognition';

    fields
    {
        field(1;"Integration Type";Text[50])
        {
            Caption = 'Integration Type';
        }
        field(2;"Shopper Reference";Text[50])
        {
            Caption = 'Shopper Reference';
        }
        field(3;"Contract ID";Text[50])
        {
            Caption = 'Contract ID';
        }
        field(4;"Contract Type";Text[50])
        {
            Caption = 'Contract Type';
        }
        field(10;"Entity Type";Option)
        {
            Caption = 'Entity Type';
            OptionCaption = 'Customer,Contact';
            OptionMembers = Customer,Contact;
        }
        field(11;"Entity Key";Code[20])
        {
            Caption = 'Entity Key';
            TableRelation = IF ("Entity Type"=CONST(Customer)) Customer."No."
                            ELSE IF ("Entity Type"=CONST(Contact)) Contact."No.";
        }
    }

    keys
    {
        key(Key1;"Integration Type","Shopper Reference")
        {
        }
        key(Key2;"Entity Type","Entity Key")
        {
        }
    }

    fieldgroups
    {
    }
}

