#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
table 6248182 "NPR Ecom Sales Membership Link"
{
    Access = Internal;
    Caption = 'Ecom Sales Membership Link';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { AutoIncrement = true; Caption = 'Entry No.'; }
        field(2; "Source System Id"; Guid) { Caption = 'Source System Id'; DataClassification = CustomerContent; }
        field(3; "Source Line System Id"; Guid) { Caption = 'Source Line System Id'; DataClassification = CustomerContent; }
        field(4; "Membership System Id"; Guid) { Caption = 'Membership System Id'; DataClassification = CustomerContent; }
    }
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(BySource; "Source System Id", "Source Line System Id") { }
        key(BySourceLine; "Source Line System Id", "Entry No.") { }   // Entry No. tiebreaker — deterministic FindSet order.
    }
}
#endif
