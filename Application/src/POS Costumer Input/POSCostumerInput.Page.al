page 6150774 "NPR POS Costumer Input"
{
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR POS Costumer Input";
    Extensible = false;
    ApplicationArea = NPRRetail;
    Caption = 'Customer Input';
#IF NOT BC17
    AboutTitle = 'Customer Input';
    AboutText = 'Customer input defines the input given by a customer, for a given context.';
#ENDIF

    layout
    {
        area(Content)
        {
            group("Costumer Input Fields")
            {
                field(Id; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'POS Entry No.';
                    ToolTip = 'Specifies the POS Entry that the input relates to.';
                    Editable = false;
#IF NOT BC17
                    AboutTitle = 'POS Entry No.';
                    AboutText = 'Specifies the POS Entry that the input relates to.';
#ENDIF
                }
                field("Date"; Rec."Date & Time")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Customer Input Date & Time';
                    ToolTip = 'The date and time for collection of input.';
                    Editable = false;
#IF NOT BC17
                    AboutTitle = 'Customer Input Date & Time';
                    AboutText = 'The date and time for collection of input.';
#ENDIF
                }
                field("Context Type"; Rec.Context)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Caption = 'Customer Input Context';
                    ToolTip = 'Describes the context in which the input was gathered.';
#IF NOT BC17
                    AboutTitle = 'Customer Input Context';
                    AboutText = 'Describes the context in which the input was gathered.';
#ENDIF

                }
                field("Phone Number"; Rec."Phone Number")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Caption = 'Customer Phone Number';
                    ToolTip = 'The phone number given by the customer';
#IF NOT BC17
                    AboutTitle = 'Customer Phone Number';
                    AboutText = 'The phone number given by the customer';
#ENDIF

                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Caption = 'Customer E-Mail';
                    ToolTip = 'The e-mail given by the customer';
#IF NOT BC17
                    AboutTitle = 'Customer E-Mail';
                    AboutText = 'The e-mail given by the customer';
#ENDIF
                }
            }
            group(InputHtml)
            {
                Caption = 'Signature';
                usercontrol("HtmlInput"; "NPR HTML Display Input")
                {
                    ApplicationArea = NPRRetail;

                    trigger Ready()
                    begin
                        FillAddIn();
                    end;
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
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
        if (Rec.Signature.HasValue()) then begin
            Rec.CalcFields(Rec.Signature);
            Rec.Signature.CreateInStream(SignStream);
            repeat
                SignStream.ReadText(tmp);
                SignatureTxt := SignatureTxt + tmp;
            until SignStream.EOS();
            InputObj.Add('Signature', SignatureTxt);
            CurrPage.HtmlInput.SendInputDataAndLabelV2(InputObj, False, '', '', '', '');
        end
    end;
}