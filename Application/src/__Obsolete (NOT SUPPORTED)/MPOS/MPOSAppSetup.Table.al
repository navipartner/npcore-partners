﻿table 6059966 "NPR MPOS App Setup"
{
    Access = Internal;
    Caption = 'MPOS App Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'This table won''t be used anymore.';

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(11; "Payment Gateway"; Code[10])
        {
            Caption = 'Payment Gateway';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(12; "Web Service Is Published"; Boolean)
        {
            CalcFormula = Exist("Web Service Aggregate" WHERE("Object Type" = CONST(Codeunit),
                                                     "Service Name" = CONST('mpos_service')));
            Caption = 'Web Service Is Published';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "Ticket Admission Web Url"; Text[250])
        {
            Caption = 'Ticket Admission Web Url';
            DataClassification = CustomerContent;
        }
        field(16; "Receipt Web API"; Text[250])
        {
            Caption = 'Receipt Web API';
            DataClassification = CustomerContent;
        }
        field(17; "Custom Web Service URL"; Text[250])
        {
            Caption = 'Custom Web Service URL';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'This field won''t be used anymore.';
        }
        field(18; "Receipt Source Type"; Option)
        {
            Caption = 'Receipt Source Type';
            DataClassification = CustomerContent;
            OptionCaption = 'NAV,Magento';
            OptionMembers = NAV,Magento;
        }
        field(19; "Encryption Key"; Text[30])
        {
            Caption = 'Encryption Key';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(100; Enable; Boolean)
        {
            Caption = 'Enable';
            DataClassification = CustomerContent;
        }
        field(1000; "Handle EFT Print in NAV"; Boolean)
        {
            Caption = 'Handle EFT Print in NAV';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'We always print mpos EFT receipts from NAV now';
        }
    }

    keys
    {
        key(Key1; "Register No.")
        {
        }
    }
}
