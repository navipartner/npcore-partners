xmlport 6060138 "NPR MM Regret Member Timeframe"
{
    // MM1.26/TSA /20180219 CASE 305631 Initial Version
    // MM1.28/TSA /20180419 CASE 303635 External Document No

    Caption = 'Change Membership';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(memberships)
        {
            MaxOccurs = Once;
            textelement(regretmembershiptimeframe)
            {
                MaxOccurs = Once;
                tableelement(tmpmemberinfocapture; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(documentid; tmpMemberInfoCapture."Import Entry Document ID")
                    {
                    }
                }
                tableelement(tmpmembershipresponse; "NPR MM Membership")
                {
                    MaxOccurs = Unbounded;
                    MinOccurs = Zero;
                    XmlName = 'response';
                    UseTemporary = true;
                    textelement(status)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(errordescription)
                    {
                        MaxOccurs = Once;
                    }
                    tableelement(tmpmembershipentry; "NPR MM Membership Entry")
                    {
                        MinOccurs = Zero;
                        XmlName = 'membership';
                        UseTemporary = true;
                        fieldelement(communitycode; tmpMembershipResponse."Community Code")
                        {
                        }
                        fieldelement(membershipcode; tmpMembershipResponse."Membership Code")
                        {
                        }
                        fieldelement(membershipnumber; tmpMembershipResponse."External Membership No.")
                        {
                        }
                        fieldelement(issuedate; TmpMembershipEntry."Created At")
                        {
                        }
                        fieldelement(context; TmpMembershipEntry.Context)
                        {
                        }
                        fieldelement(blocked; TmpMembershipEntry.Blocked)
                        {
                        }
                        fieldelement(validfromdate; TmpMembershipEntry."Valid From Date")
                        {
                            MaxOccurs = Once;
                        }
                        fieldelement(validuntildate; TmpMembershipEntry."Valid Until Date")
                        {
                            MaxOccurs = Once;
                        }
                        fieldelement(documentid; TmpMembershipEntry."Import Entry Document ID")
                        {
                        }
                    }

                    trigger OnAfterGetRecord()
                    var
                        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
                        DateValidFromDate: Date;
                        DateValidUntilDate: Date;
                    begin
                    end;
                }
            }
        }
    }

    requestpage
    {
        Caption = 'MM Change Membership';

        layout
        {
        }

        actions
        {
        }
    }

    procedure ClearResponse()
    begin

        tmpMembershipResponse.DeleteAll();
    end;

    procedure AddResponse(MembershipEntryNo: Integer)
    var
        Membership: Record "NPR MM Membership";
        MembershipLedgerEntry: Record "NPR MM Membership Entry";
    begin

        errordescription := '';
        status := '1';

        if (MembershipEntryNo <= 0) then
            exit;

        Membership.Get(MembershipEntryNo);

        tmpMembershipResponse.TransferFields(Membership, true);
        if (tmpMembershipResponse.Insert()) then;

        MembershipLedgerEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        if (MembershipLedgerEntry.FindSet()) then begin
            repeat
                TmpMembershipEntry.TransferFields(MembershipLedgerEntry, true);
                TmpMembershipEntry.Insert();
            until (MembershipLedgerEntry.Next() = 0);
        end;
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';
        if (tmpMembershipResponse.Insert()) then;
    end;
}

