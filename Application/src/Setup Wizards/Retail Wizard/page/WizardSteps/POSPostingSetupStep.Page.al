page 6014688 "NPR POS Posting Setup Step"
{
    Caption = 'POS Posting Setup';
    PageType = ListPart;
    SourceTable = "NPR POS Posting Setup";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Store Code"; POSStoreCode)
                {

                    Caption = 'POS Store Code';
                    Lookup = true;
                    ToolTip = 'Specifies the value of the POSStoreCode field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if POSStoreCode <> '' then
                            if TempAllPOSStore.Get(POSStoreCode) then;

                        if Page.RunModal(Page::"NPR POS Stores Select", TempAllPOSStore) = Action::LookupOK then begin
                            POSStoreCode := TempAllPOSStore.Code;
                            Rec."POS Store Code" := TempAllPOSStore.Code;
                        end;
                    end;
                }
                field("POS Payment Method Code"; POSPaymentMethodCode)
                {

                    Caption = 'POS Payment Method Code';
                    Lookup = true;
                    ToolTip = 'Specifies the value of the POSPaymentMethodCode field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if POSPaymentMethodCode <> '' then
                            if TempAllPOSPaymentMethod.Get(POSPaymentMethodCode) then;

                        if Page.RunModal(Page::"NPR POS Pmt Methods Select", TempAllPOSPaymentMethod) = Action::LookupOK then begin
                            POSPaymentMethodCode := TempAllPOSPaymentMethod.Code;
                            Rec."POS Payment Method Code" := TempAllPOSPaymentMethod.Code;
                        end;
                    end;
                }
                field("POS Payment Bin Code"; POSPaymentBinNo)
                {

                    Caption = 'POS Payment Bin Code';
                    Lookup = true;
                    ToolTip = 'Specifies the value of the POSPaymentBinNo field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if POSPaymentBinNo <> '' then
                            if TempAllPOSPaymentBin.Get(POSPaymentBinNo) then;

                        if Page.RunModal(Page::"NPR POS Payment Bins Select", TempAllPOSPaymentBin) = Action::LookupOK then begin
                            POSPaymentBinNo := TempAllPOSPaymentBin."No.";
                            Rec."POS Payment Bin Code" := TempAllPOSPaymentBin."No.";
                        end;
                    end;
                }
                field("Close to POS Bin No."; CloseToPOSPaymentBinNo)
                {

                    Caption = 'Close to POS Bin No.';
                    Lookup = true;
                    ToolTip = 'Specifies the value of the CloseToPOSPaymentBinNo field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if CloseToPOSPaymentBinNo <> '' then
                            if TempAllPOSPaymentBin.Get(POSPaymentBinNo) then;

                        if Page.RunModal(Page::"NPR POS Payment Bins Select", TempAllPOSPaymentBin) = Action::LookupOK then begin
                            CloseToPOSPaymentBinNo := TempAllPOSPaymentBin."No.";
                            Rec."Close to POS Bin No." := TempAllPOSPaymentBin."No.";
                        end;
                    end;
                }
                field("Account Type"; Rec."Account Type")
                {

                    ToolTip = 'Specifies the value of the Account Type field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec."Account No." := '';
                    end;
                }
                field("Account No."; Rec."Account No.")
                {

                    ToolTip = 'Specifies the value of the Account No. field';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Specifies the value of the Difference Account Type field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec."Difference Acc. No." := '';

                        Rec."Difference Acc. No. (Neg)" := '';
                    end;
                }
                field("Difference Acc. No."; Rec."Difference Acc. No.")
                {

                    ToolTip = 'Specifies the value of the Difference Acc. No. field';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Specifies the value of the Difference Acc. No. (Neg) field';
                    ApplicationArea = NPRRetail;

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
        POSStoreCode: Code[10];
        POSPaymentMethodCode: Code[10];
        POSPaymentBinNo: Code[10];
        CloseToPOSPaymentBinNo: Code[10];


    procedure SetGlobals(var POSStoreCodeAll: Record "NPR POS Store"; var POSPaymentMethodAll: Record "NPR POS Payment Method"; var POSPaymentBinAll: Record "NPR POS Payment Bin")
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

    procedure POSPostingSetupToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    procedure CreatePOSPostingSetupData()
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
}