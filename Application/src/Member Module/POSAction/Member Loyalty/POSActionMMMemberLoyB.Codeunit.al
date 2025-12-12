codeunit 6150955 "NPR POSAction: MM Member Loy.B"
{
    Access = Internal;

    var
        NO_MEMBER: Label 'No member/customer specified.';
        MULTIPLE_MEMBERSHIPS: Label 'Customer number %1 resolves to more than one membership. Before redeeming points for this customer, this issue needs to be corrected. One possible solution is to block the incorrect memberships for this customer.';

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::MM_MEMBER_LOYALTY));
    end;

    procedure ViewPoints(MemberCardNumber: Text[100]; ForeignCommunityCode: Code[20])
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
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
        POSMemberCard.SetMemberCard(MemberCardNumber);
        POSMemberCard.SetMembershipEntryNo(MembershipEntryNo);
        if (POSMemberCard.RunModal() <> ACTION::LookupOK) then
            Error('');
    end;

    procedure RedeemPoints(Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; MemberCardNumber: Text[50]; ForeignCommunityCode: Code[20]; var ActionContext: JsonObject)
    var
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        LoyaltyPointMgr: Codeunit "NPR MM Loyalty Point Mgt.";
        SalePOS: Record "NPR POS Sale";
        Membership: Record "NPR MM Membership";
        TempLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary;
        POSAction: Record "NPR POS Action";
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

        SetCustomer(MemberCardNumber, ForeignCommunityCode);

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
        if (LoyaltyPointMgr.GetCouponToRedeemPOS(MembershipEntryNo, TempLoyaltyPointsSetup, SubTotal)) then begin

            TempLoyaltyPointsSetup.Reset();
            TempLoyaltyPointsSetup.FindSet();
            repeat
                CouponNo := LoyaltyPointMgr.IssueOneCoupon(MembershipEntryNo, TempLoyaltyPointsSetup, SalePOS."Sales Ticket No.", SalePOS.Date, SubTotal);

                Coupon.Get(CouponNo);

                EanBoxEventHandler.ResolveEanBoxActionForValue(Coupon."Reference No.", POSSession, FrontEnd, POSAction);

            until (TempLoyaltyPointsSetup.Next() = 0);

            if (POSAction.Code <> '') then
                SetActionContent(ActionContext, POSAction);
        end;
    end;

    procedure SelectAvailableCoupon(Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; MemberCardNumber: Text[50]; ForeignCommunityCode: Code[20]; var ActionContext: JsonObject)
    var
        CouponsPage: Page "NPR NpDc Coupons";
        Coupon: Record "NPR NpDc Coupon";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SalePOS: Record "NPR POS Sale";
        POSAction: Record "NPR POS Action";
        PageAction: Action;
        EanBoxEventHandler: Codeunit "NPR POS Input Box Evt Handler";
    begin

        SetCustomer(MemberCardNumber, ForeignCommunityCode);

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

        EanBoxEventHandler.ResolveEanBoxActionForValue(Coupon."Reference No.", POSSession, FrontEnd, POSAction);
        if POSAction.Code <> '' then
            SetActionContent(ActionContext, POSAction);
    end;

    procedure SetCustomer(MemberCardNumber: Text[100]; ForeignCommunityCode: Code[20]) Response: JsonObject
    var
        POSActionMemberMgt: Codeunit "NPR POS Action Member MgtWF3-B";
        POSSale: Codeunit "NPR POS Sale";
        MemberArrival: Codeunit "NPR POS Action: MM Member ArrB";
        POSSession: Codeunit "NPR POS Session";
        SalePOS: Record "NPR POS Sale";
        MemberCardEntryNo: Integer;
    begin

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();
        POSSale.Refresh(SalePOS);

        if (SalePOS."Customer No." <> '') then
            exit;

        MemberCardEntryNo := POSActionMemberMgt.SelectMembership(2, MemberCardNumber, ForeignCommunityCode, false);
        MemberArrival.AddToastMemberScannedData(MemberCardEntryNo, 1, Response);

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

    local procedure SetActionContent(var ActionContext: JsonObject; var POSAction: Record "NPR POS Action")
    var
        ActionVersion: Integer;
        WorkflowInvocationParametersOut: JsonObject;
        WorkflowInvocationContextOut: JsonObject;
    begin
        ActionVersion := 3;
        if POSAction."Workflow Implementation" = POSAction."Workflow Implementation"::LEGACY then
            ActionVersion := 1;

        ActionContext.Add('name', POSAction.Code);
        ActionContext.Add('version', ActionVersion);

        POSAction.GetWorkflowInvocationContext(WorkflowInvocationParametersOut, WorkflowInvocationContextOut);

        ActionContext.Add('parameters', WorkflowInvocationParametersOut);
    end;

    local procedure ThisExtension(): Text
    begin

        exit('LOYALTY');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscoverDataSourceExtensions(DataSourceName: Text; Extensions: List of [Text])
    var
        MemberCommunity: Record "NPR MM Member Community";
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin

        if POSDataMgt.POSDataSource_BuiltInSale() <> DataSourceName then
            exit;

        // disable this extension unless member community is setup with loyalty
        MemberCommunity.SetFilter("Activate Loyalty Program", '=%1', true);
        if (not MemberCommunity.IsEmpty()) then
            Extensions.Add(ThisExtension());

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        DataType: Enum "NPR Data Type";
    begin
        if (DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale()) or (ExtensionName <> ThisExtension()) then
            exit;

        DataSource.AddColumn('RemainingPoints', 'Remaining Points', DataType::String, false);
        DataSource.AddColumn('RemainingValue', 'Remaining Value', DataType::String, false);
        DataSource.AddColumn('RedeemablePoints', 'Redeemable Points', DataType::String, false);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
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

        if (DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale()) or (ExtensionName <> ThisExtension()) then
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpDc Coupon Module Mgt.", 'OnCancelDiscountApplication', '', true, true)]
    local procedure OnCancelDiscountApplication(Coupon: Record "NPR NpDc Coupon"; SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon")
    var
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
    begin

        if (LoyaltyPointManagement.UnRedeemPointsCoupon(0, SaleLinePOSCoupon."Sales Ticket No.", SaleLinePOSCoupon."Sale Date", Coupon."No.")) then
            Coupon.Delete();

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

        exit(CODEUNIT::"NPR POS Action: MM Member Loy.");

    end;
}