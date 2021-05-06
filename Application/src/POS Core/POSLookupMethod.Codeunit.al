/// <summary>
/// Responds to LookupFromPOS custom method.
/// Retrieves lookup data from specified table, and does paging if necessary. The lookup data is, for example, when during
/// balancing, a user wants to look up a bank deposit bin code. It replaces typical TableRelation situations, only in POS.
/// For the lookup to be as optimal as possible, the tables being looked up should contain a timestamp column.
/// Page size is hardcoded at 40 rows. This is good enough for lookup fuctionality.
/// </summary>
codeunit 6014570 "NPR POS Lookup Method"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    local procedure OnPreSearch(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        Json: Codeunit "NPR POS JSON Management";
        Data: Codeunit "NPR POS Lookup Data Set";
        Request: Codeunit "NPR Front-End: Generic";
        LookupType: Text;
        LookupContextId: Text;
        LastKnownTimestamp: BigInteger;
        StartAtPage: Integer;
        RetrievingLookupTypeLbl: Label 'Retrieving lookup type during LookupFromPOS';
        InvalidLookupTypeErr: Label 'Invalid lookup type requested: %1';
    begin
        if Method <> 'LookupFromPOS' then
            exit;

        Handled := true;

        Json.InitializeJObjectParser(Context, FrontEnd);
        LookupType := Json.GetStringOrFail('type', RetrievingLookupTypeLbl);
        LastKnownTimestamp := Json.GetBigInteger('timestamp');
        StartAtPage := Json.GetInteger('page');
        LookupContextId := Json.GetString('lookupContextId');

        case LookupType of
            'BANK_DEPOSIT_BIN_CODE':
                LookupBankDepositBinCode(LastKnownTimestamp, StartAtPage, Data);
            else
                FrontEnd.ReportBugAndThrowError(StrSubstNo(InvalidLookupTypeErr, LookupType));
        end;

        Data.SetLookupContextId(LookupContextId);

        Request.SetMethod('LookupFromPOSResponse');
        Request.SetContent(Data);
        FrontEnd.InvokeFrontEndMethod(Request);
    end;

    /// <summary>
    /// Retrieves lookup data for Bank Deposit Bin Code.
    /// </summary>
    /// <param name="Timestamp">Timestamp to check in the table to determine if any changes happened since the last time.</param>
    /// <param name="StartAtPage">Data "page" at which to start adding records to the result set.</param>
    /// <param name="Result">Data set to store the results into.</param>
    local procedure LookupBankDepositBinCode(Timestamp: BigInteger; StartAtPage: Integer; Data: Codeunit "NPR POS Lookup Data Set")
    var
        Rec: Record "NPR POS Payment Bin";
        Row: JsonObject;
        SkippedCount: Integer;
        ReadCount: Integer;
        HasMore: Boolean;
    begin
        if Timestamp > 0 then begin
            Rec.SetCurrentKey(Timestamp);
            Rec.SetAscending(Timestamp, false);
            if not Rec.FindFirst() then
                exit;

            if Rec.Timestamp > Timestamp then begin
                StartAtPage := 0;
                Data.SetFullRefresh(true);
            end;
        end;

        Rec.SetRange("Bin Type", Rec."Bin Type"::BANK);
        if not Rec.FindSet(false) then
            exit;

        if StartAtPage > 0 then begin
            if Rec.Next(StartAtPage * 40) < StartAtPage * 40 then
                exit;
        end;

        while true do begin
            Clear(Row);

            // Begin non-boilerplate code
            Row.Add('id', Rec."No.");
            Row.Add('storeId', Rec."POS Store Code");
            Row.Add('attachedToUnitId', Rec."Attached to POS Unit No.");
            Row.Add('description', Rec.Description);
            // End non-boilerplate code
            Data.AddRow(Row);

            ReadCount += 1;
            HasMore := Rec.Next() <> 0;
            if (ReadCount = 40) or (not HasMore) then
                break;
        end;

        if HasMore then
            Data.SetMoreDataAvailable(true);

        Rec.SetCurrentKey(Timestamp);
        Rec.SetAscending(Timestamp, false);
        Rec.FindFirst();
        Data.SetTimestamp(Rec.Timestamp);
    end;
}
