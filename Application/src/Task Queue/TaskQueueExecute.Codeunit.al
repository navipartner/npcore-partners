codeunit 6059903 "NPR Task Queue Execute"
{
    TableNo = "NPR Task Line";

    trigger OnRun()
    var
        TaskOutputLog: Record "NPR Task Output Log";
        CurrLangID: Integer;
        RunOnRecRef: Boolean;
        RecRef: RecordRef;
        OutStr: OutStream;
    begin
        Rec.SetRecFilter();

        if (Rec."Language ID" <> 0) and (Rec."Language ID" <> GlobalLanguage) then begin
            CurrLangID := GlobalLanguage;
            GlobalLanguage(Rec."Language ID");
        end;

        case Rec."Object Type" of
            Rec."Object Type"::Report:
                begin
                    if Rec."Call Object With Task Record" then begin
                        RecRef.GetTable(Rec);
                        RecRef.SetRecFilter();
                        RunOnRecRef := true;
                    end;

                    if Rec.TaskGenerateOutput() then begin
                        TaskOutputLog.InitRecord(Rec);
                        TaskOutputLog.File.CreateOutStream(OutStr);
                        TaskOutputLog.Insert();
                    end;

                    case Rec."Type Of Output" of
                        Rec."Type Of Output"::" ":
                            begin
                                if RunOnRecRef then
                                    REPORT.Execute(Rec."Object No.", Rec.GetReportParameters(), RecRef)
                                else
                                    REPORT.Execute(Rec."Object No.", Rec.GetReportParameters());
                            end;
                        Rec."Type Of Output"::Paper:
                            begin
                                if RunOnRecRef then
                                    REPORT.Print(Rec."Object No.", Rec.GetReportParameters(), Rec."Printer Name", RecRef)
                                else
                                    REPORT.Print(Rec."Object No.", Rec.GetReportParameters(), Rec."Printer Name");
                            end;
                        Rec."Type Of Output"::XMLFile:
                            begin
                                if RunOnRecRef then
                                    REPORT.SaveAs(Rec."Object No.", Rec.GetReportParameters(), REPORTFORMAT::Xml, OutStr, RecRef)
                                else
                                    REPORT.SaveAs(Rec."Object No.", Rec.GetReportParameters(), REPORTFORMAT::Xml, OutStr);
                            end;
                        Rec."Type Of Output"::HTMLFile:
                            begin
                                if RunOnRecRef then
                                    Error('Not Supported')
                                else
                                    REPORT.SaveAs(Rec."Object No.", Rec.GetReportParameters(), REPORTFORMAT::Html, OutStr);
                            end;
                        Rec."Type Of Output"::PDFFile:
                            begin
                                if RunOnRecRef then
                                    REPORT.SaveAs(Rec."Object No.", Rec.GetReportParameters(), REPORTFORMAT::Pdf, OutStr, RecRef)
                                else
                                    REPORT.SaveAs(Rec."Object No.", Rec.GetReportParameters(), REPORTFORMAT::Pdf, OutStr);
                            end;
                        Rec."Type Of Output"::Excel:
                            begin
                                if RunOnRecRef then
                                    REPORT.SaveAs(Rec."Object No.", Rec.GetReportParameters(), REPORTFORMAT::Excel, OutStr, RecRef)
                                else
                                    REPORT.SaveAs(Rec."Object No.", Rec.GetReportParameters(), REPORTFORMAT::Excel, OutStr);
                            end;
                        Rec."Type Of Output"::Word:
                            begin
                                if RunOnRecRef then
                                    REPORT.SaveAs(Rec."Object No.", Rec.GetReportParameters(), REPORTFORMAT::Word, OutStr, RecRef)
                                else
                                    REPORT.SaveAs(Rec."Object No.", Rec.GetReportParameters(), REPORTFORMAT::Word, OutStr);
                            end;
                    end;
                end;
            Rec."Object Type"::Codeunit:
                begin
                    if Rec."Call Object With Task Record" then
                        CODEUNIT.Run(Rec."Object No.", Rec)
                    else
                        CODEUNIT.Run(Rec."Object No.");
                end;
        end;

        if (CurrLangID <> 0) then
            GlobalLanguage(CurrLangID);
        if not Rec."Disable File Logging" then
            if Rec.TaskGenerateOutput() then begin
                Rec.CalcFields("Report Name");
                TaskOutputLog."File Name" := DelChr(Rec."Report Name", '=', '\/:*?"<>|') + Suffix(Rec);
                TaskOutputLog.Modify();
            end;
    end;

    procedure GetFileName(TaskLine: Record "NPR Task Line"): Text[1024]
    var
        NewFileName: Text[1024];
    begin
        //input eg c:\{DATE,0,1}
        //whatever is in the {} should be as the normal "format" property of the corresponding datatype

        TaskLine.TestField("File Name");
        NewFileName := FormatFileNameText(TaskLine."File Name");
        NewFileName := DelChr(NewFileName, '=', '<>:\/*?|"''''');
        exit(NewFileName);
    end;

    procedure GetFilePath(TaskLine: Record "NPR Task Line"): Text[1024]
    var
        NewFilePath: Text[1024];
    begin
        //input eg c:\{DATE,0,1}
        //whatever is in the {} should be as the normal "format" property of the corresponding datatype

        TaskLine.TestField("File Path");
        NewFilePath := FormatFileNameText(TaskLine."File Path");
        NewFilePath := DelChr(NewFilePath, '=', '<>/*?|"''''');
        exit(NewFilePath);
    end;

    procedure FormatFileNameText(TextIn: Text[1024]): Text[1024]
    var
        NewFilePath: Text[1024];
        FieldValue: Text[100];
        FormatStr: Text[100];
        FormatLenghtTxt: Text[100];
        StartPos: Integer;
        EndPos: Integer;
        CommaPos: Integer;
        TextToAdd: Text[100];
        Counter: Integer;
        FormatLength: Integer;
        FormatNumber: Integer;
        UseFormatNumber: Boolean;
    begin
        NewFilePath := TextIn;

        while (StrPos(NewFilePath, '{') <> 0) and (Counter < 10) do begin
            Counter += 1;
            StartPos := StrPos(NewFilePath, '{');
            EndPos := StrPos(NewFilePath, '}');
            if (StartPos = 0) or (EndPos = 0) then
                exit(NewFilePath);

            FieldValue := CopyStr(NewFilePath, StartPos + 1, EndPos - StartPos - 1);
            CommaPos := StrPos(FieldValue, ',');
            if CommaPos <> 0 then begin
                FormatLenghtTxt := CopyStr(FieldValue, CommaPos + 1);
                FieldValue := CopyStr(FieldValue, 1, CommaPos - 1);
            end;

            CommaPos := StrPos(FormatLenghtTxt, ',');
            if CommaPos <> 0 then begin
                FormatStr := CopyStr(FormatLenghtTxt, CommaPos + 1);
                FormatLenghtTxt := CopyStr(FormatLenghtTxt, 1, CommaPos - 1);
            end;

            if FormatLenghtTxt <> '' then
                Evaluate(FormatLength, FormatLenghtTxt);

            if FormatStr <> '' then
                UseFormatNumber := Evaluate(FormatNumber, FormatStr);

            case UpperCase(FieldValue) of
                'CURRENTDATETIME':
                    begin
                        case true of
                            (UseFormatNumber):
                                TextToAdd := Format(CurrentDateTime, FormatLength, FormatNumber);
                            (FormatStr <> ''):
                                TextToAdd := Format(CurrentDateTime, FormatLength, FormatStr);
                            (FormatLenghtTxt <> ''):
                                TextToAdd := Format(CurrentDateTime, FormatLength);
                            else
                                TextToAdd := Format(CurrentDateTime);
                        end;
                    end;
                'TODAY':
                    begin
                        case true of
                            (UseFormatNumber):
                                TextToAdd := Format(Today, FormatLength, FormatNumber);
                            (FormatStr <> ''):
                                TextToAdd := Format(Today, FormatLength, FormatStr);
                            (FormatLenghtTxt <> ''):
                                TextToAdd := Format(Today, FormatLength);
                            else
                                TextToAdd := Format(Today);
                        end;
                    end;
                'TIME':
                    begin
                        case true of
                            (UseFormatNumber):
                                TextToAdd := Format(Time, FormatLength, FormatNumber);
                            (FormatStr <> ''):
                                TextToAdd := Format(Time, FormatLength, FormatStr);
                            (FormatLenghtTxt <> ''):
                                TextToAdd := Format(Time, FormatLength);
                            else
                                TextToAdd := Format(Time);
                        end;
                    end;
                'USERID':
                    begin
                        case true of
                            (UseFormatNumber):
                                TextToAdd := Format(UserId, FormatLength, FormatNumber);
                            (FormatStr <> ''):
                                TextToAdd := Format(UserId, FormatLength, FormatStr);
                            (FormatLenghtTxt <> ''):
                                TextToAdd := Format(UserId, FormatLength);
                            else
                                TextToAdd := Format(UserId);
                        end;
                    end;
            end;
            NewFilePath := CopyStr(NewFilePath, 1, StartPos - 1) + TextToAdd + CopyStr(NewFilePath, EndPos + 1);
        end;

        exit(NewFilePath);
    end;

    local procedure Suffix(TaskLine: Record "NPR Task Line"): Text
    begin
        case TaskLine."Type Of Output" of
            TaskLine."Type Of Output"::PDFFile:
                exit('.pdf');
            TaskLine."Type Of Output"::Word:
                exit('.docx');
            TaskLine."Type Of Output"::Excel:
                exit('.xlsx');
            TaskLine."Type Of Output"::XMLFile:
                exit('.XML');
        end;
    end;
}

