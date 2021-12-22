page 6059963 "NPR MPOS QR Code FactBox"
{
    Caption = 'MPOS QR Code FactBox';
    PageType = CardPart;
    UsageCategory = Administration;

    ShowFilter = false;
    SourceTable = "NPR MPOS QR Code";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            field("QR code"; Rec."QR Image")
            {
                ShowCaption = false;
                ToolTip = 'Specifies the value of the QR code field';
                ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Save To Disk action';
                Image = Save;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    FileManagement: Codeunit "File Management";
                    fPath: Text[1024];
                    FileBlob: Codeunit "Temp Blob";
                    OutStr: OutStream;
                begin
                    if Rec."QR Image".HasValue() then begin
                        if Rec.Company <> '' then
                            fPath := StringReplace(Rec."User ID" + '_' + Rec.Company) + '.png'
                        else
                            fPath := StringReplace(Rec."User ID") + '.png';
                        FileBlob.CreateOutStream(OutStr);
                        Rec."QR Image".ExportStream(OutStr);
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

