﻿codeunit 6060146 "NPR MM POS Action: Member Loy."
{
    Access = Internal;

    var
        ActionDescription: Label 'This action is capable of redeeming member points and applying them as a coupon.';
        LoyaltyWindowTitle: Label '%1 - Membership Loyalty.';
        DialogMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        MemberCardPrompt: Label 'Member Card No.';
        NO_MEMBER: Label 'No member/customer specified.';
        MULTIPLE_MEMBERSHIPS: Label 'Customer number %1 resolves to more than one membership. Before redeeming points for this customer, this issue needs to be corrected. One possible solution is to block the incorrect memberships for this customer.';

    local procedure ActionCode(): Code[20]
    begin
        exit('MM_MEMBER_LOYALTY');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.3');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        FunctionOptionString: Text;
        N: Integer;
        JSArr: Text;
        JSArrLbl: Label '"%1",', Locked = true;
        JSArr2Lbl: Label 'var optionNames = [%1];if (param.Function < 0) param.Function = 0;if (param.DefaultInputValue.length > 0) {context.show_dialog = false;}; ', Locked = true;
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            FunctionOptionString := 'Select Membership,View Points,Redeem Points,Available Coupons,Select Membership (EAN Box)';
            for N := 1 to 5 do
                JSArr += StrSubstNo(JSArrLbl, SelectStr(N, FunctionOptionString));
            JSArr := StrSubstNo(JSArr2Lbl, CopyStr(JSArr, 1, StrLen(JSArr) - 1));

            Sender.RegisterWorkflowStep('0', JSArr + 'windowTitle = labels.LoyaltyWindowTitle.substitute (optionNames[param.Function].toString()); ');
            Sender.RegisterWorkflowStep('membercard_number', 'context.show_dialog && input ({caption: labels.MemberCardPrompt, title: windowTitle}).cancel(abort);');
            Sender.RegisterWorkflowStep('do_work', 'respond ();');
            Sender.RegisterWorkflow(true);

            Sender.RegisterOptionParameter('Function', FunctionOptionString, 'Select Membership');

            Sender.RegisterTextParameter('DefaultInputValue', '');
            Sender.RegisterTextParameter('ForeignCommunityCode', '');

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'LoyaltyWindowTitle', LoyaltyWindowTitle);
        Captions.AddActionCaption(ActionCode(), 'MemberCardPrompt', MemberCardPrompt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();

        Context.SetContext('show_dialog', (SalePOS."Customer No." = ''));
        FrontEnd.SetActionContext(ActionCode(), Context);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSSalesInfo: Record "NPR MM POS Sales Info";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        JSON: Codeunit "NPR POS JSON Management";
        FunctionId: Integer;
        MemberCardNumber: Text[50];
        ForeignCommunityCode: Code[20];
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        FunctionId := JSON.GetIntegerParameterOrFail('Function', ActionCode());
        if (FunctionId < 0) then
            FunctionId := 0;

        MemberCardNumber := CopyStr(JSON.GetStringParameter('DefaultInputValue'), 1, MaxStrLen(MemberCardNumber));
        ForeignCommunityCode := CopyStr(JSON.GetStringParameter('ForeignCommunityCode'), 1, MaxStrLen(ForeignCommunityCode));

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();
        POSSalesInfo.SetFilter("Association Type", '=%1', POSSalesInfo."Association Type"::HEADER);
        POSSalesInfo.SetFilter("Receipt No.", '=%1', SalePOS."Sales Ticket No.");
        if (POSSalesInfo.FindFirst()) then;

        case WorkflowStep of
            'do_work':
                begin

                    if (MemberCardNumber = '') then
                        MemberCardNumber := CopyStr(GetInput(JSON, 'membercard_number'), 1, MaxStrLen(MemberCardNumber));

                    if (MemberCardNumber = '') then
                        MemberCardNumber := CopyStr(POSSalesInfo."Scanned Card Data", 1, MaxStrLen(MemberCardNumber));

                    case FunctionId of
                        0:
                            SetCustomer(POSSession, MemberCardNumber, ForeignCommunityCode);
                        1:
                            ViewPoints(MemberCardNumber, ForeignCommunityCode);
                        2:
                            RedeemPoints(Context, POSSession, FrontEnd, MemberCardNumber, ForeignCommunityCode);
                        3:
                            SelectAvailableCoupon(Context, POSSession, FrontEnd, MemberCardNumber, ForeignCommunityCode);
                        4:
                            SetCustomer(POSSession, MemberCardNumber, ForeignCommunityCode);

                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnCancelDiscountApplication', '', true, true)]
    local procedure OnCancelDiscountApplication(Coupon: Record "NPR NpDc Coupon"; SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon")
    var
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
    begin

        if (LoyaltyPointManagement.UnRedeemPointsCoupon(0, SaleLinePOSCoupon."Sales Ticket No.", SaleLinePOSCoupon."Sale Date", Coupon."No.")) then
            Coupon.Delete();

    end;

    local procedure ViewPoints(MemberCardNumber: Text[100]; ForeignCommunityCode: Code[20])
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipEntryNo: Integer;
        Member: Record "NPR MM Member";
        POSMemberCard: Page "NPR MM POS Member Card";
        NotFoundReasonText: Text;
    begin

        if (MemberCardNumber = '') then
            if (not SelectMemberCardUI(MemberCardNumber, ForeignCommunityCode)) then
                exit;

        MembershipEntryNo := MembershipManagement.GetMembershipFromExtCardNo(MemberCardNumber, Today, NotFoundReasonText);
        if (MembershipEntryNo = 0) then
            Error(NotFoundReasonText);

        if not (Member.Get(MembershipManagement.GetMemberFromExtCardNo(MemberCardNumber, Today, NotFoundReasonText))) then
            Error(NotFoundReasonText);

        POSMemberCard.LookupMode(true);
        POSMemberCard.SetRecord(Member);
        POSMemberCard.SetMembershipEntryNo(MembershipEntryNo);
        if (POSMemberCard.RunModal() <> ACTION::LookupOK) then
            Error('');
    end;

    local procedure RedeemPoints(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; MemberCardNumber: Text[50]; ForeignCommunityCode: Code[20])
    var
        POSSale: Codeunit "NPR POS Sale";
        LoyaltyPointMgr: Codeunit "NPR MM Loyalty Point Mgt.";
        SalePOS: Record "NPR POS Sale";
        Membership: Record "NPR MM Membership";
        TempLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary;
        MembershipEntryNo: Integer;
        CouponNo: Code[20];
        Coupon: Record "NPR NpDc Coupon";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        EanBoxEventHandler: Codeunit "NPR POS Input Box Evt Handler";
    begin

        SetCustomer(POSSession, MemberCardNumber, ForeignCommunityCode);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS.TestField("Customer No.");
        Membership.SetFilter("Customer No.", '=%1', SalePOS."Customer No.");
        Membership.SetFilter(Blocked, '=%1', false);
        if (Membership.IsEmpty()) then
            Error(NO_MEMBER);

        Membership.FindFirst();
        MembershipEntryNo := Membership."Entry No.";
        Membership.FindLast();
        if (MembershipEntryNo <> Membership."Entry No.") then
            Error(MULTIPLE_MEMBERSHIPS, SalePOS."Customer No.");
        Commit();

        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);
        //IF (LoyaltyPointMgr.GetCouponToRedeem (MembershipEntryNo, TmpLoyaltyPointsSetup)) THEN BEGIN
        if (LoyaltyPointMgr.GetCouponToRedeemPOS(MembershipEntryNo, TempLoyaltyPointsSetup, SubTotal)) then begin

            TempLoyaltyPointsSetup.Reset();
            TempLoyaltyPointsSetup.FindSet();
            repeat

                //    IF (TmpLoyaltyPointsSetup."Value Assignment" = TmpLoyaltyPointsSetup."Value Assignment"::FROM_COUPON) THEN
                //      CouponNo := LoyaltyCouponMgr.IssueOneCoupon (TmpLoyaltyPointsSetup."Coupon Type Code", MembershipEntryNo, TmpLoyaltyPointsSetup."Points Threshold", 0);
                //
                //    
                //    IF (TmpLoyaltyPointsSetup."Value Assignment" = TmpLoyaltyPointsSetup."Value Assignment"::FROM_LOYALTY) THEN BEGIN
                //      Membership.CALCFIELDS ("Remaining Points");
                //
                //      // POSSession.GetPaymentLine (POSPaymentLine);
                //      // POSPaymentLine.CalculateBalance (SalesAmount, PaidAmount, ReturnAmount, SubTotal);
                //      CouponAmount := SubTotal;
                //      IF (Membership."Remaining Points" * TmpLoyaltyPointsSetup."Point Rate" < SubTotal) THEN
                //        CouponAmount := Membership."Remaining Points" * TmpLoyaltyPointsSetup."Point Rate";
                //
                //      PointsToRedeem := ROUND (CouponAmount / TmpLoyaltyPointsSetup."Point Rate", 1);
                //
                //      IF (CouponAmount >= TmpLoyaltyPointsSetup."Minimum Coupon Amount") THEN
                //        CouponNo := LoyaltyCouponMgr.IssueOneCoupon (TmpLoyaltyPointsSetup."Coupon Type Code", MembershipEntryNo, PointsToRedeem, CouponAmount);
                //
                //    END;
                //    

                //CouponNo := LoyaltyPointMgr.IssueOneCoupon (MembershipEntryNo, TmpLoyaltyPointsSetup, SubTotal);
                CouponNo := LoyaltyPointMgr.IssueOneCoupon(MembershipEntryNo, TempLoyaltyPointsSetup, SalePOS."Sales Ticket No.", SalePOS.Date, SubTotal);

                Coupon.Get(CouponNo);

                //POSActionTextEnter.ScanBarcode (Context, POSSession, FrontEnd, Coupon."Reference No.");
                EanBoxEventHandler.InvokeEanBox(Coupon."Reference No.", Context, POSSession, FrontEnd);

            until (TempLoyaltyPointsSetup.Next() = 0);
        end;
    end;

    local procedure SelectAvailableCoupon(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; MemberCardNumber: Text[50]; ForeignCommunityCode: Code[20])
    var
        CouponsPage: Page "NPR NpDc Coupons";
        Coupon: Record "NPR NpDc Coupon";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        PageAction: Action;
        EanBoxEventHandler: Codeunit "NPR POS Input Box Evt Handler";
    begin

        SetCustomer(POSSession, MemberCardNumber, ForeignCommunityCode);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS.TestField("Customer No.");
        Coupon.SetFilter("Customer No.", '=%1', SalePOS."Customer No.");

        CouponsPage.SetTableView(Coupon);
        CouponsPage.LookupMode(true);
        Commit();
        PageAction := CouponsPage.RunModal();

        if (PageAction <> ACTION::LookupOK) then
            exit;

        CouponsPage.GetRecord(Coupon);

        //POSActionTextEnter.ScanBarcode (Context, POSSession, FrontEnd, Coupon."Reference No.");
        EanBoxEventHandler.InvokeEanBox(Coupon."Reference No.", Context, POSSession, FrontEnd);

    end;

    local procedure SetCustomer(POSSession: Codeunit "NPR POS Session"; MemberCardNumber: Text[100]; ForeignCommunityCode: Code[20])
    var
        POSActionMemberMgt: Codeunit "NPR MM POS Action: MemberMgmt.";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();
        POSSale.Refresh(SalePOS);

        if (SalePOS."Customer No." = '') then
            if (not POSActionMemberMgt.SelectMembership(POSSession, DialogMethod::NO_PROMPT, MemberCardNumber, ForeignCommunityCode)) then
                exit;
    end;

    local procedure GetInput(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin

        JSON.SetScopeRoot();
        if (not JSON.SetScope('$' + Path)) then
            exit('');

        exit(JSON.GetString('input'));
    end;

    local procedure SelectMemberCardUI(var ExtMemberCardNo: Text[100]; ForeignCommunityCode: Code[20]): Boolean
    var
        MemberCard: Record "NPR MM Member Card";
        NPRMembershipMgt: Codeunit "NPR MM NPR Membership";
    begin

        IF (ForeignCommunityCode <> '') THEN
            exit(NPRMembershipMgt.SearchForeignMembers(ForeignCommunityCode, ExtMemberCardNo));

        if (ACTION::LookupOK <> PAGE.RunModal(0, MemberCard)) then
            exit(false);

        ExtMemberCardNo := MemberCard."External Card No.";
        exit(ExtMemberCardNo <> '');
    end;


    local procedure ThisDataSource(): Text
    begin

        exit('BUILTIN_SALE');
    end;

    local procedure ThisExtension(): Text
    begin

        exit('LOYALTY');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscoverDataSourceExtensions(DataSourceName: Text; Extensions: List of [Text])
    var
        MemberCommunity: Record "NPR MM Member Community";
    begin

        if ThisDataSource() <> DataSourceName then
            exit;

        // disable this extension unless member community is setup with loyalty
        MemberCommunity.SetFilter("Activate Loyalty Program", '=%1', true);
        if (not MemberCommunity.IsEmpty()) then
            Extensions.Add(ThisExtension());

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        DataType: Enum "NPR Data Type";
    begin
        if (DataSourceName <> ThisDataSource()) or (ExtensionName <> ThisExtension()) then
            exit;

        DataSource.AddColumn('RemainingPoints', 'Remaining Points', DataType::String, false);
        DataSource.AddColumn('RemainingValue', 'Remaining Points', DataType::String, false);
        DataSource.AddColumn('RedeemablePoints', 'Redeemable Points', DataType::String, false);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSSale: Codeunit "NPR POS Sale";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        SalePOS: Record "NPR POS Sale";
        POSSalesInfo: Record "NPR MM POS Sales Info";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        RemainingPoints: Text;
        RemainingValue: Text;
        RedeemablePoints: Text;
        PlaceHolderLbl: Label '%1', Locked = true;
    begin

        if (DataSourceName <> ThisDataSource()) or (ExtensionName <> ThisExtension()) then
            exit;

        RemainingPoints := ' -- ';
        RemainingValue := '0.00';

        RedeemablePoints := ' -- ';

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if (POSSalesInfo.Get(POSSalesInfo."Association Type"::HEADER, SalePOS."Sales Ticket No.", 0)) then begin
            Membership.Get(POSSalesInfo."Membership Entry No.");
            Membership.CalcFields("Remaining Points");
            RemainingPoints := Format(Membership."Remaining Points");

            if (Membership."Remaining Points" > 0) then begin
                MembershipSetup.Get(Membership."Membership Code");
                LoyaltySetup.Get(MembershipSetup."Loyalty Code");
                RemainingValue := StrSubstNo(PlaceHolderLbl, Round(Membership."Remaining Points" * LoyaltySetup."Point Rate"));

                RedeemablePoints := StrSubstNo(PlaceHolderLbl, LoyaltyPointManagement.CalculateRedeemablePointsCurrentPeriod(Membership."Entry No."));

            end;
        end;

        DataRow.Add('RemainingPoints', RemainingPoints);
        DataRow.Add('RemainingValue', RemainingValue);

        DataRow.Add('RedeemablePoints', RedeemablePoints);

        Handled := true;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        MMMemberCard: Record "NPR MM Member Card";
    begin

        if (not EanBoxEvent.Get(EventCodeMemberSelect())) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeMemberSelect();
            EanBoxEvent."Module Name" := 'Membership Loyalty';

            EanBoxEvent.Description := CopyStr(MMMemberCard.FieldCaption("External Card No."), 1, MaxStrLen(EanBoxEvent.Description));

            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin

        case EanBoxEvent.Code of
            EventCodeMemberSelect():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'DefaultInputValue', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'Function', false, 'Select Membership (EAN Box)');
                end;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeMemberSelect(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        MMMemberCard: Record "NPR MM Member Card";
    begin

        if (EanBoxSetupEvent."Event Code" <> EventCodeMemberSelect()) then
            exit;

        if StrLen(EanBoxValue) > MaxStrLen(MMMemberCard."External Card No.") then
            exit;

        MMMemberCard.SetRange("External Card No.", UpperCase(EanBoxValue));
        if not MMMemberCard.IsEmpty() then
            InScope := true;

    end;

    local procedure EventCodeMemberSelect(): Code[20]
    begin

        exit('MEMBER_SELECT');

    end;

    local procedure CurrCodeunitId(): Integer
    begin

        exit(CODEUNIT::"NPR MM POS Action: Member Loy.");

    end;
}

