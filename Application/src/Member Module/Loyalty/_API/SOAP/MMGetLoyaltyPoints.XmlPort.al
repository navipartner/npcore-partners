xmlport 6060141 "NPR MM Get Loyalty Points"
{

    Caption = 'Get Loyalty Points';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(loyalty)
        {
            MaxOccurs = Once;
            textelement(getloyaltypoints)
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
                            textattribute(communityname)
                            {
                                XmlName = 'name';
                            }
                        }
                        fieldelement(membershipcode; tmpMembershipResponse."Membership Code")
                        {
                            textattribute(membershipname)
                            {
                                XmlName = 'name';
                            }
                        }
                        textelement(loyaltycode)
                        {
                            MaxOccurs = Once;
                            XmlName = 'loyaltyprogram';
                            textattribute(loyaltyname)
                            {
                                XmlName = 'name';
                            }
                        }
                        textelement(loyaltycollectionperiodcode)
                        {
                            XmlName = 'loyaltycollectionperiod';
                            textattribute(loyaltycollectionperiodname)
                            {
                                XmlName = 'name';
                            }
                        }
                        textelement(loyaltypointsourcecode)
                        {
                            XmlName = 'loyaltypointsource';
                            textattribute(loyaltypointsourcename)
                            {
                                XmlName = 'name';
                            }
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
                        textelement(pointsummary)
                        {
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
                        textelement(previousperiod)
                        {
                            textattribute(spendperiodstart)
                            {
                                XmlName = 'spendperiodstart';
                            }
                            textattribute(spendperiodend)
                            {
                                XmlName = 'spendperiodend';
                            }
                            textelement(pointsearned)
                            {
                                XmlName = 'pointsearned';
                                textattribute(pointsearnedvalue)
                                {
                                    XmlName = 'value';
                                }
                                textattribute(pointsearnedcurrencycode)
                                {
                                    XmlName = 'currencycode';
                                }
                            }
                            textelement(pointsremaining)
                            {
                                XmlName = 'pointsremaining';
                                textattribute(pointsremainingvalue)
                                {
                                    XmlName = 'value';
                                }
                                textattribute(pointsremainingcurrencycode)
                                {
                                    XmlName = 'currencycode';
                                }
                            }
                        }
                        textelement(pointsbyperiods)
                        {
                            tableelement(TmpMembershipPointsSummary; "NPR MM Members. Points Summary")
                            {
                                XmlName = 'period';
                                UseTemporary = true;
                                fieldattribute(relativeperiod; TmpMembershipPointsSummary."Relative Period")
                                {
                                }
                                fieldelement(earnperiodstart; TmpMembershipPointsSummary."Earn Period Start") { }
                                fieldelement(earnperiodend; TmpMembershipPointsSummary."Earn Period End") { }
                                fieldelement(burnperiodstart; TmpMembershipPointsSummary."Burn Period Start") { }
                                fieldelement(burnperiodend; TmpMembershipPointsSummary."Burn Period End") { }
                                fieldelement(pointsearned; TmpMembershipPointsSummary."Points Earned") { }
                                fieldelement(pointsredeemed; TmpMembershipPointsSummary."Points Redeemed") { }
                                fieldelement(pointsremaining; TmpMembershipPointsSummary."Points Remaining") { }
                                fieldelement(pointsexpired; TmpMembershipPointsSummary."Points Expired") { }
                                fieldelement(amountlcyearned; TmpMembershipPointsSummary."Amount Earned (LCY)") { }
                                fieldelement(amountlcyredeemed; TmpMembershipPointsSummary."Amount Redeemed (LCY)") { }
                                fieldelement(amountlcyremaining; TmpMembershipPointsSummary."Amount Remaining (LCY)") { }
                            }
                        }
                        textelement(loyaltytiers)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            textelement(upgrade)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                textattribute(upgradetolevel)
                                {
                                    XmlName = 'tolevel';
                                }
                                textattribute(upgradethreshold)
                                {
                                    XmlName = 'threshold';
                                }
                                textattribute(upgradetoname)
                                {
                                    XmlName = 'toname';
                                }
                            }
                            textelement(downgrade)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                textattribute(downgradetolevel)
                                {
                                    XmlName = 'tolevel';
                                }
                                textattribute(downgradethreshold)
                                {
                                    XmlName = 'threshold';
                                }
                                textattribute(downgradetoname)
                                {
                                    XmlName = 'toname';
                                }
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

    internal procedure ClearResponse()
    begin

        tmpMembershipResponse.DeleteAll();
    end;

    internal procedure AddResponse(MembershipEntryNo: Integer)
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipSetupTiers: Record "NPR MM Membership Setup";
        LoyaltyAlterMembership: Record "NPR MM Loyalty Alter Members.";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        MemberCommunity: Record "NPR MM Member Community";
        TempLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary;
        GeneralLedgerSetup: Record "General Ledger Setup";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        ReasonText: Text;
        Earned: Decimal;
        Redeemable: Decimal;
        PeriodStart: Date;
        PeriodEnd: Date;
    begin

        responsemessage := '';
        responsecode := 'OK';

        if (MembershipEntryNo <= 0) then
            exit;

        Membership.Get(MembershipEntryNo);
        Membership.CalcFields("Awarded Points (Sale)", "Awarded Points (Refund)", "Redeemed Points (Withdrawl)", "Redeemed Points (Deposit)", "Expired Points", "Remaining Points");

        tmpMembershipResponse.TransferFields(Membership, true);
        if (tmpMembershipResponse.Insert()) then;

        MemberCommunity.Get(Membership."Community Code");
        MembershipSetup.Get(Membership."Membership Code");
        CommunityName := MemberCommunity.Description;
        MembershipName := MembershipSetup.Description;
        UpgradeToName := '';
        DowngradeToName := '';

        if (MemberCommunity."Activate Loyalty Program") then begin
            if (LoyaltySetup.Get(MembershipSetup."Loyalty Code")) then begin
                LoyaltyCode := LoyaltySetup.Code;
                LoyaltyName := LoyaltySetup.Description;

                LoyaltyCollectionPeriodCode := Format(LoyaltySetup."Collection Period", 0, 9);
                LoyaltyCollectionPeriodName := Format(LoyaltySetup."Collection Period");
                LoyaltyPointSourceCode := Format(LoyaltySetup."Voucher Point Source", 0, 9);
                LoyaltyPointSourceName := Format(LoyaltySetup."Voucher Point Source");

                LoyaltyPointManagement.CalculateFixedPeriodPointsTransaction(LoyaltySetup, Membership, 0, TmpMembershipPointsSummary); // Current period
                LoyaltyPointManagement.CalculateFixedPeriodPointsTransaction(LoyaltySetup, Membership, -1, TmpMembershipPointsSummary); // Previous period

            end;
        end;

        if (LoyaltyPointManagement.GetNextLoyaltyTier(MembershipEntryNo, true, LoyaltyAlterMembership)) then begin
            UpgradeToLevel := LoyaltyAlterMembership."To Membership Code";
            UpgradeThreshold := Format(LoyaltyAlterMembership."Points Threshold", 0, 9);
            if (UpgradeToLevel <> '') then
                if (MembershipSetupTiers.Get(UpgradeToLevel)) then
                    UpgradeToName := MembershipSetupTiers.Description;
        end;

        if (LoyaltyPointManagement.GetNextLoyaltyTier(MembershipEntryNo, false, LoyaltyAlterMembership)) then begin
            DowngradeToLevel := LoyaltyAlterMembership."To Membership Code";
            DowngradeThreshold := Format(LoyaltyAlterMembership."Points Threshold", 0, 9);
            if (DowngradeToLevel <> '') then
                if (MembershipSetupTiers.Get(DowngradeToLevel)) then
                    DowngradeToName := MembershipSetupTiers.Description
        end;

        Earned := LoyaltyPointManagement.CalculateEarnedPointsCurrentPeriod(MembershipEntryNo);
        Redeemable := LoyaltyPointManagement.CalculateRedeemablePointsCurrentPeriod(MembershipEntryNo);

        pointsearned := Format(Earned, 0, 9);
        pointsremaining := Format(Redeemable, 0, 9);
        pointsearnedvalue := '0';
        pointsremainingvalue := '0';

        if (LoyaltyPointManagement.GetCouponToRedeemWS(MembershipEntryNo, TempLoyaltyPointsSetup, 1000000000, ReasonText)) then begin
            TempLoyaltyPointsSetup.Reset();
            TempLoyaltyPointsSetup.SetCurrentKey(Code, "Amount LCY");
            TempLoyaltyPointsSetup.FindLast();
            pointsearnedvalue := Format(Round(Earned * TempLoyaltyPointsSetup."Point Rate", 1), 0, 9);
            pointsremainingvalue := Format(Round(Redeemable * TempLoyaltyPointsSetup."Point Rate", 1), 0, 9);

            GeneralLedgerSetup.Get();
            pointsearnedcurrencycode := GeneralLedgerSetup."LCY Code";
            pointsremainingcurrencycode := GeneralLedgerSetup."LCY Code";
        end;

        LoyaltyPointManagement.CalculateSpendPeriod(MembershipEntryNo, Today, PeriodStart, PeriodEnd);
        spendperiodstart := Format(PeriodStart, 0, 9);
        spendperiodend := Format(PeriodEnd, 0, 9);

    end;

    internal procedure AddErrorResponse(ErrorMessage: Text)
    begin

        responsemessage := ErrorMessage;
        responsecode := 'ERROR';
        if (tmpMembershipResponse.Insert()) then;
    end;
}

