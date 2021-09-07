codeunit 6151130 "NPR TM Seating Mgt."
{
    procedure AddRoot(AdmissionCode: Code[20]; pDescription: Text[80]) EntryNo: Integer
    var
        SeatingTemplate: Record "NPR TM Seating Template";
        PathLbl: Label '/%1', Locked = true;
    begin

        SeatingTemplate.Init();
        SeatingTemplate.Insert();

        SeatingTemplate."Admission Code" := AdmissionCode;
        SeatingTemplate.Description := pDescription;
        SeatingTemplate.Path := StrSubstNo(PathLbl, SeatingTemplate."Entry No.");
        SeatingTemplate.Ordinal := SeatingTemplate."Entry No.";
        SeatingTemplate."Entry Type" := SeatingTemplate."Entry Type"::NODE;
        SeatingTemplate."Reservation Category" := SeatingTemplate."Reservation Category"::NA;
        SeatingTemplate."Indent Level" := 0;
        SeatingTemplate.Description := 'Root';
        SeatingTemplate."Entry Type" := SeatingTemplate."Entry Type"::LEAF;
        SeatingTemplate.Modify();

        exit(SeatingTemplate."Entry No.");
    end;

    procedure AddChild(ParentEntryNo: Integer) EntryNo: Integer
    begin

        exit(AddChildWorker(ParentEntryNo, ''));
    end;

    procedure AddChildWorker(ParentEntryNo: Integer; Description: Text[80]) EntryNo: Integer
    var
        ParentSeatingTemplate: Record "NPR TM Seating Template";
        SeatingTemplate: Record "NPR TM Seating Template";
        PathLbl: Label '%1/%2', Locked = true;
        DescriptionLbl: Label 'Level %1';
    begin

        ParentSeatingTemplate.Get(ParentEntryNo);
        if (ParentSeatingTemplate."Entry Type" = ParentSeatingTemplate."Entry Type"::LEAF) then begin
            ParentSeatingTemplate."Entry Type" := ParentSeatingTemplate."Entry Type"::NODE;
            ParentSeatingTemplate.Capacity := 0;
            ParentSeatingTemplate.Modify();
        end;

        SeatingTemplate.Init();
        SeatingTemplate.Insert();

        SeatingTemplate.TransferFields(ParentSeatingTemplate, false);
        SeatingTemplate."Parent Entry No." := ParentEntryNo;
        SeatingTemplate."Indent Level" += 1;
        SeatingTemplate."Entry Type" := SeatingTemplate."Entry Type"::LEAF;
        SeatingTemplate."Unit Price" := 0;

        SeatingTemplate.Description := Description;
        if (Description = '') then
            SeatingTemplate.Description := StrSubstNo(DescriptionLbl, SeatingTemplate."Indent Level");

        ParentSeatingTemplate.SetFilter("Parent Entry No.", '=%1', ParentEntryNo);
        SeatingTemplate.Ordinal := ParentSeatingTemplate.Count() + 1;
        SeatingTemplate.Path := StrSubstNo(PathLbl, ParentSeatingTemplate.Path, Format(SeatingTemplate.Ordinal, 0, '<Integer,4><Filler Character,0>'));

        SeatingTemplate.Modify();

        exit(SeatingTemplate."Entry No.");
    end;

    procedure AddSibling(SiblingEntryNo: Integer) EntryNo: Integer
    var
        SeatingTemplate: Record "NPR TM Seating Template";
        SiblingLbl: Label '%1:2', Locked = true;
    begin

        SeatingTemplate.Get(SiblingEntryNo);
        if (SeatingTemplate.Get(SeatingTemplate."Parent Entry No.")) then;

        exit(AddSiblingWorker(SiblingEntryNo, StrSubstNo(SiblingLbl, SeatingTemplate.Description)));
    end;

    procedure AddSiblingWorker(SiblingEntryNo: Integer; Description: Text[80]) EntryNo: Integer
    var
        SiblingSeatingTemplate: Record "NPR TM Seating Template";
    begin

        SiblingSeatingTemplate.Get(SiblingEntryNo);

        if (SiblingSeatingTemplate."Parent Entry No." = 0) then
            exit(AddRoot(SiblingSeatingTemplate."Admission Code", Description));

        if (SiblingSeatingTemplate."Parent Entry No." <> 0) then
            exit(AddChildWorker(SiblingSeatingTemplate."Parent Entry No.", Description));
    end;

    procedure DeleteNode(EntryNo: Integer)
    var
        SeatingTemplate: Record "NPR TM Seating Template";
        ParentEntryNo: Integer;
    begin

        SeatingTemplate.Get(EntryNo);
        ParentEntryNo := SeatingTemplate."Parent Entry No.";

        DeleteNodeWorker(EntryNo);

        SeatingTemplate.SetCurrentKey("Parent Entry No.");
        SeatingTemplate.SetFilter("Parent Entry No.", '=%1', ParentEntryNo);
        if (SeatingTemplate.IsEmpty()) then begin
            if (SeatingTemplate.Get(ParentEntryNo)) then begin
                SeatingTemplate."Entry Type" := SeatingTemplate."Entry Type"::LEAF;
                SeatingTemplate.Modify();
            end;
        end;
    end;

    local procedure DeleteNodeWorker(EntryNo: Integer)
    var
        SeatingTemplate: Record "NPR TM Seating Template";
    begin

        SeatingTemplate.SetCurrentKey("Parent Entry No.");
        SeatingTemplate.SetFilter("Parent Entry No.", '=%1', EntryNo);
        if (SeatingTemplate.FindSet()) then begin
            repeat
                DeleteNodeWorker(SeatingTemplate."Entry No.");
            until (SeatingTemplate.Next() = 0);
        end;

        if (SeatingTemplate.Get(EntryNo)) then
            SeatingTemplate.Delete();
    end;

    procedure MoveNodeUp(RecToMove: Record "NPR TM Seating Template")
    var
        SeatingTemplate: Record "NPR TM Seating Template";
        RecCopy: Record "NPR TM Seating Template";
    begin

        SeatingTemplate.SetCurrentKey("Admission Code", Path);
        SeatingTemplate.SetFilter("Parent Entry No.", '=%1', RecToMove."Parent Entry No.");
        SeatingTemplate.SetFilter(Ordinal, '<%1', RecToMove.Ordinal);
        if (SeatingTemplate.FindLast()) then begin

            RecToMove.Get(RecToMove."Entry No.");
            RecCopy.Copy(RecToMove);
            RecToMove.Ordinal := SeatingTemplate.Ordinal;
            RecToMove.Path := SeatingTemplate.Path;
            RecToMove.Modify();

            SeatingTemplate.Ordinal := RecCopy.Ordinal;
            SeatingTemplate.Path := RecCopy.Path;
            SeatingTemplate.Modify();

            SwapSubNodes(SeatingTemplate."Admission Code", RecToMove.Path, SeatingTemplate.Path);
        end;
    end;

    procedure MoveNodeDown(RecToMove: Record "NPR TM Seating Template")
    var
        SeatingTemplate: Record "NPR TM Seating Template";
        RecCopy: Record "NPR TM Seating Template";
    begin

        SeatingTemplate.SetCurrentKey("Admission Code", Path);
        SeatingTemplate.SetFilter("Parent Entry No.", '=%1', RecToMove."Parent Entry No.");
        SeatingTemplate.SetFilter(Ordinal, '>%1', RecToMove.Ordinal);
        if (SeatingTemplate.FindFirst()) then begin

            RecToMove.Get(RecToMove."Entry No.");
            RecCopy.Copy(RecToMove);
            RecToMove.Ordinal := SeatingTemplate.Ordinal;
            RecToMove.Path := SeatingTemplate.Path;
            RecToMove.Modify();

            SeatingTemplate.Ordinal := RecCopy.Ordinal;
            SeatingTemplate.Path := RecCopy.Path;
            SeatingTemplate.Modify();

            SwapSubNodes(SeatingTemplate."Admission Code", RecToMove.Path, SeatingTemplate.Path);

        end;
    end;

    procedure SwapSubNodes(AdmissionCode: Code[20]; PathA: Text; PathB: Text)
    var
        TempSeatingTemplateA: Record "NPR TM Seating Template" temporary;
        TempSeatingTemplateB: Record "NPR TM Seating Template" temporary;
    begin

        UpdateTemporaryPathList(AdmissionCode, PathA, PathB, TempSeatingTemplateA);
        UpdateTemporaryPathList(AdmissionCode, PathB, PathA, TempSeatingTemplateB);

        UpdatePersistentTemplate(TempSeatingTemplateA, 0);
        UpdatePersistentTemplate(TempSeatingTemplateB, 0);
    end;

    local procedure ChangeParent(CurrentEntryNumber: Integer; NewParentEntryNumber: Integer)
    var
        CurrentTemplate: Record "NPR TM Seating Template";
        NewTemplate: Record "NPR TM Seating Template";
        TempSeatingTemplate: Record "NPR TM Seating Template" temporary;
        ParentSeatingTemplate: Record "NPR TM Seating Template";
        CurrentDepth: Integer;
        NewDepth: Integer;
        NewOrdinal: Integer;
        NewPath: Code[250];
        PathLbl: Label '%1/%2', Locked = true;
    begin

        CurrentTemplate.Get(CurrentEntryNumber);
        CurrentDepth := CurrentTemplate."Indent Level" - 1; // Parent depth

        NewTemplate.Get(NewParentEntryNumber);
        NewDepth := NewTemplate."Indent Level";

        ParentSeatingTemplate.SetFilter("Parent Entry No.", '=%1', NewParentEntryNumber);
        NewOrdinal := ParentSeatingTemplate.Count() + 1;
        NewPath := StrSubstNo(PathLbl, NewTemplate.Path, Format(CurrentTemplate.Ordinal, 0, '<Integer,4><Filler Character,0>'));

        UpdateTemporaryPathList(CurrentTemplate."Admission Code", CurrentTemplate.Path, NewPath, TempSeatingTemplate);
        UpdatePersistentTemplate(TempSeatingTemplate, (NewDepth - CurrentDepth));

        CurrentTemplate.Ordinal := NewOrdinal;
        CurrentTemplate.Path := NewPath;
        CurrentTemplate."Parent Entry No." := NewParentEntryNumber;
        CurrentTemplate.Modify();
    end;

    procedure IndentNode(RecToIndent: Record "NPR TM Seating Template")
    var
        SeatingTemplate: Record "NPR TM Seating Template";
        TempSeatingTemplate: Record "NPR TM Seating Template" temporary;
    begin

        SeatingTemplate.SetCurrentKey("Admission Code", Path);
        SeatingTemplate.SetFilter("Parent Entry No.", '=%1', RecToIndent."Parent Entry No.");
        SeatingTemplate.SetFilter(Ordinal, '<%1', RecToIndent.Ordinal);
        if (SeatingTemplate.FindLast()) then begin

            SeatingTemplate.Get(AddChild(SeatingTemplate."Entry No."));

            UpdateTemporaryPathList(RecToIndent."Admission Code", RecToIndent.Path, SeatingTemplate.Path, TempSeatingTemplate);
            UpdatePersistentTemplate(TempSeatingTemplate, 1);

            SeatingTemplate.Description := RecToIndent.Description;
            SeatingTemplate."Description 2" := RecToIndent."Description 2";
            RecToIndent.Delete();
        end
    end;

    procedure UnIndentNode(RecToUnIndent: Record "NPR TM Seating Template")
    var
        SeatingTemplate: Record "NPR TM Seating Template";
        SeatingTemplate2: Record "NPR TM Seating Template";
        TempSeatingTemplate: Record "NPR TM Seating Template" temporary;
        NewNode: Record "NPR TM Seating Template";
        I: Integer;
        Distance: Integer;
    begin

        SeatingTemplate.Get(RecToUnIndent."Parent Entry No.");
        NewNode.Get(AddChild(SeatingTemplate."Parent Entry No."));

        //SeatingManagement.TransferNodeDetails (RecToUnIndent, NewNode);
        NewNode.Modify();

        SeatingTemplate2.SetFilter("Admission Code", '=%1', RecToUnIndent."Admission Code");
        SeatingTemplate2.SetFilter("Parent Entry No.", '=%1', NewNode."Parent Entry No.");
        SeatingTemplate2.SetFilter(Ordinal, '%1..%2', SeatingTemplate.Ordinal, NewNode.Ordinal);
        Distance := SeatingTemplate2.Count();

        for I := 3 to Distance do begin
            MoveNodeUp(NewNode);
            NewNode.Get(NewNode."Entry No.");
        end;

        UpdateTemporaryPathList(RecToUnIndent."Admission Code", RecToUnIndent.Path, NewNode.Path, TempSeatingTemplate);
        UpdatePersistentTemplate(TempSeatingTemplate, -1);

        RecToUnIndent.Get(RecToUnIndent."Entry No.");
        RecToUnIndent.Delete();
    end;

    local procedure UpdateTemporaryPathList(AdmissionCode: Code[20]; PathA: Text; PathB: Text; var TmpSeatingTemplate: Record "NPR TM Seating Template" temporary)
    begin

        UpdateTemporaryPathListN(AdmissionCode, PathA, PathB, TmpSeatingTemplate, 0);
    end;

    local procedure UpdateTemporaryPathListN(AdmissionCode: Code[20]; PathA: Text; PathB: Text; var TmpSeatingTemplate: Record "NPR TM Seating Template" temporary; FirstNSeats: Integer)
    var
        SeatingTemplate: Record "NPR TM Seating Template";
        SeatCount: Integer;
        PathLbl: Label '%1/*', Locked = true;
    begin

        SeatingTemplate.SetFilter("Admission Code", '=%1', AdmissionCode);
        SeatingTemplate.SetFilter(Path, '%1', StrSubstNo(PathLbl, PathA));
        if (SeatingTemplate.FindSet()) then begin
            repeat
                TmpSeatingTemplate.TransferFields(SeatingTemplate, true);
                // Remove PathA section of Path and replace it with PathB
                TmpSeatingTemplate.Path := PathB + CopyStr(TmpSeatingTemplate.Path, StrLen(PathA) + 1);
                TmpSeatingTemplate.Insert();

                SeatCount += 1;
                if (FirstNSeats > 0) then
                    if (SeatCount >= FirstNSeats) then
                        exit;

            until (SeatingTemplate.Next() = 0);
        end;
    end;

    local procedure UpdatePersistentTemplate(var TmpSeatingTemplate: Record "NPR TM Seating Template" temporary; LevelShift: Integer)
    var
        SeatingTemplate: Record "NPR TM Seating Template";
    begin

        if (TmpSeatingTemplate.FindSet()) then begin
            repeat
                SeatingTemplate.Get(TmpSeatingTemplate."Entry No.");
                SeatingTemplate.Path := TmpSeatingTemplate.Path;
                SeatingTemplate."Indent Level" += LevelShift;
                SeatingTemplate.Modify();
            until (TmpSeatingTemplate.Next() = 0);
        end;
    end;

    procedure ShowSeatingTemplate(AdmissionCode: Code[20])
    var
        SeatingTemplate: Record "NPR TM Seating Template";
        SeatingTemplatePage: Page "NPR TM Seating Template";
    begin

        SeatingTemplate.FilterGroup(2);
        SeatingTemplate.Reset();

        SeatingTemplate.SetFilter("Admission Code", '=%1', AdmissionCode);
        if (SeatingTemplate.IsEmpty()) then
            AddRoot(AdmissionCode, '');

        SeatingTemplate.FilterGroup(0);
        SeatingTemplatePage.SetTableView(SeatingTemplate);
        SeatingTemplatePage.Run();
    end;

    procedure RowsAndSeatWizard(ApplyToEntryNo: Integer; WizardOption: Option "NONE",STRUCTURE,NUMBERING,SPLIT; var SelectionFilter: Record "NPR TM Seating Template")
    var
        SeatingWizard: Page "NPR TM Seating Wizard";
        PageAction: Action;
        Rows: Integer;
        RowLabel: Text[80];
        Seats: Integer;
        SeatLabel: Text[80];
        RowStartNumber: Code[10];
        SeatStartNumber: Code[10];
        AssignedNumber: Code[10];
        RowNumberOrder: Option "ASCENDING","DESCENDING";
        SeatNumberOrder: Option;
        ContinuousNumbering: Boolean;
        SeatingIncrement: Option;
        SpanSections: Boolean;
        SplitOptions: Option;
        SplitAtCSVList: Code[20];
    begin

        SeatingWizard.SetSectionTabValues(SelectionFilter.Count(), '<todo section names>');

        SeatingWizard.LookupMode(true);
        PageAction := SeatingWizard.RunModal();

        if (PageAction <> ACTION::LookupOK) then
            Error('');

        case WizardOption of
            WizardOption::NONE:
                ;
            WizardOption::STRUCTURE:
                begin
                    SeatingWizard.GetStructureOptions(Rows, RowLabel, Seats, SeatLabel);
                    CreateStructure(ApplyToEntryNo, Rows, RowLabel, Seats, SeatLabel);
                end;

            WizardOption::NUMBERING:
                begin
                    SeatingWizard.GetNumberingOptions(RowNumberOrder, RowStartNumber, SeatNumberOrder, SeatStartNumber, ContinuousNumbering, SeatingIncrement, SpanSections);

                    SelectionFilter.Ascending(RowNumberOrder = RowNumberOrder::ASCENDING);
                    if (SelectionFilter.FindSet(true, true)) then begin
                        AssignedNumber := SeatStartNumber;
                        repeat
                            RenumberRowAndSeat(SelectionFilter."Entry No.", RowStartNumber, SeatStartNumber, AssignedNumber, RowNumberOrder, SeatNumberOrder, ContinuousNumbering, SeatingIncrement);
                        until (SelectionFilter.Next() = 0);
                    end;
                end;
            WizardOption::SPLIT:
                begin
                    SeatingWizard.GetSplitOptions(SplitOptions, SplitAtCSVList);
                    SplitSelection(ApplyToEntryNo, SplitOptions, SplitAtCSVList);
                end;

        end;
    end;

    local procedure CreateStructure(StartFromEntryNo: Integer; Rows: Integer; RowLabel: Text[80]; Seats: Integer; SeatLabel: Text[80])
    var
        Row: Integer;
        Seat: Integer;
        ParentEntryNo: Integer;
        ChildLbl: Label '%1: %2', Locked = true;
    begin

        for Row := 1 to Rows do begin

            ParentEntryNo := AddChildWorker(StartFromEntryNo, StrSubstNo(ChildLbl, RowLabel, Row));

            for Seat := 1 to Seats do
                AddChildWorker(ParentEntryNo, StrSubstNo(ChildLbl, SeatLabel, Seat));

        end;
    end;

    local procedure RenumberRowAndSeat(StartFromEntryNo: Integer; RowStartNumber: Code[10]; SeatStartNumber: Code[10]; var AssignedNumber: Code[10]; RowNumberOrder: Option; SeatNumberOrder: Option; ContinuousNumbering: Boolean; SeatingIncrement: Option)
    begin

        if (RowStartNumber <> '') then
            RenumberNode(StartFromEntryNo, RowStartNumber, RowNumberOrder);

        if (SeatStartNumber <> '') then
            RenumberLeaf(StartFromEntryNo, SeatStartNumber, AssignedNumber, SeatNumberOrder, ContinuousNumbering, SeatingIncrement);
    end;

    local procedure RenumberNode(StartFromEntryNo: Integer; StartNumber: Code[10]; NumberOrder: Option "ASCENDING","DESCENDING")
    var
        SeatingTemplate: Record "NPR TM Seating Template";
        AssignedNumber: Code[10];
    begin

        SeatingTemplate.SetCurrentKey(Path);
        SeatingTemplate.Ascending(NumberOrder = NumberOrder::ASCENDING);
        SeatingTemplate.SetFilter("Parent Entry No.", '=%1', StartFromEntryNo);
        SeatingTemplate.SetFilter("Entry Type", '=%1', SeatingTemplate."Entry Type"::NODE);

        if (not SeatingTemplate.FindSet()) then
            exit;

        AssignedNumber := StartNumber;

        repeat
            SeatingTemplate."Seating Code" := AssignedNumber;
            SeatingTemplate.Modify();
            AssignedNumber := IncreaseNumber(AssignedNumber);

        until (SeatingTemplate.Next() = 0);
    end;

    local procedure RenumberLeaf(StartFromEntryNo: Integer; StartNumber: Code[10]; var AssignedNumber: Code[10]; NumberOrder: Option "ASCENDING","DESCENDING"; ContinuousNumbering: Boolean; IncrementStyle: Option)
    begin

        RenumberLeafWorker(StartFromEntryNo, StartNumber, AssignedNumber, NumberOrder, ContinuousNumbering, IncrementStyle);
    end;

    local procedure RenumberLeafWorker(StartFromEntryNo: Integer; StartNumber: Code[10]; var AssignedNumber: Code[10]; NumberOrder: Option "ASCENDING","DESCENDING"; ContinuousNumbering: Boolean; IncrementStyle: Option CONSECUTIVE,ODD,EVEN)
    var
        NodeList: Record "NPR TM Seating Template";
    begin

        NodeList.SetCurrentKey(Path);
        NodeList.Ascending(NumberOrder = NumberOrder::ASCENDING);
        NodeList.SetFilter("Parent Entry No.", '=%1', StartFromEntryNo);

        if (not NodeList.FindSet()) then
            exit;

        if (not ContinuousNumbering) then
            AssignedNumber := StartNumber;

        AssignedNumber := SelectNumber(AssignedNumber, IncrementStyle, false);

        repeat
            if (NodeList."Entry Type" = NodeList."Entry Type"::NODE) then
                RenumberLeafWorker(NodeList."Entry No.", StartNumber, AssignedNumber, NumberOrder, ContinuousNumbering, IncrementStyle);

            if (NodeList."Entry Type" = NodeList."Entry Type"::LEAF) then begin
                NodeList."Seating Code" := AssignedNumber;
                NodeList.Modify();
                AssignedNumber := SelectNumber(AssignedNumber, IncrementStyle, true);
            end;

        until (NodeList.Next() = 0);
    end;

    local procedure SplitSelection(ApplyToEntryNumber: Integer; SplitOption: Option HORIZONTAL,VERTICAL,DIAGONAL_LR,DIAGONAL_RL; SplitAtLocationCsvList: Text)
    var
        SeatingTemplate: Record "NPR TM Seating Template";
        NodeCount: Integer;
        NewNodeEntryNumber: Integer;
        NodeIndex: Integer;
        NewNodeAt: Decimal;
        CreateNewNode: Boolean;
    begin

        SeatingTemplate.SetFilter("Parent Entry No.", '=%1', ApplyToEntryNumber);
        NodeCount := SeatingTemplate.Count();
        if (NodeCount = 0) then
            exit;

        NewNodeEntryNumber := ApplyToEntryNumber;
        NewNodeAt := 0.5; // 50%

        SplitAtLocationCsvList := '3;8;15';

        NewNodeAt := GetNextSplitFraction(SplitAtLocationCsvList, NodeCount);

        case SplitOption of
            SplitOption::HORIZONTAL:
                begin
                    SeatingTemplate.SetCurrentKey("Parent Entry No.", Ordinal);
                    SeatingTemplate.FindSet();
                    NodeIndex := 0;
                    repeat
                        CreateNewNode := (NodeIndex / NodeCount >= NewNodeAt);

                        if (CreateNewNode) then begin
                            NewNodeEntryNumber := AddSibling(ApplyToEntryNumber);
                            NewNodeAt := GetNextSplitFraction(SplitAtLocationCsvList, NodeCount); // Advance to next threshold
                        end;

                        if (NewNodeEntryNumber <> SeatingTemplate."Parent Entry No.") then begin
                            ChangeParent(SeatingTemplate."Entry No.", NewNodeEntryNumber);
                        end;

                        NodeIndex += 1;
                    until (SeatingTemplate.Next() = 0);
                end;

            SplitOption::VERTICAL:
                begin
                    //      SeatingTemplate.SETCURRENTKEY ("Parent Entry No.",Ordinal);
                    //
                    //      NewNodeAt := GetNextSplitFraction (SplitAtLocationCsvList, NodeCount);
                    //      WHILE (NewNodeAt < 1) DO
                    //        SeatingTemplate.FindSet() ();
                    //        NodeIndex := 0;
                    //        NewNodeEntryNumber := AddSibling (ApplyToEntryNumber);
                    //        REPEAT
                    //          ChangeParentN (SeatingTemplate."Entry No.", NewNodeEntryNumber);
                    //          NewNodeAt := GetNextSplitFraction (SplitAtLocationCsvList, NodeCount); // Advance to next threshold
                    //        UNTIL (SeatingTemplate.Next() () = 0);

                end;
        end;
    end;

    local procedure GetNextSplitFraction(var CsvString: Text; MaxNodeCount: Integer) Fraction: Decimal
    var
        NewSplitText: Text;
        NewSplitNumber: Decimal;
    begin

        Fraction := 1;
        NewSplitText := NextField(CsvString);
        if (Evaluate(NewSplitNumber, NewSplitText)) then begin
            if (NewSplitNumber > 1) then
                Fraction := NewSplitNumber / MaxNodeCount;
        end;

        exit(Fraction);
    end;

    local procedure SelectNumber(StartNumber: Code[10]; IncrementStyle: Option CONSECUTIVE,ODD,EVEN; PreIncrement: Boolean) NextNumber: Code[10]
    begin

        NextNumber := StartNumber;
        if (PreIncrement) then
            NextNumber := IncreaseNumber(NextNumber);

        case IncrementStyle of
            IncrementStyle::EVEN:
                if (not IsEven(NextNumber)) then
                    NextNumber := IncreaseNumber(NextNumber);
            IncrementStyle::ODD:
                if (IsEven(NextNumber)) then
                    NextNumber := IncreaseNumber(NextNumber);
        end;

        exit(NextNumber);
    end;

    local procedure IncreaseNumber(StartNumber: Code[10]): Code[10]
    var
        AlphaNumeric: Boolean;
        Numeric: Boolean;
    begin

        AlphaNumeric := IsInRange(StartNumber[StrLen(StartNumber)], 'A', 'Z');
        Numeric := IsInRange(StartNumber[StrLen(StartNumber)], '0', '9');

        if (Numeric) then
            exit(IncStr(StartNumber));

        if (AlphaNumeric) then
            exit(StringAddOne(StartNumber, StrLen(StartNumber)));
    end;

    local procedure IsInRange(Value: Char; LowValue: Char; HighValue: Char): Boolean
    begin

        exit((Value >= LowValue) and (Value <= HighValue))
    end;

    local procedure StringAddOne(Value: Code[10]; DigitPos: Integer): Code[10]
    var
        StringLbl: Label 'A%1', Locked = true;
    begin
        if (DigitPos = 0) then
            exit(StrSubstNo(StringLbl, Value));

        if (Value[DigitPos] = 'Z') then begin
            Value[DigitPos] := 'A';
            exit(StringAddOne(Value, DigitPos - 1))
        end;

        Value[DigitPos] := Value[DigitPos] + 1;
        exit(Value);
    end;

    local procedure IsEven(StartNumber: Code[10]): Boolean
    begin

        exit((StartNumber[StrLen(StartNumber)] mod 2) = 0);
    end;

    procedure GetInheritedUnitPice(ParentEntryNo: Integer): Decimal
    var
        SeatingTemplate: Record "NPR TM Seating Template";
    begin

        if (ParentEntryNo = 0) then
            exit(0);

        if (not SeatingTemplate.Get(ParentEntryNo)) then
            exit(0);

        if (SeatingTemplate."Unit Price" <> 0) then
            exit(SeatingTemplate."Unit Price");

        exit(GetInheritedUnitPice(SeatingTemplate."Parent Entry No."));
    end;

    local procedure NextField(var VarLineOfText: Text): Text
    begin

        exit(ForwardTokenizer(VarLineOfText, ';', '"'));
    end;

    local procedure ForwardTokenizer(var vText: Text; pSeparator: Char; pQuote: Char) rField: Text
    var
        IsQuoted: Boolean;
        InputText: Text;
        NextFieldPos: Integer;
        IsNextField: Boolean;
        NextByte: Text[1];
    begin

        //  This function splits the textline into 2 parts at first occurence of separator
        //  Quotecharacter enables separator to occur inside datablock

        //  example:
        //  23;some text;"some text with a ;";xxxx

        //  result:
        //  1) 23
        //  2) some text
        //  3) some text with a ;
        //  4) xxxx

        //  Quoted text, variable length text tokenizer:
        //  forward searching tokenizer splitting string at separator.
        //  separator is protected by quoting string
        //  the separator is omitted from the resulting strings

        if ((vText[1] = pQuote) and (StrLen(vText) = 1)) then begin
            vText := '';
            rField := '';
            exit(rField);
        end;

        IsQuoted := false;
        NextFieldPos := 1;
        IsNextField := false;

        InputText := vText;

        if (pQuote = InputText[NextFieldPos]) then IsQuoted := true;
        while ((NextFieldPos <= StrLen(InputText)) and (not IsNextField)) do begin
            if (pSeparator = InputText[NextFieldPos]) then IsNextField := true;
            if (IsQuoted and IsNextField) then IsNextField := (InputText[NextFieldPos - 1] = pQuote);

            NextByte[1] := InputText[NextFieldPos];
            if (not IsNextField) then rField += NextByte;
            NextFieldPos += 1;
        end;
        if (IsQuoted) then rField := CopyStr(rField, 2, StrLen(rField) - 2);

        vText := CopyStr(InputText, NextFieldPos);
        exit(rField);
    end;
}

