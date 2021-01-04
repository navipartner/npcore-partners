page 6059963 "NPR MPOS QR Code FactBox"
{
    // NPR5.33/NPKNAV/20170630  CASE 277791 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence

    Caption = 'MPOS QR Code FactBox';
    PageType = CardPart;
    UsageCategory = Administration;
    ShowFilter = false;
    SourceTable = "NPR MPOS QR Code";

    layout
    {
        area(content)
        {
            field("QR code"; "QR code")
            {
                ApplicationArea = All;
                ShowCaption = false;
                ToolTip = 'Specifies the value of the QR code field';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("<Action1160150012>")
            {
                Caption = 'Save To Disk';
                ShortCutKey = 'Return';
                ApplicationArea = All;
                ToolTip = 'Executes the Save To Disk action';

                trigger OnAction()
                var
                    FileManagement: Codeunit "File Management";
                    fPath: Text[1024];
                    FileBlob: Codeunit "Temp Blob";
                begin
                    if "QR code".HasValue then begin
                        CalcFields("QR code");
                        if Company <> '' then
                            fPath := StringReplace("User ID" + '_' + Company) + '.png'
                        else
                            fPath := StringReplace("User ID") + '.png';
                        FileBlob.FromRecord(Rec, FieldNo("QR code"));
                        FileManagement.BLOBExport(FileBlob, fPath, true);
                    end;
                end;
            }
        }
    }

    local procedure StringReplace(String: Text): Text
    var
        Pos: Integer;
        Old: Text;
        New: Text;
    begin
        Old := '.';
        Pos := StrPos(String, Old);
        while Pos <> 0 do begin
            String := DelStr(String, Pos, StrLen(Old));
            String := InsStr(String, New, Pos);
            Pos := StrPos(String, Old);
        end;

        New := '_';
        Old := ' ';
        Pos := StrPos(String, Old);
        while Pos <> 0 do begin
            String := DelStr(String, Pos, StrLen(Old));
            String := InsStr(String, New, Pos);
            Pos := StrPos(String, Old);
        end;

        Old := '/';
        Pos := StrPos(String, Old);
        while Pos <> 0 do begin
            String := DelStr(String, Pos, StrLen(Old) + 4);
            String := InsStr(String, New, Pos);
            Pos := StrPos(String, Old);
        end;

        exit(String);
    end;
}

