/// <summary>
/// A source entry a delta metric passed while it could still change, so a later run counts it once it does.
/// </summary>
table 6060035 "NPR Customer Metric Open Entry"
{
    Access = Internal;
    Caption = 'Customer Metric Open Entry';
    DataClassification = CustomerContent;
    Extensible = false;

    fields
    {
        field(1; Metric; Enum "NPR Customer Metric")
        {
            Caption = 'Metric';
            DataClassification = CustomerContent;
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Metric, "Entry No.")
        {
            Clustered = true;
        }
    }
}
