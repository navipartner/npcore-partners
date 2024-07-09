﻿table 6014533 "NPR Payment Method Mapper"
{
    Access = Internal;
    Caption = 'Payment Method Mapper';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Payment Method"; Code[10])
        {
            Caption = 'POS Payment Method';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method".Code;
        }
        field(10; "Fiscal Name"; Code[50])
        {
            Caption = 'Fiscal Name';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by field 11 "Fiskaly Payment Type"';
        }
        field(11; "Fiskaly Payment Type"; Enum "NPR DE Fiskaly Payment Type")
        {
            Caption = 'Fiskaly Payment Type';
            DataClassification = CustomerContent;
        }
        field(20; "DSFINVK Type"; Enum "NPR DSFINVK Payment Type")
        {
            Caption = 'DSFINVK Type';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "POS Payment Method")
        {
            Clustered = true;
        }
    }
}
