xmlport 6060137 "MM Confirm Membership Payment"
{
    // 
    // MM1.24/TSA /20171026 CASE 290599 Initial Version
    // MM1.26/TSA /20180219 CASE 305631 removed element membershipnumber, replaced it with document id

    Caption = 'Confirm Membership Payment';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(memberships)
        {
            textelement(confirmmembership)
            {
                MaxOccurs = Once;
                tableelement(tmpmemberinfocapture;"MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(documentid;tmpMemberInfoCapture."Import Entry Document ID")
                    {
                    }
                    fieldelement(externaldocumentnumber;tmpMemberInfoCapture."Document No.")
                    {
                    }
                    fieldelement(amount;tmpMemberInfoCapture.Amount)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(amountinclvat;tmpMemberInfoCapture."Amount Incl VAT")
                    {
                    }
                }
                tableelement(tmpmembershipresponse;"MM Membership")
                {
                    MaxOccurs = Once;
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
                    textelement(membership)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        fieldelement(communitycode;tmpMembershipResponse."Community Code")
                        {
                        }
                        fieldelement(membershipcode;tmpMembershipResponse."Membership Code")
                        {
                        }
                        fieldelement(membershipnumber;tmpMembershipResponse."External Membership No.")
                        {
                        }
                        fieldelement(issuedate;tmpMembershipResponse."Issued Date")
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
                        MembershipManagement: Codeunit "MM Membership Management";
                        DateValidFromDate: Date;
                        DateValidUntilDate: Date;
                    begin
                        MembershipManagement.GetMembershipValidDate (tmpMembershipResponse."Entry No.", Today, DateValidFromDate, DateValidUntilDate);
                        ValidFromDate := Format (DateValidFromDate,0,9);
                        ValidUntilDate := Format (DateValidUntilDate,0,9);
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

    procedure ClearResponse()
    begin

        tmpMembershipResponse.DeleteAll ();
    end;

    procedure AddResponse(MembershipEntryNo: Integer)
    var
        Membership: Record "MM Membership";
    begin

        errordescription := '';
        status := '1';

        Membership.Get (MembershipEntryNo);

        tmpMembershipResponse.TransferFields (Membership);
        tmpMembershipResponse.Insert ();
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';

        tmpMembershipResponse.Insert ();
    end;
}

