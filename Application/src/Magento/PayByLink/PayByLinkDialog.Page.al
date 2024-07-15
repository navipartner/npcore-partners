page 6184597 "NPR Pay by Link Dialog"
{
    PageType = StandardDialog;
    Caption = 'Pay by Link';
    Extensible = false;


    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Amount; Amount)
                {
                    ApplicationArea = NPRRetail;
                    Editable = not ReSending;
                    Caption = 'Amount';
                    ToolTip = 'Specifies the total amount to be charged by Pay by Link';
                }

                field("E-Mail"; Email)
                {
                    ApplicationArea = NPRRetail;
                    Editable = true;
                    Caption = 'Send to E-Mail';
                    ToolTip = 'Specifies the recipient email address where the Pay by Link will be sent.';
                }

                field("Mobile Phone No."; MobilePhoneNo)
                {
                    ApplicationArea = NPRRetail;
                    Editable = true;
                    Caption = 'Send to Mobile Phone No.';
                    ToolTip = 'Specifies the recipient phone no. where the Pay by Link will be sent.';
                }

                field("Send SMS"; SendSMS)
                {
                    ApplicationArea = NPRRetail;
                    Editable = true;
                    Caption = 'Send SMS';
                    ToolTip = 'Specifies if SMS will be sent';
                }

                field("Send E-mail"; SendEmail)
                {
                    ApplicationArea = NPRRetail;
                    Editable = true;
                    Caption = 'Send E-mail';
                    ToolTip = 'Specifies if e-mail will be sent';
                }
                field("Expiration Duration"; ExpirationDuration)
                {
                    ApplicationArea = NPRRetail;
                    Editable = not ReSending;
                    Caption = 'Expiration Link Duration';
                    ToolTip = 'Specifies the value of the Pay by Link Expiration Duration';

                    trigger OnValidate()
                    var
                        PayByLinkSetup: Record "NPR Pay By Link Setup";
                    begin
                        PayByLinkSetup.CheckExpDuration(ExpirationDuration);
                    end;
                }
            }
        }
    }

    var
        Amount: Decimal;
        Email: Text[80];
        MobilePhoneNo: Text[30];
        SendSMS: Boolean;
        SendEmail: Boolean;
        ExpirationDuration: Duration;
        ReSending: Boolean;


    procedure SetValues(NewAmount: Decimal; NewEmail: Text[80]; NewPhoneNo: Text[30]; NewSendEmail: Boolean; NewSendSMS: Boolean; NewExpirationDuration: Duration)
    begin
        Amount := NewAmount;
        Email := NewEmail;
        MobilePhoneNo := NewPhoneNo;
        SendEmail := NewSendEmail;
        SendSMS := NewSendSMS;
        ExpirationDuration := NewExpirationDuration;
    end;

    procedure GetValues(var NewAmount: Decimal; var NewEmail: Text[80]; var NewPhoneNo: Text[30]; var NewSendEmail: Boolean; var NewSendSMS: Boolean; var NewExpirationDuration: Duration)
    begin
        NewAmount := Amount;
        NewEmail := Email;
        NewPhoneNo := MobilePhoneNo;
        NewSendEmail := SendEmail;
        NewSendSMS := SendSMS;
        NewExpirationDuration := ExpirationDuration;
    end;

    procedure SetResending()
    begin
        ReSending := true;
    end;
}