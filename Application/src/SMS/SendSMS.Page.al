page 6014636 "NPR Send SMS"
{
    Caption = 'Send SMS';

    layout
    {
        area(content)
        {
            grid(Control6150614)
            {
                ShowCaption = false;
                group(Control6150615)
                {
                    ShowCaption = false;
                    field(Sender; Sender)
                    {
                        ApplicationArea = All;
                        Caption = 'Sender';
                        ToolTip = 'Specifies the value of the Sender field';
                    }
                    field(txtNum; ToSMS)
                    {
                        ApplicationArea = All;
                        Caption = 'Mobile Number';
                        ToolTip = 'Specifies the value of the Mobile Number field';
                    }
                }
                group(Control6150618)
                {
                    ShowCaption = false;
                    field("FORMAT(LettersLeft) + ' tegn tilbage'"; Format(LettersLeft) + ' tegn tilbage')
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Format(LettersLeft) + '' tegn tilbage'' field';
                    }
                    field("SMS text (max. 160 characters)"; '')
                    {
                        ApplicationArea = All;
                        Caption = 'SMS text (max. 160 characters)';
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the SMS text (max. 160 characters) field';
                    }
                }
            }
            field("SMStekst[1]"; SMStekst[1])
            {
                ApplicationArea = All;
                ShowCaption = false;
                ToolTip = 'Specifies the value of the SMStekst[1] field';
            }
            field("SMStekst[2]"; SMStekst[2])
            {
                ApplicationArea = All;
                ShowCaption = false;
                ToolTip = 'Specifies the value of the SMStekst[2] field';
            }
            field("SMStekst[3]"; SMStekst[3])
            {
                ApplicationArea = All;
                ShowCaption = false;
                ToolTip = 'Specifies the value of the SMStekst[3] field';
            }
            field("SMStekst[4]"; SMStekst[4])
            {
                ApplicationArea = All;
                ShowCaption = false;
                ToolTip = 'Specifies the value of the SMStekst[4] field';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Reset")
            {
                Caption = 'Reset';
                Image = "Action";
                Promoted = true;
                PromotedIsBig = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Reset action';

                trigger OnAction()
                begin
                    SMStekst[1] := '';
                    SMStekst[2] := '';
                    SMStekst[3] := '';
                    SMStekst[4] := '';
                    Sender := '';
                    ToSMS := '';
                end;
            }
            action(Close)
            {
                Caption = 'Close';
                Image = "Action";
                Promoted = true;
                PromotedIsBig = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Close action';

                trigger OnAction()
                begin
                    CurrPage.Close;
                end;
            }
            action(Send)
            {
                Caption = 'Send';
                Image = SendTo;
                Promoted = true;
                PromotedIsBig = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Send action';

                trigger OnAction()
                var
                    SmsMgt: Codeunit "NPR SMS Management";
                begin
                    //-NPR5.27 [255580]
                    //"I-Comm".GET;
                    //SMSCode.SmsEclub(toSMS,SMStekst[1] + SMStekst[2] + SMStekst[3] + SMStekst[4],sender);
                    //MESSAGE('Beskeden er sendt.');
                    SmsMgt.SendSMS(ToSMS, Sender, SMStekst[1] + SMStekst[2] + SMStekst[3] + SMStekst[4]);
                    //+NPR5.27 [255580]
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        IComm: Record "NPR I-Comm";
    begin
        IComm.Get;
        Sender := IComm."E-Club Sender";
    end;

    var
        SMStekst: array[4] of Text;
        ToSMS: Text[30];
        Sender: Text[100];
        BSlash: Label '\';
        Text000: Label 'Sms Sent';

    procedure LettersLeft(): Integer
    begin
        exit(160 - StrLen(SMStekst[1] + SMStekst[2] + SMStekst[3] + SMStekst[4]));
    end;
}

