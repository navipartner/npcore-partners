codeunit 6059903 "NPR Task Queue Execute"
{
    // TQ1.15/JDH /20140909 CASE 179044 Reports can be executed without a printer setup
    // TQ1.18/JDH /20141126 CASE 198170 Fix object reference for call of function taskgenerateoutput (no code changes)
    // TQ1.21/JDH /20141219 CASE 202183 added functionality for disabling of file logging (added to save HD space)
    // TQ1.24/JDH /20150320 CASE 209090 Possible to set the language on the task line
    // TQ1.27/MH  /20150409 CASE 210797 NPR8.00 specific version due to changed parameters for REPORT.SAVEXML
    // TQ1.28/MHA /20151216 CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Possible to run with requestpage setting from Blob field + cleanup of unused vars
    // NPR5.29/MHA /20161221  CASE 258841 Updated Parameters for REPORT.SAVEASHTML to match with NAV2017

    TableNo = "NPR Task Line";

    trigger OnRun()
    var
        CurrentFileName: Text[250];
        CurrentFilePath: Text[250];
        TaskOutputLog: Record "NPR Task Output Log";
        Printer: Record Printer;
        TaskTemplate: Record "NPR Task Template";
        CurrLangID: Integer;
        RunOnRecRef: Boolean;
        RecRef: RecordRef;
        OutStr: OutStream;
    begin
        //Cleanup
        if TaskUsesPrinter then begin
            Printer.Get("Printer Name");//needs for testing if it exists
        end;

        //-TQ1.29
        //IF TaskGenerateOutput THEN BEGIN
        //  CurrentFileName := GetFileName(Rec);
        //  CurrentFilePath := GetFilePath(Rec);
        //  IF EXISTS(CurrentFilePath + CurrentFileName) THEN
        //    ERASE(CurrentFilePath + CurrentFileName);
        //END;

        //TaskTemplate.GET("Journal Template Name");
        //+TQ1.29

        SetRecFilter;

        if ("Language ID" <> 0) and ("Language ID" <> GlobalLanguage) then begin
            CurrLangID := GlobalLanguage;
            GlobalLanguage("Language ID");
        end;

        //-TQ1.29
        //  "Object Type"::Report:
        //    BEGIN
        //      CASE "Type Of Output" OF
        //        "Type Of Output"::" ",
        //        "Type Of Output"::Paper:
        //          BEGIN
        //            IF "Call Object With Task Record" THEN
        //              REPORT.RUNMODAL("Object No.", FALSE, FALSE, Rec)
        //            ELSE
        //              REPORT.RUNMODAL("Object No.", FALSE, FALSE);
        //          END;
        //        "Type Of Output"::XMLFile:
        //          BEGIN
        //            IF "Call Object With Task Record" THEN
        //              REPORT.SAVEASXML("Object No.",CurrentFilePath + CurrentFileName,Rec)
        //            ELSE
        //              REPORT.SAVEASXML("Object No.",CurrentFilePath + CurrentFileName);
        //          END;
        //        "Type Of Output"::HTMLFile:
        //          BEGIN
        //            IF "Call Object With Task Record" THEN
        //              REPORT.SAVEASHTML("Object No.", CurrentFilePath + CurrentFileName, FALSE, Rec)
        //            ELSE
        //              REPORT.SAVEASHTML("Object No.", CurrentFilePath + CurrentFileName, FALSE);
        //          END;
        //        "Type Of Output"::PDFFile:
        //          BEGIN
        //            IF "Call Object With Task Record" THEN
        //              REPORT.SAVEASPDF("Object No.", CurrentFilePath + CurrentFileName, Rec)
        //            ELSE
        //              REPORT.SAVEASPDF("Object No.", CurrentFilePath + CurrentFileName);
        //          END;
        //        "Type Of Output"::Excel:
        //          BEGIN
        //            IF "Call Object With Task Record" THEN
        //              REPORT.SAVEASEXCEL("Object No.", CurrentFilePath + CurrentFileName, Rec)
        //            ELSE
        //              REPORT.SAVEASEXCEL("Object No.", CurrentFilePath + CurrentFileName);
        //          END;
        //        "Type Of Output"::Word:
        //          BEGIN
        //            IF "Call Object With Task Record" THEN
        //              REPORT.SAVEASWORD("Object No.", CurrentFilePath + CurrentFileName, Rec)
        //            ELSE
        //              REPORT.SAVEASWORD("Object No.", CurrentFilePath + CurrentFileName);
        //          END;
        //
        //      END;
        //    END;
        //  "Object Type"::Codeunit:
        //    BEGIN
        //      IF "Call Object With Task Record" THEN
        //        CODEUNIT.RUN("Object No.", Rec)
        //      ELSE
        //        CODEUNIT.RUN("Object No.");
        //    END;
        case "Object Type" of
            "Object Type"::Report:
                begin
                    if "Call Object With Task Record" then begin
                        RecRef.GetTable(Rec);
                        RecRef.SetRecFilter;
                        RunOnRecRef := true;
                    end;

                    if TaskGenerateOutput then begin
                        TaskOutputLog.InitRecord(Rec);
                        TaskOutputLog.File.CreateOutStream(OutStr);
                        TaskOutputLog.Insert;
                    end;

                    case "Type Of Output" of
                        "Type Of Output"::" ":
                            begin
                                if RunOnRecRef then
                                    REPORT.Execute("Object No.", GetReportParameters, RecRef)
                                else
                                    REPORT.Execute("Object No.", GetReportParameters);
                            end;
                        "Type Of Output"::Paper:
                            begin
                                if RunOnRecRef then
                                    REPORT.Print("Object No.", GetReportParameters, "Printer Name", RecRef)
                                else
                                    REPORT.Print("Object No.", GetReportParameters, "Printer Name");
                            end;
                        "Type Of Output"::XMLFile:
                            begin
                                if RunOnRecRef then
                                    REPORT.SaveAs("Object No.", GetReportParameters, REPORTFORMAT::Xml, OutStr, RecRef)
                                else
                                    REPORT.SaveAs("Object No.", GetReportParameters, REPORTFORMAT::Xml, OutStr);
                            end;
                        "Type Of Output"::HTMLFile:
                            begin
                                if RunOnRecRef then
                                    Error('Not Supported')
                                else
                                    //-#258841 [258841]
                                    //REPORT.SAVEASHTML("Object No.", CurrentFilePath + CurrentFileName, FALSE);
                                    REPORT.SaveAsHtml("Object No.", CurrentFilePath + CurrentFileName);
                                //+#258841 [258841]
                            end;
                        "Type Of Output"::PDFFile:
                            begin
                                if RunOnRecRef then
                                    REPORT.SaveAs("Object No.", GetReportParameters, REPORTFORMAT::Pdf, OutStr, RecRef)
                                else
                                    REPORT.SaveAs("Object No.", GetReportParameters, REPORTFORMAT::Pdf, OutStr);
                            end;
                        "Type Of Output"::Excel:
                            begin
                                if RunOnRecRef then
                                    REPORT.SaveAs("Object No.", GetReportParameters, REPORTFORMAT::Excel, OutStr, RecRef)
                                else
                                    REPORT.SaveAs("Object No.", GetReportParameters, REPORTFORMAT::Excel, OutStr);
                            end;
                        "Type Of Output"::Word:
                            begin
                                if RunOnRecRef then
                                    REPORT.SaveAs("Object No.", GetReportParameters, REPORTFORMAT::Word, OutStr, RecRef)
                                else
                                    REPORT.SaveAs("Object No.", GetReportParameters, REPORTFORMAT::Word, OutStr);
                            end;
                    end;
                end;
            "Object Type"::Codeunit:
                begin
                    if "Call Object With Task Record" then
                        CODEUNIT.Run("Object No.", Rec)
                    else
                        CODEUNIT.Run("Object No.");
                end;
        end;

        if (CurrLangID <> 0) then
            GlobalLanguage(CurrLangID);

        //-TQ1.29 [242044]
        if TaskGenerateOutput then begin
            CalcFields("Report Name");
            TaskOutputLog."File Name" := DelChr("Report Name", '=', '\/:*?"<>|') + Suffix(Rec);
            TaskOutputLog.Modify;
        end;
        //+TQ1.29 [242044]

        Clear(Printer);
        //import files generated
        if not "Disable File Logging" then
            if CurrentFileName <> '' then
                TaskOutputLog.AddFile(Rec, CurrentFilePath + CurrentFileName);
    end;

    procedure GetFileName(TaskLine: Record "NPR Task Line"): Text[1024]
    var
        NewFileName: Text[1024];
        NewFilePath: Text[1024];
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
        NewFileName: Text[1024];
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
        TempText: Text[100];
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
        //-TQ1.29
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
        //+TQ1.29
    end;
}

