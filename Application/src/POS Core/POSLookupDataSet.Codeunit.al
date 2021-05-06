/// <summary>
/// Represents a data set for POS Lookup custom method. It contains internal data set state and serializes
/// into JSON structure expected by the POS front-end lookup handler.
/// </summary>
codeunit 6014572 "NPR POS Lookup Data Set" implements "NPR IJsonSerializable"
{
    var
        ResultSet: JsonArray;
        FullRefresh: Boolean;
        MoreDataAvailable: Boolean;
        Timestamp: BigInteger;
        LookupContextId: Text;

    /// <summary>
    /// Adds a row to the lookup data set
    /// </summary>
    /// <param name="Row">Row of data</param>
    procedure AddRow(Row: JsonObject)
    begin
        ResultSet.Add(Row);
    end;

    /// <summary>
    /// Specifies that the full refresh of the data is needed in the front end. When this is true, the data set
    /// being sent to the front end is not incremental page, but starts at page 0. Also, when receiving such a
    /// data set, front end doesn't update redux state, but replaces it.
    /// </summary>
    /// <param name="FullRefreshIn">Indicates whether full front-end state refresh is needed</param>
    procedure SetFullRefresh(NewFullRefresh: Boolean)
    begin
        FullRefresh := NewFullRefresh;
    end;

    /// <summary>
    /// Specifies that there is more data available, and that front end should request the next page of data when
    /// the user reaches the end of the data set in the lookup box.
    /// </summary>
    /// <param name="MoreDataAvailableIn">Indicates whether there is more data available in the back end</param>
    procedure SetMoreDataAvailable(NewMoreDataAvailable: Boolean)
    begin
        MoreDataAvailable := NewMoreDataAvailable;
    end;

    /// <summary>
    /// Specifies the timestamp of the last record in the back-end data set. This is used by both front end and
    /// back end to keep track of when the state needs refreshing.
    /// </summary>
    /// <param name="TimestampIn">Contains the last timestamp of the back-end data table</param>
    procedure SetTimestamp(NewTimestamp: BigInteger)
    begin
        Timestamp := NewTimestamp;
    end;

    /// <summary>
    /// Specifies the lookup context of this data set. Lookup context is used by the front end to control which
    /// part of redux state should be affected by the data update method invocation.
    /// </summary>
    /// <param name="NewLookupContextId">LookupContextId for the front end</param>
    procedure SetLookupContextId(NewLookupContextId: Text)
    begin
        LookupContextId := NewLookupContextId;
    end;

    /// <summary>
    /// Implements IJsonSerializable.
    /// </summary>
    procedure GetJson() Result: JsonObject;
    begin
        Result.Add('lookupContextId', LookupContextId);
        Result.Add('fullRefresh', FullRefresh);
        Result.Add('page', LookupContextId);
        Result.Add('moreDataAvailable', MoreDataAvailable);
        Result.Add('timestamp', Timestamp);
        Result.Add('data', ResultSet);
    end;
}
