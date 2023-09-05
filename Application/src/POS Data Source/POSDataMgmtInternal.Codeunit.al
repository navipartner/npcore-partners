codeunit 6150790 "NPR POS Data Mgmt. Internal"
{
    Access = Internal;

    var
        _MissingSubscriberErr: Label 'Extension "%1" for data source "%2" did not respond to %3 event.';
        _POSDataManagementAPI: Codeunit "NPR POS Data Management";


    internal procedure SetupDefaultDataSourcesForView(View: Codeunit "NPR POS View"; Setup: Codeunit "NPR POS Setup")
    var
        DataSource: Codeunit "NPR Data Source";
    begin
        GetDataSource(_POSDataManagementAPI.POSDataSource_BuiltInSaleLine(), DataSource, Setup);
        View.AddDataSource(DataSource);
        GetDataSource(_POSDataManagementAPI.POSDataSource_BuiltInSale(), DataSource, Setup);
        View.AddDataSource(DataSource);
        GetDataSource(_POSDataManagementAPI.POSDataSource_BuiltInPaymentLine(), DataSource, Setup);
        View.AddDataSource(DataSource);
    end;

    internal procedure GetDataSource(Name: Text; var DataSource: Codeunit "NPR Data Source"; Setup: Codeunit "NPR POS Setup")
    var
        Extensions: List of [Text];
        ExtensionDataSource: Codeunit "NPR Data Source";
        Column: JsonToken;
        DataColumn: Codeunit "NPR Data Column";
        ExtensionName: Text;
        Handled: Boolean;
        Text001: Label 'Data Source "%1" is unknown or has not been defined.';
    begin
        _POSDataManagementAPI.OnGetDataSource(Name, DataSource, Handled, Setup);
        if (not Handled) or (DataSource.IsNull()) then
            Error(Text001, Name);

        _POSDataManagementAPI.OnDiscoverDataSourceExtensions(Name, Extensions);
        if Extensions.Count() > 0 then begin
            DataSource.AddExtensions(Extensions);

            foreach ExtensionName in Extensions do begin
                Handled := false;
                ExtensionDataSource.Constructor();
                ExtensionDataSource.SetId(ExtensionName);
                _POSDataManagementAPI.OnGetDataSourceExtension(Name, ExtensionName, ExtensionDataSource, Handled, Setup);
                if not Handled then
                    Error(_MissingSubscriberErr, ExtensionName, Name, 'OnGetDataSourceExtension');

                foreach Column in ExtensionDataSource.Columns() do begin
                    DataColumn.Constructor(Column);
                    DataSource.AddColumn(
                      ExtensionName + '.' + DataColumn.FieldId(),
                      DataColumn.Caption(),
                      DataColumn.DataType(),
                      DataColumn.Visible());
                end;
            end;
        end;

        _POSDataManagementAPI.OnAfterGetDataSource(Name, DataSource, Setup);
    end;

    internal procedure RecordToDataSet("Record": Variant; var CurrDataSet: Codeunit "NPR Data Set"; DataSource: Codeunit "NPR Data Source"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        RecRef: RecordRef;
        DataRow: Codeunit "NPR Data Row";
        CurrentPosition: Text;
    begin
        CurrDataSet.Constructor(DataSource.Id());

        RecRef.GetTable(Record);
        CurrentPosition := RecRef.GetPosition();
        if RecRef.Find() then
            CurrDataSet.SetCurrentPosition(CurrentPosition);

        if RecRef.FindSet() then
            repeat
                CurrDataSet.NewRow(RecRef.GetPosition(), DataRow);
                NavOneRecordToDataRow(RecRef, DataRow, DataSource, POSSession, FrontEnd);
            until RecRef.Next() = 0;
    end;

    local procedure NavOneRecordToDataRow(var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; DataSource: Codeunit "NPR Data Source"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        "Field": FieldRef;
        DataColumnToken: JsonToken;
        DataColumnObject: JsonObject;
        DataColumnProxy: Codeunit "NPR Data Column";
        Extensions: List of [Text];
        ExtensionDataRow: Codeunit "NPR Data Row";
        ExtensionKeys: List of [Text];
        ExtensionKey: Text;
        VariableValue: Variant;
        FieldIdText: Text;
        Extension: Text;
        FieldId: Integer;
        Handled: Boolean;
        HasVariables: Boolean;
        IsExtensionField: Boolean;
        DataRowLbl: Label '%1.%2', Locked = true;
        Text002: Label 'Data Source "%1" did not bind variables.';
    begin
        foreach DataColumnToken in DataSource.Columns() do begin
            DataColumnObject := DataColumnToken.AsObject();
            FieldIdText := DataColumnProxy.FieldId(DataColumnObject);
            if Evaluate(FieldId, FieldIdText) then begin
                Field := RecRef.Field(FieldId);
                VariableValue := Field.Value;
                DataRow.Add(FieldIdText, VariableValue);
            end else begin
                if DataSource.HasExtensions() then begin
                    DataSource.GetExtensions(Extensions);
                    IsExtensionField := false;
                    foreach Extension in Extensions do
                        if CopyStr(FieldIdText, 1, StrLen(Extension) + 1) = Extension + '.' then
                            IsExtensionField := true;
                    if not IsExtensionField then
                        HasVariables := true;
                end else
                    HasVariables := true;
            end;
        end;

        _POSDataManagementAPI.OnAfterReadDataSourceRow(POSSession, RecRef, DataSource.Id(), DataRow);

        if HasVariables then begin
            _POSDataManagementAPI.OnReadDataSourceVariables(POSSession, RecRef, DataSource.Id(), DataRow, Handled);
            if not Handled then
                FrontEnd.ReportBugAndThrowError(StrSubstNo(Text002, DataSource.Id()));

            _POSDataManagementAPI.OnAfterReadDataSourceVariables(POSSession, RecRef, DataSource.Id(), DataRow);
        end;

        if DataSource.HasExtensions() then begin
            DataSource.GetExtensions(Extensions);
            foreach Extension in Extensions do begin
                Clear(ExtensionDataRow);
                ExtensionDataRow.Constructor(DataRow.Position());
                Handled := false;
                _POSDataManagementAPI.OnDataSourceExtensionReadData(DataSource.Id(), Extension, RecRef, ExtensionDataRow, POSSession, FrontEnd, Handled);
                if not Handled then
                    FrontEnd.ReportBugAndThrowError(StrSubstNo(_MissingSubscriberErr, Extension, DataSource.Id(), 'OnDataSourceExtensionReadData'));
                ExtensionKeys := ExtensionDataRow.Fields().Keys();
                foreach ExtensionKey in ExtensionKeys do
                    DataRow.Add(StrSubstNo(DataRowLbl, Extension, ExtensionKey), ExtensionDataRow.Field(ExtensionKey));
            end;
        end;
    end;

    internal procedure AddFieldToDataSource(DataSource: Codeunit "NPR Data Source"; "Record": Variant; FieldNo: Integer; Visible: Boolean; Editable: Boolean)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        DataType: Enum "NPR Data Type";
        DataColumn: Codeunit "NPR Data Column";
        Type: Text;
        Width: Integer;
    begin
        RecRef.GetTable(Record);
        FieldRef := RecRef.Field(FieldNo);

        Type := UpperCase(Format(FieldRef.Type));
        case Type of
            'BOOLEAN':
                begin
                    DataType := DataType::Boolean;
                    Width := 2;
                end;
            'DATE', 'DATETIME', 'TIME':
                begin
                    DataType := DataType::DateTime;
                    Width := 4;
                end;
            'DECIMAL':
                begin
                    DataType := DataType::Decimal;
                    Width := 5;
                end;
            'INTEGER', 'BIGINTEGER':
                begin
                    DataType := DataType::Integer;
                    Width := 4;
                end;
            'OPTION', 'TEXT', 'CODE':
                begin
                    DataType := DataType::String;
                    case true of
                        FieldRef.Length <= 10:
                            Width := 10;
                        FieldRef.Length <= 20:
                            Width := 13;
                        FieldRef.Length <= 30:
                            Width := 16;
                        else
                            Width := 20;
                    end;
                end;
            else
                exit;
        end;

        DataSource.AddColumn(Format(FieldRef.Number), FieldRef.Caption, DataType, Visible, DataColumn, Editable);
        DataColumn.SetWidth(Width);
    end;
}