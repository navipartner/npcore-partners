report 6014461 "NPR HL Import Members"
{
#IF NOT BC17
    Extensible = false;
#ENDIF
    Caption = 'Import HeyLoyalty Members';
    UsageCategory = None;
    ProcessingOnly = true;
    UseRequestPage = false;

    trigger OnPreReport()
    var
        ExcelFileStream: InStream;
        SheetName: Text[250];
        DoneLbl: Label 'Import process completed successfully.';
    begin
        SelectExcelWorksheet(SheetName, ExcelFileStream);
        TempExcelBuffer.OpenBookStream(ExcelFileStream, SheetName);
        TempExcelBuffer.ReadSheet();
        AnalyzeData();
        Message(DoneLbl);
    end;

    local procedure AnalyzeData()
    var
        Headers: Dictionary of [Integer, Text];
        Window: Dialog;
        RecNo: Integer;
        TotalRecNo: Integer;
        DialogTxt01Lbl: Label 'Importing HeyLoyalty Members...\\';
        DialogTxt02Lbl: Label '@1@@@@@@@@@@@@@@@@@@@@@@@@@';
        NothingToImportErr: Label 'There is nothing to do.';
        IdColumnMissingErr: Label 'The worksheet must contain a column called ''id'' with HeyLoyalty Ids of members to be imported.';
    begin
        if not ReadWorksheetHeaders(TempExcelBuffer, Headers) then
            Error(NothingToImportErr);
        if not Headers.Values.Contains('id') then
            Error(IdColumnMissingErr);

        TempExcelBuffer.SetRange("Column No.", Headers.Keys.Get(Headers.Values.IndexOf('id')));
        TempExcelBuffer.SetFilter("Row No.", '>%1', 1);
        if TempExcelBuffer.IsEmpty() then
            Error(NothingToImportErr);

        Window.Open(
            DialogTxt01Lbl +
            DialogTxt02Lbl);
        Window.Update(1, 0);
        TotalRecNo := TempExcelBuffer.Count();
        RecNo := 0;

        TempExcelBuffer.SetRange("Column No.");

        repeat
            RecNo += 1;
            if ProcessWorksheetRow(TempExcelBuffer, RecNo + 1, Headers) then
                Commit();
            Window.Update(1, Round(RecNo / TotalRecNo * 10000, 1));
        until RecNo = TotalRecNo;

        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        Window.Close();
    end;

    local procedure SelectExcelWorksheet(var SheetName: Text[250]; var ExcelFileStream: InStream)
    var
        ServerFileName: Text;
        ExcelFileExtensionTok: Label '.xlsx', Locked = true;
        ImportFromExcelLbl: Label 'Select Excel File';
    begin
        if not UploadIntoStream(ImportFromExcelLbl, '', ExcelFileExtensionTok, ServerFileName, ExcelFileStream) or (ServerFileName = '') then
            Error('');
        if SheetName = '' then
            SheetName := TempExcelBuffer.SelectSheetsNameStream(ExcelFileStream);
        if SheetName = '' then
            Error('');
    end;

    [TryFunction]
    local procedure ReadWorksheetHeaders(var TempExcelBuffer: Record "Excel Buffer" temporary; var Headers: Dictionary of [Integer, Text])
    begin
        Clear(Headers);
        TempExcelBuffer.SetRange("Row No.", 1);
        TempExcelBuffer.FindSet();
        repeat
            Headers.Add(TempExcelBuffer."Column No.", TempExcelBuffer."Cell Value as Text");
        until TempExcelBuffer.Next() = 0;
    end;

    local procedure ProcessWorksheetRow(var TempExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; Headers: Dictionary of [Integer, Text]): Boolean
    var
        HLMember: Record "NPR HL HeyLoyalty Member";
        HLMemberEssensialValuesIn: Record "NPR HL HeyLoyalty Member";
        HLMemberMgt: Codeunit "NPR HL Member Mgt.";
        HLWebservice: Codeunit "NPR HL HeyLoyalty Webservice";
        HLMemberJObject: JsonObject;
        HLMemberFieldsJObject: JsonObject;
        HLMemberStatusesJObject: JsonObject;
        ColumnName: Text;
        DateTimeAsDecimal: Decimal;
        EmailNotFoundErr: Label 'Email address could not be found. Worksheet row No. %1', Comment = '%1 - excell worksheet row number';
        IdNotFoundErr: Label 'HeyLoyalty ID could not be found. Worksheet row No. %1', Comment = '%1 - excell worksheet row number';
    begin
        TempExcelBuffer.SetRange("Row No.", RowNo);
        if TempExcelBuffer.FindSet() then
            repeat
                Headers.Get(TempExcelBuffer."Column No.", ColumnName);
                case ColumnName of
                    'id',
                    'opt_in', 'opt_in_date',
                    'last_open', 'last_click', 'open_rate', 'click_rate',
                    'reference_from', 'deleted_from':
                        HLMemberJObject.Add(ColumnName, TempExcelBuffer."Cell Value as Text");

                    'created_at', 'updated_at', 'unsubscribed_at':
                        begin
                            if Evaluate(DateTimeAsDecimal, TempExcelBuffer."Cell Value as Text", 9) then
                                HLMemberJObject.Add(ColumnName, TempExcelBuffer.ConvertDateTimeDecimalToDateTime(DateTimeAsDecimal))
                            else
                                HLMemberJObject.Add(ColumnName, TempExcelBuffer."Cell Value as Text");
                        end;

                    'status', 'status_email':
                        AddStatus(HLMemberStatusesJObject, ColumnName, TempExcelBuffer."Cell Value as Text");

                    'sent_mail', 'sent_sms', 'sent_push',
                    'open_count', 'open_count_push', 'click_count',
                    'imported', 'created_by', 'reference_at':
                        ;

                    else
                        AddField(HLMemberFieldsJObject, ColumnName, TempExcelBuffer."Cell Value as Text");
                end;
            until TempExcelBuffer.Next() = 0;

        HLMemberJObject.Add('status', HLMemberStatusesJObject);
        HLMemberJObject.Add('fields', HLMemberFieldsJObject);

        Clear(HLMemberEssensialValuesIn);
        HLMemberMgt.GetHLEssentialFieldValues(HLMemberEssensialValuesIn, HLMemberJObject.AsToken(), false);
        if HLMemberEssensialValuesIn."HeyLoyalty Id" = '' then
            Error(IdNotFoundErr, RowNo);

        if not HLWebservice.GetHLMemberByHeyLoyaltyID(HLMemberEssensialValuesIn."HeyLoyalty Id", HLMember) then begin
            if HLMemberEssensialValuesIn."E-Mail Address" = '' then
                Error(EmailNotFoundErr, RowNo);
            HLMember := HLMemberEssensialValuesIn;
            if not HLWebservice.GetHLMemberByEmailAddress(HLMember) then begin
                if HLMemberEssensialValuesIn."Unsubscribed at" <> 0DT then
                    exit(false);
                HLMember.Init();
                HLMember."Entry No." := 0;
                HLMember."HeyLoyalty Id" := HLMemberEssensialValuesIn."HeyLoyalty Id";
                HLMember.Insert(true);
            end else
                if (HLMemberEssensialValuesIn."Unsubscribed at" <> 0DT) and
                   (HLMemberEssensialValuesIn."HeyLoyalty Id" <> HLMember."HeyLoyalty Id") and (HLMember."HeyLoyalty Id" <> '')
                then
                    exit(false);
        end;
        HLMember."Unsubscribed at" := 0DT;
        exit(HLMemberMgt.UpdateHLMemberWithDataFromHeyLoyalty(HLMember, HLMemberJObject.AsToken(), false));
    end;

    local procedure AddField(var HLMemberFieldsJObject: JsonObject; ColumnName: Text; CellValueasText: Text)
    var
        HLFieldJObject: JsonObject;
    begin
        HLFieldJObject.Add('name', ColumnName);
        HLFieldJObject.Add('value', CellValueasText);
        HLMemberFieldsJObject.Add(ColumnName, HLFieldJObject);
    end;

    local procedure AddStatus(var HLMemberStatusesJObject: JsonObject; ColumnName: Text; CellValueasText: Text)
    begin
        case ColumnName of
            'status_email':
                HLMemberStatusesJObject.Add('email', CellValueasText);
            else
                HLMemberStatusesJObject.Add(ColumnName, CellValueasText);
        end;
    end;

    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
}