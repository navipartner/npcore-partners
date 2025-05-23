﻿table 6184500 "NPR CleanCash Setup"
{
    Access = Internal;

    Caption = 'CleanCash Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Register; Code[20])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(2; "Connection String"; Text[100])
        {
            Caption = 'Connection String';
            DataClassification = CustomerContent;
        }
        field(3; "Organization ID"; Text[10])
        {
            Caption = 'Organization ID';
            DataClassification = CustomerContent;
        }
        field(4; "Last Z Reort Date"; Date)
        {
            Caption = 'Last Report Date';
            DataClassification = CustomerContent;
            ObsoleteReason = 'This field is not used anymore';
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
        }
        field(5; "Last Z Report Time"; Time)
        {
            Caption = 'Last Report Time';
            DataClassification = CustomerContent;
        }
        field(6; "Multi Organization ID Per POS"; Boolean)
        {
            Caption = 'Multi Organization ID Per POS';
            DataClassification = CustomerContent;
            ObsoleteReason = 'This field is not used anymore';
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
        }
        field(7; Training; Boolean)
        {
            Caption = 'Training';
            DataClassification = CustomerContent;
        }
        field(8; "Show Error Message"; Boolean)
        {
            Caption = 'Show Error Message';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(9; "CleanCash Register No."; Text[16])
        {
            Caption = 'CleanCash POS Unit No.';
            DataClassification = CustomerContent;

        }

        field(20; "CleanCash No. Series"; Code[20])
        {
            Caption = 'CleanCash No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }

        field(10; "Run Local"; Boolean)
        {
            Caption = 'Run Local';
            DataClassification = CustomerContent;
            Description = 'Used to tell where the CleanCashAPI dll is placed (third part application)';
            ObsoleteReason = 'This field is not used anymore';
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
        }
    }

    keys
    {
        key(Key1; Register)
        {
        }
    }

    trigger OnInsert()
    begin
        if Rec."CleanCash Register No." = '' then
            Rec."CleanCash Register No." := CopyStr(Register, 1, MaxStrLen(Rec."CleanCash Register No."));
    end;
}
