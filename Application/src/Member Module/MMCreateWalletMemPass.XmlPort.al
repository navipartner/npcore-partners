xmlport 6060143 "NPR MM Create Wallet Mem. Pass"
{

    Caption = 'Create Wallet Member Pass';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;

    schema
    {
        textelement(wallet)
        {
            MaxOccurs = Once;
            textelement(createwalletpass)
            {
                MaxOccurs = Once;
                tableelement(tmpmemberinfocapture; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(cardnumber; tmpMemberInfoCapture."External Card No.")
                    {
                    }
                }
                textelement(response)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    textelement(status)
                    {
                        MaxOccurs = Once;
                        XmlName = 'status';
                    }
                    textelement(errordescription)
                    {
                        MaxOccurs = Once;
                        XmlName = 'errordescription';
                    }
                    tableelement(tmpnotificationentry; "NPR MM Member Notific. Entry")
                    {
                        MinOccurs = Zero;
                        XmlName = 'walletpass';
                        UseTemporary = true;
                        textelement(emembercard)
                        {
                            textattribute(type)
                            {

                                trigger OnBeforePassVariable()
                                begin
                                    with TmpNotificationEntry do
                                        case "Notification Trigger" of
                                            "Notification Trigger"::WALLET_CREATE:
                                                type := 'CREATE';
                                            "Notification Trigger"::WALLET_UPDATE:
                                                type := 'UPDATE';
                                        end;
                                end;
                            }
                            fieldattribute(id; TmpNotificationEntry."Wallet Pass Id")
                            {
                            }
                            fieldattribute(walleturl; TmpNotificationEntry."Wallet Pass Landing URL")
                            {
                            }
                        }
                    }
                }
            }
        }
    }

    requestpage
    {
        Caption = 'MM Get Membership';

        layout
        {
        }

        actions
        {
        }
    }

    procedure ClearResponse()
    begin
    end;

    procedure AddResponse(MemberInfoCaptureEntryNo: Integer)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberNotificationEntry: Record "NPR MM Member Notific. Entry";
    begin

        if (not MemberInfoCapture.Get(MemberInfoCaptureEntryNo)) then begin
            AddErrorResponse('Invalid request.');
            exit;
        end;

        MemberNotificationEntry.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MemberNotificationEntry.SetFilter("Member Entry No.", '=%1', MemberInfoCapture."Member Entry No");
        if (not MemberNotificationEntry.FindLast()) then begin
            AddErrorResponse('Wallet create request not found.');
            exit;
        end;

        TmpNotificationEntry.TransferFields(MemberNotificationEntry, true);
        TmpNotificationEntry.Insert();

        ErrorDescription := 'OK';
        Status := '1';
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        ErrorDescription := ErrorMessage;
        Status := '0';
    end;
}

