#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
table 6059934 "NPR Ecom Sales Coupon Link"
{
    Access = Internal;
    Caption = 'Ecom Sales Coupon Link';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; Source; Enum "NPR Ecom Sales Coupon Source")
        {
            Caption = 'Source';
            DataClassification = CustomerContent;
        }
        field(3; "Source System Id"; Guid)
        {
            Caption = 'Source System Id';
            DataClassification = CustomerContent;
        }
        field(4; "Source Line System Id"; Guid)
        {
            Caption = 'Source Line System Id';
            DataClassification = CustomerContent;
        }
        field(5; "Coupon System Id"; Guid)
        {
            Caption = 'Coupon System Id';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(BySource; "Source", "Source System Id", "Source Line System Id") { }
    }
}
#endif
