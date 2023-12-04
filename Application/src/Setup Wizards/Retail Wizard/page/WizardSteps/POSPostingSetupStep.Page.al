page 6014688 "NPR POS Posting Setup Step"
{
    Caption = 'POS Posting Setup';
    DelayedInsert = true;
    Extensible = False;
    PageType = ListPart;
    SourceTable = "NPR POS Posting Setup";
    SourceTableTemporary = true;
    UsageCategory = None;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Store Code"; Rec."POS Store Code")
                {

                    ApplicationArea = NPRRetail;
                    Caption = 'POS Store Code';
                    Lookup = true;
                    ToolTip = 'Specifies the value of the POSStoreCode field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if POSStoreCode <> '' then
                            if POSStore.Get(POSStoreCode) then;

                        if Page.RunModal(Page::"NPR POS Stores Select", POSStore) = Action::LookupOK then begin
                            POSStoreCode := POSStore.Code;
                            Rec."POS Store Code" := POSStore.Code;
                        end;
                    end;
                }
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {

                    ApplicationArea = NPRRetail;
                    Caption = 'POS Payment Method Code';
                    Lookup = true;
                    ToolTip = 'Specifies the value of the POSPaymentMethodCode field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if POSPaymentMethodCode <> '' then
                            if POSPaymentMethod.Get(POSPaymentMethodCode) then;

                        if Page.RunModal(Page::"NPR POS Pmt Methods Select", POSPaymentMethod) = Action::LookupOK then begin
                            POSPaymentMethodCode := POSPaymentMethod.Code;
                            Rec."POS Payment Method Code" := POSPaymentMethod.Code;
                        end;
                    end;
                }
                field("POS Payment Bin Code"; Rec."POS Payment Bin Code")
                {

                    ApplicationArea = NPRRetail;
                    Caption = 'POS Payment Bin Code';
                    Lookup = true;
                    ToolTip = 'Specifies the value of the POSPaymentBinNo field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if POSPaymentBinNo <> '' then
                            if POSPaymentBin.Get(POSPaymentBinNo) then;

                        if Page.RunModal(Page::"NPR POS Payment Bins Select", POSPaymentBin) = Action::LookupOK then begin
                            POSPaymentBinNo := POSPaymentBin."No.";
                            Rec."POS Payment Bin Code" := POSPaymentBin."No.";
                        end;
                    end;
                }
                field("Close to POS Bin No."; Rec."Close to POS Bin No.")
                {

                    ApplicationArea = NPRRetail;
                    Caption = 'Close to POS Bin No.';
                    Lookup = true;
                    ToolTip = 'Specifies the value of the CloseToPOSPaymentBinNo field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if CloseToPOSPaymentBinNo <> '' then
                            if POSPaymentBin.Get(POSPaymentBinNo) then;

                        if Page.RunModal(Page::"NPR POS Payment Bins Select", POSPaymentBin) = Action::LookupOK then begin
                            CloseToPOSPaymentBinNo := POSPaymentBin."No.";
                            Rec."Close to POS Bin No." := POSPaymentBin."No.";
                        end;
                    end;
                }
                field("Account Type"; Rec."Account Type")
                {

                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Account Type field';

                    trigger OnValidate()
                    begin
                        Rec."Account No." := '';
                    end;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Account No. field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Customer: Record Customer;
                        BankAcc: Record "Bank Account";
                        GLAcc: Record "G/L Account";
                        CustomerList: Page "Customer List";
                        BankAccList: Page "Bank Account List";
                        GLAccList: Page "G/L Account List";
                    begin
                        if Rec."Account Type" = Rec."Account Type"::"G/L Account" then begin
                            GLAccList.LookupMode := true;

                            if Rec."Account No." <> '' then
                                if GLAcc.Get(Rec."Account No.") then
                                    GLAccList.SetRecord(GLAcc);

                            if GLAccList.RunModal() = Action::LookupOK then begin
                                GLAccList.GetRecord(GLAcc);
                                Rec."Account No." := GLAcc."No.";
                            end;
                        end;

                        if Rec."Account Type" = Rec."Account Type"::"Bank Account" then begin
                            BankAccList.LookupMode := true;

                            if Rec."Account No." <> '' then
                                if BankAcc.Get(Rec."Account No.") then
                                    BankAccList.SetRecord(BankAcc);

                            if BankAccList.RunModal() = Action::LookupOK then begin
                                BankAccList.GetRecord(BankAcc);
                                Rec."Account No." := BankAcc."No.";
                            end;
                        end;

                        if Rec."Account Type" = Rec."Account Type"::Customer then begin
                            CustomerList.LookupMode := true;

                            if Rec."Account No." <> '' then
                                if Customer.Get(Rec."Account No.") then
                                    CustomerList.SetRecord(Customer);

                            if CustomerList.RunModal() = Action::LookupOK then begin
                                CustomerList.GetRecord(Customer);
                                Rec."Account No." := Customer."No.";
                            end;
                        end;
                    end;
                }
                field("Difference Account Type"; Rec."Difference Account Type")
                {

                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Difference Account Type field';

                    trigger OnValidate()
                    begin
                        Rec."Difference Acc. No." := '';

                        Rec."Difference Acc. No. (Neg)" := '';
                    end;
                }
                field("Difference Acc. No."; Rec."Difference Acc. No.")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Difference Acc. No. (Pos)';
                    ToolTip = 'Specifies the value of the Difference Acc. No. field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Customer: Record Customer;
                        BankAcc: Record "Bank Account";
                        GLAcc: Record "G/L Account";
                        CustomerList: Page "Customer List";
                        BankAccList: Page "Bank Account List";
                        GLAccList: Page "G/L Account List";
                    begin
                        if Rec."Difference Account Type" = Rec."Difference Account Type"::"G/L Account" then begin
                            GLAccList.LookupMode := true;

                            if Rec."Difference Acc. No." <> '' then
                                if GLAcc.Get(Rec."Difference Acc. No.") then
                                    GLAccList.SetRecord(GLAcc);

                            if GLAccList.RunModal() = Action::LookupOK then begin
                                GLAccList.GetRecord(GLAcc);
                                Rec."Difference Acc. No." := GLAcc."No.";
                            end;
                        end;

                        if Rec."Difference Account Type" = Rec."Difference Account Type"::"Bank Account" then begin
                            BankAccList.LookupMode := true;

                            if Rec."Difference Acc. No." <> '' then
                                if BankAcc.Get(Rec."Difference Acc. No.") then
                                    BankAccList.SetRecord(BankAcc);

                            if BankAccList.RunModal() = Action::LookupOK then begin
                                BankAccList.GetRecord(BankAcc);
                                Rec."Difference Acc. No." := BankAcc."No.";
                            end;
                        end;

                        if Rec."Difference Account Type" = Rec."Difference Account Type"::Customer then begin
                            CustomerList.LookupMode := true;

                            if Rec."Difference Acc. No." <> '' then
                                if Customer.Get(Rec."Difference Acc. No.") then
                                    CustomerList.SetRecord(Customer);

                            if CustomerList.RunModal() = Action::LookupOK then begin
                                CustomerList.GetRecord(Customer);
                                Rec."Difference Acc. No." := Customer."No.";
                            end;
                        end;
                    end;
                }
                field("Difference Acc. No. (Neg)"; Rec."Difference Acc. No. (Neg)")
                {

                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Difference Acc. No. (Neg) field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Customer: Record Customer;
                        BankAcc: Record "Bank Account";
                        GLAcc: Record "G/L Account";
                        CustomerList: Page "Customer List";
                        BankAccList: Page "Bank Account List";
                        GLAccList: Page "G/L Account List";
                    begin
                        if Rec."Difference Account Type" = Rec."Difference Account Type"::"G/L Account" then begin
                            GLAccList.LookupMode := true;

                            if Rec."Difference Acc. No. (Neg)" <> '' then
                                if GLAcc.Get(Rec."Difference Acc. No. (Neg)") then
                                    GLAccList.SetRecord(GLAcc);

                            if GLAccList.RunModal() = Action::LookupOK then begin
                                GLAccList.GetRecord(GLAcc);
                                Rec."Difference Acc. No. (Neg)" := GLAcc."No.";
                            end;
                        end;

                        if Rec."Difference Account Type" = Rec."Difference Account Type"::"Bank Account" then begin
                            BankAccList.LookupMode := true;

                            if Rec."Difference Acc. No. (Neg)" <> '' then
                                if BankAcc.Get(Rec."Difference Acc. No. (Neg)") then
                                    BankAccList.SetRecord(BankAcc);

                            if BankAccList.RunModal() = Action::LookupOK then begin
                                BankAccList.GetRecord(BankAcc);
                                Rec."Difference Acc. No. (Neg)" := BankAcc."No.";
                            end;
                        end;

                        if Rec."Difference Account Type" = Rec."Difference Account Type"::Customer then begin
                            CustomerList.LookupMode := true;

                            if Rec."Difference Acc. No. (Neg)" <> '' then
                                if Customer.Get(Rec."Difference Acc. No. (Neg)") then
                                    CustomerList.SetRecord(Customer);

                            if CustomerList.RunModal() = Action::LookupOK then begin
                                CustomerList.GetRecord(Customer);
                                Rec."Difference Acc. No. (Neg)" := Customer."No.";
                            end;
                        end;
                    end;
                }
            }
        }
    }

    var
        TempAllPOSStore: Record "NPR POS Store" temporary;
        TempAllPOSPaymentMethod: Record "NPR POS Payment Method" temporary;
        TempAllPOSPaymentBin: Record "NPR POS Payment Bin" temporary;
        POSStore: Record "NPR POS Store";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSStoreCode: Code[10];
        POSPaymentMethodCode: Code[10];
        POSPaymentBinNo: Code[10];
        CloseToPOSPaymentBinNo: Code[10];


    internal procedure SetGlobals(var POSStoreCodeAll: Record "NPR POS Store"; var POSPaymentMethodAll: Record "NPR POS Payment Method"; var POSPaymentBinAll: Record "NPR POS Payment Bin")
    begin
        TempAllPOSStore.DeleteAll();
        if POSStoreCodeAll.FindSet() then
            repeat
                TempAllPOSStore := POSStoreCodeAll;
                TempAllPOSStore.Insert();
            until POSStoreCodeAll.Next() = 0;
        if TempAllPOSStore.FindSet() then;

        TempAllPOSPaymentMethod.DeleteAll();
        if POSPaymentMethodAll.FindSet() then
            repeat
                TempAllPOSPaymentMethod := POSPaymentMethodAll;
                TempAllPOSPaymentMethod.Insert();
            until POSPaymentMethodAll.Next() = 0;
        if TempAllPOSPaymentMethod.FindSet() then;

        TempAllPOSPaymentBin.DeleteAll();
        if POSPaymentBinAll.FindSet() then
            repeat
                TempAllPOSPaymentBin := POSPaymentBinAll;
                TempAllPOSPaymentBin.Insert();
            until POSPaymentBinAll.Next() = 0;
        if TempAllPOSPaymentBin.FindSet() then;
    end;

    internal procedure POSPostingSetupToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CopyRealToTemp(var DoNotCopy: Boolean)
    var
        POSPostingSetup: Record "NPR POS Posting Setup";
    begin
        if POSPostingSetup.FindSet() then
            repeat
                Rec := POSPostingSetup;
                if not Rec.Insert() then
                    Rec.Modify();
            until POSPostingSetup.Next() = 0;

        DoNotCopy := true;
    end;

    internal procedure CreatePOSPostingSetupData()
    var
        POSPostingSetup: Record "NPR POS Posting Setup";
    begin
        if Rec.FindSet() then
            repeat
                POSPostingSetup := Rec;
                if not POSPostingSetup.Insert() then
                    POSPostingSetup.Modify();
            until Rec.Next() = 0;
    end;

    internal procedure AllAccountNosAreEqual(): Boolean
    var
        TempPOSPostingSetup: Record "NPR POS Posting Setup" temporary;
    begin
        if Rec.IsEmpty() then
            exit(false);
        if Rec.Count() = 1 then
            exit(false);

        TempPOSPostingSetup.Copy(Rec, true);
        TempPOSPostingSetup.FindFirst();
        TempPOSPostingSetup.SetFilter("Account No.", '<>%1', TempPOSPostingSetup."Account No.");
        exit(TempPOSPostingSetup.IsEmpty());
    end;

    internal procedure ApplyValues(AccountType: Option " ","G/L Account","Bank Account",Customer; AccountNo: Code[20]; DifferenceAccountType: Option " ","G/L Account","Bank Account",Customer; DifferenceAccountNo: Code[20]; DifferenceAccountNoNeg: Code[20])
    begin
        if Rec.FindSet() then
            repeat
                if AccountType <> AccountType::" " then begin
                    if AccountType = AccountType::"G/L Account" then
                        Rec.Validate("Account Type", Rec."Account Type"::"G/L Account");
                    if AccountType = AccountType::"Bank Account" then
                        Rec.Validate("Account Type", Rec."Account Type"::"Bank Account");
                    if AccountType = AccountType::Customer then
                        Rec.Validate("Account Type", Rec."Account Type"::Customer);
                end;

                if AccountNo <> '' then
                    Rec.Validate("Account No.", AccountNo);

                if DifferenceAccountType <> DifferenceAccountType::" " then begin
                    if DifferenceAccountType = DifferenceAccountType::"G/L Account" then
                        Rec.Validate("Difference Account Type", Rec."Difference Account Type"::"G/L Account");
                    if DifferenceAccountType = DifferenceAccountType::"Bank Account" then
                        Rec.Validate("Difference Account Type", Rec."Difference Account Type"::"Bank Account");
                    if DifferenceAccountType = DifferenceAccountType::Customer then
                        Rec.Validate("Difference Account Type", Rec."Difference Account Type"::Customer);
                end;
                if DifferenceAccountNo <> '' then
                    Rec.Validate("Difference Acc. No.", DifferenceAccountNo);

                if DifferenceAccountNoNeg <> '' then
                    Rec.Validate("Difference Acc. No. (Neg)", DifferenceAccountNoNeg);

                if (AccountType <> AccountType::" ") or
                   (AccountNo <> '') or
                   (DifferenceAccountType <> DifferenceAccountType::" ") or
                   (DifferenceAccountNo <> '') or
                   (DifferenceAccountNoNeg <> '') then
                    Rec.Modify();
            until Rec.Next() = 0;

        Clear(Rec);
    end;

    internal procedure MandatoryFieldsPopulated(): Boolean
    begin
        if Rec.IsEmpty() then
            exit;

        Rec.FindSet();
        repeat
            if Rec."Account No." = '' then
                exit(false);
        until Rec.Next() = 0;

        exit(true);
    end;
}
