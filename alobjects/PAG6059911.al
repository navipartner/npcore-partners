page 6059911 "Task Output Log"
{
    // TQ1.29/JDH /20161101 CASE 242044 Possible to show the log
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Task Output Log';
    PageType = List;
    SourceTable = "Task Output Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                }
                field("Task Log Entry No.";"Task Log Entry No.")
                {
                }
                field("Journal Template Name";"Journal Template Name")
                {
                }
                field("Journal Batch Name";"Journal Batch Name")
                {
                }
                field("Journal Line No.";"Journal Line No.")
                {
                }
                field(File;File)
                {
                }
                field("File Name";"File Name")
                {
                }
                field("Import DateTime";"Import DateTime")
                {
                }
                field(Description;Description)
                {
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
                    Downloaded := DownloadFromStream(Instr,FileDownLoadTxt,'','',"File Name");
                end;
            }
        }
    }

    var
        FileDownLoadTxt: Label 'Export';
        ReportIsEmptyMsg: Label 'The report is empty.';
}

