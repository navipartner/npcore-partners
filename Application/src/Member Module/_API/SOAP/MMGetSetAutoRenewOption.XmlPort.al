xmlport 6060146 "NPR MM GetSet AutoRenew Option"
{

    Caption = 'GetSet AutoRenew Option';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(membershipelement)
        {
            XmlName = 'membership';
            textelement(getsetautorenew)
            {
                tableelement(tmpmembershiprequest; "NPR MM Membership")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membershipnumber; tmpMembershipRequest."External Membership No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    textelement(autorenewrequest)
                    {
                        MinOccurs = Zero;
                        XmlName = 'autorenew';
                    }
                    fieldelement(extrainfo; tmpMembershipRequest."Auto-Renew External Data")
                    {
                        MinOccurs = Zero;
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
                    tableelement(tmpmembershipresponse; "NPR MM Membership")
                    {
                        XmlName = 'membership';
                        UseTemporary = true;
                        textelement(autorenewresponse)
                        {
                            XmlName = 'autorenew';

                            trigger OnBeforePassVariable()
                            begin

                                case tmpMembershipResponse."Auto-Renew" of
                                    tmpMembershipResponse."Auto-Renew"::NO:
                                        AutoRenewResponse := 'Off';
                                    tmpMembershipResponse."Auto-Renew"::YES_INTERNAL:
                                        AutoRenewResponse := 'Internal';
                                    tmpMembershipResponse."Auto-Renew"::YES_EXTERNAL:
                                        AutoRenewResponse := 'External';
                                end;
                            end;
                        }
                        fieldelement(extrainfo; tmpMembershipResponse."Auto-Renew External Data")
                        {
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

    internal procedure createResponse()
    var
        Membership: Record "NPR MM Membership";
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
    begin

        if (not tmpMembershipRequest.FindFirst()) then begin
            setError('Invalid request.');
            exit;
        end;

        if (tmpMembershipRequest."External Membership No." = '') then begin
            setError('Invalid request.');
            exit;
        end;

        Membership.SetFilter("External Membership No.", '=%1', tmpMembershipRequest."External Membership No.");
        if (not Membership.FindFirst()) then begin
            setError('Membership not found.');
            exit;
        end;

        tmpMembershipResponse.TransferFields(Membership, true);
        tmpMembershipResponse.Insert();

        case UpperCase(AutoRenewRequest) of
            '':
                ; // query current status of auto renew
            'NO', 'OFF', 'FALSE':
                if (Membership."Auto-Renew" = Membership."Auto-Renew"::YES_INTERNAL) then begin
                    setError('Membership is currently setup to autorenew with internal and cant be changed by external.');
                    exit;
                end else begin
                    Membership."Auto-Renew" := Membership."Auto-Renew"::NO;
                    Membership."Auto-Renew External Data" := '';
                    Membership.Modify(true);
                end;
            'ON', 'YES', 'TRUE', 'EXTERNAL':
                if (Membership."Auto-Renew" = Membership."Auto-Renew"::YES_INTERNAL) then begin
                    setError('Membership is currently setup to autorenew with internal and cant be changed by external.');
                    exit;
                end else begin
                    Membership."Auto-Renew" := Membership."Auto-Renew"::YES_EXTERNAL;
                    Membership."Auto-Renew External Data" := tmpMembershipRequest."Auto-Renew External Data";
                    Membership.Modify(true);
                end;
            'OFF_INTERNAL':
                MembershipMgtInternal.DisableMembershipAutoRenewal(Membership, true, false);
            'ON_INTERNAL':
                MembershipMgtInternal.EnableMembershipInternalAutoRenewal(Membership, true, false);
            else begin
                setError('Incorrect auto-renew state.');
                exit;
            end;
        end;

        tmpMembershipResponse.TransferFields(Membership, true);
        tmpMembershipResponse.Modify();

        status := 'OK';
        errordescription := '';
    end;

    internal procedure setError(ReasonText: Text)
    begin
        status := 'ERROR';
        errordescription := ReasonText;
    end;
}

