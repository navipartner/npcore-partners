page 6151320 "NPR PDF Digital Receipt Viewer"
{
    UsageCategory = None;
    Caption = 'PDF Digital Receipt Preview';
    PageType = CardPart;
    SourceTable = "NPR POSSale Dig. Receipt Entry";
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
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
                usercontrol(QRCodePreview; "Microsoft.Dynamics.Nav.Client.WebPageViewer")
#ELSE
                usercontrol(QRCodePreview; WebPageViewer)
#ENDIF
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
