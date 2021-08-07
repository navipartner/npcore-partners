/// <summary>
/// Responds to LookupFromPOS custom method.
/// Retrieves lookup data from specified table, and does paging if necessary. The lookup data is, for example, when during
/// balancing, a user wants to look up a bank deposit bin code. It replaces typical TableRelation situations, only in POS.
/// </summary>
codeunit 6014570 "NPR POS Lookup Method"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    local procedure OnPreSearch(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        Json: Codeunit "NPR POS JSON Management";
        Data: Codeunit "NPR POS Lookup Data Set";
        LookupTypeText: Text;
        LookupTypeEnum: Enum "NPR POS Lookup Type";
        Generation: Integer;
        Skip: Integer;
        BatchSize: Integer;
        FetchType: Integer;
        LoadAll: Boolean;
        RetrievingLookupTypeLbl: Label 'Retrieving lookup type during LookupFromPOS';
    begin
        if Method <> 'LookupFromPOS' then
            exit;

        Handled := true;

        Json.InitializeJObjectParser(Context, FrontEnd);

        Generation := Json.GetInteger('generation');
        LookupTypeText := Json.GetStringOrFail('type', RetrievingLookupTypeLbl);
        LookupTypeEnum := LookupTypeFromTextToEnum(LookupTypeText, FrontEnd);
        Skip := Json.GetInteger('skip');
        BatchSize := Json.GetInteger('batchSize');
        FetchType := Json.GetInteger('fetchType');
        LoadAll := Json.GetBoolean('loadAll');
        if BatchSize <= 0 then
            BatchSize := 120;

        Data.SetLookupType(LookupTypeText);
        ProcessLookup(Generation, Skip, BatchSize, LoadAll, FetchType, LookupTypeEnum, Data);

        FrontEnd.RespondToFrontEndMethod(Context, Data.GetJson(), FrontEnd);
    end;

    /// <summary>
    /// Processes the lookup logic.
    /// This function retrieves the correct lookup type interface, then uses that interface to initialize the data iteration.
    /// After the data iteration is initialized, this function iterates through records and populates the data set to be passed
    /// to the front end.
    /// </summary>
    /// <param name="FrontEndGeneration">Data generation "known" to the front end</param>
    /// <param name="Skip">Number of records to skip (this is the count of records already retrieved by the front end)</param>
    /// <param name="BatchSize">Size of batch. The result data set won't contain more than this many records.</param>
    /// <param name="LoadAll">Indicates whether all records must be loaded regardless of the batch size.</param>
    /// <param name="FetchType">Specifies how data is to be fetched. Different fetch types are invoked from different places in the front-end (check Dragonglass project documentation, constant FETCH_TYPE for more details.</param>
    /// <param name="LookupTypeEnum">Lookup type to use for processing</param>
    /// <param name="Data">Resulting data set instance to populate data into</param>
    local procedure ProcessLookup(FrontEndGeneration: Integer; Skip: Integer; BatchSize: Integer; LoadAll: Boolean; FetchType: Option FetchFirstBatch,UpdateIfNeeded,FetchNextBatch; LookupTypeEnum: Enum "NPR POS Lookup Type"; Data: Codeunit "NPR POS Lookup Data Set")
    var
        LookupTypeGeneration: Record "NPR POS Lookup Type Generation";
        RecRef: RecordRef;
        LookupType: Interface "NPR IPOSLookupType";
        Row: JsonObject;
        ReadCount: Integer;
        BackEndGeneration: Integer;
        HasMore: Boolean;
    begin
        LookupType := LookupTypeEnum;

        LookupType.InitializeDataRead(RecRef);
        BackEndGeneration := LookupTypeGeneration.GetGeneration(LookupTypeEnum);
        if Data.ShouldDoFullRefresh(BackEndGeneration, FrontEndGeneration) then begin
            // If full refresh is needed (generations are different) then we must modify the BatchSize and Skip parameter values!
            case FetchType of
                FetchType::UpdateIfNeeded:
                    BatchSize := Skip; // We only update known rows, but don't fetch more
                FetchType::FetchNextBatch:
                    BatchSize += Skip; // We update known rows, and fetch one more batch
            end;
            Skip := 0; // And finally we reset the starting position to make sure to start reading from the first row
        end else begin
            // If this is the first batch requested by the front end, and front-end and back-end generations are equal, no update is needed
            // Keep in mind that for the very first front-end call (empty redux lookup cache), front-end generation is always -1 so full refresh will have been requested, so this else block cannot happen
            if FetchType = FetchType::FetchFirstBatch then
                exit;
        end;

        if not RecRef.FindSet(false) then
            exit;

        if Skip > 0 then begin
            if RecRef.Next(Skip) < Skip then
                exit;
        end;

        while true do begin
            Row := LookupType.GetLookupEntry(RecRef);
            Data.AddRow(Row);
            ReadCount += 1;
            HasMore := RecRef.Next() <> 0;
            if ((ReadCount = BatchSize) and (not LoadAll)) or (not HasMore) then
                break;
        end;

        if HasMore then
            Data.SetMoreDataAvailable(true);
    end;

    /// <summary>
    /// Converts a lookup type identified by text (coming from front end) into enum (for the back end).
    /// </summary>
    /// <param name="AsText">Text identifier of the lookup type</param>
    /// <param name="FrontEnd">Front End Management instance to handle errors if they should happen</param>
    /// <returns>Enum representation of the lookup type</returns>
    local procedure LookupTypeFromTextToEnum(AsText: Text; FrontEnd: Codeunit "NPR POS Front End Management") AsEnum: enum "NPR POS Lookup Type"
    var
        Index: Integer;
        AsInteger: Integer;
        InvalidLookupTypeErr: Label 'Invalid lookup type requested: %1';
    begin
        Index := AsEnum.Names.IndexOf(AsText);
        if Index = 0 then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(InvalidLookupTypeErr, AsText));

        AsInteger := AsEnum.Ordinals.Get(Index);
        AsEnum := Enum::"NPR POS Lookup Type".FromInteger(AsInteger);
    end;
}
