xmlport 6060145 "NPR MM Get Loy. Statement"
{
    // MM1.37/TSA /20190226 CASE 338215 Initial Version

    Caption = 'Get Loyalty Statement';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(loyalty)
        {
            MaxOccurs = Once;
            textelement(getloyaltystatement)
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
                        MinOccurs = Zero;
                    }
                    fieldelement(membershipnumber; tmpMemberInfoCapture."External Membership No.")
                    {
                    }
                    fieldelement(customernumber; tmpMemberInfoCapture."Document No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(transactionsfromdate; tmpMemberInfoCapture."Document Date")
                    {
                        MaxOccurs = Once;

                        trigger OnAfterAssignField()
                        begin

                            if (tmpMemberInfoCapture."Document Date" = 0D) then
                                tmpMemberInfoCapture."Document Date" := CalcDate('<-1M+CM+1D>', Today);
                        end;
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
                        textelement(accumulated)
                        {
                            textattribute(untildate)
                            {

                                trigger OnBeforePassVariable()
                                begin

                                    untildate := Format(CalcDate('<-1D>', tmpMemberInfoCapture."Document Date"), 0, 9);
                                end;
                            }
                            textelement(awarded)
                            {
                                fieldelement(sales; tmpMembershipResponse."Awarded Points (Sale)")
                                {
                                }
                                fieldelement(refund; tmpMembershipResponse."Awarded Points (Refund)")
                                {
                                }
                            }
                            textelement(redeemed)
                            {
                                fieldelement(withdrawl; tmpMembershipResponse."Redeemed Points (Withdrawl)")
                                {
                                }
                                fieldelement(deposit; tmpMembershipResponse."Redeemed Points (Deposit)")
                                {
                                }
                            }
                            fieldelement(expired; tmpMembershipResponse."Expired Points")
                            {
                            }
                            fieldelement(remaining; tmpMembershipResponse."Remaining Points")
                            {
                            }
                        }
                    }
                    textelement(transactions)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        tableelement(membershippointsentry; "NPR MM Members. Points Entry")
                        {
                            LinkFields = "Membership Entry No." = FIELD("Entry No.");
                            LinkTable = tmpMembershipResponse;
                            MinOccurs = Zero;
                            XmlName = 'transaction';
                            fieldelement(date; MembershipPointsEntry."Posting Date")
                            {
                            }
                            textelement(type)
                            {

                                trigger OnBeforePassVariable()
                                begin

                                    with MembershipPointsEntry do
                                        case "Entry Type" of
                                            "Entry Type"::CAPTURE:
                                                type := 'capture';
                                            "Entry Type"::EXPIRED:
                                                type := 'expired';
                                            "Entry Type"::POINT_DEPOSIT:
                                                type := 'deposit';
                                            "Entry Type"::POINT_WITHDRAW:
                                                type := 'withdrawl';
                                            "Entry Type"::REFUND:
                                                type := 'refund';
                                            "Entry Type"::RESERVE:
                                                type := 'reserve';
                                            "Entry Type"::SYNCHRONIZATION:
                                                type := 'synchronization';
                                            "Entry Type"::SALE:
                                                type := 'sale';
                                        end;
                                end;
                            }
                            fieldelement(reference; MembershipPointsEntry."Document No.")
                            {
                            }
                            fieldelement(storecode; MembershipPointsEntry."POS Store Code")
                            {
                            }
                            fieldelement(points; MembershipPointsEntry.Points)
                            {
                            }
                            fieldelement(itemno; MembershipPointsEntry."Item No.")
                            {
                            }
                            fieldelement(description; MembershipPointsEntry.Description)
                            {
                            }
                        }
                    }

                    trigger OnAfterGetRecord()
                    var
                        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
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

        tmpMembershipResponse.DeleteAll();
    end;

    procedure AddResponse(MembershipEntryNo: Integer)
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
    begin

        responsemessage := '';
        responsecode := 'OK';

        if (MembershipEntryNo <= 0) then
            exit;

        tmpMemberInfoCapture.FindFirst();
        Membership.Get(MembershipEntryNo);
        tmpMembershipResponse.SetFilter("Date Filter", '>%1', tmpMemberInfoCapture."Document Date");
        MembershipPointsEntry.SetFilter("Posting Date", '>=%1', tmpMemberInfoCapture."Document Date");

        tmpMembershipResponse.SetFilter("Date Filter", '..%1', tmpMemberInfoCapture."Document Date");
        tmpMembershipResponse.CalcFields("Awarded Points (Sale)", "Awarded Points (Refund)", "Redeemed Points (Withdrawl)", "Redeemed Points (Deposit)", "Expired Points", "Remaining Points");
        tmpMembershipResponse.TransferFields(Membership, true);
        if (tmpMembershipResponse.Insert()) then;
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        responsemessage := ErrorMessage;
        responsecode := 'ERROR';
        if (tmpMembershipResponse.Insert()) then;
    end;
}

