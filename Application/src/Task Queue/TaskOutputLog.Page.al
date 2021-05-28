page 6059911 "NPR Task Output Log"
{

    Caption = 'Task Output Log';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Task Output Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Task Log Entry No."; Rec."Task Log Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Log Entry No. field';
                }
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Journal Template Name field';
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Journal Batch Name field';
                }
                field("Journal Line No."; Rec."Journal Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Journal Line No. field';
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the File Name field';
                }
                field("Import DateTime"; Rec."Import DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import DateTime field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Show Document action';

                trigger OnAction()
                var
                    Instr: InStream;
                    Downloaded: Boolean;
                begin
                    Rec.CalcFields(File);
                    if not Rec.File.HasValue() then begin
                        Message(ReportIsEmptyMsg);
                        exit;
                    end;

                    Rec.File.CreateInStream(Instr);
                    Downloaded := DownloadFromStream(Instr, FileDownLoadTxt, '', '', Rec."File Name");
                end;
            }
        }
    }

    var
        FileDownLoadTxt: Label 'Export';
        ReportIsEmptyMsg: Label 'The report is empty.';
}

