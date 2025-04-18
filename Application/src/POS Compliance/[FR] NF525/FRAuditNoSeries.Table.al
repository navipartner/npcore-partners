﻿table 6184851 "NPR FR Audit No. Series"
{
    Access = Internal;
    Caption = 'FR Audit No. Series';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(2; "Reprint No. Series"; Code[20])
        {
            Caption = 'Reprint No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(3; "JET No. Series"; Code[20])
        {
            Caption = 'JET No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(4; "Period No. Series"; Code[20])
        {
            Caption = 'Period No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(5; "Grand Period No. Series"; Code[20])
        {
            Caption = 'Grand Period No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(6; "Yearly Period No. Series"; Code[20])
        {
            Caption = 'Yearly Period No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; "POS Unit No.")
        {
        }
    }
}
