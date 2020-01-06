codeunit 6060146 "MM POS Action - Member Loyalty"
{
    // MM1.22/TSA /20170801 CASE 285403 POS Action to redeem points
    // MM1.25/TSA /20171101 CASE 295172 disable loyalty data source extension unless member community is setup with loyalty
    // MM1.28/TSA /20180426 CASE 307048 Adding dynamic coupon value support
    // MM1.32/TSA/20180725  CASE 321176 Transport MM1.32 - 25 July 2018
    // MM1.33/TSA /20180822 CASE 326754 EAN Box Changes
    // MM1.37/TSA /20190227 CASE 343053 Made the select membership a little smarter for loyalty
    // MM1.37/TSA /20190328 CASE 350364 Added Member Select as EAN box Event
    // MM1.37/MHA /20190328  CASE 350288 Added MaxStrLen to EanBox.Description in DiscoverEanBoxEvents()
    // MM1.40/TSA /20190815 CASE 343352 Refactored coupon creation
    // MM1.41/TSA /20191002 CASE 371095 Added RedeemablePoints KPI


    trigger OnRun()
    begin
    end;

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
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
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

            //-MM1.37 [350364]
            // FunctionOptionString := 'Select Membership,View Points,Redeem Points,Available Coupons';
            // FOR N := 1 TO 4 DO
            //   JSArr += STRSUBSTNO ('"%1",', SELECTSTR (N, FunctionOptionString));
            // JSArr := STRSUBSTNO ('var optionNames = [%1];', COPYSTR (JSArr, 1, STRLEN(JSArr)-1));

            FunctionOptionString := 'Select Membership,View Points,Redeem Points,Available Coupons,Select Membership (EAN Box)';
            for N := 1 to 5 do
                JSArr += StrSubstNo('"%1",', SelectStr(N, FunctionOptionString));
            JSArr := StrSubstNo('var optionNames = [%1];' +
                                 'if (param.Function < 0) param.Function = 0;' +
                                 'if (param.DefaultInputValue.length > 0) {context.show_dialog = false;}; ', CopyStr(JSArr, 1, StrLen(JSArr) - 1));
            //+MM1.37 [350364]

            Sender.RegisterWorkflowStep('0', JSArr + 'windowTitle = labels.LoyaltyWindowTitle.substitute (optionNames[param.Function].toString()); ');
            Sender.RegisterWorkflowStep('membercard_number', 'context.show_dialog && input ({caption: labels.MemberCardPrompt, title: windowTitle}).cancel(abort);');
            Sender.RegisterWorkflowStep('do_work', 'respond ();');
            Sender.RegisterWorkflow(true);

            Sender.RegisterOptionParameter('Function', FunctionOptionString, 'Select Membership');
            //-MM1.37 [350364]
            Sender.RegisterTextParameter('DefaultInputValue', '');
            //+MM1.37 [350364]

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'LoyaltyWindowTitle', LoyaltyWindowTitle);
        Captions.AddActionCaption(ActionCode, 'MemberCardPrompt', MemberCardPrompt);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action"; Parameters: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "POS JSON Management";
        JSON: Codeunit "POS JSON Management";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
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
    local procedure OnAction("Action": Record "POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        POSSalesInfo: Record "MM POS Sales Info";
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
        JSON: Codeunit "POS JSON Management";
        FunctionId: Integer;
        MemberCardNumber: Text[50];
        POSActionMemberMgt: Codeunit "MM POS Action - Member Mgmt.";
        DefaultValue: Text;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        FunctionId := JSON.GetIntegerParameter('Function', true);
        if (FunctionId < 0) then
            FunctionId := 0;

        //-MM1.37 [350364]
        MemberCardNumber := JSON.GetStringParameter('DefaultInputValue', false);
        //+MM1.37 [350364]

        //-MM1.37 [343053]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();
        POSSalesInfo.SetFilter("Association Type", '=%1', POSSalesInfo."Association Type"::HEADER);
        POSSalesInfo.SetFilter("Receipt No.", '=%1', SalePOS."Sales Ticket No.");
        if (POSSalesInfo.FindFirst()) then;
        //+MM1.37 [343053]

        case WorkflowStep of
            'do_work':
                begin
                    //-MM1.37 [350364]
                    //MemberCardNumber := COPYSTR (GetInput (JSON, 'membercard_number'), 1, MAXSTRLEN (MemberCardNumber));
                    if (MemberCardNumber = '') then
                        MemberCardNumber := CopyStr(GetInput(JSON, 'membercard_number'), 1, MaxStrLen(MemberCardNumber));
                    //+MM1.37 [350364]

                    //-MM1.37 [343053]
                    if (MemberCardNumber = '') then
                        MemberCardNumber := POSSalesInfo."Scanned Card Data";
                    //+MM1.37 [343053]

                    case FunctionId of
                        0:
                            SetCustomer(POSSession, MemberCardNumber);
                        1:
                            ViewPoints(POSSession, MemberCardNumber);
                        2:
                            RedeemPoints(Context, POSSession, FrontEnd, MemberCardNumber);
                        3:
                            SelectAvailableCoupon(Context, POSSession, FrontEnd, MemberCardNumber);
                        //-MM1.37 [350364]
                        4:
                            SetCustomer(POSSession, MemberCardNumber);
                            //+MM1.37 [350364]

                    end;
                end;
        end;
    end;

    local procedure "--Functions"()
    begin
    end;

    local procedure ViewPoints(POSSession: Codeunit "POS Session"; MemberCardNumber: Text[50])
    var
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipEntryNo: Integer;
        Member: Record "MM Member";
        POSMemberCard: Page "MM POS Member Card";
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

    local procedure RedeemPoints(Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; MemberCardNumber: Text[50])
    var
        POSActionMemberMgt: Codeunit "MM POS Action - Member Mgmt.";
        POSSale: Codeunit "POS Sale";
        POSActionTextEnter: Codeunit "POS Action - Text Enter";
        LoyaltyPointMgr: Codeunit "MM Loyalty Point Management";
        SaleLinePOS: Record "Sale Line POS";
        SalePOS: Record "Sale POS";
        Membership: Record "MM Membership";
        TmpLoyaltyPointsSetup: Record "MM Loyalty Points Setup" temporary;
        MembershipEntryNo: Integer;
        CouponNo: Code[20];
        Coupon: Record "NpDc Coupon";
        POSPaymentLine: Codeunit "POS Payment Line";
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        CouponAmount: Decimal;
        PointsToRedeem: Integer;
        EanBoxEventHandler: Codeunit "Ean Box Event Handler";
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

        //-MM1.32 [321176]
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);
        //IF (LoyaltyPointMgr.GetCouponToRedeem (MembershipEntryNo, TmpLoyaltyPointsSetup)) THEN BEGIN
        if (LoyaltyPointMgr.GetCouponToRedeemPOS (MembershipEntryNo, TmpLoyaltyPointsSetup, SubTotal)) then begin
            //+MM1.32 [321176]

            TmpLoyaltyPointsSetup.Reset;
            TmpLoyaltyPointsSetup.FindSet();
            repeat

            //-MM1.40 [343352]
            //    IF (TmpLoyaltyPointsSetup."Value Assignment" = TmpLoyaltyPointsSetup."Value Assignment"::FROM_COUPON) THEN
            //      CouponNo := LoyaltyCouponMgr.IssueOneCoupon (TmpLoyaltyPointsSetup."Coupon Type Code", MembershipEntryNo, TmpLoyaltyPointsSetup."Points Threshold", 0);
            //
            //    //-#307048 [307048]
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
            //    //+#307048 [307048]

            CouponNo := LoyaltyPointMgr.IssueOneCoupon (MembershipEntryNo, TmpLoyaltyPointsSetup, SubTotal);
            //+MM1.40 [343352]

                Coupon.Get(CouponNo);

                //-MM1.33 [326754]
                //POSActionTextEnter.ScanBarcode (Context, POSSession, FrontEnd, Coupon."Reference No.");
                EanBoxEventHandler.InvokeEanBox(Coupon."Reference No.", Context, POSSession, FrontEnd);
                //+MM1.33 [326754]

            until (TmpLoyaltyPointsSetup.Next() = 0);
        end;
    end;

    local procedure SelectAvailableCoupon(Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; MemberCardNumber: Text[50])
    var
        CouponsPage: Page "NpDc Coupons";
        Coupon: Record "NpDc Coupon";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        PageAction: Action;
        POSActionTextEnter: Codeunit "POS Action - Text Enter";
        EanBoxEventHandler: Codeunit "Ean Box Event Handler";
    begin

        SetCustomer(POSSession, MemberCardNumber);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS.TestField("Customer No.");
        Coupon.SetFilter("Customer No.", '=%1', SalePOS."Customer No.");

        CouponsPage.SetTableView(Coupon);
        CouponsPage.LookupMode(true);
        Commit;
        PageAction := CouponsPage.RunModal();

        if (PageAction <> ACTION::LookupOK) then
            exit;

        CouponsPage.GetRecord(Coupon);

        //-MM1.33 [326754]
        //POSActionTextEnter.ScanBarcode (Context, POSSession, FrontEnd, Coupon."Reference No.");
        EanBoxEventHandler.InvokeEanBox(Coupon."Reference No.", Context, POSSession, FrontEnd);
        //+MM1.33 [326754]
    end;

    local procedure "--Helpers"()
    begin
        //
    end;

    local procedure SetCustomer(POSSession: Codeunit "POS Session"; MemberCardNumber: Text[50])
    var
        POSActionMemberMgt: Codeunit "MM POS Action - Member Mgmt.";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
    begin

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();
        POSSale.Refresh(SalePOS);

        if (SalePOS."Customer No." = '') then
            if (not POSActionMemberMgt.SelectMembership(POSSession, DialogMethod::NO_PROMPT, MemberCardNumber)) then
                exit;
    end;

    local procedure GetInput(JSON: Codeunit "POS JSON Management"; Path: Text): Text
    begin

        JSON.SetScope('/', true);
        if (not JSON.SetScope('$' + Path, false)) then
            exit('');

        exit(JSON.GetString('input', false));
    end;

    local procedure SelectMemberCardUI(var ExtMemberCardNo: Text[100]): Boolean
    var
        MemberCard: Record "MM Member Card";
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
    local procedure OnDiscoverDataSourceExtensions(DataSourceName: Text; Extensions: DotNet npNetList_Of_T)
    var
        MemberCommunity: Record "MM Member Community";
    begin

        if ThisDataSource <> DataSourceName then
            exit;

        //-MM1.25 [295172]
        // disable this extension unless member community is setup with loyalty
        MemberCommunity.SetFilter("Activate Loyalty Program", '=%1', true);
        if (not MemberCommunity.IsEmpty()) then
            Extensions.Add(ThisExtension);
        //+MM1.25 [295172]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: DotNet npNetDataSource0; var Handled: Boolean; Setup: Codeunit "POS Setup")
    var
        DataType: DotNet npNetDataType;
    begin
        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
            exit;

        DataSource.AddColumn('RemainingPoints', 'Remaining Points', DataType.String, false);
        DataSource.AddColumn('RemainingValue', 'Remaining Points', DataType.String, false);

        //-MM1.41 [371095]
        DataSource.AddColumn ('RedeemablePoints', 'Redeemable Points', DataType.String, false);
        //+MM1.41 [371095]


        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: DotNet npNetDataRow0; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        DataType: DotNet npNetDataType;
        POSSale: Codeunit "POS Sale";
        LoyaltyPointManagement: Codeunit "MM Loyalty Point Management";
        SalePOS: Record "Sale POS";
        POSSalesInfo: Record "MM POS Sales Info";
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        LoyaltySetup: Record "MM Loyalty Setup";
        RemainingPoints: Text;
        RemainingValue: Text;
        RedeemablePoints: Text;
    begin

        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
            exit;

        RemainingPoints := ' -- ';
        RemainingValue := '0.00';
        //-MM1.41 [371095]
        RedeemablePoints := ' -- ';
        //+MM1.41 [371095]


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
            //-MM1.41 [371095]
            RedeemablePoints := StrSubstNo ('%1', LoyaltyPointManagement.CalculateRedeemablePoints (Membership."Entry No."));
            //-MM1.41 [371095]
            end;
        end;

        DataRow.Add('RemainingPoints', RemainingPoints);
        DataRow.Add('RemainingValue', RemainingValue);

        //-MM1.41 [371095]
        DataRow.Add ('RedeemablePoints', RedeemablePoints);
        //+MM1.41 [371095]

        //-MM1.41 [371095]
        DataRow.Add ('RedeemablePoints', RedeemablePoints);
        //+MM1.41 [371095]

        Handled := true;
    end;

    local procedure "--- Ean Box Event Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "Ean Box Event")
    var
        MMMember: Record "MM Member";
        MMMemberCard: Record "MM Member Card";
        MMMembership: Record "MM Membership";
    begin

        //-MM1.37 [350364]
        if (not EanBoxEvent.Get(EventCodeMemberSelect())) then begin
            EanBoxEvent.Init;
            EanBoxEvent.Code := EventCodeMemberSelect();
            EanBoxEvent."Module Name" := 'Membership Loyalty';
            //-MM1.37 [350288]
            //EanBoxEvent.Description := MMMemberCard.FIELDCAPTION("External Card No.");
            EanBoxEvent.Description := CopyStr(MMMemberCard.FieldCaption("External Card No."), 1, MaxStrLen(EanBoxEvent.Description));
            //+MM1.37 [350288]
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
        //+MM1.37 [350364]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "Ean Box Setup Mgt."; EanBoxEvent: Record "Ean Box Event")
    begin

        //-MM1.37 [350364]
        case EanBoxEvent.Code of
            EventCodeMemberSelect():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'DefaultInputValue', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'Function', false, 'Select Membership (EAN Box)');
                end;
        end;
        //+MM1.37 [350364]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeMemberSelect(EanBoxSetupEvent: Record "Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        MMMemberCard: Record "MM Member Card";
    begin

        //-MM1.37 [350364]
        if (EanBoxSetupEvent."Event Code" <> EventCodeMemberSelect()) then
            exit;

        if StrLen(EanBoxValue) > MaxStrLen(MMMemberCard."External Card No.") then
            exit;

        MMMemberCard.SetRange("External Card No.", UpperCase(EanBoxValue));
        if (MMMemberCard.FindFirst()) then
            InScope := true;
        //+MM1.37 [350364]
    end;

    local procedure EventCodeMemberSelect(): Code[20]
    begin

        //-MM1.37 [350364]
        exit('MEMBER_SELECT');
        //+MM1.37 [350364]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-MM1.37 [350364]
        exit(CODEUNIT::"MM POS Action - Member Loyalty");
        //+MM1.37 [350364]
    end;
}

