xmlport 6060141 "MM Get Loyalty Points"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.06/TSA/20160127  CASE 232910 - Enchanced error handling when there is a runtime error processing the request
    // MM1.08/TSA/20160219  CASE 234298 - Added valid to from contents
    // MM1.14/TSA/20160524  CASE 239052 - Added customernumber as a search parameter
    // MM1.18/TSA/20170207  CASE 265562 - Changed to XML format
    // MM1.18/TSA/20170216  CASE 265729 - Added membercardinality and membercount
    // MM1.37/TSA /20190226 CASE 338215 - Touch-up on the response status section (breaking change)

    Caption = 'Get Loyalty Points';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(loyalty)
        {
            MaxOccurs = Once;
            textelement(getloyaltypoints)
            {
                MaxOccurs = Once;
                tableelement(tmpmemberinfocapture;"MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(cardnumber;tmpMemberInfoCapture."External Card No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(membershipnumber;tmpMemberInfoCapture."External Membership No.")
                    {
                    }
                    fieldelement(customernumber;tmpMemberInfoCapture."Document No.")
                    {
                        MinOccurs = Zero;
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
                        textelement(responsecode)
                        {
                        }
                        textelement(responsemessage)
                        {
                            MaxOccurs = Once;
                        }
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
                        textelement(pointsummary)
                        {
                            textelement(awarded)
                            {
                                fieldelement(sales;tmpMembershipResponse."Awarded Points (Sale)")
                                {
                                }
                                fieldelement(refund;tmpMembershipResponse."Awarded Points (Refund)")
                                {
                                }
                            }
                            textelement(redeemed)
                            {
                                fieldelement(withdrawl;tmpMembershipResponse."Redeemed Points (Withdrawl)")
                                {
                                }
                                fieldelement(deposit;tmpMembershipResponse."Redeemed Points (Deposit)")
                                {
                                }
                            }
                            fieldelement(expired;tmpMembershipResponse."Expired Points")
                            {
                            }
                            fieldelement(remaining;tmpMembershipResponse."Remaining Points")
                            {
                            }
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

        tmpMembershipResponse.DeleteAll ();
    end;

    procedure AddResponse(MembershipEntryNo: Integer)
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        Member: Record "MM Member";
        MembershipRole: Record "MM Membership Role";
    begin

        responsemessage := '';
        responsecode := 'OK';

        if (MembershipEntryNo <= 0) then
          exit;

        Membership.Get (MembershipEntryNo);
        Membership.CalcFields ("Awarded Points (Sale)", "Awarded Points (Refund)", "Redeemed Points (Withdrawl)", "Redeemed Points (Deposit)", "Expired Points", "Remaining Points");

        tmpMembershipResponse.TransferFields (Membership, true);
        if (tmpMembershipResponse.Insert ()) then ;
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        responsemessage := ErrorMessage;
        responsecode := 'ERROR';
        if (tmpMembershipResponse.Insert ()) then ;
    end;
}

