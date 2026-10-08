/// <summary>
/// The row's SystemId is the event ID of the metric sent for the business date.
/// </summary>
table 6059943 "NPR Customer Metric Sync"
{
    Access = Internal;
    Caption = 'Customer Metric Sync';
    DataClassification = CustomerContent;
    Extensible = false;

    fields
    {
        field(1; Metric; Enum "NPR Customer Metric")
        {
            Caption = 'Metric';
            DataClassification = CustomerContent;
        }
        field(2; "Business Date"; Date)
        {
            Caption = 'Business Date';
            DataClassification = CustomerContent;
        }
        /// <summary>
        /// For a delta metric, the last source entry the event covers.
        /// </summary>
        field(3; "Last Entry No."; Integer)
        {
            Caption = 'Last Entry No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Metric, "Business Date")
        {
            Clustered = true;
        }
        key(LastEntryNo; Metric, "Last Entry No.")
        {
        }
    }
}
