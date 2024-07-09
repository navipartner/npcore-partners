codeunit 6150708 "NPR POS Setup"
{
    // The purpose of this codeunit is to abstract retrieval of setup.
    // Sometimes setup is defined on Retail Setup level, sometimes on Register level. There may be a store level in the future.
    // It may be possible to define overruling setup configurations in more specific entities, and this codeunit serves the purpose
    // of taking care of future requirements. Instead of reading a setting directly from Retail Setup or Register, instead create a
    // function here, make this function return the correct setting, and then call that function from consumer code. That would make
    // sure that in the future, when different levels are introduced, and when setup is perhaps made hierarchical, no consumer code
    // has to be changed.

    var
        Setup: Record "NPR POS Setup";
        UserSetup: Record "User Setup";
        SalespersonRec: Record "Salesperson/Purchaser";
        xPOSUnitRec: Record "NPR POS Unit";
        POSUnitRec: Record "NPR POS Unit";
        POSStoreRec: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSRestaurantProfile: Record "NPR POS NPRE Rest. Profile";
        Initialized: Boolean;
        SetupInitialized: Boolean;

    #region Initialization

    procedure Initialize()
    var
        Handled: Boolean;
    begin
        if (Initialized) then
            exit;

        if not UserSetup.Get(UserId) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId, 1, MaxStrLen(UserSetup."User ID"));
            UserSetup.Insert();
        end;

        OnBeforeSetPOSUnitOnInitalize(UserSetup, POSUnitRec, Handled);
        if not Handled then
            if (UserSetup."NPR POS Unit No." = '') or (not POSUnitRec.Get(UserSetup."NPR POS Unit No.")) then begin
                Commit();
                while (not (Page.RunModal(Page::"NPR POS Unit Selection", POSUnitRec) = Action::LookupOK)) do;
                UserSetup."NPR POS Unit No." := POSUnitRec."No.";
                UserSetup.Modify();
            end;

        SetPOSUnit(POSUnitRec);

        Initialized := true;
    end;

    local procedure InitializeSetup()
    begin
        if SetupInitialized then
            exit;

        Setup.Get(POSUnitRec."POS Named Actions Profile");

        SetupInitialized := true;
    end;

    local procedure InitializeSetupPosUnit(POSUnit: Record "NPR POS Unit")
    begin
        if (not SetupInitialized) then
            InitializeSetup();

        if (POSUnit."POS Named Actions Profile" <> '') then
            Setup.Get(POSUnit."POS Named Actions Profile");

        FindPOSRestaurantProfile();
    end;
    #endregion Initialization

    #region Setup

    internal procedure GetPOSUnitNo(): Code[10]
    begin
        Initialize();
        exit(POSUnitRec."No.");
    end;

    procedure GetxPOSUnitNo(): Code[10]
    begin
        exit(xPOSUnitRec."No.");
    end;

    internal procedure Salesperson(): Code[20]
    begin
        exit(SalespersonRec.Code);
    end;

    internal procedure ShowDiscountFieldsInSaleView(): Boolean
    var
        POSVieWProfile: Record "NPR POS View Profile";
    begin
        GetPOSViewProfile(POSVieWProfile);
        exit(POSVieWProfile."POS - Show discount fields");
    end;

    internal procedure AmountRoundingPrecision(): Decimal
    begin
        exit(POSPostingProfile."POS Sales Amt. Rndng Precision");
    end;

    internal procedure AmountRoundingDirection(): Text[1]
    begin
        exit(POSPostingProfile.RoundingDirection());
    end;

    procedure RoundingAccount(Mandatory: Boolean): Code[20]
    begin
        if Mandatory then
            POSPostingProfile.TestField("POS Sales Rounding Account");
        exit(POSPostingProfile."POS Sales Rounding Account");
    end;

    internal procedure SalesChannel(): Code[20]
    var
    begin
        exit(POSPostingProfile."Sales Channel");
    end;

    internal procedure ExchangeLabelDefaultDate(): Code[10]
    var
        ExchangeLabelSetup: Record "NPR Exchange Label Setup";
    begin
        ExchangeLabelSetup.Get();
        exit(ExchangeLabelSetup."Exchange label default date");
    end;

    [Obsolete('Not used anymore. To access security profile use codeunit "NPR POS Secuyrity Profile"', '2023-06-28')]
    internal procedure CashDrawerPassword(CashDrawerNo: Text): Text
    begin
    end;

    internal procedure RestaurantCode(): Code[20]
    begin
        exit(POSRestaurantProfile."Restaurant Code");
    end;

    local procedure FindPOSPostingProfile()
    begin
        if POSStoreRec.Code <> POSUnitRec."POS Store Code" then begin
            POSStoreRec.Get(POSUnitRec."POS Store Code");
            SetPOSStore(POSStoreRec);
        end;
        POSStoreRec.GetProfile(POSPostingProfile);
    end;

    local procedure FindPOSRestaurantProfile()
    begin
        case true of
            (POSUnitRec."POS Restaurant Profile" <> ''):
                POSRestaurantProfile.Get(POSUnitRec."POS Restaurant Profile");
            (POSStoreRec."POS Restaurant Profile" <> ''):
                POSRestaurantProfile.Get(POSStoreRec."POS Restaurant Profile");
            else
                Clear(POSRestaurantProfile);
        end;
    end;

    internal procedure UsesNewPOSFrontEnd(): Boolean
    var
        POSLayout: Record "NPR POS Layout";
    begin
        Initialize();
        exit(POSLayout.Get(POSUnitRec."POS Layout Code"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnAfterActionUpdated', '', false, false)]
    local procedure OnAfterActionUpdated("Action": Record "NPR POS Action")
    var
        POSSetup: Record "NPR POS Setup";
    begin
        RefreshActionParameterInAllSetups(POSSetup.FieldNo("Login Action Code"), Action.Code);
        RefreshActionParameterInAllSetups(POSSetup.FieldNo("Text Enter Action Code"), Action.Code);
        RefreshActionParameterInAllSetups(POSSetup.FieldNo("Item Insert Action Code"), Action.Code);
        RefreshActionParameterInAllSetups(POSSetup.FieldNo("Payment Action Code"), Action.Code);
        RefreshActionParameterInAllSetups(POSSetup.FieldNo("Customer Action Code"), Action.Code);
        RefreshActionParameterInAllSetups(POSSetup.FieldNo("Lock POS Action Code"), Action.Code);
        RefreshActionParameterInAllSetups(POSSetup.FieldNo("Unlock POS Action Code"), Action.Code);
        RefreshActionParameterInAllSetups(POSSetup.FieldNo("OnBeforePaymentView Action"), Action.Code);
        RefreshActionParameterInAllSetups(POSSetup.FieldNo("Idle Timeout Action Code"), Action.Code);
        RefreshActionParameterInAllSetups(POSSetup.FieldNo("Admin Menu Action Code"), Action.Code);
        RefreshActionParameterInAllSetups(POSSetup.FieldNo("End of Day Action Code"), Action.Code);
    end;

    internal procedure RefreshActionParameterInAllSetups(FieldNo: Integer; ActionCode: Code[20])
    var
        POSSetup: Record "NPR POS Setup";
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
        POSSetupRecordRef: RecordRef;
        POSSetupFieldRef: FieldRef;
    begin
        Clear(POSSetupRecordRef);
        Clear(POSSetupFieldRef);

        POSSetupRecordRef.GetTable(POSSetup);
        POSSetupRecordRef.SetLoadFields(FieldNo);
        POSSetupFieldRef := POSSetupRecordRef.Field(FieldNo);

        POSSetupFieldRef.SetRange(ActionCode);
        if not POSSetupRecordRef.FindSet(false) then
            exit;

        repeat
            ParamMgt.RefreshParameters(POSSetupRecordRef.RecordId, '', FieldNo, POSSetupFieldRef.Value);
        until POSSetupRecordRef.Next() = 0;
    end;
    #endregion Setup

    #region "Set Record => functions"

    internal procedure SetSalesperson(SalespersonPurchaser: Record "Salesperson/Purchaser")
    begin
        SalespersonRec := SalespersonPurchaser;
    end;

    procedure SetPOSUnit(POSUnit: Record "NPR POS Unit")
    begin
        xPOSUnitRec := POSUnitRec;
        POSStoreRec.Get(POSUnit."POS Store Code");
        POSUnitRec := POSUnit;
        InitializeSetupPosUnit(POSUnitRec);
        FindPOSPostingProfile();
    end;

    internal procedure SetPOSStore(POSStore: Record "NPR POS Store")
    begin
        POSStoreRec := POSStore;
        FindPOSRestaurantProfile();
    end;

    #endregion "Set Record => functions"

    #region "Get Record => functions"

    internal procedure GetUserSetupRecord(var UserSetupOut: Record "User Setup")
    begin
        UserSetup := UserSetup;
    end;

    internal procedure GetSalespersonRecord(var SalespersonOut: Record "Salesperson/Purchaser")
    begin
        SalespersonOut := SalespersonRec;
    end;

    procedure GetPOSUnit(var POSUnitOut: Record "NPR POS Unit")
    begin
        POSUnitOut := POSUnitRec;
    end;

    internal procedure GetPOSViewProfile(var POSViewProfile: Record "NPR POS View Profile"): Boolean
    begin
        POSUnitRec.TestField("No.");
        exit(POSUnitRec.GetProfile(POSViewProfile));
    end;

    [Obsolete('Use codeunit "NPR POS Security Profile"', '2023-06-28')]
    internal procedure GetPOSSecurityProfile(var POSSecurtyProfile: Record "NPR POS Security Profile"): Boolean
    begin
    end;

    procedure GetPOSStore(var POSStoreOut: Record "NPR POS Store")
    begin
        POSStoreOut := POSStoreRec;
    end;

    internal procedure GetPOSRestProfile(var POSRestaurantProfileOut: Record "NPR POS NPRE Rest. Profile")
    begin
        POSRestaurantProfileOut := POSRestaurantProfile;
    end;

    internal procedure GetLockTimeout() LockTimeoutInSeconds: Integer
    var
        SecurityProfile: Codeunit "NPR POS Security Profile";
    begin
        POSUnitRec.TestField("No.");
        exit(SecurityProfile.GetLockTimeoutIfProfileExist(POSUnitRec."POS Security Profile"));
    end;

    internal procedure GetPOSButtonRefreshTime() TimeInSeconds: Integer
    var
        SecurityProfile: Codeunit "NPR POS Security Profile";
    begin
        POSUnitRec.TestField("No.");
        exit(SecurityProfile.GetPOSButtonRefreshTimeIfProfileExist(POSUnitRec."POS Security Profile"));
    end;

    internal procedure GetKioskUnlockEnabled(): Boolean
    var
        SelfServiceProfile: Codeunit "NPR SS Profile";
    begin
        exit(SelfServiceProfile.IsUnlockPINEnabledIfProfileExist(POSUnitRec."POS Self Service Profile"));
    end;

    procedure GetNamedActionSetup(var POSSetupOut: Record "NPR POS Setup")
    begin
        POSSetupOut := Setup;
    end;

    internal procedure GetPosLayoutCode(): Code[20]
    begin
        exit(POSUnitRec."POS Layout Code");
    end;

    #endregion "Get Record => functions"

    #region "Action Settings"

    internal procedure Action_Login(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session")
    begin
        InitializeSetup();
        Setup.TestField("Login Action Code");
        POSSession.RetrieveSessionAction(Setup."Login Action Code", ActionOut);
    end;

    internal procedure Action_TextEnter(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session")
    begin
        InitializeSetup();
        Setup.TestField("Text Enter Action Code");
        POSSession.RetrieveSessionAction(Setup."Text Enter Action Code", ActionOut);
    end;

    internal procedure Action_Item(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session")
    begin
        InitializeSetup();
        Setup.TestField("Item Insert Action Code");
        POSSession.RetrieveSessionAction(Setup."Item Insert Action Code", ActionOut);
    end;

    internal procedure Action_Payment(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session")
    begin
        InitializeSetup();
        Setup.TestField("Payment Action Code");
        POSSession.RetrieveSessionAction(Setup."Payment Action Code", ActionOut);
    end;

    internal procedure Action_Customer(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session")
    begin
        InitializeSetup();
        Setup.TestField("Customer Action Code");
        POSSession.RetrieveSessionAction(Setup."Customer Action Code", ActionOut);
    end;

    internal procedure Action_UnlockPOS(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session") IsConfigured: Boolean
    begin
        Clear(ActionOut);
        InitializeSetup();
        IsConfigured := POSSession.RetrieveSessionAction(ActionCode_UnlockPOS(), ActionOut);
    end;

    internal procedure Action_LockPOS(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session") IsConfigured: Boolean
    begin
        Clear(ActionOut);
        InitializeSetup();
        IsConfigured := POSSession.RetrieveSessionAction(ActionCode_LockPOS(), ActionOut);
    end;

    internal procedure Action_IdleTimeout(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session") IsConfigured: Boolean
    begin
        Clear(ActionOut);
        InitializeSetup();
        IsConfigured := POSSession.RetrieveSessionAction(ActionCode_IdleTimeout(), ActionOut);
    end;

    internal procedure Action_AdminMenu(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session") IsConfigured: Boolean
    begin
        Clear(ActionOut);
        InitializeSetup();
        IsConfigured := POSSession.RetrieveSessionAction(ActionCode_AdminMenu(), ActionOut);
    end;

    internal procedure Action_EndOfDay(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session") IsConfigured: Boolean
    begin
        Clear(ActionOut);
        InitializeSetup();
        IsConfigured := POSSession.RetrieveSessionAction(ActionCode_EndOfDay(), ActionOut);
    end;

    internal procedure ActionCode_Login(): Code[20]
    begin
        InitializeSetup();
        Setup.TestField("Login Action Code");
        exit(Setup."Login Action Code");
    end;

    internal procedure ActionCode_TextEnter(): Code[20]
    begin
        InitializeSetup();
        Setup.TestField("Text Enter Action Code");
        exit(Setup."Text Enter Action Code");
    end;

    internal procedure ActionCode_Item(): Code[20]
    begin
        InitializeSetup();
        Setup.TestField("Item Insert Action Code");
        exit(Setup."Item Insert Action Code");
    end;

    internal procedure ActionCode_Payment(): Code[20]
    begin
        InitializeSetup();
        Setup.TestField("Payment Action Code");
        exit(Setup."Payment Action Code");
    end;

    internal procedure ActionCode_Customer(): Code[20]
    begin
        InitializeSetup();
        Setup.TestField("Customer Action Code");
        exit(Setup."Customer Action Code");
    end;

    internal procedure ActionCode_UnlockPOS(): Code[20]
    begin
        InitializeSetup();
        exit(Setup."Unlock POS Action Code");
    end;

    internal procedure ActionCode_LockPOS(): Code[20]
    begin
        InitializeSetup();
        exit(Setup."Lock POS Action Code");
    end;

    internal procedure ActionCode_IdleTimeout(): Code[20]
    begin
        InitializeSetup();
        exit(Setup."Idle Timeout Action Code");
    end;

    internal procedure ActionCode_AdminMenu(): Code[20]
    begin
        InitializeSetup();
        exit(Setup."Admin Menu Action Code");
    end;

    internal procedure ActionCode_EndOfDay(): Code[20]
    begin
        InitializeSetup();
        if Setup."End of Day Action Code" = '' then
            Setup."End of Day Action Code" := 'BALANCE_V4';
        exit(Setup."End of Day Action Code");
    end;

    #endregion "Action Settings"

    #region events

    [Obsolete('Not used anymore.', '2023-06-28')]
    [IntegrationEvent(true, false)]
    local procedure OnGetLockTimeout(POSSecurtyProfile: Record "NPR POS Security Profile"; var LockTimeoutInSeconds: Integer; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetPOSUnitOnInitalize(var UserSetup: Record "User Setup"; var POSUnitRec: Record "NPR POS Unit"; var Handled: Boolean)
    begin
    end;
    #endregion events
}
