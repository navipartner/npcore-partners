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
        POSUnitRec: Record "NPR POS Unit";
        POSStoreRec: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSRestaurantProfile: Record "NPR POS NPRE Rest. Profile";
        Initialized: Boolean;
        SetupInitialized: Boolean;

    #region Initialization

    procedure Initialize()
    begin
        if (Initialized) then
            exit;

        if not UserSetup.Get(UserId) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId, 1, MaxStrLen(UserSetup."User ID"));
            UserSetup.Insert();
        end;

        if (UserSetup."NPR POS Unit No." = '') or (not POSUnitRec.Get(UserSetup."NPR POS Unit No.")) then begin
            Commit();
            while (not (Page.RunModal(Page::"NPR POS Unit Selection", POSUnitRec) = Action::LookupOK)) do;
            UserSetup."NPR POS Unit No." := POSUnitRec."No.";
            UserSetup.Modify();
        end;

        POSUnitRec.Get(UserSetup."NPR POS Unit No.");
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

    procedure GetPOSUnitNo(): Code[10]
    begin
        Initialize();
        exit(POSUnitRec."No.");
    end;

    procedure Salesperson(): Code[20]
    begin
        exit(SalespersonRec.Code);
    end;

    procedure ShowDiscountFieldsInSaleView(): Boolean
    var
        POSVieWProfile: Record "NPR POS View Profile";
    begin
        GetPOSViewProfile(POSVieWProfile);
        exit(POSVieWProfile."POS - Show discount fields");
    end;

    procedure AmountRoundingPrecision(): Decimal
    begin
        exit(POSPostingProfile."POS Sales Amt. Rndng Precision");
    end;

    procedure AmountRoundingDirection(): Text[1]
    begin
        exit(POSPostingProfile.RoundingDirection());
    end;

    procedure RoundingAccount(Mandatory: Boolean): Code[20]
    begin
        if Mandatory then
            POSPostingProfile.TestField("POS Sales Rounding Account");
        exit(POSPostingProfile."POS Sales Rounding Account");
    end;

    procedure ExchangeLabelDefaultDate(): Code[10]
    var
        ExchangeLabelSetup: Record "NPR Exchange Label Setup";
    begin
        ExchangeLabelSetup.Get();
        exit(ExchangeLabelSetup."Exchange label default date");
    end;

    procedure CashDrawerPassword(CashDrawerNo: Text): Text
    var
        POSSecurtyProfile: Record "NPR POS Security Profile";
    begin
        GetPOSSecurityProfile(POSSecurtyProfile);
        exit(POSSecurtyProfile."Unlock Password");
    end;

    procedure RestaurantCode(): Code[20]
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

    #endregion Setup

    #region "Set Record => functions"

    procedure SetSalesperson(SalespersonPurchaser: Record "Salesperson/Purchaser")
    begin
        SalespersonRec := SalespersonPurchaser;
    end;

    procedure SetPOSUnit(POSUnit: Record "NPR POS Unit")
    begin
        POSStoreRec.Get(POSUnit."POS Store Code");
        POSUnitRec := POSUnit;
        InitializeSetupPosUnit(POSUnitRec);
        FindPOSPostingProfile();
    end;

    procedure SetPOSStore(POSStore: Record "NPR POS Store")
    begin
        POSStoreRec := POSStore;
        FindPOSRestaurantProfile();
    end;

    #endregion "Set Record => functions"

    #region "Get Record => functions"

    procedure GetUserSetupRecord(var UserSetupOut: Record "User Setup")
    begin
        UserSetup := UserSetup;
    end;

    procedure GetSalespersonRecord(var SalespersonOut: Record "Salesperson/Purchaser")
    begin
        SalespersonOut := SalespersonRec;
    end;

    procedure GetPOSUnit(var POSUnitOut: Record "NPR POS Unit")
    begin
        POSUnitOut := POSUnitRec;
    end;

    procedure GetPOSViewProfile(var POSViewProfile: Record "NPR POS View Profile"): Boolean
    begin
        POSUnitRec.TestField("No.");
        exit(POSUnitRec.GetProfile(POSViewProfile));
    end;

    procedure GetPOSSecurityProfile(var POSSecurtyProfile: Record "NPR POS Security Profile"): Boolean
    begin
        POSUnitRec.TestField("No.");
        exit(POSUnitRec.GetProfile(POSSecurtyProfile));
    end;

    procedure GetPOSStore(var POSStoreOut: Record "NPR POS Store")
    begin
        POSStoreOut := POSStoreRec;
    end;

    procedure GetPOSRestProfile(var POSRestaurantProfileOut: Record "NPR POS NPRE Rest. Profile")
    begin
        POSRestaurantProfileOut := POSRestaurantProfile;
    end;

    procedure GetLockTimeout() LockTimeoutInSeconds: Integer
    var
        POSSecurtyProfile: Record "NPR POS Security Profile";
        Handled: Boolean;
    begin
        GetPOSSecurityProfile(POSSecurtyProfile);

        OnGetLockTimeout(POSSecurtyProfile, LockTimeoutInSeconds, Handled);
        if Handled then
            exit;

        case POSSecurtyProfile."Lock Timeout" of
            POSSecurtyProfile."Lock Timeout"::"30S":
                LockTimeoutInSeconds := 30;
            POSSecurtyProfile."Lock Timeout"::"60S":
                LockTimeoutInSeconds := 60;
            POSSecurtyProfile."Lock Timeout"::"90S":
                LockTimeoutInSeconds := 90;
            POSSecurtyProfile."Lock Timeout"::"120S":
                LockTimeoutInSeconds := 120;
            POSSecurtyProfile."Lock Timeout"::"600S":
                LockTimeoutInSeconds := 600;
            else
                LockTimeoutInSeconds := 0;
        end;
    end;

    procedure GetKioskUnlockEnabled(): Boolean
    var
        SSProfile: Record "NPR SS Profile";
    begin
        exit(POSUnitRec.GetProfile(SSProfile) and (SSProfile."Kiosk Mode Unlock PIN" <> ''));
    end;

    procedure GetNamedActionSetup(var POSSetupOut: Record "NPR POS Setup")
    begin
        POSSetupOut := Setup;
    end;

    #endregion "Get Record => functions"

    #region "Action Settings"

    procedure Action_Login(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session")
    begin
        InitializeSetup();
        Setup.TestField("Login Action Code");
        POSSession.RetrieveSessionAction(Setup."Login Action Code", ActionOut);
    end;

    procedure Action_TextEnter(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session")
    begin
        InitializeSetup();
        Setup.TestField("Text Enter Action Code");
        POSSession.RetrieveSessionAction(Setup."Text Enter Action Code", ActionOut);
    end;

    procedure Action_Item(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session")
    begin
        InitializeSetup();
        Setup.TestField("Item Insert Action Code");
        POSSession.RetrieveSessionAction(Setup."Item Insert Action Code", ActionOut);
    end;

    procedure Action_Payment(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session")
    begin
        InitializeSetup();
        Setup.TestField("Payment Action Code");
        POSSession.RetrieveSessionAction(Setup."Payment Action Code", ActionOut);
    end;

    procedure Action_Customer(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session")
    begin
        InitializeSetup();
        Setup.TestField("Customer Action Code");
        POSSession.RetrieveSessionAction(Setup."Customer Action Code", ActionOut);
    end;

    procedure Action_UnlockPOS(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session") IsConfigured: Boolean
    begin
        Clear(ActionOut);
        InitializeSetup();
        IsConfigured := POSSession.RetrieveSessionAction(ActionCode_UnlockPOS(), ActionOut);
    end;

    procedure Action_LockPOS(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session") IsConfigured: Boolean
    begin
        Clear(ActionOut);
        InitializeSetup();
        IsConfigured := POSSession.RetrieveSessionAction(ActionCode_LockPOS(), ActionOut);
    end;

    procedure Action_IdleTimeout(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session") IsConfigured: Boolean
    begin
        Clear(ActionOut);
        InitializeSetup();
        IsConfigured := POSSession.RetrieveSessionAction(ActionCode_IdleTimeout(), ActionOut);
    end;

    procedure Action_AdminMenu(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session") IsConfigured: Boolean
    begin
        Clear(ActionOut);
        InitializeSetup();
        IsConfigured := POSSession.RetrieveSessionAction(ActionCode_AdminMenu(), ActionOut);
    end;

    procedure ActionCode_Login(): Code[20]
    begin
        InitializeSetup();
        Setup.TestField("Login Action Code");
        exit(Setup."Login Action Code");
    end;

    procedure ActionCode_TextEnter(): Code[20]
    begin
        InitializeSetup();
        Setup.TestField("Text Enter Action Code");
        exit(Setup."Text Enter Action Code");
    end;

    procedure ActionCode_Item(): Code[20]
    begin
        InitializeSetup();
        Setup.TestField("Item Insert Action Code");
        exit(Setup."Item Insert Action Code");
    end;

    procedure ActionCode_Payment(): Code[20]
    begin
        InitializeSetup();
        Setup.TestField("Payment Action Code");
        exit(Setup."Payment Action Code");
    end;

    procedure ActionCode_Customer(): Code[20]
    begin
        InitializeSetup();
        Setup.TestField("Customer Action Code");
        exit(Setup."Customer Action Code");
    end;

    procedure ActionCode_UnlockPOS(): Code[20]
    begin
        InitializeSetup();
        exit(Setup."Unlock POS Action Code");
    end;

    procedure ActionCode_LockPOS(): Code[20]
    begin
        InitializeSetup();
        exit(Setup."Lock POS Action Code");
    end;

    procedure ActionCode_IdleTimeout(): Code[20]
    begin
        InitializeSetup();
        exit(Setup."Idle Timeout Action Code");
    end;

    procedure ActionCode_AdminMenu(): Code[20]
    begin
        InitializeSetup();
        exit(Setup."Admin Menu Action Code");
    end;

    #endregion "Action Settings"

    #region events
    [IntegrationEvent(true, false)]
    local procedure OnGetLockTimeout(POSSecurtyProfile: Record "NPR POS Security Profile"; var LockTimeoutInSeconds: Integer; var Handled: Boolean)
    begin
    end;
    #endregion events
}
