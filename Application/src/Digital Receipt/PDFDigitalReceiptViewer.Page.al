page 6151320 "NPR PDF Digital Receipt Viewer"
{
    UsageCategory = None;
    Caption = 'PDF Digital Receipt Preview';
    PageType = CardPart;
    SourceTable = "NPR POSSaleDigitalReceiptEntry";
    InsertAllowed = false;
    ModifyAllowed = false;
    Editable = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                ShowCaption = false;
                usercontrol(DigitalReceiptPreview; "NPR DigitalReceiptViewer")
                {
                    ApplicationArea = NPRRetail;
                }
                usercontrol(QRCodePreview; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
                {
                    ApplicationArea = NPRRetail;
                    trigger ControlAddInReady(callbackUrl: Text)
                    begin
                        FillQRAddin();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        FillQRAddin();
        FillDigitalReceiptAddin();
    end;

    local procedure FillQRAddin()
    var
        POSActionQRViewDigRcptB: Codeunit "NPR POS Action QRViewDigRcpt B";
        QRCodeText: Text;
        HTMLText: Text;
    begin
        if Rec."QR Code Link" = '' then begin
            CurrPage.QRCodePreview.SetContent('');
            exit;
        end;
        QRCodeText := POSActionQRViewDigRcptB.GenerateQRCode(Rec."QR Code Link");
        HTMLText := StrSubstNo('<div style="text-align: center;"><img src="data:image/png;base64,%1" width="300" height="300"/></div>', QRCodeText);
        CurrPage.QRCodePreview.SetContent(HTMLText);
    end;

    local procedure FillDigitalReceiptAddin()
    begin
        CurrPage.DigitalReceiptPreview.SetContent(Rec.PDFLink);
    end;
}
