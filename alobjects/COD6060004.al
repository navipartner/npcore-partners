codeunit 6060004 "GIM - Data Creation"
{
    TableNo = "GIM - Import Document";

    trigger OnRun()
    var
        LastRow: Integer;
        i: Integer;
        RecRef: RecordRef;
    begin
        GIMImportDoc := Rec;

        MapTableLine.SetCurrentKey(Priority);
        ImpEntity.SetCurrentKey("Row No.","Table ID","Column No.","Field ID");
        ImpEntity.SetRange("Document No.",GIMImportDoc."No.");
        if TableID <> 0 then
          ImpEntity.SetRange("Table ID",TableID);
        if ImpEntity.FindLast then
          LastRow := ImpEntity."Row No."
        else
          Error(Text001);

        MapTableLine.SetRange("Document No.",GIMImportDoc."No.");
        if TableID <> 0 then
          MapTableLine.SetRange("Table ID",TableID);
        if MapTableLine.FindSet then
          repeat
            for i := 1 to LastRow do begin
              ImpEntity.SetRange("Row No.",i);
              ImpEntity.SetRange("Table ID",MapTableLine."Table ID");
              ImpEntity.SetRange("Mapping Table Line No.",MapTableLine."Line No.");
              ImpEntity.SetRange("Part of Primary Key",true);
              if ImpEntity.FindSet then begin
                RecRef.Open(MapTableLine."Table ID");
                RecRef.Reset;
                repeat
                  FldRef := RecRef.Field(ImpEntity."Field ID");
                  FilterFieldRefOrAssignValue(false);
                until ImpEntity.Next = 0;
                if not RecRef.FindFirst then begin
                  ImpEntity.SetRange("Entity Action",ImpEntity."Entity Action"::Insert);
                  if ImpEntity.FindSet then
                    repeat
                      FldRef := RecRef.Field(ImpEntity."Field ID");
                      FilterFieldRefOrAssignValue(true);
                    until ImpEntity.Next = 0;
                  RecRef.Insert(true);
                end;
                ImpEntity.SetRange("Entity Action");
                ImpEntity.SetRange("Part of Primary Key",false);
                if ImpEntity.FindSet then begin
                  repeat
                    FldRef := RecRef.Field(ImpEntity."Field ID");
                    case ImpEntity."Entity Action" of
                      ImpEntity."Entity Action"::Insert:
                        FilterFieldRefOrAssignValue(true);
                      ImpEntity."Entity Action"::Modify:
                        if ImpEntity."Current Value" <> Format(FldRef) then
                          FilterFieldRefOrAssignValue(true);
                    end;
                  until ImpEntity.Next = 0;
                  RecRef.Modify(true);
                end;
                RecRef.Close;
              end;
            end;
          until MapTableLine.Next = 0;
    end;

    var
        GIMImportDoc: Record "GIM - Import Document";
        ImpEntity: Record "GIM - Import Entity";
        MapTableLine: Record "GIM - Mapping Table Line";
        Text001: Label 'No import entities found.';
        FldRef: FieldRef;
        TableID: Integer;

    local procedure FilterFieldRefOrAssignValue(Assign: Boolean)
    begin
        case UpperCase(ImpEntity."Data Type") of
          'TEXT','CODE':
            if Assign then begin
              if ImpEntity."Validate Field" then
                FldRef.Validate(ImpEntity."Text Value")
              else
                FldRef.Value(ImpEntity."Text Value")
            end else
              FldRef.SetRange(ImpEntity."Text Value");
          'INTEGER','OPTION':
            if Assign then
              if ImpEntity."Validate Field" then
                FldRef.Validate(ImpEntity."Integer Value")
              else
                FldRef.Value(ImpEntity."Integer Value")
            else
              FldRef.SetRange(ImpEntity."Integer Value");
          'DECIMAL':
            if Assign then
              if ImpEntity."Validate Field" then
                FldRef.Validate(ImpEntity."Decimal Value")
              else
                FldRef.Value(ImpEntity."Decimal Value")
            else
              FldRef.SetRange(ImpEntity."Decimal Value");
          'DATE':
            if Assign then
              if ImpEntity."Validate Field" then
                FldRef.Validate(ImpEntity."Date Value")
              else
                FldRef.Value(ImpEntity."Date Value")
            else
              FldRef.SetRange(ImpEntity."Date Value");
          'TIME':
            if Assign then
              if ImpEntity."Validate Field" then
                FldRef.Validate(ImpEntity."Time Value")
              else
                FldRef.Value(ImpEntity."Time Value")
            else
              FldRef.SetRange(ImpEntity."Time Value");
          'DATETIME':
            if Assign then
              if ImpEntity."Validate Field" then
                FldRef.Validate(ImpEntity."Datetime Value")
              else
                FldRef.Value(ImpEntity."Datetime Value")
            else
              FldRef.SetRange(ImpEntity."Datetime Value");
          'BOOLEAN':
            if Assign then
              if ImpEntity."Validate Field" then
                FldRef.Validate(ImpEntity."Boolean Value")
              else
                FldRef.Value(ImpEntity."Boolean Value")
            else
              FldRef.SetRange(ImpEntity."Boolean Value");
          'DATEFORMULA':
            if Assign then
              if ImpEntity."Validate Field" then
                FldRef.Validate(ImpEntity."DateFormula Value")
              else
                FldRef.Value(ImpEntity."DateFormula Value")
            else
              FldRef.SetRange(ImpEntity."DateFormula Value");
        end;
    end;

    procedure SetTableID(TableIDHere: Integer)
    begin
        TableID := TableIDHere;
    end;
}

