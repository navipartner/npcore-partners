codeunit 6060163 "NPR Event Transf.Ext.Text Mgt."
{
    var
        GLAcc: Record "G/L Account";
        Item: Record Item;
        Res: Record Resource;
        TmpExtTextLine: Record "Extended Text Line" temporary;
        NextLineNo: Integer;
        LineSpacing: Integer;
        MakeUpdateRequired: Boolean;
        AutoText: Boolean;
        Text000: Label 'There is not enough space to insert extended text lines.';

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteJobPlanningLine(var Rec: Record "Job Planning Line"; RunTrigger: Boolean)
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        if not RunTrigger then
            exit;
        JobPlanningLine.SetRange("Job No.", Rec."Job No.");
        JobPlanningLine.SetRange("Job Task No.", Rec."Job Task No.");
        JobPlanningLine.SetRange("NPR Att. to Line No.", Rec."Line No.");
        JobPlanningLine.SetFilter("Line No.", '<>%1', Rec."Line No.");
        JobPlanningLine.DeleteAll(true);
    end;

    procedure EventCheckIfAnyExtText(var JobPlanningLine: Record "Job Planning Line"; Unconditionally: Boolean): Boolean
    var
        Job: Record Job;
        ExtTextHeader: Record "Extended Text Header";
    begin
        MakeUpdateRequired := false;
        if IsDeleteAttachedLines(JobPlanningLine."Line No.", JobPlanningLine."No.", JobPlanningLine."NPR Att. to Line No.") then
            MakeUpdateRequired := DeleteJobPlanningLine(JobPlanningLine);

        AutoText := true;

        if Unconditionally then
            AutoText := true
        else
            case JobPlanningLine.Type of
                JobPlanningLine.Type::Text:
                    AutoText := true;
                JobPlanningLine.Type::"G/L Account":
                    begin
                        if GLAcc.Get(JobPlanningLine."No.") then
                            AutoText := GLAcc."Automatic Ext. Texts";
                    end;
                JobPlanningLine.Type::Item:
                    begin
                        if Item.Get(JobPlanningLine."No.") then
                            AutoText := Item."Automatic Ext. Texts";
                    end;
                JobPlanningLine.Type::Resource:
                    begin
                        if Res.Get(JobPlanningLine."No.") then
                            AutoText := Res."Automatic Ext. Texts";
                    end;
            end;

        if AutoText then begin
            JobPlanningLine.TestField("Job No.");
            Job.Get(JobPlanningLine."Job No.");
            case JobPlanningLine.Type of
                JobPlanningLine.Type::Resource:
                    ExtTextHeader.SetRange("Table Name", ExtTextHeader."Table Name"::Resource);
                JobPlanningLine.Type::Item:
                    ExtTextHeader.SetRange("Table Name", ExtTextHeader."Table Name"::Item);
                JobPlanningLine.Type::"G/L Account":
                    ExtTextHeader.SetRange("Table Name", ExtTextHeader."Table Name"::"G/L Account");
                JobPlanningLine.Type::Text:
                    ExtTextHeader.SetRange("Table Name", ExtTextHeader."Table Name"::"Standard Text");
            end;
            ExtTextHeader.SetRange("No.", JobPlanningLine."No.");
            ExtTextHeader.SetRange("NPR Event", true);
            exit(ReadLines(ExtTextHeader, Job."Starting Date", Job."Language Code"));
        end;
    end;

    local procedure DeleteJobPlanningLine(var JobPlanningLine: Record "Job Planning Line"): Boolean
    var
        JobPlanningLine2: Record "Job Planning Line";
    begin
        JobPlanningLine2.SetRange("Job No.", JobPlanningLine."Job No.");
        JobPlanningLine2.SetRange("Job Task No.", JobPlanningLine."Job Task No.");
        JobPlanningLine2.SetRange("NPR Att. to Line No.", JobPlanningLine."Line No.");
        JobPlanningLine2 := JobPlanningLine;
        if JobPlanningLine2.Find('>') then begin
            repeat
                JobPlanningLine2.Delete(true);
            until JobPlanningLine2.Next() = 0;
            exit(true);
        end;
    end;

    procedure MakeUpdate(): Boolean
    begin
        exit(MakeUpdateRequired);
    end;

    local procedure ReadLines(var ExtTextHeader: Record "Extended Text Header"; DocDate: Date; LanguageCode: Code[10]): Boolean
    var
        ExtTextLine: Record "Extended Text Line";
    begin
        ExtTextHeader.SetCurrentKey(
          "Table Name", "No.", "Language Code", "All Language Codes", "Starting Date", "Ending Date");
        ExtTextHeader.SetRange("Starting Date", 0D, DocDate);
        ExtTextHeader.SetFilter("Ending Date", '%1..|%2', DocDate, 0D);
        if LanguageCode = '' then begin
            ExtTextHeader.SetRange("Language Code", '');
            if not ExtTextHeader.Find('+') then
                exit;
        end else begin
            ExtTextHeader.SetRange("Language Code", LanguageCode);
            if not ExtTextHeader.Find('+') then begin
                ExtTextHeader.SetRange("All Language Codes", true);
                ExtTextHeader.SetRange("Language Code", '');
                if not ExtTextHeader.Find('+') then
                    exit;
            end;
        end;

        ExtTextLine.SetRange("Table Name", ExtTextHeader."Table Name");
        ExtTextLine.SetRange("No.", ExtTextHeader."No.");
        ExtTextLine.SetRange("Language Code", ExtTextHeader."Language Code");
        ExtTextLine.SetRange("Text No.", ExtTextHeader."Text No.");
        if ExtTextLine.Find('-') then begin
            TmpExtTextLine.DeleteAll();
            repeat
                TmpExtTextLine := ExtTextLine;
                TmpExtTextLine.Insert();
            until ExtTextLine.Next() = 0;
            exit(true);
        end;
    end;

    procedure InsertEventExtText(var JobPlanningLine: Record "Job Planning Line")
    var
        ToJobPlanningLine: Record "Job Planning Line";
    begin
        ToJobPlanningLine.Reset();
        ToJobPlanningLine.SetRange("Job No.", JobPlanningLine."Job No.");
        ToJobPlanningLine.SetRange("Job Task No.", JobPlanningLine."Job Task No.");
        ToJobPlanningLine := JobPlanningLine;
        if ToJobPlanningLine.Find('>') then begin
            LineSpacing :=
              (ToJobPlanningLine."Line No." - JobPlanningLine."Line No.") div
              (1 + TmpExtTextLine.Count());
            if LineSpacing = 0 then
                Error(Text000);
        end else
            LineSpacing := 10000;

        NextLineNo := JobPlanningLine."Line No." + LineSpacing;

        TmpExtTextLine.Reset();
        if TmpExtTextLine.Find('-') then begin
            repeat
                ToJobPlanningLine.Init();
                ToJobPlanningLine."Job No." := JobPlanningLine."Job No.";
                ToJobPlanningLine."Job Task No." := JobPlanningLine."Job Task No.";
                ToJobPlanningLine."Line No." := NextLineNo;
                NextLineNo := NextLineNo + LineSpacing;
                ToJobPlanningLine.Type := ToJobPlanningLine.Type::Text;
                ToJobPlanningLine.Description := TmpExtTextLine.Text;
                ToJobPlanningLine."NPR Att. to Line No." := JobPlanningLine."Line No.";
                ToJobPlanningLine."Line Type" := JobPlanningLine."Line Type";
                ToJobPlanningLine."Planning Date" := JobPlanningLine."Planning Date";
                ToJobPlanningLine.Insert();
            until TmpExtTextLine.Next() = 0;
            MakeUpdateRequired := true;
        end;
        TmpExtTextLine.DeleteAll();
    end;

    local procedure IsDeleteAttachedLines(LineNo: Integer; No: Code[20]; AttachedToLineNo: Integer): Boolean
    begin
        exit((LineNo <> 0) and (AttachedToLineNo = 0) and (No <> ''));
    end;
}

