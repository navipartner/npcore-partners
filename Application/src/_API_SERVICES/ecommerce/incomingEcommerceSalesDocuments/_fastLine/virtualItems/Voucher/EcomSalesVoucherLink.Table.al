#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
table 6059925 "NPR Ecom Sales Voucher Link"
{
    Access = Internal;
    Caption = 'Ecom Sales Voucher Link';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Source System Id"; Guid)
        {
            Caption = 'Source System Id';
            DataClassification = CustomerContent;
        }
        field(3; "Source Line System Id"; Guid)
        {
            Caption = 'Source Line System Id';
            DataClassification = CustomerContent;
        }
        field(4; "Voucher System Id"; Guid)
        {
            Caption = 'Voucher System Id';
            DataClassification = CustomerContent;
        }
        field(5; "Voucher No."; Code[20])
        {
            Caption = 'Voucher No.';
            DataClassification = CustomerContent;
        }
        field(6; "Reference No."; Text[50])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
        }
        field(7; "Voucher State"; Enum "NPR Ecom Voucher Link State")
        {
            Caption = 'Voucher State';
            DataClassification = CustomerContent;
        }
        field(8; "Voucher Type"; Code[20])
        {
            Caption = 'Voucher Type';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(BySource; "Source System Id", "Source Line System Id") { }
        key(BySourceLine; "Source Line System Id") { }
        key(BySystemId; "Voucher System Id", "Voucher State") { }
    }
}
#endif
