table 6151289 "NPR BG SIS POS Sale"
{
    Access = Internal;
    Caption = 'BG SIS POS Sale';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Sale SystemId"; Guid)
        {
            Caption = 'POS Sale SystemId';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Sale".SystemId;
        }
        field(2; "Return Receipt Timestamp"; Text[30])
        {
            Caption = 'Return Receipt Timestamp';
            DataClassification = CustomerContent;
        }
        field(3; "Return FP Memory No."; Text[8])
        {
            Caption = 'Return Fiscal Printer Memory No.';
            DataClassification = CustomerContent;
        }
        field(4; "Return FP Device No."; Text[8])
        {
            Caption = 'Return Fiscal Printer Device No.';
            DataClassification = CustomerContent;
        }
        field(5; "Return Ext. Receipt Counter"; Code[20])
        {
            Caption = 'Extended Receipt Counter';
            DataClassification = CustomerContent;
        }
        field(6; "Return Grand Receipt No."; Text[10])
        {
            Caption = 'Return Grand Receipt No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "POS Sale SystemId")
        {
            Clustered = true;
        }
    }

}