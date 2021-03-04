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
        POSUnitIdentityGlobal: Record "NPR POS Unit Identity";
        Initialized: Boolean;
        SetupInitialized: Boolean;

    #region Initialization

    procedure Initialize(UserCode: Code[50])
    var
        POSUnitIdentityRec: Record "NPR POS Unit Identity";
        POSUnitIdentity: Codeunit "NPR POS Unit Identity";
    begin

        if (Initialized) then
            exit;

        if UserCode = '' then
            UserCode := UserId;

        // Setup is initialied twice, first when the page has been initialized and then when framework send the the hardware ID
        UserSetup.Get(UserId);
        UserSetup.TestField("NPR Backoffice Register No.");
        POSUnitIdentity.ConfigureTemporaryDevice(UserSetup."NPR Backoffice Register No.", POSUnitIdentityRec);

        Initialized := true;
    end;

    procedure InitializeUsingPosUnitIdentity(POSUnitIdentity: Record "NPR POS Unit Identity")
    var
        POSStore: Record "NPR POS Store";
    begin
        POSUnitRec.Get(POSUnitIdentity."Default POS Unit No.");

        SetPOSUnit(POSUnitRec);
        if POSStore.Get(POSUnitRec."POS Store Code") then
            SetPOSStore(POSStore);

        POSUnitIdentityGlobal := POSUnitIdentity;

        Initialized := true;
    end;

    local procedure InitializeDefault()
    begin
        Initialize('');
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

    local procedure MakeSureIsInitialized()
    begin
        if not Initialized then
            InitializeDefault();
    end;

    #endregion Initialization

    #region Setup

    procedure GetPOSUnitNo(): Code[10]
    begin
        MakeSureIsInitialized();
        exit(POSUnitRec."No.");
    end;

    procedure Salesperson(): Code[20]
    begin
        exit(SalespersonRec.Code);
    end;

    procedure ShowDiscountFieldsInSaleView(POSUnitNo: Code[10]): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        POSVieWProfile: Record "NPR POS View Profile";
    begin
        if not POSUnit.Get(POSUnitNo) then
            Clear(POSUnit);

        if not POSVieWProfile.Get(POSUnit."POS View Profile") then
            Clear(POSVieWProfile);

        exit(POSVieWProfile."POS - Show discount fields");
    end;

    procedure AmountRoundingPrecision(): Decimal
    begin
        exit(POSPostingProfile."POS Sales Amt. Rndng Precision");
    end;

    procedure AmountRoundingDirection(): Text[1]
    begin
        exit(POSPostingProfile.RoundingDirection);
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
        POSUnit: Record "NPR POS Unit";
    begin
        GetPOSUnit(POSUnit);
        exit(POSUnit."Open Register Password");
    end;

    procedure RestaurantCode(): Code[20]
    begin
        exit(POSRestaurantProfile."Restaurant Code");
    end;

    local procedure FindPOSPostingProfile()
    var
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.GetPostingProfile(POSUnitRec."No.", POSPostingProfile);
    end;

    local procedure FindPOSRestaurantProfile()
    begin
        case true of
            (POSUnitRec."POS Restaurant Profile" <> ''):
                POSRestaurantProfile.Get(POSUnitRec."POS Restaurant Profile");
            (POSStoreRec."POS Restaurant Profile" <> ''):
                POSRestaurantProfile.Get(POSStoreRec."POS Restaurant Profile");
            else
                Clear(POSPostingProfile);
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
        POSUnitRec := POSUnit;
        InitializeSetupPosUnit(POSUnitRec);
        FindPOSPostingProfile;
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
        if (POSUnitRec."POS View Profile" = '') then
            exit(false);

        POSViewProfile.Get(POSUnitRec."POS View Profile");
        exit(true);
    end;

    procedure GetPOSStore(var POSStoreOut: Record "NPR POS Store")
    begin
        POSStoreOut := POSStoreRec;
    end;

    procedure GetPOSUnitIdentity(var POSUnitIdentity: Record "NPR POS Unit Identity")
    begin
        POSUnitIdentity := POSUnitIdentityGlobal;
    end;

    procedure GetPOSRestProfile(var POSRestaurantProfileOut: Record "NPR POS NPRE Rest. Profile")
    begin
        POSRestaurantProfileOut := POSRestaurantProfile;
    end;

    procedure GetLockTimeout() LockTimeoutInSeconds: Integer
    var
        POSViewProfile: Record "NPR POS View Profile";
    begin
        POSUnitRec.TestField("No.");
        POSUnitRec.GetProfile(POSViewProfile);

        case POSViewProfile."Lock Timeout" of
            POSViewProfile."Lock Timeout"::"30S":
                LockTimeoutInSeconds := 30;
            POSViewProfile."Lock Timeout"::"60S":
                LockTimeoutInSeconds := 60;
            POSViewProfile."Lock Timeout"::"90S":
                LockTimeoutInSeconds := 90;
            POSViewProfile."Lock Timeout"::"120S":
                LockTimeoutInSeconds := 120;
            POSViewProfile."Lock Timeout"::"600S":
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
        IsConfigured := POSSession.RetrieveSessionAction(ActionCode_UnlockPOS, ActionOut);
    end;

    procedure Action_LockPOS(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session") IsConfigured: Boolean
    begin
        Clear(ActionOut);
        InitializeSetup();
        IsConfigured := POSSession.RetrieveSessionAction(ActionCode_LockPOS, ActionOut);
    end;

    procedure Action_IdleTimeout(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session") IsConfigured: Boolean
    begin
        Clear(ActionOut);
        InitializeSetup();
        IsConfigured := POSSession.RetrieveSessionAction(ActionCode_IdleTimeout, ActionOut);
    end;

    procedure Action_AdminMenu(var ActionOut: Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session") IsConfigured: Boolean
    begin
        Clear(ActionOut);
        InitializeSetup();
        IsConfigured := POSSession.RetrieveSessionAction(ActionCode_AdminMenu, ActionOut);
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
}
