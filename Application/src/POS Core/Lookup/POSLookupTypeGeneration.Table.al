/// <summary>
/// Table keeps information about data generation per lookup type. Generations represent stable
/// states of back-end data. Same generation means no data changed. Any time anything about data
/// changes (new row, modified row, deleted row), generation of that data must update. That way,
/// front end can keep track of data it has read and can know whether or not it needs to update
/// its own cached state. When data comes from the back end, if generation has changed, it means
/// that the back-end data has changed since last time it wasa read by the front end, and the
/// full front-end state has to be replaced from the new state in the back end.
/// 
/// The POS Lookup Method codeunit takes care of this. All exchange between front end and back
/// end includes the generation id. If back end receives an old generation id when front end
/// requests new data, back end will force a full refresh of the data and will send all the
/// rows previously sent to the front end.
/// 
/// Concrete codeunits that implement specific IPOSLookupType behaviour monitor the necessary
/// tables and if data update occurs that should invalidate front-end caches, the matching
/// data generation is increaased in this table.
/// 
/// This makes cache invalidation decisions as lightweight as possible.
/// 
/// Any cache invalidation decision based on Data Log infrastructure would potentially be
/// resource-expensive, because of very fast-moving and large tables monitored through Data
/// Log, determining whether and when a change occurred could be as expensive as determining
/// it through timestamps on the table itself. With this lightweight table, there is one record
/// per POS Lookup Type enum value, and both retrieval and update is fast.
/// </summary>
table 6014549 "NPR POS Lookup Type Generation"
{
    Caption = 'POS Lookup Type Generation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Lookup Type"; Enum "NPR POS Lookup Type")
        {
            Caption = 'Lookup Type';
            DataClassification = CustomerContent;
        }

        field(2; Generation; Integer)
        {
            Caption = 'Generation';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Primary; "Lookup Type")
        {
        }
    }

    /// <summary>
    /// Increases the generation of the specified lookup type.
    /// </summary>
    /// <param name="LookupType">Lookup type for which data generation is being increased</param>
    procedure IncreaseGeneration(LookupType: Enum "NPR POS Lookup Type")
    var
        CanModify: Boolean;
    begin
        Rec."Lookup Type" := LookupType;
        CanModify := Rec.Find('=');
        Rec.Generation += 1;
        if CanModify then
            Rec.Modify()
        else
            Rec.Insert();
    end;

    /// <summary>
    /// Retrieves current data generation for the specified lookup type.
    /// </summary>
    /// <param name="LookupType">Lookup type for which the generation is being retrieved.</param>
    /// <returns>Generation for the specified lookup type</returns>
    procedure GetGeneration(LookupType: Enum "NPR POS Lookup Type"): Integer;
    begin
        if not Rec.Get(LookupType) then;
        exit(Rec.Generation);
    end;
}
