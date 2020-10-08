xmlport 6151187 "NPR MM Block Membership Member"
{

    Caption = 'Block Membership';
    UseDefaultNamespace = true;

    schema
    {
        textelement(members)
        {
            MaxOccurs = Once;
            textelement(blockmember)
            {
                MaxOccurs = Once;
                tableelement(tmpmemberinforequest; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membernumber; tmpMemberInfoRequest."External Member No")
                    {
                    }
                    fieldelement(membershipnumber; tmpMemberInfoRequest."External Membership No.")
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

    var
        NOT_FOUND: Label 'Filter combination removed all results.';

    procedure ClearResponse()
    begin

        tmpMemberInfoResponse.DeleteAll();
    end;

    procedure AddResponse(MembershipEntryNo: Integer; MemberExternalNumber: Code[20]; MemberExternalCardNo: Code[50])
    var
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
    begin

        errordescription := '';
        status := '1';

        tmpMemberInfoResponse."External Member No" := MemberExternalNumber;
        tmpMemberInfoResponse.Insert();
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';

        tmpMemberInfoResponse.Insert();
    end;
}

