xmlport 6060132 "NPR MM Block Membership"
{

    Caption = 'Block Membership';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(members)
        {
            textelement(blockmembers)
            {
                tableelement(tmpmemberinforequest; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membershipnumber; tmpMemberInfoRequest."External Membership No.")
                    {
                    }
                    fieldelement(membernumber; tmpMemberInfoRequest."External Member No")
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
                    }
                    textelement(errordescription)
                    {
                        MaxOccurs = Once;
                    }
                    tableelement(tmpmemberinforesponse; "NPR MM Member Info Capture")
                    {
                        MaxOccurs = Unbounded;
                        MinOccurs = Zero;
                        XmlName = 'member';
                        UseTemporary = true;
                        fieldelement(membernumber; tmpMemberInfoResponse."External Member No")
                        {
                        }
                    }
                }
            }
        }
    }

    requestpage
    {
        Caption = 'MM Block Membership Member';

        layout
        {
        }

        actions
        {
        }
    }


    internal procedure ClearResponse()
    begin

        tmpMemberInfoResponse.DeleteAll();
    end;

    internal procedure AddResponse(MembershipEntryNo: Integer; MemberExternalNumber: Code[20]; MemberExternalCardNo: Code[100])
    begin

        errordescription := '';
        status := '1';

        tmpMemberInfoResponse.Insert();
    end;

    internal procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';

        tmpMemberInfoResponse.Insert();
    end;
}

