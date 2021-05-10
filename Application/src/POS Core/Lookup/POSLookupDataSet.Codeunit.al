/// <summary>
/// Represents a data set for POS Lookup custom method. It contains internal data set state and serializes
/// into JSON structure expected by the POS front-end lookup handler.
/// </summary>
codeunit 6014572 "NPR POS Lookup Data Set" implements "NPR IJsonSerializable"
{
    var
        ResultSet: JsonArray;
        Generation: Integer;
        FullRefresh: Boolean;
        MoreDataAvailable: Boolean;
        LookupType: Text;

    /// <summary>
    /// Adds a row to the lookup data set
    /// </summary>
    /// <param name="Row">Row of data</param>
    procedure AddRow(Row: JsonObject)
    begin
        ResultSet.Add(Row);
    end;

    /// <summary>
    /// Compares the back-end and front-end generations to decide whether full data update should be required in
    /// the front end. It records this information in the data set, and returns the decision to the caller.
    /// </summary>
    /// <param name="BackEndGeneration">The back-end generation of the data</param>
    /// <param name="FrontEndGeneration">The front-end generation of the data</param>
    /// <returns>Boolean value indicating whether full refresh is needed. If so, the lookup infrastructure starts data retrieval from scratch.</returns>
    procedure ShouldDoFullRefresh(BackEndGeneration: Integer; FrontEndGeneration: Integer): Boolean;
    begin
        FullRefresh := BackEndGeneration > FrontEndGeneration;
        Generation := BackEndGeneration;
        exit(FullRefresh);
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
    /// Specifies the lookup type of this data set. It always matches the type of request, and front end uses the
    /// type to select the state subtree which to update after receiving data set update request.
    /// </summary>
    /// <param name="NewLookupType">LookupType for the front end</param>
    procedure SetLookupType(NewLookupType: Text)
    begin
        LookupType := NewLookupType;
    end;

    /// <summary>
    /// Implements IJsonSerializable.
    /// </summary>
    procedure GetJson() Result: JsonObject;
    begin
        Result.Add('type', LookupType);
        Result.Add('fullRefresh', FullRefresh);
        Result.Add('generation', Generation);
        Result.Add('moreDataAvailable', MoreDataAvailable);
        Result.Add('data', ResultSet);
    end;
}
