table 6151404 "NPR Magento Store"
{
    Caption = 'Magento Store';
    LookupPageId = "NPR Magento Store List";
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
        field(1030; "VAT Bus. Posting Gr. (Price)"; Code[20])
        {
            Caption = 'VAT Bus. Posting Gr. (Price)';
            TableRelation = "VAT Business Posting Group";
            DataClassification = CustomerContent;
        }
        field(6151479; "Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
        key(Key2; "Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key(Key3; SystemRowVersion)
        {
        }
#ENDIF
    }
}
