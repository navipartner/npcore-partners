page 6060026 "GIM - Import Buffer by Columns"
{
    Caption = 'GIM - Import Buffer by Columns';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SourceTable = "Integer";
    SourceTableView = SORTING(Number)
                      WHERE(Number=CONST(1));

    layout
    {
        area(content)
        {
            group("Matrix options")
            {
                Caption = 'Matrix options';
                field(ColumnSet;ColumnSet)
                {
                    Caption = 'Column Set';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ShowMatrix)
            {
                Caption = 'Show Matrix';
                Image = ShowMatrix;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    BufferMatrix: Page "GIM - Import Buffer Matrix";
                begin
                    if MatrixColCaption[1] <> '' then begin
                      BufferMatrix.SetDocNo(DocNo);
                      BufferMatrix.SetMatrixColumnCaptions(MatrixColCaption);
                      BufferMatrix.Run;
                    end;
                end;
            }
            action(PreviousSet)
            {
                Caption = 'Previous Set';
                Image = PreviousSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    GetPreviousSet();
                end;
            }
            action(NextSet)
            {
                Caption = 'Next Set';
                Image = NextSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    GetNextSet();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        ColumnSetSize := ArrayLen(MatrixColCaption);
        GetNextSet();
    end;

    var
        ColumnSet: Text[30];
        ColumnSetSize: Integer;
        MatrixColCaption: array [30] of Text[50];
        MappingTable: Record "GIM - Mapping Table";
        MappingTable2: Record "GIM - Mapping Table";
        DocNo: Code[20];

    local procedure GetNextSet()
    var
        WorkingCode: Integer;
    begin
        MappingTable.Reset;
        MappingTable.SetRange("Document No.",DocNo);
        MappingTable2.SetCurrentKey("Column No.");
        MappingTable2.SetRange("Document No.",DocNo);
        if ColumnSet <> '' then begin
          MappingTable2.SetFilter("Column No.",ColumnSet);
          WorkingCode := MappingTable2.GetRangeMax("Column No.");
          MappingTable2.SetRange("Column No.",WorkingCode);
          MappingTable2.FindFirst;
          MappingTable2.SetRange("Column No.");
          if MappingTable2.Next <> 0 then begin
            MappingTable.SetFilter("Column No.",'%1..',MappingTable2."Column No.");
            SearchForward();
          end else
            exit;
        end else
          SearchForward();
    end;

    local procedure GetPreviousSet()
    var
        WorkingCode: Integer;
    begin
        MappingTable.Reset;
        MappingTable.SetRange("Document No.",DocNo);
        MappingTable2.SetCurrentKey("Column No.");
        MappingTable2.SetRange("Document No.",DocNo);
        if ColumnSet <> '' then begin
          MappingTable2.SetFilter("Column No.",ColumnSet);
          WorkingCode := MappingTable2.GetRangeMin("Column No.");
          MappingTable2.SetRange("Column No.",WorkingCode);
          MappingTable2.FindFirst;
          MappingTable2.SetRange("Column No.");
          if MappingTable2.Next(-1) <> 0 then begin
            MappingTable.SetFilter("Column No.",'..%1',MappingTable2."Column No.");
            SearchBackward();
          end else
            exit;
        end else
          SearchBackward();
    end;

    local procedure SearchForward()
    var
        i: Integer;
        StopIteration: Boolean;
        FirstColumnNo: Integer;
        LastColumnNo: Integer;
    begin
        i := 1;
        MappingTable.SetRange("Document No.",DocNo);
        if MappingTable.FindSet then
          repeat
            if MappingTable."Column No." <> 0 then begin
              if i = 1 then
                FirstColumnNo := MappingTable."Column No.";
              LastColumnNo := MappingTable."Column No.";
              MatrixColCaption[i] := MappingTable."Column Name";
              StopIteration := i = ColumnSetSize;
              if not StopIteration then
                i += 1;
            end;
            if not StopIteration then
              StopIteration := MappingTable.Next = 0;
          until StopIteration;

        if FirstColumnNo <> LastColumnNo then
          ColumnSet := Format(FirstColumnNo) + '..' + Format(LastColumnNo)
        else
          ColumnSet := Format(FirstColumnNo);
    end;

    local procedure SearchBackward()
    var
        i: Integer;
        StopIteration: Boolean;
        FirstColumnNo: Integer;
        LastColumnNo: Integer;
    begin
        i := 1;
        MappingTable.SetRange("Document No.",DocNo);
        if MappingTable.FindLast then
          repeat
            if MappingTable."Column No." <> 0 then begin
              if i = 1 then
                LastColumnNo := MappingTable."Column No.";
              FirstColumnNo := MappingTable."Column No.";
              MatrixColCaption[i] := MappingTable."Column Name";
              StopIteration := i = ColumnSetSize;
              if not StopIteration then
                i += 1;
            end;
            if not StopIteration then
              StopIteration := MappingTable.Next(-1) = 0;
          until StopIteration;

        if FirstColumnNo <> LastColumnNo then
          ColumnSet := Format(FirstColumnNo) + '..' + Format(LastColumnNo)
        else
          ColumnSet := Format(LastColumnNo);
    end;

    procedure SetDocNo(DocNoHere: Code[20])
    begin
        DocNo := DocNoHere;
    end;
}

