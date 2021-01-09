codeunit 6060137 "NPR MM Member Camera Hook"
{
    var
        Txt001: Label 'data:image/jpeg;base64,';

    procedure OpenCameraMMMemberInfoCapture(var MMMemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        MMMemberInfoCaptureCamera: Page "NPR MM Member Info Cap. Camera";
        InS: InStream;
        Txt: Text;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        if MMMemberInfoCapture.Picture.HasValue then begin
            MMMemberInfoCapture.Picture.CreateInStream(InS);
            Txt := Txt001 + Base64Convert.ToBase64(InS);
        end;

        MMMemberInfoCaptureCamera.SetText(Txt);
        MMMemberInfoCaptureCamera.SetRecord(MMMemberInfoCapture);
        MMMemberInfoCaptureCamera.Run();
    end;

    procedure Base64Encode(plainText: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        exit(Base64Convert.ToBase64(plainText));
    end;

    procedure Base64Decode(base64EncodedData: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        exit(Base64Convert.FromBase64(base64EncodedData));
    end;
}

