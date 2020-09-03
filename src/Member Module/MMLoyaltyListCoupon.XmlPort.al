xmlport 6151164 "NPR MM Loyalty List Coupon"
{
    // MM1.42/TSA /20200114 CASE 370398 Initial Version

    Caption = 'Loyalty Create Coupon';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(loyalty)
        {
            MaxOccurs = Once;
            textelement(listcoupon)
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
                    }
                    textelement(availablecoupons)
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
                                textattribute(currencycode)
                                {

                                    trigger OnBeforePassVariable()
                                    begin
                                        if (TmpCouponResponse."Discount Amount" <> 0) then
                                            currencycode := GeneralLedgerSetup."LCY Code";
                                    end;
                                }
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

    trigger OnPreXmlPort()
    begin

        if (not GeneralLedgerSetup.Get()) then
            GeneralLedgerSetup.Init();
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
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

    procedure AddResponse(MembershipEntryNo: Integer; var TmpCoupon: Record "NPR NpDc Coupon" temporary; ResponseMessageIn: Text)
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

