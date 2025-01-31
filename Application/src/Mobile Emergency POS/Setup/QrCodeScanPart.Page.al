page 6184890 "NPR Qr Code Scan Part"
{
    PageType = CardPart;
    Extensible = False;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            usercontrol("QR"; "NPR Image Viewer")
            {
                ApplicationArea = NPRRetail;
                trigger ControlAddInReady()
                begin
                    if (Base64QrContentSrc <> '') then
                        CurrPage.QR.SetSource(Base64QrContentSrc)
                    else
                        CurrPage.QR.HideImage();
                end;
            }
        }
    }

    internal procedure SetQrContent(QrContent: Text)
    var
        AFQRCode: Codeunit "NPR AF QR Code";
        Base64: Text;
    begin
        if (AFQRCode.GenerateQRCode(QrContent, Base64)) then begin
            Base64QrContentSrc := StrSubstNo('data:image/png;base64, %1', Base64);
            CurrPage.QR.SetSource(Base64QrContentSrc);
        end else begin
            Message(GetLastErrorText());
        end;
    end;

    internal procedure HidQrImage()
    begin
        CurrPage.QR.HideImage();
    end;

    var
        Base64QrContentSrc: Text;
}