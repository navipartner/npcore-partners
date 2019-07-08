xmlport 6060134 "MM Change Membership"
{
    // MM1.11/TSA/20160428  CASE 239025 Online membership change management
    // MM1.11/TSA/20160502  CASE 239052 Transport MM1.11 - 29 April 2016
    // TM1.17/TSA /20161025  CASE 256152 Conform to OMA Guidelines
    // MM1.26/TSA /20180219 CASE 305631 Added element documentid

    Caption = 'Change Membership';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(memberships)
        {
            MaxOccurs = Once;
            textelement(changemembership)
            {
                MaxOccurs = Once;
                tableelement(tmpmemberinfocapture;"MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membershipnumber;tmpMemberInfoCapture."External Membership No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(changetype;tmpMemberInfoCapture."Information Context")
                    {
                    }
                    fieldelement(membershipchangeitem;tmpMemberInfoCapture."Item No.")
                    {
                    }
                }
                tableelement(tmpmembershipresponse;"MM Membership")
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
                    tableelement(tmpmembershipentry;"MM Membership Entry")
                    {
                        MinOccurs = Zero;
                        XmlName = 'membership';
                        UseTemporary = true;
                        fieldelement(communitycode;tmpMembershipResponse."Community Code")
                        {
                        }
                        fieldelement(membershipcode;tmpMembershipResponse."Membership Code")
                        {
                        }
                        fieldelement(membershipnumber;tmpMembershipResponse."External Membership No.")
                        {
                        }
                        fieldelement(issuedate;TmpMembershipEntry."Created At")
                        {
                        }
                        fieldelement(context;TmpMembershipEntry.Context)
                        {
                        }
                        fieldelement(blocked;TmpMembershipEntry.Blocked)
                        {
                        }
                        fieldelement(validfromdate;TmpMembershipEntry."Valid From Date")
                        {
                            MaxOccurs = Once;
                        }
                        fieldelement(validuntildate;TmpMembershipEntry."Valid Until Date")
                        {
                            MaxOccurs = Once;
                        }
                        fieldelement(documentid;TmpMembershipEntry."Import Entry Document ID")
                        {
                        }
                    }

                    trigger OnAfterGetRecord()
                    var
                        MembershipManagement: Codeunit "MM Membership Management";
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

        tmpMembershipResponse.DeleteAll ();
    end;

    procedure AddResponse(MembershipEntryNo: Integer)
    var
        Membership: Record "MM Membership";
        MembershipLedgerEntry: Record "MM Membership Entry";
    begin

        errordescription := '';
        status := '1';

        if (MembershipEntryNo <= 0) then
          exit;

        Membership.Get (MembershipEntryNo);

        tmpMembershipResponse.TransferFields (Membership, true);
        if (tmpMembershipResponse.Insert ()) then ;

        MembershipLedgerEntry.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        if (MembershipLedgerEntry.FindSet ()) then begin
          repeat
            TmpMembershipEntry.TransferFields (MembershipLedgerEntry, true);
            TmpMembershipEntry.Insert ();
          until (MembershipLedgerEntry.Next () = 0);
        end;
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';
        if (tmpMembershipResponse.Insert ()) then ;
    end;
}

