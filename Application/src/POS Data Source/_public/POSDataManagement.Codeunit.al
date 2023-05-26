﻿codeunit 6150710 "NPR POS Data Management"
{
    var
        Text001: Label 'Data Source "%1" is unknown or has not been defined.';
        Text002: Label 'Data Source "%1" did not bind variables.';
        Text003: Label 'Extension "%1" for data source "%2" did not respond to %3 event.';

    internal procedure SetupDefaultDataSourcesForView(View: Codeunit "NPR POS View"; Setup: Codeunit "NPR POS Setup")
    var
        DataSource: Codeunit "NPR Data Source";
    begin
        GetDataSource(POSDataSource_BuiltInSaleLine(), DataSource, Setup);
        View.AddDataSource(DataSource);
        GetDataSource(POSDataSource_BuiltInSale(), DataSource, Setup);
        View.AddDataSource(DataSource);
        GetDataSource(POSDataSource_BuiltInPaymentLine(), DataSource, Setup);
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
    begin
        OnGetDataSource(Name, DataSource, Handled, Setup);
        if (not Handled) or (DataSource.IsNull()) then
            Error(Text001, Name);

        OnDiscoverDataSourceExtensions(Name, Extensions);
        if Extensions.Count() > 0 then begin
            DataSource.AddExtensions(Extensions);

            foreach ExtensionName in Extensions do begin
                Handled := false;
                ExtensionDataSource.Constructor();
                ExtensionDataSource.SetId(ExtensionName);
                OnGetDataSourceExtension(Name, ExtensionName, ExtensionDataSource, Handled, Setup);
                if not Handled then
                    Error(Text003, ExtensionName, Name, 'OnGetDataSourceExtension');

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

        OnAfterGetDataSource(Name, DataSource, Setup);
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

        OnAfterReadDataSourceRow(POSSession, RecRef, DataSource.Id(), DataRow);

        if HasVariables then begin
            OnReadDataSourceVariables(POSSession, RecRef, DataSource.Id(), DataRow, Handled);
            if not Handled then
                FrontEnd.ReportBugAndThrowError(StrSubstNo(Text002, DataSource.Id()));

            OnAfterReadDataSourceVariables(POSSession, RecRef, DataSource.Id(), DataRow);
        end;

        if DataSource.HasExtensions() then begin
            DataSource.GetExtensions(Extensions);
            foreach Extension in Extensions do begin
                Clear(ExtensionDataRow);
                ExtensionDataRow.Constructor(DataRow.Position());
                Handled := false;
                OnDataSourceExtensionReadData(DataSource.Id(), Extension, RecRef, ExtensionDataRow, POSSession, FrontEnd, Handled);
                if not Handled then
                    FrontEnd.ReportBugAndThrowError(StrSubstNo(Text003, Extension, DataSource.Id(), 'OnDataSourceExtensionReadData'));
                ExtensionKeys := ExtensionDataRow.Fields().Keys();
                foreach ExtensionKey in ExtensionKeys do
                    DataRow.Add(StrSubstNo(DataRowLbl, Extension, ExtensionKey), ExtensionDataRow.Field(ExtensionKey));
            end;
        end;
    end;

    procedure AddFieldToDataSource(DataSource: Codeunit "NPR Data Source"; "Record": Variant; FieldNo: Integer; Visible: Boolean)
    begin
        AddFieldToDataSource(DataSource, "Record", FieldNo, Visible, false);
    end;

    procedure AddFieldToDataSource(DataSource: Codeunit "NPR Data Source"; "Record": Variant; FieldNo: Integer; Visible: Boolean; Editable: Boolean)
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

    [IntegrationEvent(false, false)]
    local procedure OnGetDataSource(Name: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetDataSource(Name: Text; DataSource: Codeunit "NPR Data Source"; Setup: Codeunit "NPR POS Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDiscoverDataSourceExtensions(DataSourceName: Text; Extensions: List of [Text])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRefreshDataSet(POSSession: Codeunit "NPR POS Session"; DataSource: Codeunit "NPR Data Source"; var CurrDataSet: Codeunit "NPR Data Set"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterRefreshDataSet(POSSession: Codeunit "NPR POS Session"; DataSource: Codeunit "NPR Data Source"; CurrDataSet: Codeunit "NPR Data Set"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    /// <summary>
    /// Event called after a a data source row has been read and converted to DataRow instance. It allows individual
    /// data source to modify the content of the DataRow (for example, setting negative property, etc.)
    /// </summary>
    [IntegrationEvent(false, false)]
    local procedure OnAfterReadDataSourceRow(POSSession: Codeunit "NPR POS Session"; RecRef: RecordRef; DataSource: Text; DataRow: Codeunit "NPR Data Row")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReadDataSourceVariables(POSSession: Codeunit "NPR POS Session"; RecRef: RecordRef; DataSource: Text; DataRow: Codeunit "NPR Data Row"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReadDataSourceVariables(POSSession: Codeunit "NPR POS Session"; RecRef: RecordRef; DataSource: Text; DataRow: Codeunit "NPR Data Row")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSetPosition(DataSource: Text; Position: Text; POSSession: Codeunit "NPR POS Session"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnIsDataSourceModified(POSSession: Codeunit "NPR POS Session"; DataSource: Text; var Modified: Boolean)
    begin
    end;

    [IntegrationEvent(FALSE, FALSE)]
    [Obsolete('We are slowly moving the concept of a view out of backend, into frontend with data pulled by frontend instead of pushed out of backend depending on a flag backend remembers between requests.')]
    local procedure OnSetupDataSourcesForView(View: Codeunit "NPR POS View"; Setup: Codeunit "NPR POS Setup")
    begin
    end;

    procedure POSDataSource_BuiltInSale(): Text[50]
    begin
        exit('BUILTIN_SALE');
    end;

    procedure POSDataSource_BuiltInSaleLine(): Text[50]
    begin
        exit('BUILTIN_SALELINE');
    end;

    procedure POSDataSource_BuiltInPaymentLine(): Text[50]
    begin
        exit('BUILTIN_PAYMENTLINE');
    end;
}
