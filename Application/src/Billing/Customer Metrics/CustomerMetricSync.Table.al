/// <summary>
/// For a date metric, the row's SystemId is the event ID of the value sent for the business date.
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
        /// For a delta metric, the last source entry that the next run continues after.
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

    /// <summary>
    /// Finds the highest Last Entry No. sent for Rec.Metric, so a delta metric can continue after it.
    /// </summary>
    [InherentPermissions(PermissionObjectType::TableData, Database::"NPR Customer Metric Sync", 'r')]
    internal procedure FindLastSentEntryNo(var LastSentEntryNo: Integer): Boolean
    var
        SentMetricSync: Record "NPR Customer Metric Sync";
    begin
        SentMetricSync.ReadIsolation := IsolationLevel::UpdLock;
        SentMetricSync.SetCurrentKey(Metric, "Last Entry No.");
        SentMetricSync.SetRange(Metric, Rec.Metric);
        SentMetricSync.SetLoadFields("Last Entry No.");
        if not SentMetricSync.FindLast() then
            exit(false);
        // The locked read waits for an overlapping run to commit, but then returns the row it waited on, so it is repeated to see the position that run stored
        SentMetricSync.FindLast();
        LastSentEntryNo := SentMetricSync."Last Entry No.";
        exit(true);
    end;
}
