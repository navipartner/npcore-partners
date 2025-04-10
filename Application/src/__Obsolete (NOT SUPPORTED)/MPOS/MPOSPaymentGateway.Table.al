﻿table 6059967 "NPR MPOS Payment Gateway"
{
    Access = Internal;
    Caption = 'MPOS Payment Gateway';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Removing MPOS Payment Gateway';

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(11; Provider; Option)
        {
            Caption = 'Provider';
            DataClassification = CustomerContent;
            OptionCaption = 'NETS,ADYEN';
            OptionMembers = NETS,ADYEN;
        }
        field(12; Decription; Text[50])
        {
            Caption = 'Decription';
            DataClassification = CustomerContent;
        }
        field(13; "Merchant Id"; Text[30])
        {
            Caption = 'Merchant Id';
            DataClassification = CustomerContent;
        }
        field(14; User; Text[30])
        {
            Caption = 'User';
            DataClassification = CustomerContent;
        }
        field(15; Password; Text[30])
        {
            Caption = 'Password';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}

