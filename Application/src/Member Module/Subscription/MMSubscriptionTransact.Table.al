table 6150919 "NPR MM Subscription Transact."
{
    Access = Internal;
    Caption = 'Subscription Transaction';
    DataClassification = CustomerContent;
    //DrillDownPageId = ;
    //LookupPageId = ;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}