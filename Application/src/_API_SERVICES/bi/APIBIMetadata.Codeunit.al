/// <summary>
/// Describes tables and fields for the BI API: which fields the data endpoint returns, what they are
/// called in JSON, and how they are named in English and in the language of the request.
/// The field map built here is the single source of truth for both /bi and /tablemetadata, so the
/// property names a consumer reads in the metadata always match the payload it gets from the data endpoint.
/// </summary>
codeunit 6151564 "NPR API BI Metadata"
{
    Access = Internal;

    var
        _EnglishLanguageId: Integer;
        RowVersionKeyFilterTok: Label 'timestamp*|SystemRowVersion*', Locked = true;

    #region Field map
    /// <summary>
    /// Maps field number to JSON property name for every field the BI API exposes on a table:
    /// stored fields only, so no FlowFields, FlowFilters, Blobs or media. The system id is always
    /// mapped to "id"; "rowVersion" is reserved for the row version the data endpoint adds in sync mode.
    /// </summary>
    procedure BuildFieldMap(TableNo: Integer; var Fields: Dictionary of [Integer, Text])
    var
        Field: Record Field;
        RecRef: RecordRef;
        UsedNames: List of [Text];
        JsonName: Text;
        SystemIdFieldNo: Integer;
    begin
        Clear(Fields);
        UsedNames.Add('id');
        UsedNames.Add('rowVersion');

        RecRef.Open(TableNo);
        SystemIdFieldNo := RecRef.SystemIdNo();
        RecRef.Close();

        SetPhysicalFieldFilters(Field, TableNo);
        if not Field.FindSet() then
            exit;
        repeat
            if Field."No." = SystemIdFieldNo then
                JsonName := 'id'
            else begin
                JsonName := ToJsonName(Field.FieldName);
                if (JsonName = '') or UsedNames.Contains(JsonName) then
                    JsonName := StrSubstNo('%1_%2', JsonName, Field."No.");
                UsedNames.Add(JsonName);
            end;
            Fields.Add(Field."No.", JsonName);
        until Field.Next() = 0;

        if not Fields.ContainsKey(SystemIdFieldNo) then
            Fields.Add(SystemIdFieldNo, 'id');
    end;

    /// <summary>
    /// The one definition of "a field the BI API can return". Both the data endpoint and the metadata
    /// endpoint filter with this, so the two can never disagree about which fields exist.
    /// </summary>
    procedure SetPhysicalFieldFilters(var Field: Record Field; TableNo: Integer)
    begin
        Field.Reset();
        Field.SetRange(TableNo, TableNo);
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetRange(Enabled, true);
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        Field.SetFilter(Type, '<>%1&<>%2&<>%3&<>%4', Field.Type::BLOB, Field.Type::Media, Field.Type::MediaSet, Field.Type::TableFilter);
    end;

    /// <summary>
    /// Turns an English field name into the camelCase JSON property name used by the BI API.
    /// Everything that is not a letter or a digit separates words: "VAT Bus. Posting Group" becomes
    /// "vatBusPostingGroup" and "Unit Price (LCY)" becomes "unitPriceLCY".
    /// </summary>
    procedure ToJsonName(FieldName: Text): Text
    var
        Result: TextBuilder;
        Words: List of [Text];
        Word: Text;
        IsFirstWord: Boolean;
    begin
        Words := SplitIntoWords(FieldName);
        IsFirstWord := true;
        foreach Word in Words do begin
            if IsFirstWord then
                Result.Append(LowerCaseLeadingCapitals(Word))
            else
                Result.Append(UpperCase(CopyStr(Word, 1, 1)) + CopyStr(Word, 2));
            IsFirstWord := false;
        end;
        exit(Result.ToText());
    end;

    local procedure SplitIntoWords(FieldName: Text) Words: List of [Text]
    var
        Current: TextBuilder;
        Character: Text;
        i: Integer;
    begin
        for i := 1 to StrLen(FieldName) do begin
            Character := CopyStr(FieldName, i, 1);
            if IsWordCharacter(Character) then
                Current.Append(Character)
            else
                if Current.Length() > 0 then begin
                    Words.Add(Current.ToText());
                    Clear(Current);
                end;
        end;
        if Current.Length() > 0 then
            Words.Add(Current.ToText());
    end;

    /// <summary>
    /// Lower cases the capitals a word starts with, which is what turns "VAT" into "vat" and
    /// "No" into "no". A capital that is followed by a lower case letter starts the next word inside
    /// the name and is left alone, so "SystemModifiedAt" becomes "systemModifiedAt" rather than
    /// "systemmodifiedat".
    /// </summary>
    local procedure LowerCaseLeadingCapitals(Word: Text): Text
    var
        Result: TextBuilder;
        Character: Text;
        NextCharacter: Text;
        i: Integer;
        StopLowerCasing: Boolean;
    begin
        for i := 1 to StrLen(Word) do begin
            Character := CopyStr(Word, i, 1);
            if not StopLowerCasing then begin
                if Character <> UpperCase(Character) then
                    StopLowerCasing := true
                else
                    if i > 1 then begin
                        NextCharacter := CopyStr(Word, i + 1, 1);
                        if (NextCharacter <> '') and (NextCharacter = LowerCase(NextCharacter)) and (NextCharacter <> UpperCase(NextCharacter)) then
                            StopLowerCasing := true;
                    end;
            end;

            if StopLowerCasing then
                Result.Append(Character)
            else
                Result.Append(LowerCase(Character));
        end;
        exit(Result.ToText());
    end;

    /// <summary>
    /// Whether a character belongs inside a word. Defined by exclusion, as the punctuation and
    /// whitespace Business Central uses between the words of a field name. Testing for a letter
    /// instead would have to ask whether the character has distinct upper and lower case forms,
    /// which is false for Chinese, Japanese, Thai, Hebrew and Arabic, so a field name written in one
    /// of those would produce no words at all and fall back to a bare field number.
    /// </summary>
    local procedure IsWordCharacter(Character: Text): Boolean
    var
        SeparatorsTok: Label ' .,;:!?()[]{}<>/\|@#$%^&*+=~`''"-_', Locked = true;
    begin
        if Character = '' then
            exit(false);
        exit(StrPos(SeparatorsTok, Character) = 0);
    end;
    #endregion

    #region Response language
    /// <summary>
    /// Decides which language the translated captions are returned in: the first tag of the
    /// Accept-Language header, then the language of the calling user, then English.
    /// </summary>
    procedure ResolveLanguageId(var Request: Codeunit "NPR API Request"; var LanguageTag: Text): Integer
    var
        UserPersonalization: Record "User Personalization";
        HeaderTag: Text;
        LanguageId: Integer;
    begin
        HeaderTag := GetFirstAcceptLanguageTag(Request);
        if HeaderTag <> '' then
            if not TryGetLanguageIdFromCultureName(HeaderTag, LanguageId) then
                LanguageId := 0;

        if LanguageId = 0 then begin
            UserPersonalization.ReadIsolation := IsolationLevel::ReadCommitted;
            UserPersonalization.SetLoadFields("Language ID");
            if UserPersonalization.Get(UserSecurityId()) then
                LanguageId := UserPersonalization."Language ID";
        end;

        if LanguageId = 0 then
            LanguageId := EnglishLanguageId();

        LanguageTag := GetCultureName(LanguageId);
        exit(LanguageId);
    end;

    /// <summary>
    /// True for English in any region. Comparing against 1033 alone sent en-GB and en-AU down the
    /// two pass path, which walked the whole table catalogue twice to produce an English name and an
    /// English translated name that were the same string.
    /// </summary>
    local procedure IsEnglish(LanguageId: Integer): Boolean
    var
        WindowsLanguage: Record "Windows Language";
        EnglishWindowsLanguage: Record "Windows Language";
    begin
        if LanguageId = EnglishLanguageId() then
            exit(true);
        if not WindowsLanguage.Get(LanguageId) then
            exit(false);
        if not EnglishWindowsLanguage.Get(EnglishLanguageId()) then
            exit(false);
        exit(WindowsLanguage."Primary Language ID" = EnglishWindowsLanguage."Primary Language ID");
    end;

    procedure EnglishLanguageId(): Integer
    begin
        if _EnglishLanguageId = 0 then
            _EnglishLanguageId := 1033;
        exit(_EnglishLanguageId);
    end;

    local procedure GetCultureName(LanguageId: Integer) CultureName: Text
    begin
        // An unusable language id must not fail a metadata request, so fall back to the English tag.
        if not TryGetCultureName(LanguageId, CultureName) then
            CultureName := '';
        if CultureName = '' then
            if LanguageId <> EnglishLanguageId() then
                if not TryGetCultureName(EnglishLanguageId(), CultureName) then
                    CultureName := '';
        if CultureName = '' then
            CultureName := 'en-US';
        exit(CultureName);
    end;

    // Language.GetLanguageIdFromCultureName and GetCultureName construct a CultureInfo, which throws
    // on an unknown culture name or language id. A client-supplied header must not be able to fail
    // the request, so both are called through a try function.
    [TryFunction]
    local procedure TryGetLanguageIdFromCultureName(CultureName: Text; var LanguageId: Integer)
    var
        Language: Codeunit Language;
    begin
        LanguageId := Language.GetLanguageIdFromCultureName(CultureName);
    end;

    [TryFunction]
    local procedure TryGetCultureName(LanguageId: Integer; var CultureName: Text)
    var
        Language: Codeunit Language;
    begin
        CultureName := Language.GetCultureName(LanguageId);
    end;

    local procedure GetFirstAcceptLanguageTag(var Request: Codeunit "NPR API Request"): Text
    var
        Headers: Dictionary of [Text, Text];
        HeaderKey: Text;
        HeaderValue: Text;
    begin
        Headers := Request.Headers();
        foreach HeaderKey in Headers.Keys() do
            if HeaderKey.ToLower() = 'accept-language' then begin
                HeaderValue := Headers.Get(HeaderKey);
                HeaderValue := HeaderValue.Split(',').Get(1);
                HeaderValue := HeaderValue.Split(';').Get(1);
                exit(HeaderValue.Trim());
            end;
        exit('');
    end;
    #endregion

    #region Metadata payloads
    /// <summary>
    /// The builders below switch the session language to read captions. The switch must be undone
    /// even when a caption read fails, because the API session is reused for later requests, so the
    /// work runs inside a try function and the language is restored before any error is re-raised.
    /// </summary>
    procedure GetTableListJson(var Request: Codeunit "NPR API Request") ResultJson: JsonObject
    var
        PreviousLanguageId: Integer;
        LastError: Text;
        Built: Boolean;
    begin
        PreviousLanguageId := GlobalLanguage();
        Built := TryBuildTableListJson(Request, ResultJson);
        if not Built then
            LastError := GetLastErrorText();
        GlobalLanguage(PreviousLanguageId);
        if not Built then
            Rethrow(LastError);
    end;

    [TryFunction]
    local procedure TryBuildTableListJson(var Request: Codeunit "NPR API Request"; var ResultJson: JsonObject)
    var
        TableMetadata: Record "Table Metadata";
        BIAccess: Codeunit "NPR API BI Access";
        PrincipalType: Enum "NPR API BI Principal Type";
        PrincipalId: Guid;
        EnglishCaptions: Dictionary of [Integer, Text];
        AllowedTables: Dictionary of [Integer, Boolean];
        SyncTables: Dictionary of [Integer, Boolean];
        TableJson: JsonObject;
        DataArray: JsonArray;
        LanguageTag: Text;
        LanguageId: Integer;
    begin
        LanguageId := ResolveLanguageId(Request, LanguageTag);
        if BIAccess.ResolvePrincipal(PrincipalType, PrincipalId) then
            AllowedTables := BIAccess.GetAllowedTables(PrincipalType, PrincipalId);
        SyncTables := GetTablesWithRowVersionKey();

        SetSupportedTableFilters(TableMetadata, BIAccess.FirstSystemTableNo());

        if not IsEnglish(LanguageId) then begin
            GlobalLanguage(EnglishLanguageId());
            if TableMetadata.FindSet() then
                repeat
                    EnglishCaptions.Add(TableMetadata.ID, TableMetadata.Caption);
                until TableMetadata.Next() = 0;
        end;

        GlobalLanguage(LanguageId);
        if TableMetadata.FindSet() then
            repeat
                Clear(TableJson);
                TableJson.Add('tableNo', TableMetadata.ID);
                if EnglishCaptions.ContainsKey(TableMetadata.ID) then
                    TableJson.Add('name', EnglishCaptions.Get(TableMetadata.ID))
                else
                    TableJson.Add('name', TableMetadata.Caption);
                TableJson.Add('translatedName', TableMetadata.Caption);
                TableJson.Add('systemName', TableMetadata.Name);
                TableJson.Add('allowed', AllowedTables.ContainsKey(TableMetadata.ID));
                TableJson.Add('syncSupported', SyncTables.ContainsKey(TableMetadata.ID));
                TableJson.Add('dataPerCompany', TableMetadata.DataPerCompany);
                DataArray.Add(TableJson);
            until TableMetadata.Next() = 0;

        ResultJson.Add('language', LanguageTag);
        ResultJson.Add('data', DataArray);
    end;

    procedure GetTableJson(var Request: Codeunit "NPR API Request"; TableNo: Integer) ResultJson: JsonObject
    var
        PreviousLanguageId: Integer;
        LastError: Text;
        Built: Boolean;
    begin
        PreviousLanguageId := GlobalLanguage();
        Built := TryBuildTableJson(Request, TableNo, ResultJson);
        if not Built then
            LastError := GetLastErrorText();
        GlobalLanguage(PreviousLanguageId);
        if not Built then
            Rethrow(LastError);
    end;

    [TryFunction]
    local procedure TryBuildTableJson(var Request: Codeunit "NPR API Request"; TableNo: Integer; var ResultJson: JsonObject)
    var
        Field: Record Field;
        TableMetadata: Record "Table Metadata";
        BIAccess: Codeunit "NPR API BI Access";
        PrincipalType: Enum "NPR API BI Principal Type";
        PrincipalId: Guid;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        Fields: Dictionary of [Integer, Text];
        EnglishFieldCaptions: Dictionary of [Integer, Text];
        FieldJson: JsonObject;
        FieldsArray: JsonArray;
        LanguageTag: Text;
        EnglishTableCaption: Text;
        LanguageId: Integer;
        FieldNo: Integer;
        Allowed: Boolean;
        TranslateCaptions: Boolean;
    begin
        LanguageId := ResolveLanguageId(Request, LanguageTag);
        if BIAccess.ResolvePrincipal(PrincipalType, PrincipalId) then
            Allowed := BIAccess.IsTableAllowed(PrincipalType, PrincipalId, TableNo);

        TableMetadata.SetLoadFields(DataPerCompany);
        TableMetadata.Get(TableNo);

        RecRef.Open(TableNo);
        BuildFieldMap(TableNo, Fields);
        TranslateCaptions := not IsEnglish(LanguageId);

        if TranslateCaptions then begin
            GlobalLanguage(EnglishLanguageId());
            EnglishTableCaption := RecRef.Caption();
            foreach FieldNo in Fields.Keys() do
                EnglishFieldCaptions.Add(FieldNo, RecRef.Field(FieldNo).Caption());
        end;

        GlobalLanguage(LanguageId);
        if not TranslateCaptions then
            EnglishTableCaption := RecRef.Caption();

        ResultJson.Add('tableNo', TableNo);
        ResultJson.Add('name', EnglishTableCaption);
        ResultJson.Add('translatedName', RecRef.Caption());
        ResultJson.Add('systemName', RecRef.Name());
        ResultJson.Add('allowed', Allowed);
        ResultJson.Add('syncSupported', Request.HasRowVersionKey(RecRef));
        ResultJson.Add('dataPerCompany', TableMetadata.DataPerCompany);
        ResultJson.Add('language', LanguageTag);

        SetPhysicalFieldFilters(Field, TableNo);
        if Field.FindSet() then
            repeat
                FieldRef := RecRef.Field(Field."No.");
                Clear(FieldJson);
                FieldJson.Add('fieldNo', Field."No.");
                if EnglishFieldCaptions.ContainsKey(Field."No.") then
                    FieldJson.Add('name', EnglishFieldCaptions.Get(Field."No."))
                else
                    FieldJson.Add('name', FieldRef.Caption());
                FieldJson.Add('translatedName', FieldRef.Caption());
                FieldJson.Add('systemName', Field.FieldName);
                FieldJson.Add('jsonName', Fields.Get(Field."No."));
                FieldJson.Add('type', GetTypeName(FieldRef));
                if FieldRef.Type() in [FieldRef.Type::Code, FieldRef.Type::Text] then
                    FieldJson.Add('length', FieldRef.Length());
                FieldJson.Add('isPartOfPrimaryKey', Field.IsPartOfPrimaryKey);
                FieldsArray.Add(FieldJson);
            until Field.Next() = 0;

        RecRef.Close();

        ResultJson.Add('fields', FieldsArray);
    end;

    procedure SetSupportedTableFilters(var TableMetadata: Record "Table Metadata"; FirstSystemTableNo: Integer)
    begin
        TableMetadata.Reset();
        TableMetadata.SetLoadFields(ID, Name, Caption, DataPerCompany, TableType, ObsoleteState);
        TableMetadata.SetRange(TableType, TableMetadata.TableType::Normal);
        TableMetadata.SetFilter(ObsoleteState, '<>%1', TableMetadata.ObsoleteState::Removed);
        TableMetadata.SetFilter(ID, '<%1', FirstSystemTableNo);
    end;

    /// <summary>
    /// Re-raises the error a try function swallowed, once the session language has been put back.
    /// The caller reads the text before restoring the language, so nothing in between can clear it,
    /// and passes it as a parameter so a percent sign in it is never read as a placeholder.
    /// </summary>
    local procedure Rethrow(LastError: Text)
    var
        UnknownFailureErr: Label 'The BI API could not build the table metadata.', Locked = true;
    begin
        if LastError = '' then
            Error(UnknownFailureErr);
        Error('%1', LastError);
    end;

    local procedure GetTypeName(var FieldRef: FieldRef): Text
    begin
        if FieldRef.IsEnum() then
            exit('Enum');
        exit(Format(FieldRef.Type()));
    end;

    /// <summary>
    /// The tables that can be read in sync mode, i.e. the ones with a key that starts with
    /// SystemRowVersion. Read in one pass over the key metadata, because opening a RecordRef per
    /// table would be far too expensive for a list of every table in the database.
    /// </summary>
    /// <summary>
    /// The tables that can be read in sync mode. This has to agree with
    /// "NPR API Request".HasRowVersionKey, which walks the keys of a RecordRef and does not look at
    /// whether a key is enabled, so this does not filter on that either. Reporting a table as sync
    /// capable when its key is disabled costs a slow read; reporting the two differently would make
    /// the list contradict the read, which is worse.
    /// </summary>
    local procedure GetTablesWithRowVersionKey() TableNos: Dictionary of [Integer, Boolean]
    var
        TableKey: Record "Key";
    begin
        TableKey.SetFilter("Key", RowVersionKeyFilterTok);
        if not TableKey.FindSet() then
            exit;
        repeat
            if IsRowVersionKey(TableKey."Key") then
                if not TableNos.ContainsKey(TableKey.TableNo) then
                    TableNos.Add(TableKey.TableNo, true);
        until TableKey.Next() = 0;
    end;

    /// <summary>
    /// The key metadata renders a key as a comma separated list of field names. BC28 calls the row
    /// version field by its original name "timestamp", and both spellings are accepted here so a
    /// later platform version can rename it without breaking this. Only a key whose FIRST field is
    /// that one can be used for delta load, which is the rule
    /// "NPR API Request".HasRowVersionKey applies to a RecordRef.
    /// </summary>
    local procedure IsRowVersionKey(KeyText: Text): Boolean
    var
        FirstFieldName: Text;
        SeparatorPosition: Integer;
    begin
        FirstFieldName := KeyText;
        SeparatorPosition := StrPos(FirstFieldName, ',');
        if SeparatorPosition > 0 then
            FirstFieldName := CopyStr(FirstFieldName, 1, SeparatorPosition - 1);
        FirstFieldName := LowerCase(FirstFieldName.Trim());

        exit((FirstFieldName = 'timestamp') or (FirstFieldName = 'systemrowversion'));
    end;
    #endregion
}
