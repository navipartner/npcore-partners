codeunit 6060146 "NPR MM POS Action: Member Loy."
{
    var
        ActionDescription: Label 'This action is capable of redeeming member points and applying them as a coupon.';
        LoyaltyWindowTitle: Label '%1 - Membership Loyalty.';
        DialogMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        LoyaltyCalcOnEOS: Label 'Calculates loyalty points when POS ends the sale, as opposed to when G/L is posted.';
        MemberCardPrompt: Label 'Member Card No.';
        NO_MEMBER: Label 'No member/customer specified.';
        MULTIPLE_MEMBERSHIPS: Label 'Customer number %1 resolves to more than one membership. Before redeeming points for this customer, this issue needs to be corrected. One possible solution is to block the incorrect memberships for this customer.';

    local procedure ActionCode(): Text
    begin
        exit('MM_MEMBER_LOYALTY');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.3');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        FunctionOptionString: Text;
        N: Integer;
        JSArr: Text;
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin

            // FunctionOptionString := 'Select Membership,View Points,Redeem Points,Available Coupons';
            // FOR N := 1 TO 4 DO
            //   JSArr += StrSubstNo ('"%1",', SELECTSTR (N, FunctionOptionString));
            // JSArr := StrSubstNo ('var optionNames = [%1];', COPYSTR (JSArr, 1, STRLEN(JSArr)-1));

            FunctionOptionString := 'Select Membership,View Points,Redeem Points,Available Coupons,Select Membership (EAN Box)';
            for N := 1 to 5 do
                JSArr += StrSubstNo('"%1",', SelectStr(N, FunctionOptionString));
            JSArr := StrSubstNo('var optionNames = [%1];' +
                                 'if (param.Function < 0) param.Function = 0;' +
                                 'if (param.DefaultInputValue.length > 0) {context.show_dialog = false;}; ', CopyStr(JSArr, 1, StrLen(JSArr) - 1));

            Sender.RegisterWorkflowStep('0', JSArr + 'windowTitle = labels.LoyaltyWindowTitle.substitute (optionNames[param.Function].toString()); ');
            Sender.RegisterWorkflowStep('membercard_number', 'context.show_dialog && input ({caption: labels.MemberCardPrompt, title: windowTitle}).cancel(abort);');
            Sender.RegisterWorkflowStep('do_work', 'respond ();');
            Sender.RegisterWorkflow(true);

            Sender.RegisterOptionParameter('Function', FunctionOptionString, 'Select Membership');

            Sender.RegisterTextParameter('DefaultInputValue', '');

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'LoyaltyWindowTitle', LoyaltyWindowTitle);
        Captions.AddActionCaption(ActionCode, 'MemberCardPrompt', MemberCardPrompt);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
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

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSSalesInfo: Record "NPR MM POS Sales Info";
        SalePOS: Record "NPR Sale POS";
        POSSale: Codeunit "NPR POS Sale";
        JSON: Codeunit "NPR POS JSON Management";
        FunctionId: Integer;
        MemberCardNumber: Text[50];
        POSActionMemberMgt: Codeunit "NPR MM POS Action: MemberMgmt.";
        DefaultValue: Text;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        FunctionId := JSON.GetIntegerParameter('Function', true);
        if (FunctionId < 0) then
            FunctionId := 0;

        MemberCardNumber := JSON.GetStringParameter('DefaultInputValue', false);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();
        POSSalesInfo.SetFilter("Association Type", '=%1', POSSalesInfo."Association Type"::HEADER);
        POSSalesInfo.SetFilter("Receipt No.", '=%1', SalePOS."Sales Ticket No.");
        if (POSSalesInfo.FindFirst()) then;

        case WorkflowStep of
            'do_work':
                begin

                    //MemberCardNumber := COPYSTR (GetInput (JSON, 'membercard_number'), 1, MAXSTRLEN (MemberCardNumber));
                    if (MemberCardNumber = '') then
                        MemberCardNumber := CopyStr(GetInput(JSON, 'membercard_number'), 1, MaxStrLen(MemberCardNumber));

                    if (MemberCardNumber = '') then
                        MemberCardNumber := POSSalesInfo."Scanned Card Data";

                    case FunctionId of
                        0:
                            SetCustomer(POSSession, MemberCardNumber);
                        1:
                            ViewPoints(POSSession, MemberCardNumber);
                        2:
                            RedeemPoints(Context, POSSession, FrontEnd, MemberCardNumber);
                        3:
                            SelectAvailableCoupon(Context, POSSession, FrontEnd, MemberCardNumber);

                        4:
                            SetCustomer(POSSession, MemberCardNumber);

                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnCancelDiscountApplication', '', true, true)]
    local procedure OnCancelDiscountApplication(Coupon: Record "NPR NpDc Coupon"; SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon")
    var
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
    begin

        if (LoyaltyPointManagement.UnRedeemPointsCoupon(0, SaleLinePOSCoupon."Sales Ticket No.", SaleLinePOSCoupon."Sale Date", Coupon."No.")) then
            Coupon.Delete();

    end;

    local procedure "--Functions"()
    begin
    end;

    local procedure ViewPoints(POSSession: Codeunit "NPR POS Session"; MemberCardNumber: Text[50])
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipEntryNo: Integer;
        Member: Record "NPR MM Member";
        POSMemberCard: Page "NPR MM POS Member Card";
        NotFoundReasonText: Text;
    begin

        if (MemberCardNumber = '') then
            if (not SelectMemberCardUI(MemberCardNumber)) then
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

    local procedure RedeemPoints(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; MemberCardNumber: Text[50])
    var
        POSActionMemberMgt: Codeunit "NPR MM POS Action: MemberMgmt.";
        POSSale: Codeunit "NPR POS Sale";
        POSActionTextEnter: Codeunit "NPR POS Action: Text Enter";
        LoyaltyPointMgr: Codeunit "NPR MM Loyalty Point Mgt.";
        SaleLinePOS: Record "NPR Sale Line POS";
        SalePOS: Record "NPR Sale POS";
        Membership: Record "NPR MM Membership";
        TmpLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary;
        MembershipEntryNo: Integer;
        CouponNo: Code[20];
        Coupon: Record "NPR NpDc Coupon";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        CouponAmount: Decimal;
        PointsToRedeem: Integer;
        EanBoxEventHandler: Codeunit "NPR Ean Box Event Handler";
    begin

        SetCustomer(POSSession, MemberCardNumber);

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

        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);
        //IF (LoyaltyPointMgr.GetCouponToRedeem (MembershipEntryNo, TmpLoyaltyPointsSetup)) THEN BEGIN
        if (LoyaltyPointMgr.GetCouponToRedeemPOS(MembershipEntryNo, TmpLoyaltyPointsSetup, SubTotal)) then begin

            TmpLoyaltyPointsSetup.Reset;
            TmpLoyaltyPointsSetup.FindSet();
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
                CouponNo := LoyaltyPointMgr.IssueOneCoupon(MembershipEntryNo, TmpLoyaltyPointsSetup, SalePOS."Sales Ticket No.", SalePOS.Date, SubTotal);

                Coupon.Get(CouponNo);

                //POSActionTextEnter.ScanBarcode (Context, POSSession, FrontEnd, Coupon."Reference No.");
                EanBoxEventHandler.InvokeEanBox(Coupon."Reference No.", Context, POSSession, FrontEnd);

            until (TmpLoyaltyPointsSetup.Next() = 0);
        end;
    end;

    local procedure SelectAvailableCoupon(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; MemberCardNumber: Text[50])
    var
        CouponsPage: Page "NPR NpDc Coupons";
        Coupon: Record "NPR NpDc Coupon";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        PageAction: Action;
        POSActionTextEnter: Codeunit "NPR POS Action: Text Enter";
        EanBoxEventHandler: Codeunit "NPR Ean Box Event Handler";
    begin

        SetCustomer(POSSession, MemberCardNumber);

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

    local procedure "--Helpers"()
    begin
        //
    end;

    local procedure SetCustomer(POSSession: Codeunit "NPR POS Session"; MemberCardNumber: Text[50])
    var
        POSActionMemberMgt: Codeunit "NPR MM POS Action: MemberMgmt.";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
    begin

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();
        POSSale.Refresh(SalePOS);

        if (SalePOS."Customer No." = '') then
            if (not POSActionMemberMgt.SelectMembership(POSSession, DialogMethod::NO_PROMPT, MemberCardNumber)) then
                exit;
    end;

    local procedure GetInput(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin

        JSON.SetScope('/', true);
        if (not JSON.SetScope('$' + Path, false)) then
            exit('');

        exit(JSON.GetString('input', false));
    end;

    local procedure SelectMemberCardUI(var ExtMemberCardNo: Text[100]): Boolean
    var
        MemberCard: Record "NPR MM Member Card";
    begin

        if (ACTION::LookupOK <> PAGE.RunModal(0, MemberCard)) then
            exit(false);

        ExtMemberCardNo := MemberCard."External Card No.";
        exit(ExtMemberCardNo <> '');
    end;

    local procedure "--DataSource Extension"()
    begin
    end;

    local procedure ThisDataSource(): Text
    begin

        exit('BUILTIN_SALE');
    end;

    local procedure ThisExtension(): Text
    begin

        exit('LOYALTY');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscoverDataSourceExtensions(DataSourceName: Text; Extensions: List of [Text])
    var
        MemberCommunity: Record "NPR MM Member Community";
    begin

        if ThisDataSource <> DataSourceName then
            exit;

        // disable this extension unless member community is setup with loyalty
        MemberCommunity.SetFilter("Activate Loyalty Program", '=%1', true);
        if (not MemberCommunity.IsEmpty()) then
            Extensions.Add(ThisExtension);

    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        DataType: Enum "NPR Data Type";
    begin
        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
            exit;

        DataSource.AddColumn('RemainingPoints', 'Remaining Points', DataType::String, false);
        DataSource.AddColumn('RemainingValue', 'Remaining Points', DataType::String, false);
        DataSource.AddColumn('RedeemablePoints', 'Redeemable Points', DataType::String, false);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        DataType: Enum "NPR Data Type";
        POSSale: Codeunit "NPR POS Sale";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        SalePOS: Record "NPR Sale POS";
        POSSalesInfo: Record "NPR MM POS Sales Info";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        RemainingPoints: Text;
        RemainingValue: Text;
        RedeemablePoints: Text;
    begin

        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
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
                RemainingValue := StrSubstNo('%1', Round(Membership."Remaining Points" * LoyaltySetup."Point Rate"));

                RedeemablePoints := StrSubstNo('%1', LoyaltyPointManagement.CalculateRedeemablePointsCurrentPeriod(Membership."Entry No."));

            end;
        end;

        DataRow.Add('RemainingPoints', RemainingPoints);
        DataRow.Add('RemainingValue', RemainingValue);

        DataRow.Add('RedeemablePoints', RedeemablePoints);

        Handled := true;
    end;

    local procedure "--- Ean Box Event Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        MMMember: Record "NPR MM Member";
        MMMemberCard: Record "NPR MM Member Card";
        MMMembership: Record "NPR MM Membership";
    begin

        if (not EanBoxEvent.Get(EventCodeMemberSelect())) then begin
            EanBoxEvent.Init;
            EanBoxEvent.Code := EventCodeMemberSelect();
            EanBoxEvent."Module Name" := 'Membership Loyalty';

            //EanBoxEvent.Description := MMMemberCard.FIELDCAPTION("External Card No.");
            EanBoxEvent.Description := CopyStr(MMMemberCard.FieldCaption("External Card No."), 1, MaxStrLen(EanBoxEvent.Description));

            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR Ean Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin

        case EanBoxEvent.Code of
            EventCodeMemberSelect():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'DefaultInputValue', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'Function', false, 'Select Membership (EAN Box)');
                end;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeMemberSelect(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        MMMemberCard: Record "NPR MM Member Card";
    begin

        if (EanBoxSetupEvent."Event Code" <> EventCodeMemberSelect()) then
            exit;

        if StrLen(EanBoxValue) > MaxStrLen(MMMemberCard."External Card No.") then
            exit;

        MMMemberCard.SetRange("External Card No.", UpperCase(EanBoxValue));
        if (MMMemberCard.FindFirst()) then
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

