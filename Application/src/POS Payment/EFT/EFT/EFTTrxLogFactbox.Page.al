page 6184473 "NPR EFT Trx Log Factbox"
{
    Extensible = False;
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
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Logged At"; Rec."Logged At")
                {

                    ToolTip = 'Specifies the value of the Logged At field';
                    ApplicationArea = NPRRetail;
                }
                field("Has Log File"; Rec.Log.HasValue)
                {

                    Caption = 'Has Log File';
                    ToolTip = 'Specifies the value of the Has Log File field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Download action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    InStream: InStream;
                    FileName: Text;
                    FileNameLbl: Label 'EFT_Log_%1_%2', Locked = true;
                begin
                    if not Rec.Log.HasValue() then
                        exit;
                    Rec.CalcFields(Log);
                    Rec.Log.CreateInStream(InStream);
                    FileName := StrSubstNo(FileNameLbl, Rec."Transaction Entry No.", Rec."Log Entry No.");
                    DownloadFromStream(InStream, 'Log Download', '', 'All Files (*.*)|*.*', FileName);
                end;
            }
        }
    }
}

