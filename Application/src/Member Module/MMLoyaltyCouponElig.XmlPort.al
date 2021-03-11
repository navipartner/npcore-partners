xmlport 6060147 "NPR MM Loyalty Coupon Elig."
{

    Caption = 'Loyalty Coupon Eligibility';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(loyalty)
        {
            MaxOccurs = Once;
            textelement(getcouponeligibility)
            {
                MaxOccurs = Once;
                tableelement(tmpmemberinfocapture; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membershipnumber; tmpMemberInfoCapture."External Membership No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(cardnumber; tmpMemberInfoCapture."External Card No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(customernumber; tmpMemberInfoCapture."Document No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ordervalue; tmpMemberInfoCapture."Amount Incl VAT")
                    {
                    }

                    trigger OnBeforeInsertRecord()
                    begin

                        tmpMemberInfoCapture."Document Date" := Today;
                    end;
                }
                tableelement(tmpmembershipresponse; "NPR MM Membership")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'response';
                    UseTemporary = true;
                    textelement(status)
                    {
                        MaxOccurs = Once;
                        textelement(responsecode)
                        {
                            MaxOccurs = Once;
                        }
                        textelement(responsemessage)
                        {
                            MaxOccurs = Once;
                        }
                    }
                    textelement(membership)
                    {
                        MaxOccurs = Once;
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
                            MaxOccurs = Once;
                            textattribute(untildate)
                            {

                                trigger OnBeforePassVariable()
                                begin

                                    untildate := Format(CalcDate('<-1D>', tmpMemberInfoCapture."Document Date"), 0, 9);
                                end;
                            }
                            textelement(awarded)
                            {
                                MaxOccurs = Once;
                                fieldelement(sales; tmpMembershipResponse."Awarded Points (Sale)")
                                {
                                }
                                fieldelement(refund; tmpMembershipResponse."Awarded Points (Refund)")
                                {
                                }
                            }
                            textelement(redeemed)
                            {
                                MaxOccurs = Once;
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
                    textelement(coupons)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        tableelement(tmployaltypointssetupresponse; "NPR MM Loyalty Point Setup")
                        {
                            MinOccurs = Zero;
                            XmlName = 'coupon';
                            UseTemporary = true;
                            fieldattribute(code; TmpLoyaltyPointsSetupResponse.Code)
                            {
                            }
                            fieldattribute(line; TmpLoyaltyPointsSetupResponse."Line No.")
                            {
                            }
                            fieldelement(description; TmpLoyaltyPointsSetupResponse.Description)
                            {
                            }
                            fieldelement(points; TmpLoyaltyPointsSetupResponse."Points Threshold")
                            {
                            }
                            fieldelement(amount; TmpLoyaltyPointsSetupResponse."Amount LCY")
                            {
                            }
                            fieldelement(discountpercent; TmpLoyaltyPointsSetupResponse."Discount %")
                            {
                            }
                            fieldelement(discountamount; TmpLoyaltyPointsSetupResponse."Discount Amount")
                            {
                            }
                        }
                    }

                    trigger OnAfterGetRecord()
                    var
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

        layout
        {
        }

        actions
        {
        }
    }

    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";

    procedure GetRequest(var TmpMemberInfoCaptureOut: Record "NPR MM Member Info Capture" temporary)
    begin

        tmpMemberInfoCapture.FindFirst();
        TmpMemberInfoCaptureOut.TransferFields(tmpMemberInfoCapture, true);
        TmpMemberInfoCaptureOut.Insert();
    end;

    procedure ClearResponse()
    begin

        tmpMembershipResponse.DeleteAll();
    end;

    procedure AddResponse(MembershipEntryNo: Integer; var TmpLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary; ResponseMessageIn: Text)
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
    begin

        if (MembershipEntryNo <= 0) then begin
            AddErrorResponse('Invalid membership entry no.');
            exit;
        end;

        if (not Membership.Get(MembershipEntryNo)) then begin
            AddErrorResponse('Invalid membership entry no.');
            exit;
        end;

        responsemessage := '';
        responsecode := 'OK';
        tmpMemberInfoCapture.FindFirst();

        tmpMembershipResponse.TransferFields(Membership, true);
        tmpMembershipResponse.SetFilter("Date Filter", '..%1', tmpMemberInfoCapture."Document Date");
        tmpMembershipResponse.CalcFields("Awarded Points (Sale)", "Awarded Points (Refund)", "Redeemed Points (Withdrawl)", "Redeemed Points (Deposit)", "Expired Points", "Remaining Points");
        if (tmpMembershipResponse.Insert()) then;

        TmpLoyaltyPointsSetup.Reset();
        if (TmpLoyaltyPointsSetup.FindSet()) then begin
            repeat
                TmpLoyaltyPointsSetupResponse.TransferFields(TmpLoyaltyPointsSetup, true);
                TmpLoyaltyPointsSetupResponse.Insert();
            until (TmpLoyaltyPointsSetup.Next() = 0)
        end else begin
            responsecode := 'WARNING';
            responsemessage := ResponseMessageIn;
        end;
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        responsemessage := ErrorMessage;
        responsecode := 'ERROR';
        if (tmpMembershipResponse.Insert()) then;
    end;
}

