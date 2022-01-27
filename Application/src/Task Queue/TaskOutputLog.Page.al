page 6059911 "NPR Task Output Log"
{
    Extensible = False;

    Caption = 'Task Output Log';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Task Output Log";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Task Log Entry No."; Rec."Task Log Entry No.")
                {

                    ToolTip = 'Specifies the value of the Task Log Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Journal Template Name"; Rec."Journal Template Name")
                {

                    ToolTip = 'Specifies the value of the Journal Template Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {

                    ToolTip = 'Specifies the value of the Journal Batch Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Journal Line No."; Rec."Journal Line No.")
                {

                    ToolTip = 'Specifies the value of the Journal Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("File Name"; Rec."File Name")
                {

                    ToolTip = 'Specifies the value of the File Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Import DateTime"; Rec."Import DateTime")
                {

                    ToolTip = 'Specifies the value of the Import DateTime field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Show Document action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    Instr: InStream;
                begin
                    Rec.CalcFields(File);
                    if not Rec.File.HasValue() then begin
                        Message(ReportIsEmptyMsg);
                        exit;
                    end;

                    Rec.File.CreateInStream(Instr);
                    DownloadFromStream(Instr, FileDownLoadTxt, '', '', Rec."File Name");
                end;
            }
        }
    }

    var
        FileDownLoadTxt: Label 'Export';
        ReportIsEmptyMsg: Label 'The report is empty.';
}

