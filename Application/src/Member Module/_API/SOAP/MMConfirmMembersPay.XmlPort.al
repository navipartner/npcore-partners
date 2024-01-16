xmlport 6060137 "NPR MM Confirm Members. Pay."
{
    Caption = 'Confirm Membership Payment';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(memberships)
        {
            textelement(confirmmembership)
            {
                MaxOccurs = Once;
                tableelement(tmpmemberinfocapture; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    textattribute(NstServiceInstanceIdIn)
                    {
                        XmlName = 'cache_instance_id';
                        Occurrence = Optional;
                    }
                    fieldelement(documentid; tmpMemberInfoCapture."Import Entry Document ID")
                    {
                    }
                    fieldelement(externaldocumentnumber; tmpMemberInfoCapture."Document No.")
                    {
                    }
                    fieldelement(amount; tmpMemberInfoCapture.Amount)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(amountinclvat; tmpMemberInfoCapture."Amount Incl VAT")
                    {
                    }
                }
                tableelement(tmpmembershipresponse; "NPR MM Membership")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'response';
                    UseTemporary = true;
                    textattribute(NstServiceInstanceIdOut)
                    {
                        XmlName = 'cache_instance_id';
                        trigger OnBeforePassVariable()
                        begin
                            NstServiceInstanceIdOut := Format(ServiceInstanceId(), 0, 9);
                        end;
                    }
                    textelement(status)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(errordescription)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(membership)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        fieldelement(communitycode; tmpMembershipResponse."Community Code")
                        {
                        }
                        fieldelement(membershipcode; tmpMembershipResponse."Membership Code")
                        {
                        }
                        fieldelement(membershipnumber; tmpMembershipResponse."External Membership No.")
                        {
                        }
                        fieldelement(issuedate; tmpMembershipResponse."Issued Date")
                        {
                        }
                        textelement(validfromdate)
                        {
                            MaxOccurs = Once;
                            XmlName = 'validfromdate';
                        }
                        textelement(validuntildate)
                        {
                            MaxOccurs = Once;
                            XmlName = 'validuntildate';
                        }
                    }

                    trigger OnAfterGetRecord()
                    var
                        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
                        DateValidFromDate: Date;
                        DateValidUntilDate: Date;
                    begin
                        MembershipManagement.GetMembershipValidDate(tmpMembershipResponse."Entry No.", Today, DateValidFromDate, DateValidUntilDate);
                        ValidFromDate := Format(DateValidFromDate, 0, 9);
                        ValidUntilDate := Format(DateValidUntilDate, 0, 9);
                    end;
                }
            }
        }
    }

    requestpage
    {
        Caption = 'MM Create Membership';

        layout
        {
        }

        actions
        {
        }
    }

    internal procedure ClearResponse()
    begin

        tmpMembershipResponse.DeleteAll();
    end;

    internal procedure AddResponse(MembershipEntryNo: Integer)
    var
        Membership: Record "NPR MM Membership";
    begin

        errordescription := '';
        status := '1';

        Membership.Get(MembershipEntryNo);

        tmpMembershipResponse.TransferFields(Membership);
        tmpMembershipResponse.Insert();
    end;

    internal procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';

        tmpMembershipResponse.Insert();
    end;
}

