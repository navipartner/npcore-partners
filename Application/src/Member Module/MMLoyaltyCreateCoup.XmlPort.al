xmlport 6060148 "NPR MM Loyalty Create Coup."
{

    Caption = 'Loyalty Create Coupon';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(loyalty)
        {
            MaxOccurs = Once;
            textelement(createcoupon)
            {
                MaxOccurs = Once;
                tableelement(tmpmemberinfocapture; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membershipnumber; tmpMemberInfoCapture."External Membership No.")
                    {
                    }
                    fieldelement(documentno; tmpMemberInfoCapture."Document No.")
                    {
                    }
                    fieldelement(documentdate; tmpMemberInfoCapture."Document Date")
                    {
                    }
                    fieldelement(ordervalue; tmpMemberInfoCapture."Amount Incl VAT")
                    {
                    }
                    textelement(coupons)
                    {
                        tableelement(tmployaltypointssetuprequest; "NPR MM Loyalty Point Setup")
                        {
                            XmlName = 'coupon';
                            UseTemporary = true;
                            fieldattribute(code; TmpLoyaltyPointsSetupRequest.Code)
                            {
                            }
                            fieldattribute(line; TmpLoyaltyPointsSetupRequest."Line No.")
                            {
                            }
                        }
                    }

                    trigger OnBeforeInsertRecord()
                    begin

                        tmpMemberInfoCapture."Document Date" := Today();
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
                    textelement(createdcoupons)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        tableelement(tmpcouponresponse; "NPR NpDc Coupon")
                        {
                            MinOccurs = Zero;
                            XmlName = 'coupon';
                            UseTemporary = true;
                            fieldattribute(reference; TmpCouponResponse."Reference No.")
                            {
                            }
                            fieldelement(description; TmpCouponResponse.Description)
                            {
                            }
                            fieldelement(discounttype; TmpCouponResponse."Discount Type")
                            {
                            }
                            fieldelement(discountamount; TmpCouponResponse."Discount Amount")
                            {
                            }
                            fieldelement(discountpercent; TmpCouponResponse."Discount %")
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

    procedure GetRequest(var TmpMemberInfoCaptureOut: Record "NPR MM Member Info Capture" temporary; var TmpLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary)
    begin

        tmpMemberInfoCapture.FindFirst();
        TmpMemberInfoCaptureOut.TransferFields(tmpMemberInfoCapture, true);
        TmpMemberInfoCaptureOut.Insert();

        TmpLoyaltyPointsSetupRequest.Reset();
        if (TmpLoyaltyPointsSetupRequest.FindFirst()) then begin
            repeat
                TmpLoyaltyPointsSetup.TransferFields(TmpLoyaltyPointsSetupRequest, true);
                TmpLoyaltyPointsSetup.Insert();
            until (TmpLoyaltyPointsSetupRequest.Next() = 0);
        end;
    end;

    procedure ClearResponse()
    begin

        tmpMembershipResponse.DeleteAll();
    end;

    procedure AddResponse(MembershipEntryNo: Integer; var TmpCoupon: Record "NPR NpDc Coupon" temporary; ResponseMessageIn: Text)
    var
        Membership: Record "NPR MM Membership";
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

        TmpCoupon.Reset();
        if (TmpCoupon.FindSet()) then begin
            repeat
                TmpCouponResponse.TransferFields(TmpCoupon, true);
                TmpCouponResponse.Insert();
            until (TmpCoupon.Next() = 0)
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

