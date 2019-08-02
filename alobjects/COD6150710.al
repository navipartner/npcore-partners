codeunit 6150710 "POS Data Management"
{
    // NPR5.36/VB  /20170925  CASE 291525 Adding data source extension functionality
    // NPR5.37/MMV /20171026  CASE 287688 Replaced text constants with proper constants to avoid translation.
    // NPR5.38/TSA /20170811  CASE 286726 added publisher OnSetupDataSourcesForView
    // NPR5.38/MHA /20180105  CASE 301053 Changed Parameter name from DataSet to CurrDataset as DataSet is a reserved word in RecordToDataSet(),OnAfterRefreshDataSet(),OnRefreshDataSet()
    // NPR5.40/MMV /20180214  CASE 294655 Small blip on performance trace: EVALUATE performing better than DotNet interop Int32.Parse


    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'Data Source "%1" is unknown or has not been defined.';
        Text002: Label 'Data Source "%1" did not bind variables.';
        Text003: Label 'Extension "%1" for data source "%2" did not respond to %3 event.';

    procedure SetupDefaultDataSourcesForView(View: DotNet npNetView0; Setup: Codeunit "POS Setup")
    var
        ViewType: DotNet npNetViewType0;
        DataSource: DotNet npNetDataSource0;
    begin
        case true of
            //-NPR5.37 [287688]
            View.Type.Equals(View.Type.Login):
                begin
                    GetDataSource(BuiltInSale, DataSource, Setup);
                    View.DataSources.Add(DataSource.Id, DataSource);
                end;
            View.Type.Equals(ViewType.Sale):
                begin
                    GetDataSource(BuiltInSaleLine, DataSource, Setup);
                    View.DataSources.Add(DataSource.Id, DataSource);
                    GetDataSource(BuiltInSale, DataSource, Setup);
                    View.DataSources.Add(DataSource.Id, DataSource);
                end;
            View.Type.Equals(ViewType.Payment):
                begin
                    GetDataSource(BuiltInPaymentLine, DataSource, Setup);
                    View.AddDataSource(DataSource);
                    GetDataSource(BuiltInSale, DataSource, Setup);
                    View.DataSources.Add(DataSource.Id, DataSource);
                end;
            View.Type.Equals(ViewType.BalanceRegister):
                begin
                    GetDataSource(BuiltInBalancing, DataSource, Setup);
                    View.AddDataSource(DataSource);
                end;

                //  View.Type.Equals(View.Type.Login):
                //    BEGIN
                //      //GetDataSource(DefaultDataSource_SaleLine,DataSource,Setup);
                //      //View.DataSources.Add(DataSource.Id,DataSource);
                //      GetDataSource(DefaultDataSource_Sale,DataSource,Setup);
                //      View.DataSources.Add(DataSource.Id,DataSource);
                //    END;
                //  View.Type.Equals(ViewType.Sale):
                //    BEGIN
                //      GetDataSource(DefaultDataSource_SaleLine,DataSource,Setup);
                //      View.DataSources.Add(DataSource.Id,DataSource);
                //      GetDataSource(DefaultDataSource_Sale,DataSource,Setup);
                //      View.DataSources.Add(DataSource.Id,DataSource);
                //    END;
                //  View.Type.Equals(ViewType.Payment):
                //    BEGIN
                //      GetDataSource(DefaultDataSource_PaymentLine,DataSource,Setup);
                //      View.AddDataSource(DataSource);
                //      GetDataSource(DefaultDataSource_Sale,DataSource,Setup);
                //      View.DataSources.Add(DataSource.Id,DataSource);
                //    END;
                //  View.Type.Equals(ViewType.BalanceRegister):
                //    BEGIN
                //      GetDataSource(DefaultDataSource_Register,DataSource,Setup);
                //      View.AddDataSource(DataSource);
                //    END;
                //+NPR5.37 [287688]
        end;

        //-NPR5.38 [286726]
        OnSetupDataSourcesForView(View, Setup);
        //+NPR5.38 [286726]
    end;

    procedure GetDataSource(Name: Text; var DataSource: DotNet npNetDataSource0; Setup: Codeunit "POS Setup")
    var
        Extensions: DotNet npNetList_Of_T;
        ExtensionDataSource: DotNet npNetDataSource0;
        Column: DotNet npNetDataColumn1;
        ExtensionName: Text;
        Handled: Boolean;
    begin
        OnGetDataSource(Name, DataSource, Handled, Setup);
        if (not Handled) or (IsNull(DataSource)) then
            Error(Text001, Name);

        //-NPR5.36 [291525]
        Extensions := Extensions.List();
        OnDiscoverDataSourceExtensions(Name, Extensions);
        if Extensions.Count > 0 then begin
            DataSource.Content.Add('_extensions', Extensions);

            foreach ExtensionName in Extensions do begin
                Handled := false;
                ExtensionDataSource := ExtensionDataSource.DataSource();
                ExtensionDataSource.Id := ExtensionName;
                OnGetDataSourceExtension(Name, ExtensionName, ExtensionDataSource, Handled, Setup);
                if not Handled then
                    Error(Text003, ExtensionName, Name, 'OnGetDataSourceExtension');

                foreach Column in ExtensionDataSource.Columns do
                    DataSource.AddColumn(
                      ExtensionName + '.' + Column.FieldId,
                      Column.Caption,
                      Column.DataType,
                      Column.Visible);
            end;
        end;
        //+NPR5.36 [291525]

        OnAfterGetDataSource(Name, DataSource, Setup);
    end;

    procedure RecordToDataSet("Record": Variant; var CurrDataSet: DotNet npNetDataSet; DataSource: DotNet npNetDataSource0; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management")
    var
        RecRef: RecordRef;
        DataRow: DotNet npNetDataRow0;
        CurrentPosition: Text;
    begin
        //-NPR5.38 [301053]
        // DataSet := DataSet.DataSet(DataSource.Id);
        //
        // RecRef.GETTABLE(Record);
        // CurrentPosition := RecRef.GETPOSITION();
        // IF RecRef.FIND THEN
        //  DataSet.CurrentPosition := CurrentPosition;
        //
        // IF RecRef.FINDSET THEN
        //  REPEAT
        //    DataRow := DataSet.NewRow(RecRef.GETPOSITION());
        //    NavOneRecordToDataRow(RecRef,DataRow,DataSource,POSSession,FrontEnd);
        //  UNTIL RecRef.NEXT = 0;
        CurrDataSet := CurrDataSet.DataSet(DataSource.Id);

        RecRef.GetTable(Record);
        CurrentPosition := RecRef.GetPosition();
        if RecRef.Find then
            CurrDataSet.CurrentPosition := CurrentPosition;

        if RecRef.FindSet then
            repeat
                DataRow := CurrDataSet.NewRow(RecRef.GetPosition());
                NavOneRecordToDataRow(RecRef, DataRow, DataSource, POSSession, FrontEnd);
            until RecRef.Next = 0;
        //+NPR5.38 [301053]
    end;

    local procedure NavOneRecordToDataRow(var RecRef: RecordRef; DataRow: DotNet npNetDataRow0; DataSource: DotNet npNetDataSource0; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management")
    var
        "Field": FieldRef;
        DataColumn: DotNet npNetDataColumn1;
        Int32: DotNet npNetInt32;
        Extensions: DotNet npNetList_Of_T;
        ExtensionDataRow: DotNet npNetDataRow0;
        KeyValuePair: DotNet npNetKeyValuePair_Of_T_U;
        VariableValue: Variant;
        FieldIdText: Text;
        Extension: Text;
        FieldId: Integer;
        i: Integer;
        Handled: Boolean;
        HasVariables: Boolean;
        IsExtensionField: Boolean;
        FieldValueVariant: Variant;
    begin
        foreach DataColumn in DataSource.Columns do begin
            //-NPR5.40 [294655]
            //  IF Int32.TryParse(DataColumn.FieldId,FieldId) THEN BEGIN
            if Evaluate(FieldId, DataColumn.FieldId) then begin
                //+NPR5.40 [294655]
                Field := RecRef.Field(FieldId);
                FieldValueVariant := Field.Value;
                DataRow.Add(DataColumn.FieldId, FieldValueVariant);
            end else
              //-NPR5.36 [291525]
              //    HasVariables := TRUE;
              begin
                if DataSource.Content.ContainsKey('_extensions') then begin
                    Extensions := DataSource.Content.Item('_extensions');
                    IsExtensionField := false;
                    foreach Extension in Extensions do
                        if CopyStr(DataColumn.FieldId, 1, StrLen(Extension) + 1) = Extension + '.' then
                            IsExtensionField := true;
                    if not IsExtensionField then
                        HasVariables := true;
                end else
                    HasVariables := true;
            end;
            //+NPR5.36 [291525]
        end;

        if HasVariables then begin
            OnReadDataSourceVariables(POSSession, RecRef, DataSource.Id, DataRow, Handled);
            if not Handled then
                FrontEnd.ReportBug(StrSubstNo(Text002, DataSource.Id));

            OnAfterReadDataSourceVariables(POSSession, RecRef, DataSource.Id, DataRow);
        end;

        //-NPR5.36 [291525]
        if DataSource.Content.ContainsKey('_extensions') then begin
            Extensions := DataSource.Content.Item('_extensions');
            foreach Extension in Extensions do begin
                ExtensionDataRow := ExtensionDataRow.DataRow(DataRow.Position);
                Handled := false;
                OnDataSourceExtensionReadData(DataSource.Id, Extension, RecRef, ExtensionDataRow, POSSession, FrontEnd, Handled);
                if not Handled then
                    FrontEnd.ReportBug(StrSubstNo(Text003, Extension, DataSource.Id, 'OnDataSourceExtensionReadData'));
                foreach KeyValuePair in ExtensionDataRow.Fields do
                    DataRow.Add(StrSubstNo('%1.%2', Extension, KeyValuePair.Key), KeyValuePair.Value);
            end;
        end;
        //+NPR5.36 [291525]
    end;

    procedure AddFieldToDataSource(DataSource: DotNet npNetDataSource0; "Record": Variant; FieldNo: Integer; Visible: Boolean)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        DataType: DotNet npNetDataType;
        DataColumn: DotNet npNetDataColumn1;
        Type: Text;
        Width: Integer;
    begin
        RecRef.GetTable(Record);
        FieldRef := RecRef.Field(FieldNo);

        Type := UpperCase(Format(FieldRef.Type));
        case Type of
            'BOOLEAN':
                begin
                    DataType := DataType.Boolean;
                    Width := 2;
                end;
            'DATE', 'DATETIME', 'TIME':
                begin
                    DataType := DataType.DateTime;
                    Width := 4;
                end;
            'DECIMAL':
                begin
                    DataType := DataType.Decimal;
                    Width := 5;
                end;
            'INTEGER', 'BIGINTEGER':
                begin
                    DataType := DataType.Integer;
                    Width := 4;
                end;
            'OPTION', 'TEXT', 'CODE':
                begin
                    DataType := DataType.String;
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

        DataColumn := DataSource.AddColumn(Format(FieldRef.Number), FieldRef.Caption, DataType, Visible);
        DataColumn.Width := Width;
    end;

    local procedure "--- Events ---"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDataSource(Name: Text; var DataSource: DotNet npNetDataSource0; var Handled: Boolean; Setup: Codeunit "POS Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetDataSource(Name: Text; DataSource: DotNet npNetDataSource0; Setup: Codeunit "POS Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDiscoverDataSourceExtensions(DataSourceName: Text; Extensions: DotNet npNetList_Of_T)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: DotNet npNetDataSource0; var Handled: Boolean; Setup: Codeunit "POS Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: DotNet npNetDataRow0; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRefreshDataSet(POSSession: Codeunit "POS Session"; DataSource: DotNet npNetDataSource0; var CurrDataSet: DotNet npNetDataSet; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterRefreshDataSet(POSSession: Codeunit "POS Session"; DataSource: DotNet npNetDataSource0; CurrDataSet: DotNet npNetDataSet; FrontEnd: Codeunit "POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReadDataSourceVariables(POSSession: Codeunit "POS Session"; RecRef: RecordRef; DataSource: Text; DataRow: DotNet npNetDataRow0; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReadDataSourceVariables(POSSession: Codeunit "POS Session"; RecRef: RecordRef; DataSource: Text; DataRow: DotNet npNetDataRow0)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetPosition(DataSource: Text; Position: Text; POSSession: Codeunit "POS Session"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnIsDataSourceModified(POSSession: Codeunit "POS Session"; DataSource: Text; var Modified: Boolean)
    begin
    end;

    [IntegrationEvent(FALSE, FALSE)]
    local procedure OnSetupDataSourcesForView(View: DotNet npNetView0; Setup: Codeunit "POS Setup")
    begin
    end;

    local procedure "--- Constants ---"()
    begin
    end;

    local procedure BuiltInSale(): Text
    begin
        //-NPR5.37 [287688]
        exit('BUILTIN_SALE');
        //+NPR5.37 [287688]
    end;

    local procedure BuiltInSaleLine(): Text
    begin
        //-NPR5.37 [287688]
        exit('BUILTIN_SALELINE');
        //+NPR5.37 [287688]
    end;

    local procedure BuiltInPaymentLine(): Text
    begin
        //-NPR5.37 [287688]
        exit('BUILTIN_PAYMENTLINE');
        //+NPR5.37 [287688]
    end;

    local procedure BuiltInBalancing(): Text
    begin
        //-NPR5.37 [287688]
        exit('BUILTIN_REGISTER_BALANCING');
        //+NPR5.37 [287688]
    end;
}

