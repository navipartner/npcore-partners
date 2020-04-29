codeunit 6014523 "NavTable To DotNet Table Tool"
{

    trigger OnRun()
    var
        RecRef: RecordRef;
        Start: Time;
        Done: Time;
    begin
    end;

    var
        DotNetDataTable: DotNet npNetDataTable;
        GlobalRecRef: RecordRef;
        "-- Properties": Integer;
        MaxFieldCount: Integer;
        MaxRowCount: Integer;
        TableID: Integer;
        "-- Field Descriptor": Integer;
        DataItemDescriptor: array [40] of Integer;
        "-- CustomColumns": Integer;
        CustomColumnCount: Integer;
        CustomColumnsNames: array [10] of Text[50];
        CustomColumnsCaptions: array [10] of Text[50];

    procedure SetRecordRef(var RecRef: RecordRef)
    begin
        GlobalRecRef := RecRef;
    end;

    procedure CreateColumns("Count": Integer)
    var
        "Fields": Record "Field";
        OverRideColHeader: Boolean;
        DotNetDataColumn: DotNet npNetDataColumn;
    begin
        OverRideColHeader := DataItemDescriptor[1] > 0;

        Fields.SetRange(TableNo,GlobalRecRef.Number);

        if not OverRideColHeader then begin
          Count := 0;
          if Fields.FindSet then repeat
            DotNetDataTable.Columns.Add(DelChr(Fields.FieldName,'=','.'));
            Count += 1;
          until (Fields.Next = 0) or (Count >= MaxFieldCount);
        end else begin
          for Count := 1 to ArrayLen(DataItemDescriptor) do begin
            if DataItemDescriptor[Count] = 0 then
              exit;
            Fields.SetRange("No.", DataItemDescriptor[Count]);
            Fields.FindFirst;
            DotNetDataTable.Columns.Add(DelChr(Fields."Field Caption",'=','.'));
          end;
        end;
    end;

    procedure FillTable()
    var
        "Fields": Record "Field";
        FieldRef: FieldRef;
        DataRow: DotNet npNetDataRow;
        Itt: Integer;
        Itt2: Integer;
        OverRideColHeader: Boolean;
        ExitLoop: Boolean;
        DotNetDataColumn: DotNet npNetDataColumn;
        Type: DotNet npNetType;
        [RunOnClient]
        Bytes: DotNet npNetArray;
        Encoding: DotNet npNetEncoding;
        BinaryReader: DotNet npNetBinaryReader;
        Stream: DotNet npNetStream;
        TempBlob: Record TempBlob temporary;
        InStream: InStream;
        BigText: BigText;
        Tempint: Integer;
        Text: Text;
    begin
        SetDefaultValues();

        OverRideColHeader := DataItemDescriptor[1] > 0;

        if IsNull(DotNetDataTable) then begin
          DotNetDataTable := DotNetDataTable.DataTable();
        end else begin
          DotNetDataTable.Rows.Clear();
        end;

        if DotNetDataTable.Columns.Count = 0 then begin
          DotNetDataTable.TableName := GlobalRecRef.Name;
          CreateColumns(GlobalRecRef.Number);
          DotNetDataTable.Columns.Add('Position');
        end;

        for Itt := 1 to CustomColumnCount do begin
          DotNetDataTable.TableName := GlobalRecRef.Name;
          FieldRef := GlobalRecRef.Field(DataItemDescriptor[Itt]);
          if CustomColumnsNames[Itt] = 'Selected' then begin
            DotNetDataColumn          := DotNetDataColumn.DataColumn('Selected');
            DotNetDataColumn.DataType := Type.GetType('System.Boolean');
            DotNetDataColumn.Caption  := CustomColumnsCaptions[Itt];
            DotNetDataTable.Columns.Add(DotNetDataColumn);
          end else
            DotNetDataTable.Columns.Add(CustomColumnsNames[Itt]);
        end;

        for Itt   := DotNetDataTable.Rows.Count to GlobalRecRef.Count - 1 do begin
          DataRow := DotNetDataTable.NewRow();
          DotNetDataTable.Rows.Add(DataRow);
        end;

        Fields.SetRange(TableNo,GlobalRecRef.Number);
        Itt := 0;

        if GlobalRecRef.FindFirst then repeat
          Itt2    := 1;
          if Fields.FindSet then repeat
            DataRow := DotNetDataTable.Rows.Item(Itt);
            if not OverRideColHeader then
              DataRow.Item(Itt2-1, GlobalRecRef.Field(Fields."No.").Value)
            else begin
              FieldRef := GlobalRecRef.Field(DataItemDescriptor[Itt2]);
              if (Format(FieldRef.Class) = 'FlowField') or (Format(FieldRef.Type) = 'BLOB') then begin
                FieldRef.CalcField;
              end;
              if Format(FieldRef.Type) = 'Decimal' then
                DataRow.Item(Itt2-1, Format(FieldRef.Value,0,'<Precision,2:2><Standard Format,2>'))
              else if Format(FieldRef.Type) = 'BLOB' then begin
                TempBlob.Blob := FieldRef.Value;
                TempBlob.Blob.CreateInStream(InStream);
                Stream        := InStream;
                BinaryReader  := BinaryReader.BinaryReader(Stream);
                DataRow.Item(Itt2-1, Encoding.Default.GetString(BinaryReader.ReadBytes(Stream.Length)));
              end else
                DataRow.Item(Itt2-1, FieldRef.Value);
              ExitLoop := DataItemDescriptor[Itt2+1] = 0;
            end;
            Itt2 += 1;
          until (Fields.Next = 0) or (Itt2 > MaxFieldCount) or
                (OverRideColHeader and ExitLoop);
          Itt += 1;

          DataRow.Item('Position', GlobalRecRef.GetPosition)
        until (GlobalRecRef.Next = 0) or (Itt > MaxRowCount);

        GlobalRecRef.Close;
    end;

    procedure GetDotNetDataTable(var DotNetDataTableOut: DotNet npNetDataTable)
    begin
        DotNetDataTableOut := DotNetDataTable;
    end;

    procedure SetDotNetDataTable(var DotNetDataTableIn: DotNet npNetDataTable)
    begin
        DotNetDataTable := DotNetDataTableIn;
    end;

    procedure "---- Overrides -----"()
    begin
    end;

    procedure SetColumnDataDescription(var ColumnDescription: array [40] of Integer)
    begin
        CopyArray(DataItemDescriptor, ColumnDescription, 1, 40);
    end;

    procedure "---- Custom Columns Funs----"()
    begin
    end;

    procedure AddCustomColumn(ColumnName: Text[50];ColumnCaption: Text[50])
    begin
        CustomColumnCount += 1;
        CustomColumnsNames[CustomColumnCount]    := ColumnName;
        CustomColumnsCaptions[CustomColumnCount] := ColumnCaption;
    end;

    procedure SetCustomColumnValue(RecordPosition: Text[250];RowIndex: Integer;ColumnName: Text[50];Value: Text[50])
    var
        DataRow: DotNet npNetDataRow;
        DataField: DotNet npNetDataColumn;
        Itt: Integer;
        ColumnIndex: Integer;
        PositionIndex: Integer;
        Boolean: Boolean;
    begin
        ColumnIndex   := DotNetDataTable.Columns.IndexOf(ColumnName);
        //FOR Itt := 0 TO DotNetDataTable.Rows().Count - 1 DO BEGIN
        if not Evaluate(Boolean,Value) then
          DotNetDataTable.Rows.Item(RowIndex).Item(ColumnIndex,Value)
        else
          DotNetDataTable.Rows.Item(RowIndex).Item(ColumnIndex,Boolean);
        //  IF FORMAT(DataRow.Item('Position')) = RecordPosition THEN Itt := DotNetDataTable.Rows().Count;
        //END;
    end;

    procedure "---- Aux. ------"()
    begin
    end;

    procedure SetDefaultValues()
    begin
        TestAndSetInt(MaxFieldCount,100);
        TestAndSetInt(MaxRowCount,100);
    end;

    procedure SetMaxFieldCount(MaxFieldCountIn: Integer)
    begin
        MaxFieldCount := MaxFieldCountIn;
    end;

    procedure SetMaxRowCount(MaxRowCountIn: Integer)
    begin
        MaxRowCount := MaxRowCountIn;
    end;

    procedure TestAndSetInt(var VarToSet: Integer;ValueToSet: Integer)
    begin
        if not (VarToSet > 0) then
          VarToSet := ValueToSet;
    end;

    procedure m(VarParm: Variant)
    begin
        Message(Format(VarParm));
    end;

    trigger DotNetDataTable::ColumnChanging(sender: Variant;e: DotNet npNetDataColumnChangeEventArgs)
    begin
    end;

    trigger DotNetDataTable::ColumnChanged(sender: Variant;e: DotNet npNetDataColumnChangeEventArgs)
    begin
    end;

    trigger DotNetDataTable::Initialized(sender: Variant;e: DotNet npNetEventArgs)
    begin
    end;

    trigger DotNetDataTable::RowChanged(sender: Variant;e: DotNet npNetDataRowChangeEventArgs)
    begin
    end;

    trigger DotNetDataTable::RowChanging(sender: Variant;e: DotNet npNetDataRowChangeEventArgs)
    begin
    end;

    trigger DotNetDataTable::RowDeleting(sender: Variant;e: DotNet npNetDataRowChangeEventArgs)
    begin
    end;

    trigger DotNetDataTable::RowDeleted(sender: Variant;e: DotNet npNetDataRowChangeEventArgs)
    begin
    end;

    trigger DotNetDataTable::TableClearing(sender: Variant;e: DotNet npNetDataTableClearEventArgs)
    begin
    end;

    trigger DotNetDataTable::TableCleared(sender: Variant;e: DotNet npNetDataTableClearEventArgs)
    begin
    end;

    trigger DotNetDataTable::TableNewRow(sender: Variant;e: DotNet npNetDataTableNewRowEventArgs)
    begin
    end;

    trigger DotNetDataTable::Disposed(sender: Variant;e: DotNet npNetEventArgs)
    begin
    end;
}

