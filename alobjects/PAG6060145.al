page 6060145 "MM Member Info Capture Camera"
{
    // MM1.19/TSA/20170525  CASE 278061 Handling issues reported by OMA

    Caption = 'Member Info Capture Camera';
    SourceTable = "MM Member Info Capture";

    layout
    {
        area(content)
        {
            usercontrol(Camera;"NaviPartner.POS.Camera")
            {
                trigger SaveCompleted(HTML: Text)
                var
                    OutS: OutStream;
                    StreamWriter: DotNet npNetStreamWriter;
                    Convert: DotNet npNetConvert;
                    Bytes: DotNet npNetArray;
                    MemoryStream: DotNet npNetMemoryStream;
                begin
                    if HTML <> Txt then begin
                      Error(HTML);
                      //IF HTML <> '' THEN
                      //  HTML := COPYSTR(HTML,24);
                      Bytes := Convert.FromBase64String(HTML);
                      MemoryStream := MemoryStream.MemoryStream(Bytes);
                      Picture.CreateOutStream(OutS);
                      MemoryStream.WriteTo(OutS);
                      Modify;

                    //  Picture.CREATEOUTSTREAM(OutS);
                    //  StreamWriter := StreamWriter.StreamWriter(OutS);
                    //  StreamWriter.Write(CameraHook.Base64Decode(HTML));
                    //  StreamWriter.Write(HTML);
                    //  StreamWriter.Flush();
                    //  StreamWriter.Close();
                    //  MODIFY;

                    end;

                    CurrPage.Close();
                end;
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Save Photo")
            {
                Caption = 'Save Photo';
                Image = Save;
                InFooterBar = true;
                Promoted = true;

                trigger OnAction()
                begin
                    CurrPage.Camera.RequestSave();
                end;
            }
            action("Snap Photo")
            {
                Caption = 'Snap Photo';
                Image = camera;
                InFooterBar = true;
                Promoted = true;

                trigger OnAction()
                begin
                    CurrPage.Camera.SnapPhoto();
                end;
            }
        }
    }

    var
        Txt: Text;
        Saved: Boolean;
        Txt001: Label 'data:image/jpeg;base64,';
        CameraHook: Codeunit "MM Member Camera Hook";

    procedure SetText(pTxt: Text)
    begin
        Txt := pTxt;
    end;

    procedure GetText(): Text
    begin
        exit(Txt);
    end;
}

