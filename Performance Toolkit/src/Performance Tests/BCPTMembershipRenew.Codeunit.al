codeunit 88014 "NPR BCPT Membership Renew" implements "BCPT Test Param. Provider"
{
    SingleInstance = true;
    trigger OnRun()
    begin
        if not IsInitialized then begin
            InitTest();
            IsInitialized := true;
        end;
        PerformMembershipRenewRequests();
        PerformSubsPaymentProcess();
        PerformSubsRenewProcess();
    end;

    var
        NoOfMembershipsParamLbl: Label 'NoOfMemberships', Locked = true;
        ParamValidationErr: Label 'Parameter is not defined in the correct format. The expected format is "%1"', Comment = '%1 - expected format';
        NoOfMemberships: Integer;
        BCPTTestContext: Codeunit "BCPT Test Context";
        IsInitialized: Boolean;

    procedure GetDefaultParameters(): Text[1000]
    begin
        exit(CopyStr(GetDefaultNoOfMembershipsParameter(), 1, 1000));
    end;

    procedure ValidateParameters(Params: Text[1000])
    begin
        ValidateNoOfMembershipsParameter(Params);
    end;

    local procedure GetDefaultNoOfMembershipsParameter(): Text[1000]
    begin
        exit(CopyStr(NoOfMembershipsParamLbl + '=' + Format(14000), 1, 1000));
    end;

    local procedure ValidateNoOfMembershipsParameter(Parameter: Text[1000])
    begin
        if StrPos(Parameter, NoOfMembershipsParamLbl) > 0 then begin
            Parameter := DelStr(Parameter, 1, StrLen(NoOfMembershipsParamLbl + '='));
            if Evaluate(NoOfMemberships, Parameter) then
                exit;
        end;
        Error(ParamValidationErr, GetDefaultNoOfMembershipsParameter());
    end;

    local procedure InitTest()
    var
        LibraryMembership: Codeunit "NPR BPCT Library - Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        Item: Record Item;
        RecurPaymSetup: Record "NPR MM Recur. Paym. Setup";
        MembersAlterSetup: Record "NPR MM Members. Alter. Setup";
    begin
        LibraryMembership.CreateNoSeries();
        LibraryMembership.SetupCommunity_Simple();
        LibraryMembership.CreateRecurringPaymentSetup(RecurPaymSetup);

        GetGoldMembershipSetup(MembershipSetup, RecurPaymSetup);

        Item.Get('320100');

        GetMembershipSalesSetup(MembershipSalesSetup, Item);

        LibraryMembership.CreateSubsPaymentGateway();

        LibraryMembership.CreateAlterationAutoRenewSetup(MembershipSetup.Code,
                                                        Item."No.",
                                                        'test',
                                                        '',
                                                        '',
                                                        '+1Y-1D',
                                                        MembersAlterSetup."Price Calculation"::UNIT_PRICE,
                                                        Item."No.");
        LibraryMembership.CreateNPPaySetup();
        CreateMemberships(MembershipSalesSetup);
        Commit();
    end;

    local procedure PerformMembershipRenewRequests()
    var
        Membership: Record "NPR MM Membership";
        SubscrRenewRequest: Codeunit "NPR MM Subscr. Renew Req. JQ";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        BCPTTestContext.StartScenario('Renew Request');
        SimulateRenewRequest();
        BCPTTestContext.EndScenario('Renew Request');
    end;

    local procedure SimulateRenewRequest()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        RecurPaymentSetup: Record "NPR MM Recur. Paym. Setup";
        Subscription: Record "NPR MM Subscription";
        RequestSubscrRenewal: Codeunit "NPR MM Subscr. Renew: Request";
    begin
        MembershipSetup.SetRange("Auto-Renew Model", MembershipSetup."Auto-Renew Model"::RECURRING_PAYMENT);
        MembershipSetup.SetFilter("Recurring Payment Code", '<>%1', '');

        if MembershipSetup.FindSet() then
            repeat
                RecurPaymentSetup.Get(MembershipSetup."Recurring Payment Code");

                RequestSubscrRenewal.SetRecurringPaymentSetup(RecurPaymentSetup);
                RequestSubscrRenewal.SetSkipProcessSubscriptionCheck(true);

                Subscription.SetRange("Membership Code", MembershipSetup.Code);
                Subscription.SetRange(Blocked, false);
                Subscription.SetRange("Valid Until Date", 0D, Today() + RecurPaymentSetup."First Attempt Offset (Days)");
                Subscription.SetRange("Postpone Renewal Attempt Until", 0D, Today());
                Subscription.SetRange("Subscr. Request Type Filter", Subscription."Subscr. Request Type Filter"::Renew);
                Subscription.SetRange("Outst. Subscr. Requests Exist", false);
                Subscription.SetRange("Auto-Renew", Subscription."Auto-Renew"::YES_INTERNAL);
                Subscription.SetAutoCalcFields("Outst. Subscr. Requests Exist");

                if Subscription.FindSet() then
                    repeat
                        Codeunit.Run(Codeunit::"NPR MM Subscr. Renew: Request", Subscription);
                    until Subscription.Next() = 0;
            until MembershipSetup.Next() = 0;
    end;

    local procedure PerformSubsPaymentProcess()
    var
        SubscrAdyenMock: Codeunit "NPR BCPT Subscr. Adyen Mock";
    begin
        BindSubscription(SubscrAdyenMock);
        BCPTTestContext.StartScenario('Payment Request Process');
        Codeunit.Run(Codeunit::"NPR MM Subscr. Pay Req Proc JQ");
        UnbindSubscription(SubscrAdyenMock);
        BCPTTestContext.EndScenario('Payment Request Process');
    end;

    local procedure PerformSubsRenewProcess()
    begin
        BCPTTestContext.StartScenario('Subscription Request Process');
        Codeunit.Run((Codeunit::"NPR MM Subscr. Renew Proc. JQ"));
        BCPTTestContext.EndScenario('Subscription Request Process');
    end;

    local procedure CreateMemberships(MembershipSalesSetup: Record "NPR MM Members. Sales Setup")
    var
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        i: Integer;
        InfoCapture: Record "NPR MM Member Info Capture";
        MembershipEntryNo: Integer;
        LibraryMembership: Codeunit "NPR BPCT Library - Membership";
    begin
        Evaluate(NoOfMemberships, BCPTTestContext.GetParameter(NoOfMembershipsParamLbl));

        for i := 1 to NoOfMemberships do begin
            LibraryMembership.SetRandomMemberInfoData(InfoCapture);
            MembershipEntryNo := MembershipMgtInternal.CreateMembership(MembershipSalesSetup, InfoCapture, true);
            LibraryMembership.CreateMemberPaymentMethod(MembershipEntryNo);
        end;
    end;

    local procedure GetGoldMembershipSetup(var MembershipSetup: Record "NPR MM Membership Setup"; RecurPaymSetup: Record "NPR MM Recur. Paym. Setup")
    begin
        if not MembershipSetup.Get('GOLD') then begin
            MembershipSetup.Init();
            MembershipSetup.Code := 'GOLD';
            MembershipSetup.Insert();
        end;

        MembershipSetup."Recurring Payment Code" := RecurPaymSetup.Code;
        MembershipSetup."Auto-Renew Model" := MembershipSetup."Auto-Renew Model"::RECURRING_PAYMENT;
        Evaluate(MembershipSetup."Card Number Valid Until", '0D');
        MembershipSetup.Modify();
    end;

    local procedure GetMembershipSalesSetup(var MembershipSalesSetup: Record "NPR MM Members. Sales Setup"; var Item: Record Item)
    begin
        if not MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, Item."No.") then begin
            MembershipSalesSetup.Init();
            MembershipSalesSetup.Type := MembershipSalesSetup.Type::ITEM;
            MembershipSalesSetup."No." := Item."No.";
            MembershipSalesSetup.Insert();
        end;
        MembershipSalesSetup."Valid Until Calculation" := MembershipSalesSetup."Valid Until Calculation"::DATEFORMULA;
        Evaluate(MembershipSalesSetup."Duration Formula", '0D');
        MembershipSalesSetup.Modify();
    end;
}