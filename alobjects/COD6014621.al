codeunit 6014621 "POS Web Utilities"
{
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.11/VB/20150629 CASE 213003 Support for Web Client (JavaScript) client - additional changes
    // NPR4.14/VB/20150909 CASE 222539 Show Behavior for buttons implemented
    // NPR4.14/VB/20150909 CASE 222602 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.14/VB/20150925 CASE 222938 Version increase for NaviPartner.POS.Web assembly reference(s), due to refactoring of QUANTITY_POS and QUANTITY_NEG functions.
    // NPR4.14/VB/20151001 CASE 224232 Number formatting
    // NPR4.15/VB/20150930 CASE 224237 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR9   /VB/20150104 CASE 225607 Changed references for compiling under NAV 2016
    // NPR5.00/VB/20160106 CASE 231100 Update .NET version from 1.9.1.305 to 1.9.1.369
    // NPR5.00.03/VB/20160106 CASE 231100 Update .NET version from 1.9.1.369 to 5.0.398.0
    // NPR5.01/VB/20160210 CASE 233406 Sending information about negative field values to JavaScript (to avoid issue with decimal formatting and determining negative values client-side)
    // NPR5.20/VB/20160301 CASE 235809 Removed FieldName constant and replaced its usage with hardcoded string. It's not a localizable string, and allowing localization for it has proven dangerous.
    // NPR5.22/VB/20160407 CASE 237866 GetPosition formatting changed
    // NPR5.40/BHR /20180322 CASE 308408 Rename variable Grid to PageGrid


    trigger OnRun()
    begin
    end;

    var
        Direction: Option TopBottom,LeftRight;

    procedure AssignColorFromLine(MenuLine: Record "Touch Screen - Menu Lines";Button: DotNet Button)
    var
        ButtonColor: DotNet ButtonColor;
    begin
        case MenuLine."Button Styling" of
          MenuLine."Button Styling"::Green:       Button.Color := ButtonColor.Green;
          MenuLine."Button Styling"::Red:         Button.Color := ButtonColor.Red;
          MenuLine."Button Styling"::"Dark Red":  Button.Color := ButtonColor.DarkRed;
          MenuLine."Button Styling"::Grey:        Button.Color := ButtonColor.Gray;
          MenuLine."Button Styling"::Purple:      Button.Color := ButtonColor.Purple;
          MenuLine."Button Styling"::Indigo:      Button.Color := ButtonColor.Indigo;
          MenuLine."Button Styling"::Yellow:      Button.Color := ButtonColor.Yellow;
          MenuLine."Button Styling"::Orange:      Button.Color := ButtonColor.Orange;
          MenuLine."Button Styling"::White:       Button.Color := ButtonColor.White;
          else
            Button.Color := ButtonColor.Default;
        end;
    end;

    procedure AssignShowBehaviorFromLine(MenuLine: Record "Touch Screen - Menu Lines";Button: DotNet Button)
    var
        ShowBehavior: DotNet ShowBehavior;
    begin
        case MenuLine."Show Behavior" of
          MenuLine."Show Behavior"::Always:       Button.ShowBehavior := ShowBehavior.Always;
          MenuLine."Show Behavior"::Desktop:      Button.ShowBehavior := ShowBehavior.Desktop;
          MenuLine."Show Behavior"::App:          Button.ShowBehavior := ShowBehavior.App;
        end;
    end;

    procedure FilterContains(Value: Text): Text
    begin
        if Value = '' then
          exit('');

        exit(StrSubstNo('%1|(%1,*)|(*,%1)|(*,%1,*)',Value));
    end;

    procedure FilterContainsOrBlank(Value: Text): Text
    begin
        if Value = '' then
          exit('');

        exit(StrSubstNo('%2|%1|(%1,*)|(*,%1)|(*,%1,*)',Value,''''''));
    end;

    procedure MenuInitializePlacementBuffer(var IntTmp: Record "Integer" temporary;x: Integer;y: Integer)
    var
        i: Integer;
    begin
        IntTmp.Reset;
        IntTmp.DeleteAll;
        for i := 1 to x * y do begin
          IntTmp.Number := i;
          IntTmp.Insert;
        end;
    end;

    procedure MenuDeletePlacementBuffer(var IntTmp: Record "Integer" temporary;x: Integer;y: Integer;Rows: Integer;Columns: Integer;Direction: Option TopBottom,LeftRight)
    begin
        IntTmp.Number := MenuXYToPlacementID(x,y,Rows,Columns,Direction);
        IntTmp.Delete;
    end;

    procedure MenuFindAvailablePlacementID(var IntTmp: Record "Integer" temporary;PlacementID: Integer): Integer
    begin
        with IntTmp do begin
          Number := PlacementID;
          if not Find('=>') then
            FindFirst;

          exit(Number);
        end;
    end;

    procedure MenuXYToPlacementID(x: Integer;y: Integer;Rows: Integer;Columns: Integer;Direction: Option TopBottom,LeftRight): Integer
    begin
        case Direction of
          Direction::TopBottom: exit((x - 1) * Rows + y);
          Direction::LeftRight: exit((y - 1) * Columns + x);
        end;
    end;

    procedure MenuPlacementIDToX(PlacementID: Integer;Rows: Integer;Columns: Integer;Direction: Option TopBottom,LeftRight): Integer
    var
        x: Integer;
        y: Integer;
    begin
        case Direction of
          Direction::TopBottom: exit((PlacementID - 1) div Rows + 1);
          Direction::LeftRight:
            begin
              x := PlacementID mod Columns;
              if x = 0 then
                x := Columns;
              exit(x);
            end;
        end;
    end;

    procedure MenuPlacementIDToY(PlacementID: Integer;Rows: Integer;Columns: Integer;Direction: Option TopBottom,LeftRight): Integer
    var
        y: Integer;
    begin
        case Direction of
          Direction::TopBottom:
            begin
              y := PlacementID mod Rows;
              if y = 0 then
                y := Rows;
              exit(y);
            end;
          Direction::LeftRight:
            exit((PlacementID - 1) div Columns + 1);
        end;
    end;

    procedure JavaScriptNameFromField(No: Integer;Name: Text): Text
    begin
        //-NPR5.20
        //EXIT(STRSUBSTNO(FieldName,No,Name));
        exit(StrSubstNo('Field_%1',No,Name));
        //+NPR5.20
    end;

    procedure NavRecordToRows(var RecRef: RecordRef;PageGrid: DotNet DataGrid)
    var
        Row: DotNet Dictionary_Of_T_U;
        Template: DotNet Template;
        CurrRecPosition: Text;
    begin
        //-NPR5.40 [308408]
        //Grid.Rows.Clear();
        PageGrid.Rows.Clear();
        //-NPR5.40 [308408]
        CurrRecPosition := RecRef.GetPosition();
        if RecRef.FindSet then
          repeat
            //-NPR5.40 [308408]
            //Row := Grid.NewRow();
            Row := PageGrid.NewRow();
            //-NPR5.40 [308408]
            NavOneRecordToDictionary(RecRef,Row,Template);
            if RecRef.GetPosition() = CurrRecPosition then
              Row.Add('__selected__',true);
          until RecRef.Next = 0;
        RecRef.SetPosition(CurrRecPosition);
    end;

    procedure NavRecordToRowsMarked(var RecRef: RecordRef;PageGrid: DotNet DataGrid)
    var
        Row: DotNet Dictionary_Of_T_U;
        i: Integer;
    begin
        //-NPR5.40 [308408]
        //NavRecordToRows(RecRef,Grid);
        //FOR i := 0 TO Grid.Rows.Count - 1 DO BEGIN
        //  Row := Grid.Rows.Item(i);
        NavRecordToRows(RecRef,PageGrid);
        for i := 0 to PageGrid.Rows.Count - 1 do begin
          Row := PageGrid.Rows.Item(i);
        //+NPR5.40 [308408]
          Row.Add('__marked__',true);
        end;
    end;

    local procedure NavFormatField("Field": FieldRef) String: Text
    var
        UI: Codeunit "POS Web UI Management";
        Option: Integer;
        Dec: Decimal;
        BigInt: BigInteger;
    begin
        if UpperCase(Format(Field.Class)) = 'FLOWFIELD' then
          Field.CalcField;
        case UpperCase(Format(Field.Type)) of
          'DATE','DATETIME','TIME','BOOLEAN':
            String := Format(Field.Value,0,9);
          'DECIMAL':
            begin
              Dec := Field.Value;
              String := UI.FormatDecimal(Dec);
            end;
          'INTEGER','BIGINTEGER':
            begin
              BigInt := Field.Value;
              String := UI.FormatInteger(BigInt);
            end;
          'OPTION':
            begin
              Option := Field.Value;
              String := Format(Option,0,9);
            end;
          else
            String := Format(Field.Value);
        end;
    end;

    local procedure IsKeyField(RecRef: RecordRef;FieldRef: FieldRef): Boolean
    var
        KeyRef: KeyRef;
        i: Integer;
    begin
        //-224334
        KeyRef := RecRef.KeyIndex(1);
        for i := 1 to KeyRef.FieldCount do
          if KeyRef.FieldIndex(i).Number = FieldRef.Number then
            exit(true);

        exit(false);
        //+224334
    end;

    procedure NavOneRecordToDictionary(var RecRef: RecordRef;Row: DotNet Dictionary_Of_T_U;Template: DotNet Template)
    var
        FieldRecord: Record "Field";
        UI: Codeunit "POS Web UI Management";
        "Field": FieldRef;
        FieldNo: Integer;
        RelatedRecord: RecordRef;
        RelatedField: FieldRef;
        KeyRef: KeyRef;
        KeyField: FieldRef;
        i: Integer;
        String: Text;
        Option: Integer;
        IncludeField: Boolean;
        RelatedTableFieldId: Integer;
        Dec: Decimal;
    begin
        Row.Clear();
        //-NPR5.22
        //Row.Add('__position__',RecRef.GETPOSITION());
        Row.Add('__position__',RecRef.GetPosition(false));
        //+NPR5.22

        for i := 1 to RecRef.FieldCount do begin
          Field := RecRef.FieldIndex(i);
          FieldNo := Field.Number;
          if not IsNull(Template) then begin
            IncludeField := Template.ContainsField(Field.Number);
            RelatedTableFieldId := Template.GetRelatedFieldId(Field.Number);
          end else begin
            //-224334
            //IncludeField := TRUE;
            FieldRecord.Get(RecRef.Number,Field.Number);
            case RecRef.Number of
              DATABASE::"Sale Line POS":
                IncludeField := UI.IncludeFieldSale(FieldRecord) or UI.IncludeFieldPayment(FieldRecord) or UI.IncludeFieldExchangeLabels(FieldRecord);
              DATABASE::"Payment Type POS":
                IncludeField := UI.IncludeFieldBalancing(FieldRecord);
              else
                IncludeField := true;
            end;
            IncludeField := IncludeField or IsKeyField(RecRef,Field);
            //+224334
            RelatedTableFieldId := 0;
          end;

          if IncludeField and (not (UpperCase(Format(Field.Type)) in ['BLOB','BINARY','DATEFORMULA','RECORDID','TABLEFILTER'])) then begin
            String := NavFormatField(Field);
            if (Field.Relation <> 0) and (RelatedTableFieldId <> 0) then begin
              RelatedRecord.Open(Field.Relation);
              KeyRef := RelatedRecord.KeyIndex(1);
              KeyField := KeyRef.FieldIndex(1);
              KeyField.Value := String;
              if RelatedRecord.Find then begin
                RelatedField := RelatedRecord.Field(RelatedTableFieldId);
                String := NavFormatField(RelatedField);
              end;
              RelatedRecord.Close();
            end;
            Row.Add(JavaScriptNameFromField(Field.Number,Field.Name),String);
            //-NPR5.01
            if (UpperCase(Format(Field.Type)) in ['DECIMAL','INTEGER','BIGINTEGER']) then begin
              Dec := Field.Value;
              if Dec < 0 then
                Row.Add(JavaScriptNameFromField(Field.Number,Field.Name) + '_Negative',true);
            end;
            //+NPR5.01
          end;
        end;
    end;

    procedure RowToNavRecord(Row: DotNet Dictionary_Of_T_U;var RecRef: RecordRef)
    var
        UI: Codeunit "POS Web UI Management";
        "Field": FieldRef;
        i: Integer;
        Date: Date;
        Time: Integer;
        DateTime: DateTime;
        Decimal: Decimal;
        Boolean: Boolean;
        String: Text;
        BigInt: BigInteger;
        FieldName: Text;
    begin
        RecRef.Init;
        for i := 1 to RecRef.FieldCount do begin
          Field := RecRef.FieldIndex(i);
          if not (UpperCase(Format(Field.Type)) in ['BLOB','BINARY','DATEFORMULA','RECORDID','TABLEFILTER']) then begin
            FieldName := JavaScriptNameFromField(Field.Number,Field.Name);
            if Row.ContainsKey(FieldName) then begin
              String := Row.Item(FieldName);
              if not (String in ['null','undefined']) then
                case UpperCase(Format(Field.Type)) of
                  'DATE':
                    begin
                      Evaluate(Date,String,9);
                      Field.Value := Date;
                    end;
                  'DATETIME':
                    begin
                      Evaluate(DateTime,String,9);
                      Field.Value := DateTime;
                    end;
                  'TIME':
                    begin
                      Evaluate(Time,String,9);
                      Field.Value := Time;
                    end;
                  'BOOLEAN':
                    begin
                      Evaluate(Boolean,String,9);
                      Field.Value := Boolean;
                    end;
                  'DECIMAL':
                    begin
                      Field.Value := UI.ParseDecimal(String);
                    end;
                  'INTEGER','BIGINTEGER','OPTION':
                    begin
                      Field.Value := UI.ParseInteger(String);
                    end;
                  else
                    Field.Value := String;
                end;
            end;
          end;
        end;
    end;

    procedure CountOfChar(Value: Text;Separator: Char): Integer
    var
        String: DotNet String;
        Char: Char;
        ArrayOfChar: DotNet Array;
    begin
        String := Value;
        ArrayOfChar := ArrayOfChar.CreateInstance(GetDotNetType(Separator),1);
        ArrayOfChar.SetValue(Separator,0);
        exit(String.Split(ArrayOfChar).Length - 1);
    end;
}

