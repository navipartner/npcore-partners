page 6059911 "NPR Task Output Log"
{
    // TQ1.29/JDH /20161101 CASE 242044 Possible to show the log
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Task Output Log';
    PageType = List;
    SourceTable = "NPR Task Output Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Task Log Entry No."; "Task Log Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Journal Template Name"; "Journal Template Name")
                {
                    ApplicationArea = All;
                }
                field("Journal Batch Name"; "Journal Batch Name")
                {
                    ApplicationArea = All;
                }
                field("Journal Line No."; "Journal Line No.")
                {
                    ApplicationArea = All;
                }
                field("File"; File)
                {
                    ApplicationArea = All;
                }
                field("File Name"; "File Name")
                {
                    ApplicationArea = All;
                }
                field("Import DateTime"; "Import DateTime")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Show)
            {
                Caption = 'Show Document';
                Image = ShowSelected;
                ApplicationArea=All;

                trigger OnAction()
                var
                    Instr: InStream;
                    Downloaded: Boolean;
                begin
                    CalcFields(File);
                    if not File.HasValue then begin
                        Message(ReportIsEmptyMsg);
                        exit;
                    end;

                    File.CreateInStream(Instr);
                    Downloaded := DownloadFromStream(Instr, FileDownLoadTxt, '', '', "File Name");
                end;
            }
        }
    }

    var
        FileDownLoadTxt: Label 'Export';
        ReportIsEmptyMsg: Label 'The report is empty.';
}

