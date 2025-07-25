page 6150862 "NPR Signature Viewer"
{
    UsageCategory = None;
    Caption = 'Signature Preview';
    PageType = CardPart;
    SourceTable = "NPR POS Customer Input Entry";
    InsertAllowed = false;
    ModifyAllowed = false;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(InputHtml)
            {
                Caption = 'Signature';
                Visible = not ShowReturnDataCollectionAddin;

                usercontrol("HtmlInput"; "NPR HTML Display Input")
                {
                    ApplicationArea = NPRRetail;

                    trigger Ready()
                    begin
                        if not ShowReturnDataCollectionAddin then
                            FillAddIn();
                    end;
                }
            }
            group(ReturnInformation)
            {
                Caption = 'Signature';
                Visible = ShowReturnDataCollectionAddin;
                usercontrol("POS Customer Input Display"; "NPR POS Customer Input Display")
                {
                    ApplicationArea = NPRRetail;

                    trigger Ready()
                    begin
                        if ShowReturnDataCollectionAddin then
                            FillAddIn();
                    end;
                }
            }
        }
    }

    var
        ShowReturnDataCollectionAddin: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        case Rec.Context of
            Rec.Context::MONEY_BACK:
                ShowReturnDataCollectionAddin := false;
            Rec.Context::RETURN_INFORMATION,
            Rec.Context::"SALES_CARDHOLDER_VERIFICATION":
                ShowReturnDataCollectionAddin := true;
        end;
        Rec.CalcFields(Rec.Signature);
        FillAddIn();
    end;

    local procedure FillAddIn()
    var
        InputObj: JsonObject;
        SignStream: InStream;
        SignatureTxt: Text;
        tmp: Text;
    begin
        InputObj.Add('Signature', '[{"x":"FFFF","y":"FFFF"}]');
        if (Rec.Signature.HasValue()) then begin
            Clear(InputObj);
            Rec.CalcFields(Rec.Signature);
            Rec.Signature.CreateInStream(SignStream);
            repeat
                SignStream.ReadText(tmp);
                SignatureTxt := SignatureTxt + tmp;
            until SignStream.EOS();
            InputObj.Add('Signature', SignatureTxt);
        end;
        if ShowReturnDataCollectionAddin then
            CurrPage."POS Customer Input Display".SendInputDataAndLabelV2(InputObj, False, '', '', '', '')
        else
            CurrPage."HtmlInput".SendInputDataAndLabelV2(InputObj, False, '', '', '', '')
    end;
}
