table 6151404 "NPR Magento Store"
{
    Caption = 'Magento Store';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Website Code"; Code[32])
        {
            Caption = 'Website Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Magento Website";
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
        }
        field(1024; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = CustomerContent;
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
}