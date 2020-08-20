table 6151404 "Magento Store"
{
    // MAG1.01/MHA /20150113  CASE 199932 Object created
    // MAG1.13/MHA /20150401  CASE 210548 Changed Primary Key from Field1,Field5 to Field5
    // MAG1.21/TS  /20151118  CASE 227359 Added Field Root Item Group No.
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.07/TS  /20170830  CASE 262530 Added Field 1024 Language Code

    Caption = 'Magento Store';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Website Code"; Code[32])
        {
            Caption = 'Website Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Magento Website";
        }
        field(5; "Code"; Code[32])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Name; Text[64])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(15; "Root Item Group No."; Code[20])
        {
            Caption = 'Root Item Group No.';
            DataClassification = CustomerContent;
            Description = 'MAG1.21';
        }
        field(1024; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = CustomerContent;
            Description = 'MAG2.07';
            NotBlank = true;
            TableRelation = Language;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

