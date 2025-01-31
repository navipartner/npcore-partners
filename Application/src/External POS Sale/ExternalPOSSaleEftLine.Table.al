table 6150988 "NPR External POS Sale Eft Line"
{
    DataClassification = CustomerContent;
    Extensible = False;
    Access = Internal;

    fields
    {
        field(1; "External POS Sale Entry No."; Integer)
        {
            Caption = 'External POS Sale Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "External Pos SaleLine No"; Integer)
        {
            Caption = 'External Pos SaleLine No';
            DataClassification = CustomerContent;
        }
        field(3; Base64Data; Blob)
        {
            DataClassification = CustomerContent;
        }
        field(4; "EFT Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "NP Pay";
        }
        field(5; "EFT Entry No"; Integer)
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT Transaction Request";
        }
        field(6; "Processing Type"; Option)
        {
            Caption = 'Processing Type';
            DataClassification = CustomerContent;
            OptionCaption = ',Payment,Refund,Open,Close,Auxiliary,Other,Void,Lookup,Setup,Gift Card Load';
            OptionMembers = ,PAYMENT,REFUND,OPEN,CLOSE,AUXILIARY,OTHER,VOID,LOOK_UP,SETUP,GIFTCARD_LOAD;
        }
        field(8; "EFT Reference"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'EFT Reference';
        }
    }

    keys
    {
        key(Key1; "External POS Sale Entry No.", "External Pos SaleLine No")
        {
        }
    }
}