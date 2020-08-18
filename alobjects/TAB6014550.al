table 6014550 "Package Module Configuration"
{
    // NPR-Package1.0, NPK, DL, 04-04-08, Table created
    //                      DL, 02-05-08, Added fields 13-15

    Caption = 'Package Module Configuration';

    fields
    {
        field(1;"Key";Code[10])
        {
            Caption = 'Key';
        }
        field(2;"Normal No. Series";Code[10])
        {
            Caption = 'Normal package label numbers';
            Description = 'Package Number Series (normal pakke)';
            TableRelation = "No. Series";
        }
        field(3;"COD No. Series";Code[10])
        {
            Caption = 'Cash on delivery package numbers';
            Description = 'Package Number Series for cash on delivery (postopkrævning)';
            TableRelation = "No. Series";
        }
        field(4;"Has EDI contract";Boolean)
        {
            Caption = 'Has EDI contract';
        }
        field(5;"Barcode39 Path";Text[140])
        {
            Caption = 'Path to Barcode39';
            Description = 'Path to package label programme';
        }
        field(6;"EDI Sender Identifier";Text[20])
        {
            Caption = 'Package EDI sender identification';
            Description = 'Unique sender identification for the company';
        }
        field(7;"EDI Sender SMS";Boolean)
        {
            Caption = 'SMS to sender';
            Description = 'Send sms to package sender';
        }
        field(8;"EDI Recipient SMS";Boolean)
        {
            Caption = 'SMS to recipient';
            Description = 'Send sms to package receiver';
        }
        field(9;"EDI Sender Email";Boolean)
        {
            Caption = 'Email to sender';
            Description = 'Send email to package sender';
        }
        field(10;"EDI Recipient Email";Boolean)
        {
            Caption = 'Email to recipient';
            Description = 'Send email to package receiver';
        }
        field(11;"EDI FTP username";Text[30])
        {
            Caption = 'EDI FTP Username';
        }
        field(12;"EDI FTP password";Text[30])
        {
            Caption = 'EDI FTP Password';
        }
        field(13;"Business Service Code";Code[10])
        {
            Caption = 'Business shipping agent service code';
            Description = 'Shipping agent service code for business';
            TableRelation = "Shipping Agent Services".Code;
        }
        field(14;"Private Service Code";Code[10])
        {
            Caption = 'Private shipping agent service code';
            Description = 'Shipping agent service code for private';
            TableRelation = "Shipping Agent Services".Code;
        }
        field(15;"CV No. Series";Code[10])
        {
            Caption = 'Recipient receipt package numbers';
            Description = 'Package Number Series for recipient receipt (modtagerkvittering)';
        }
        field(16;"DHL No. Series";Code[10])
        {
            Caption = 'DHL package label numbers';
            Description = 'Package Number Series (DHL pakke)';
            TableRelation = "No. Series";
        }
        field(17;"DHL AWB No. Series";Code[10])
        {
            Caption = 'DHL AWB package label numbers';
            Description = 'Package Number Series (DHL pakke)';
            TableRelation = "No. Series";
        }
        field(18;"DHL Customer No";Code[20])
        {
            Caption = 'DHL Customer No';
        }
        field(19;"DHL ftp address";Text[60])
        {
            Caption = 'DHL FTP Address';
        }
        field(20;"DHL ftp username";Text[30])
        {
            Caption = 'DHL FTP Username';
        }
        field(21;"DHL ftp password";Text[30])
        {
            Caption = 'DHL FTP Password';
        }
    }

    keys
    {
        key(Key1;"Key")
        {
        }
    }

    fieldgroups
    {
    }
}

