page 6059903 "NPR POS Costumer Input"
{
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR POS Costumer Input";
    Extensible = false;
    ApplicationArea = NPRRetail;
    Caption = 'Costumer Input';
#IF NOT BC17
    AboutTitle = 'Costumer Input';
    AboutText = 'Costumer input defines the input given by a costumer, for a given context.';
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
                    Caption = 'Costumer Input Date & Time';
                    ToolTip = 'The date and time for collection of input.';
                    Editable = false;
#IF NOT BC17
                    AboutTitle = 'Costumer Input Date & Time';
                    AboutText = 'The date and time for collection of input.';
#ENDIF
                }
                field("Context Type"; Rec.Context)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Caption = 'Costumer Input Context';
                    ToolTip = 'Describes the context in which the input was gathered.';
#IF NOT BC17
                    AboutTitle = 'Costumer Input Context';
                    AboutText = 'Describes the context in which the input was gathered.';
#ENDIF

                }
                field("Phone Number"; Rec."Phone Number")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Caption = 'Costumer Phone Number';
                    ToolTip = 'The phone number given by the costumer';
#IF NOT BC17
                    AboutTitle = 'Costumer Phone Number';
                    AboutText = 'The phone number given by the costumer';
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
                            CurrPage.HtmlInput.SendInputData(InputObj, False);
                        end
                    end;
                }
            }
        }
    }
}