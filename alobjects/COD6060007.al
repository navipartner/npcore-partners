codeunit 6060007 "GIM - Data Create Test Runner"
{
    Subtype = TestRunner;
    TableNo = "GIM - Import Document";
    TestIsolation = Codeunit;

    trigger OnRun()
    begin
        ImpDoc := Rec;
        TestCodeunit.SetImpDoc(ImpDoc."No.");
        TestCodeunit.Run;
    end;

    var
        TestCodeunit: Codeunit "GIM - Data Create Test";
        EntNo: Code[20];
        EntType: Integer;
        StartingAt: DateTime;
        ErrLog: Record "GIM - Error Log";
        ImpDoc: Record "GIM - Import Document";
        PreviewData2: Boolean;
        TableID: Integer;
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";

    trigger OnBeforeTestRun(CodeunitID: Integer;CodeunitName: Text;FunctionName: Text;TestPermission: TestPermissions): Boolean
    begin
        StartingAt := CurrentDateTime;
        exit(true);
    end;

    trigger OnAfterTestRun(CodeunitID: Integer;CodeunitName: Text;FunctionName: Text;TestPermission: TestPermissions;Success: Boolean)
    begin
        if not Success then begin
          if not PreviewData2 then begin
            if FunctionName <> '' then
              ErrLog.InsertLine(0,0,ImpDoc."No.",StartingAt,CurrentDateTime,CopyStr(GetLastErrorText,1,250),CodeunitID,CodeunitName,FunctionName,0,0,0)
          end else
            Error(GetLastErrorText);
        end else if FunctionName = 'CreateData' then begin
          if PreviewData2 then begin
            MarkRecords();
            Preview();
          end;
          UpdateValidationResults();
        end;
    end;

    procedure SetEntity2(PreviewDataHere: Boolean;TableIDHere: Integer)
    begin
        PreviewData2 := PreviewDataHere;
        TableID := TableIDHere;
    end;

    local procedure Preview()
    begin
        if PreviewData2 then begin
          case TableID of
            DATABASE::Item:
              begin
                Item.SetRange("No.");
                Item.MarkedOnly(true);
                PAGE.RunModal(0,Item);
              end;
            DATABASE::"Sales Header":
              begin
                SalesHeader.SetRange("Document Type");
                SalesHeader.SetRange("No.");
                SalesHeader.MarkedOnly(true);
                PAGE.RunModal(0,SalesHeader);
              end;
            DATABASE::"Purchase Header":
              begin
                PurchaseHeader.SetRange("Document Type");
                PurchaseHeader.SetRange("No.");
                PurchaseHeader.MarkedOnly(true);
                PAGE.RunModal(0,PurchaseHeader);
              end;
          end;
        end;
    end;

    local procedure MarkRecords()
    var
        RecRef: RecordRef;
        PKFieldIDs: array [10] of Integer;
        PKFieldValues: array [10] of Text[250];
        ImpEntity: Record "GIM - Import Entity";
        FldRef: FieldRef;
        PKRef: KeyRef;
        KeyFieldCount: Integer;
        RowCount: Integer;
        ImpEntValue: Text[250];
        LastRow: Integer;
    begin
        ImpEntity.SetCurrentKey("Row No.");
        ImpEntity.SetRange("Document No.",ImpDoc."No.");
        ImpEntity.SetRange("Table ID",TableID);
        ImpEntity.SetRange("Part of Primary Key",true);
        if ImpEntity.FindLast then
          LastRow := ImpEntity."Row No.";

        RecRef.Open(TableID);
        PKRef := RecRef.KeyIndex(1);
        RecRef.Close;

        for RowCount := 1 to LastRow do begin
          ImpEntity.SetRange("Row No.",RowCount);
          for KeyFieldCount := 1 to PKRef.FieldCount do begin
            FldRef := PKRef.FieldIndex(KeyFieldCount);
            ImpEntity.SetRange("Field ID",FldRef.Number);
            if ImpEntity.FindFirst then begin
              if ImpEntity."Current Value" <> '' then
                ImpEntValue := ImpEntity."Current Value"
              else
                ImpEntValue := ImpEntity."New Value";
              PKFieldValues[KeyFieldCount] := ImpEntValue;
            end;
          end;
          case TableID of
            DATABASE::Item:
              begin
                Item.SetFilter("No.",PKFieldValues[1]);
                if Item.FindFirst then
                  Item.Mark(true);
              end;
            DATABASE::"Sales Header":
              begin
                SalesHeader.SetFilter("Document Type",PKFieldValues[1]);
                SalesHeader.SetFilter("No.",PKFieldValues[2]);
                if SalesHeader.FindFirst then
                  SalesHeader.Mark(true);
              end;
            DATABASE::"Purchase Header":
              begin
                PurchaseHeader.SetFilter("Document Type",PKFieldValues[1]);
                PurchaseHeader.SetFilter("No.",PKFieldValues[2]);
                if PurchaseHeader.FindFirst then
                  PurchaseHeader.Mark(true);
              end;
          end;
        end;
    end;

    local procedure UpdateValidationResults()
    var
        ImpEntity: Record "GIM - Import Entity";
        ImpEntity2: Record "GIM - Import Entity";
        RecRef: RecordRef;
        FldRef: FieldRef;
        RowCount: Integer;
        LastRow: Integer;
        TableIDHere: Integer;
        ImpEntValue: Text[250];
    begin
        ImpEntity.SetCurrentKey("Row No.");
        ImpEntity.SetRange("Document No.",ImpDoc."No.");
        if ImpEntity.FindLast then
          LastRow := ImpEntity."Row No.";

        for RowCount := 1 to LastRow do begin
          TableIDHere := 0;
          ImpEntity.SetCurrentKey("Table ID");
          ImpEntity.SetRange("Row No.",RowCount);
          if ImpEntity.FindSet then
            repeat
              if TableIDHere <> ImpEntity."Table ID" then begin
                RecRef.Open(ImpEntity."Table ID");
                ImpEntity2.SetRange("Document No.",ImpDoc."No.");
                ImpEntity2.SetRange("Row No.",RowCount);
                ImpEntity2.SetRange("Table ID",ImpEntity."Table ID");
                ImpEntity2.SetRange("Part of Primary Key",true);
                if ImpEntity2.FindSet then
                  repeat
                    if ImpEntity2."Current Value" <> '' then
                      ImpEntValue := ImpEntity2."Current Value"
                    else
                      ImpEntValue := ImpEntity2."New Value";
                    FldRef := RecRef.Field(ImpEntity2."Field ID");
                    FldRef.SetFilter(ImpEntValue);
                  until ImpEntity2.Next = 0;
                if RecRef.FindFirst then begin
                  ImpEntity2.SetRange("Document No.",ImpDoc."No.");
                  ImpEntity2.SetRange("Row No.",RowCount);
                  ImpEntity2.SetRange("Table ID",ImpEntity."Table ID");
                  ImpEntity2.SetRange("Part of Primary Key",false);
                  if ImpEntity2.FindSet then
                    repeat
                      Clear(FldRef);
                      FldRef := RecRef.Field(ImpEntity2."Field ID");
                      if (ImpEntity2."Validation Value" = '') and (Format(FldRef) <> '') then begin
                        ImpEntity2."Validation Value" := Format(FldRef);
                        if ImpEntity2."New Value" = '' then
                          ImpEntity2."New Value" := ImpEntity2."Validation Value";
                        ImpEntity2.Modify;
                      end;
                    until ImpEntity2.Next = 0;
                end;
                TableIDHere := ImpEntity."Table ID";
                RecRef.Close;
              end;
            until ImpEntity.Next = 0;
        end;
    end;
}

