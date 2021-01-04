page 6060145 "NPR MM Member Info Cap. Camera"
{

    Caption = 'Member Info Capture Camera';
    SourceTable = "NPR MM Member Info Capture";

    layout
    {
        area(content)
        {
            usercontrol(Camera; "NPRNaviPartner.POS.Camera")
            {
                ApplicationArea = All;
                trigger SaveCompleted(HTML: Text)
                var
                    OutS: OutStream;
                    StreamWriter: DotNet NPRNetStreamWriter;
                    Convert: DotNet NPRNetConvert;
                    Bytes: DotNet NPRNetArray;
                    MemoryStream: DotNet NPRNetMemoryStream;
                begin
                    if HTML <> Txt then begin
                        Error(HTML);
                        //IF HTML <> '' THEN
                        //  HTML := COPYSTR(HTML,24);
                        Bytes := Convert.FromBase64String(HTML);
                        MemoryStream := MemoryStream.MemoryStream(Bytes);
                        Picture.CreateOutStream(OutS);
                        MemoryStream.WriteTo(OutS);
                        Modify();

                        //  Picture.CREATEOUTSTREAM(OutS);
                        //  StreamWriter := StreamWriter.StreamWriter(OutS);
                        //  StreamWriter.Write(CameraHook.Base64Decode(HTML));
                        //  StreamWriter.Write(HTML);
                        //  StreamWriter.Flush();
                        //  StreamWriter.Close();
                        //  Modify();

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
                ApplicationArea = All;
                ToolTip = 'Executes the Save Photo action';

                trigger OnAction()
                begin
                    CurrPage.Camera.RequestSave();
                end;
            }
            action("Snap Photo")
            {
                Caption = 'Snap Photo';
                Image = Camera;
                InFooterBar = true;
                Promoted = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Snap Photo action';

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
        CameraHook: Codeunit "NPR MM Member Camera Hook";

    procedure SetText(pTxt: Text)
    begin
        Txt := pTxt;
    end;

    procedure GetText(): Text
    begin
        exit(Txt);
    end;
}

