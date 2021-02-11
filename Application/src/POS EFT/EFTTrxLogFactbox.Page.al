page 6184473 "NPR EFT Trx Log Factbox"
{
    Caption = 'EFT Transaction Logs';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR EFT Transaction Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Logged At"; "Logged At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Logged At field';
                }
                field("Log.HASVALUE"; Log.HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Has Log File';
                    ToolTip = 'Specifies the value of the Has Log File field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Download)
            {
                Caption = 'Download';
                Image = CreateXMLFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Download action';

                trigger OnAction()
                var
                    InStream: InStream;
                    FileName: Text;
                begin
                    if not Log.HasValue then
                        exit;
                    CalcFields(Log);
                    Log.CreateInStream(InStream);
                    FileName := StrSubstNo('EFT_Log_%1_%2', "Transaction Entry No.", "Log Entry No.");
                    DownloadFromStream(InStream, 'Log Download', '', 'All Files (*.*)|*.*', FileName);
                end;
            }
        }
    }
}

