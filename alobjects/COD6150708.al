codeunit 6150708 "POS Setup"
{
    // The purpose of this codeunit is to abstract retrieval of setup.
    // Sometimes setup is defined on Retail Setup level, sometimes on Register level. There may be a store level in the future.
    // It may be possible to define overruling setup configurations in more specific entities, and this codeunit serves the purpose
    // of taking care of future requirements. Instead of reading a setting directly from Retail Setup or Register, instead create a
    // function here, make this function return the correct setting, and then call that function from consumer code. That would make
    // sure that in the future, when different levels are introduced, and when setup is perhaps made hierarchical, no consumer code
    // has to be changed.
    // 
    // NPR5.32.10/BR  /20170612  CASE 279551 Added support for new POS structure
    // NPR5.37/TSA /20171024 CASE 293905 Added function GetLockTimeout(), ActionCode_UnlockPOS(), Action_UnlockPOS, ActionCode_LockPOS(), Action_LockPOS
    // NPR5.40/VB  /20180213 CASE 306347 Performance improvement due to physical-table action discovery
    // NPR5.45/TJ  /20180908 CASE 323728 Checking if unlock PIN is set for kiosk mode


    trigger OnRun()
    begin
    end;

    var
        Setup: Record "POS Setup";
        RetailSetup: Record "Retail Setup";
        UserSetup: Record "User Setup";
        SalespersonRec: Record "Salesperson/Purchaser";
        RegisterRec: Record Register;
        POSUnitRec: Record "POS Unit";
        POSStoreRec: Record "POS Store";
        Initialized: Boolean;
        SetupInitialized: Boolean;

    local procedure "---Initialization---"()
    begin
    end;

    procedure Initialize(UserCode: Code[50])
    var
        POSUnitIdentityRec: Record "POS Unit Identity";
        POSUnitIdentity: Codeunit "POS Unit Identity";
    begin

        if (Initialized) then
          exit;

        if UserCode = '' then
          UserCode := UserId;

        RetailSetup.Get();

        // Setup is initialied twice, first when the page has been initialized and then when framework send the the hardware ID
        UserSetup.Get (UserId);
        UserSetup.TestField ("Backoffice Register No.");
        POSUnitIdentity.ConfigureTemporaryDevice (UserSetup."Backoffice Register No.", POSUnitIdentityRec);
        //InitializeUsingPosUnitIdentity (POSUnitIdentityRec);

        Initialized := true;
    end;

    procedure InitializeUsingPosUnitIdentity(POSUnitIdentity: Record "POS Unit Identity")
    var
        POSUnit: Record "POS Unit";
        POSStore: Record "POS Store";
    begin

        POSUnit.Get (POSUnitIdentity."Default POS Unit No.");
        RegisterRec.Get (POSUnitIdentity."Default POS Unit No.");

        //-NPR5.32.10 [279551]
        SetPOSUnit(POSUnit);
        if POSStore.Get(POSUnit."POS Store Code") then
          SetPOSStore(POSStore);
        //+NPR5.32.10 [279551]

        RetailSetup.Get();
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

        Setup.Get();
        SetupInitialized := true;
    end;

    local procedure MakeSureIsInitialized()
    begin
        if not Initialized then
          InitializeDefault();
    end;

    local procedure "---Setup---"()
    begin
    end;

    procedure Register(): Code[10]
    begin
        MakeSureIsInitialized();
        exit(RegisterRec."Register No.");
    end;

    procedure Salesperson(): Code[10]
    begin
        exit(SalespersonRec.Code);
    end;

    procedure ShowDiscountFieldsInSaleView(): Boolean
    begin
        exit(RetailSetup."POS - Show discount fields");
    end;

    procedure AmountRoundingPrecision(): Decimal
    begin
        exit(RetailSetup."Amount Rounding Precision");
    end;

    procedure ExchangeLabelDefaultDate(): Code[10]
    begin
        exit(RetailSetup."Exchange label default date");
    end;

    procedure CashDrawerPassword(CashDrawerNo: Text): Text
    begin
        exit(RetailSetup."Open Register Password");
    end;

    local procedure "---Set Record => functions---"()
    begin
    end;

    procedure SetSalesperson(SalespersonPurchaser: Record "Salesperson/Purchaser")
    begin
        SalespersonRec := SalespersonPurchaser;
    end;

    procedure SetRegister(Register: Record Register)
    begin
        RegisterRec := Register;
    end;

    procedure SetPOSUnit(POSUnit: Record "POS Unit")
    begin
        //-NPR5.32.10 [279551]
        POSUnitRec := POSUnit;
        //+NPR5.32.10 [279551]
    end;

    procedure SetPOSStore(POSStore: Record "POS Store")
    begin
        //-NPR5.32.10 [279551]
        POSStoreRec := POSStore;
        //+NPR5.32.10 [279551]
    end;

    local procedure "---Get Record => functions---"()
    begin
    end;

    procedure GetRegisterRecord(var RegisterOut: Record Register)
    begin
        RegisterOut := RegisterRec;
    end;

    procedure GetUserSetupRecord(var UserSetupOut: Record "User Setup")
    begin
        UserSetup := UserSetup;
    end;

    procedure GetSalespersonRecord(var SalespersonOut: Record "Salesperson/Purchaser")
    begin
        SalespersonOut := SalespersonRec;
    end;

    procedure GetPOSUnit(var POSUnitOut: Record "POS Unit")
    begin
        //-NPR5.32.10 [279551]
        POSUnitOut := POSUnitRec;
        //+NPR5.32.10 [279551]
    end;

    procedure GetPOSStore(var POSStoreOut: Record "POS Store")
    begin
        //-NPR5.32.10 [279551]
        POSStoreOut := POSStoreRec;
        //+NPR5.32.10 [279551]
    end;

    procedure GetLockTimeout() LockTimeoutInSeconds: Integer
    begin
        //-NPR5.37 [293905]
        with POSUnitRec do begin
          TestField ("No.");

          case POSUnitRec."Lock Timeout" of
            "Lock Timeout"::"30S" : LockTimeoutInSeconds := 30;
            "Lock Timeout"::"60S" : LockTimeoutInSeconds := 60;
            "Lock Timeout"::"90S" : LockTimeoutInSeconds := 90;
            "Lock Timeout"::"120S" : LockTimeoutInSeconds := 120;
            "Lock Timeout"::"600S" : LockTimeoutInSeconds := 600;
          else
            LockTimeoutInSeconds := 0;
          end;
        end;
        //+NPR5.37 [293905]
    end;

    procedure GetKioskUnlockEnabled(): Boolean
    begin
        //-NPR5.45 [323728]
        exit(POSUnitRec."Kiosk Mode Unlock PIN" <> '');
        //+NPR5.45 [323728]
    end;

    local procedure "---Action Settings---"()
    begin
    end;

    procedure Action_Login(var ActionOut: Record "POS Action";POSSession: Codeunit "POS Session")
    begin
        with Setup do begin
          InitializeSetup();
          TestField("Login Action Code");
        //-NPR5.40 [306347]
        //  ActionOut.GET("Login Action Code");
          POSSession.RetrieveSessionAction("Login Action Code",ActionOut);
        //+NPR5.40 [306347]
        end;
    end;

    procedure Action_TextEnter(var ActionOut: Record "POS Action";POSSession: Codeunit "POS Session")
    begin
        with Setup do begin
          InitializeSetup();
          TestField("Text Enter Action Code");
        //-NPR5.40 [306347]
        //  ActionOut.GET("Text Enter Action Code");
          POSSession.RetrieveSessionAction("Text Enter Action Code",ActionOut);
        //+NPR5.40 [306347]
        end;
    end;

    procedure Action_Item(var ActionOut: Record "POS Action";POSSession: Codeunit "POS Session")
    begin
        with Setup do begin
          InitializeSetup();
          TestField("Item Insert Action Code");
        //-NPR5.40 [306347]
        //  ActionOut.GET("Item Insert Action Code");
          POSSession.RetrieveSessionAction("Item Insert Action Code",ActionOut);
        //+NPR5.40 [306347]
        end;
    end;

    procedure Action_Payment(var ActionOut: Record "POS Action";POSSession: Codeunit "POS Session")
    begin
        with Setup do begin
          InitializeSetup();
          TestField("Payment Action Code");
        //-NPR5.40 [306347]
        //  ActionOut.GET("Payment Action Code");
          POSSession.RetrieveSessionAction("Payment Action Code",ActionOut);
        //+NPR5.40 [306347]
        end;
    end;

    procedure Action_Customer(var ActionOut: Record "POS Action";POSSession: Codeunit "POS Session")
    begin
        with Setup do begin
          InitializeSetup();
          TestField("Customer Action Code");
        //-NPR5.40 [306347]
        //  ActionOut.GET("Customer Action Code");
          POSSession.RetrieveSessionAction("Customer Action Code",ActionOut);
        //+NPR5.40 [306347]
        end;
    end;

    procedure Action_UnlockPOS(var ActionOut: Record "POS Action";POSSession: Codeunit "POS Session") IsConfigured: Boolean
    begin
        //-NPR5.37 [293905]
        Clear(ActionOut);
        InitializeSetup();
        //-NPR5.40 [306347]
        //IsConfigured := ActionOut.GET (ActionCode_UnlockPOS());
        IsConfigured := POSSession.RetrieveSessionAction(ActionCode_UnlockPOS,ActionOut);
        //+NPR5.40 [306347]
        //+NPR5.37 [293905]
    end;

    procedure Action_LockPOS(var ActionOut: Record "POS Action";POSSession: Codeunit "POS Session") IsConfigured: Boolean
    begin
        //-NPR5.37 [293905]
        Clear(ActionOut);
        InitializeSetup();
        //-NPR5.40 [306347]
        //IsConfigured := ActionOut.GET (ActionCode_LockPOS());
        IsConfigured := POSSession.RetrieveSessionAction(ActionCode_LockPOS,ActionOut);
        //+NPR5.40 [306347]
        //+NPR5.37 [293905]
    end;

    procedure ActionCode_Login(): Code[20]
    begin
        with Setup do begin
          InitializeSetup();
          TestField("Login Action Code");
          exit("Login Action Code");
        end;
    end;

    procedure ActionCode_TextEnter(): Code[20]
    begin
        with Setup do begin
          InitializeSetup();
          TestField("Text Enter Action Code");
          exit("Text Enter Action Code");
        end;
    end;

    procedure ActionCode_Item(): Code[20]
    begin
        with Setup do begin
          InitializeSetup();
          TestField("Item Insert Action Code");
          exit("Item Insert Action Code");
        end;
    end;

    procedure ActionCode_Payment(): Code[20]
    begin
        with Setup do begin
          InitializeSetup();
          TestField("Payment Action Code");
          exit("Payment Action Code");
        end;
    end;

    procedure ActionCode_Customer(): Code[20]
    begin
        with Setup do begin
          InitializeSetup();
          TestField("Customer Action Code");
          exit("Customer Action Code");
        end;
    end;

    procedure ActionCode_UnlockPOS(): Code[20]
    begin
        //-NPR5.37 [293905]
        with Setup do begin
          InitializeSetup();
          // This is an optional setup
          // TESTFIELD("Unlock POS Action Code");
          exit("Unlock POS Action Code");
        end;
        //+NPR5.37 [293905]
    end;

    procedure ActionCode_LockPOS(): Code[20]
    begin
        //-NPR5.37 [293905]
        with Setup do begin
          InitializeSetup();
          // This is an optional setup
          // TESTFIELD("lock POS Action Code");
          exit("Lock POS Action Code");
        end;
        //+NPR5.37 [293905]
    end;
}

