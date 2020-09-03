codeunit 6060137 "NPR MM Member Camera Hook"
{
    // MM1.16/NPKNAV/20161026  CASE 240868 Transport T0003 - MM1.16


    trigger OnRun()
    begin
    end;

    var
        Convert: DotNet NPRNetConvert;
        Bytes: DotNet NPRNetArray;
        Encoding: DotNet NPRNetEncoding;
        Txt001: Label 'data:image/jpeg;base64,';

    procedure OpenCameraMMMemberInfoCapture(var MMMemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        MMMemberInfoCaptureCamera: Page "NPR MM Member Info Cap. Camera";
        InS: InStream;
        StreamReader: DotNet NPRNetStreamReader;
        Txt: Text;
        StreamWriter: DotNet NPRNetStreamWriter;
        MemoryStream: DotNet NPRNetMemoryStream;
    begin
        if MMMemberInfoCapture.Picture.HasValue then begin
            MMMemberInfoCapture.Picture.CreateInStream(InS);

            MemoryStream := MemoryStream.MemoryStream();
            CopyStream(MemoryStream, InS);
            Bytes := MemoryStream.ToArray();
            Txt := Txt001 + Convert.ToBase64String(Bytes);

            //    StreamReader := StreamReader.StreamReader(InS);
            //    Txt := StreamReader.ReadToEnd();
            //    StreamReader.Close();

        end;

        MMMemberInfoCaptureCamera.SetText(Txt);
        MMMemberInfoCaptureCamera.SetRecord(MMMemberInfoCapture);
        MMMemberInfoCaptureCamera.Run();
    end;

    procedure Base64Encode(plainText: Text): Text
    begin
        Bytes := Encoding.UTF8.GetBytes(plainText);
        exit(Convert.ToBase64String(Bytes));
    end;

    procedure Base64Decode(base64EncodedData: Text): Text
    begin
        Bytes := Convert.FromBase64String(base64EncodedData);
        exit(Encoding.UTF8.GetString(Bytes));
    end;
}

