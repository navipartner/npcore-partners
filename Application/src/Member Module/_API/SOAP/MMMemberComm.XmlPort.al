xmlport 6151188 "NPR MM Member Comm."
{

    Caption = 'Member Communication';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(membership)
        {
            MaxOccurs = Once;
            textelement(getsetcomoptions)
            {
                MaxOccurs = Once;
                textelement(request)
                {
                    MaxOccurs = Once;
                    textelement(membernumber)
                    {
                        MaxOccurs = Once;
                        XmlName = 'membernumber';
                    }
                    textelement(membershipnumber)
                    {
                        MaxOccurs = Once;
                        XmlName = 'membershipnumber';
                    }
                    textelement(communicationoptions)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        tableelement(tmpmembercommunicationrequest; "NPR MM Member Communication")
                        {
                            MinOccurs = Zero;
                            XmlName = 'option';
                            UseTemporary = true;
                            textattribute(messagetyperequest)
                            {
                                XmlName = 'messagetype';
                            }
                            textattribute(methodrequest)
                            {
                                XmlName = 'method';
                            }
                            textattribute(acceptedrequest)
                            {
                                XmlName = 'accepted';
                            }

                            trigger OnAfterGetRecord()
                            begin

                                MessagetypeRequest := MessageTypeOptionToText(TmpMemberCommunicationRequest."Message Type");
                                MethodRequest := MethodOptionToText(TmpMemberCommunicationRequest."Preferred Method");
                                AcceptedRequest := AcceptedOptionToText(TmpMemberCommunicationRequest."Accepted Communication");
                            end;

                            trigger OnBeforeInsertRecord()
                            begin

                                TmpMemberCommunicationRequest."Message Type" := MessageTypeTextToOption(MessagetypeRequest);
                                TmpMemberCommunicationRequest."Preferred Method" := MethodTextToOption(MethodRequest);
                                TmpMemberCommunicationRequest."Accepted Communication" := AcceptedTextToOption(AcceptedRequest);
                            end;
                        }
                    }
                }
                textelement(response)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    textelement(status)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(errordescription)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(membershipresponse)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        XmlName = 'membership';
                        textattribute(membernumberresponse)
                        {
                            XmlName = 'membernumber';
                        }
                        textattribute(membershipnumberresponse)
                        {
                            XmlName = 'membershipnumber';
                        }
                        textelement(communicationoptionsresponse)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            XmlName = 'communicationoptions';
                            tableelement(tmpmembercommunicationresponse; "NPR MM Member Communication")
                            {
                                MinOccurs = Zero;
                                XmlName = 'option';
                                UseTemporary = true;
                                textattribute(messagetype)
                                {
                                }
                                textattribute(method)
                                {
                                }
                                textattribute(accepted)
                                {
                                }
                                fieldattribute(lastchangedate; TmpMemberCommunicationResponse."Changed At")
                                {
                                }

                                trigger OnAfterGetRecord()
                                begin

                                    messagetype := MessageTypeOptionToText(TmpMemberCommunicationResponse."Message Type");
                                    method := MethodOptionToText(TmpMemberCommunicationResponse."Preferred Method");
                                    accepted := AcceptedOptionToText(TmpMemberCommunicationResponse."Accepted Communication");
                                end;
                            }
                        }
                    }
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    internal procedure GetRequest(var MemberNumberOut: Code[20]; var MembershipNumberOut: Code[20]; var TmpMemberCommunication: Record "NPR MM Member Communication" temporary)
    begin

        status := 'OK';

        MemberNumberOut := membernumber;
        MembershipNumberOut := membershipnumber;

        if (TmpMemberCommunicationRequest.FindSet()) then begin
            repeat
                TmpMemberCommunication.TransferFields(TmpMemberCommunicationRequest, true);
                TmpMemberCommunication.Insert();
            until (TmpMemberCommunicationRequest.Next() = 0);
        end;

        if (errordescription <> '') then
            status := 'ERROR';
    end;

    internal procedure SetResponse(MemberNumberIn: Code[20]; MembershipNumberIn: Code[20]; var TmpMemberCommunication: Record "NPR MM Member Communication" temporary)
    begin

        if (status <> 'OK') then
            exit;

        membernumberresponse := MemberNumberIn;
        membershipnumberresponse := MembershipNumberIn;

        TmpMemberCommunication.Reset();
        if (TmpMemberCommunication.FindSet()) then begin
            repeat
                TmpMemberCommunicationResponse.TransferFields(TmpMemberCommunication, true);
                TmpMemberCommunicationResponse.Insert();
            until (TmpMemberCommunication.Next() = 0);
        end;

        TmpMemberCommunicationRequest.Reset();
    end;

    internal procedure SetErrorResponse(ResponseText: Text)
    begin

        status := 'ERROR';
        errordescription := ResponseText;
    end;

    local procedure MessageTypeOptionToText(MessageType: Option) Name: Text
    var
        MemberCommunication: Record "NPR MM Member Communication";
    begin

        case MessageType of
            MemberCommunication."Message Type"::WELCOME:
                Name := 'Welcome';
            MemberCommunication."Message Type"::RENEW:
                Name := 'Renew';
            MemberCommunication."Message Type"::TICKETS:
                Name := 'Tickets';
            MemberCommunication."Message Type"::NEWSLETTER:
                Name := 'Newsletter';
            MemberCommunication."Message Type"::MEMBERCARD:
                Name := 'MemberCard';
        end;
    end;

    local procedure MethodOptionToText(Method: Option) Name: Text
    var
        MemberCommunication: Record "NPR MM Member Communication";
    begin

        case Method of
            MemberCommunication."Preferred Method"::EMAIL:
                Name := 'E-Mail';
            MemberCommunication."Preferred Method"::SMS:
                Name := 'SMS';
            MemberCommunication."Preferred Method"::MANUAL:
                Name := 'Manual';
            MemberCommunication."Preferred Method"::WALLET_EMAIL:
                Name := 'Wallet (E-Mail)';
            MemberCommunication."Preferred Method"::WALLET_SMS:
                Name := 'Wallet (SMS)';
        end;
    end;

    local procedure AcceptedOptionToText(Accepted: Option) Name: Text
    var
        MemberCommunication: Record "NPR MM Member Communication";
    begin

        case Accepted of
            MemberCommunication."Accepted Communication"::PENDING:
                Name := 'Pending';
            MemberCommunication."Accepted Communication"::"OPT-IN":
                Name := 'OptIn';
            MemberCommunication."Accepted Communication"::"OPT-OUT":
                Name := 'OptOut';
        end;
    end;

    local procedure MessageTypeTextToOption(Name: Text) OptionValue: Integer
    var
        MemberCommunication: Record "NPR MM Member Communication";
        InvalidMessageTypeLbl: Label 'Invalid MessageType option "%1". Valid options are "Welcome|Renew|Newsletter|Membercard|Tickets".';
    begin

        case UpperCase(Name) of
            '0', 'WELCOME':
                OptionValue := MemberCommunication."Message Type"::WELCOME;
            '1', 'RENEW':
                OptionValue := MemberCommunication."Message Type"::RENEW;
            '2', 'NEWSLETTER':
                OptionValue := MemberCommunication."Message Type"::NEWSLETTER;
            '3', 'MEMBERCARD':
                OptionValue := MemberCommunication."Message Type"::MEMBERCARD;
            '4', 'TICKETS':
                OptionValue := MemberCommunication."Message Type"::TICKETS;
            else begin
                    OptionValue := TmpMemberCommunicationRequest.Count() + 1 + 5; // part of the key - to avoid insert errors on multiple incorrect types;
                    errordescription := StrSubstNo(InvalidMessageTypeLbl, Name);
                end;
        end;
    end;

    local procedure MethodTextToOption(Name: Text) OptionValue: Integer
    var
        MemberCommunication: Record "NPR MM Member Communication";
        InvalidMethodOptionLbl: Label 'Invalid Method option "%1". Valid options are "Manual|SMS|E-Mail|Wallet (SMS)|Wallet (E-Mail)".';
    begin

        case UpperCase(Name) of
            '0', 'MANUAL':
                OptionValue := MemberCommunication."Preferred Method"::MANUAL;
            '1', 'SMS':
                OptionValue := MemberCommunication."Preferred Method"::SMS;
            '2', 'EMAIL', 'E-MAIL':
                OptionValue := MemberCommunication."Preferred Method"::EMAIL;
            '3', 'WALLET_SMS', 'WALLET (SMS)':
                OptionValue := MemberCommunication."Preferred Method"::WALLET_SMS;
            '4', 'WALLET_EMAIL', 'WALLET (E-MAIL)', 'WALLET (EMAIL)':
                OptionValue := MemberCommunication."Preferred Method"::WALLET_EMAIL;
            else
                errordescription := StrSubstNo(InvalidMethodOptionLbl, Name);
        end;
    end;

    local procedure AcceptedTextToOption(Name: Text) OptionValue: Integer
    var
        MemberCommunication: Record "NPR MM Member Communication";
        InvalidAcceptedOptionLbl: Label 'Invalid Accepted option "%1". Valid options are "Pending|Opt-In|Opt-Out".';
    begin

        case UpperCase(Name) of
            '0', 'PENDING':
                OptionValue := MemberCommunication."Accepted Communication"::PENDING;
            '1', 'OPTIN', 'OPT-IN':
                OptionValue := MemberCommunication."Accepted Communication"::"OPT-IN";
            '2', 'OPTOUT', 'OPT-OUT':
                OptionValue := MemberCommunication."Accepted Communication"::"OPT-OUT";
            else
                errordescription := StrSubstNo(InvalidAcceptedOptionLbl, Name);
        end;
    end;
}

