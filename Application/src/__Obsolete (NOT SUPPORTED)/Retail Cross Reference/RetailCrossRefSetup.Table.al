﻿table 6151181 "NPR Retail Cross Ref. Setup"
{
    Access = Internal;
    // NPR5.50/MHA /20190422  CASE 337539 Object created

    Caption = 'Retail Cross Reference Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Use Setup from module POS Item Reference.';

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; "Reference No. Pattern"; Code[50])
        {
            Caption = 'Reference No. Pattern';
            DataClassification = CustomerContent;
        }
        field(10; "Pattern Guide"; Text[250])
        {
            Caption = 'Pattern Guide';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Table ID")
        {
        }
    }

    fieldgroups
    {
    }
}

