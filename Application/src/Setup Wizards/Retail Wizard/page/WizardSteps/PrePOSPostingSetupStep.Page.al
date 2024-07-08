page 6150850 "NPR Pre POS Posting Setup Step"
{
    Caption = 'Pre POS Posting Setup';
    DelayedInsert = true;
    Extensible = False;
    PageType = ListPart;
    SourceTable = "NPR POS Posting Setup";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            group(POSPostingSetupDifferenceGroup)
            {
                Caption = 'POS Posting Setup - Set up Difference';
                InstructionalText = 'Selected values will be applied to all records in setup. If you do not wish to change current setup leave all fields blank.';
            }

            group(AccountTypeGroup)
            {
                Caption = '';
                field(AccountTypeField; _AccountType)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Account Type';
                    OptionCaption = ' ,G/L Account,Bank Account,Customer';
                    ToolTip = 'Specifies the value of the Account Type field';
                }
            }

            group(AccountNoGroup)
            {
                Caption = '';
                field(AccountNoField; _AccountNo)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Account No.';
                    ToolTip = 'Specifies the value of the Account No. field';

                    trigger OnAssistEdit()
                    var
                        BankAcc: Record "Bank Account";
                        Customer: Record Customer;
                        GLAcc: Record "G/L Account";
                        BankAccList: Page "Bank Account List";
                        CustomerList: Page "Customer List";
                        GLAccList: Page "G/L Account List";
                    begin
                        if _AccountType = _AccountType::"G/L Account" then begin
                            GLAccList.LookupMode := true;

                            if _AccountNo <> '' then
                                if GLAcc.Get(_AccountNo) then
                                    GLAccList.SetRecord(GLAcc);

                            if GLAccList.RunModal() = Action::LookupOK then begin
                                GLAccList.GetRecord(GLAcc);
                                _AccountNo := GLAcc."No.";
                            end;
                        end;

                        if _AccountType = _AccountType::"Bank Account" then begin
                            BankAccList.LookupMode := true;

                            if _AccountNo <> '' then
                                if BankAcc.Get(_AccountNo) then
                                    BankAccList.SetRecord(BankAcc);

                            if BankAccList.RunModal() = Action::LookupOK then begin
                                BankAccList.GetRecord(BankAcc);
                                _AccountNo := BankAcc."No.";
                            end;
                        end;

                        if _AccountType = _AccountType::Customer then begin
                            CustomerList.LookupMode := true;

                            if _AccountNo <> '' then
                                if Customer.Get(_AccountNo) then
                                    CustomerList.SetRecord(Customer);

                            if CustomerList.RunModal() = Action::LookupOK then begin
                                CustomerList.GetRecord(Customer);
                                _AccountNo := Customer."No.";
                            end;
                        end;
                    end;
                }
            }
            group(DifferenceAccountTypeGroup)
            {
                Caption = '';
                field(DifferenceAccountTypeField; _DifferenceAccountType)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Difference Account Type';
                    OptionCaption = ' ,G/L Account,Bank Account,Customer';
                    ToolTip = 'Specifies the value of the Difference Account Type field';
                }
            }
            group(DifferenceAccountNoGroup)
            {
                Caption = '';
                field(DifferenceAccountNoField; _DifferenceAccountNo)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Difference Account No. (Pos)';
                    ToolTip = 'Specifies the value of the Difference Account No. field';

                    trigger OnAssistEdit()
                    var
                        BankAcc: Record "Bank Account";
                        Customer: Record Customer;
                        GLAcc: Record "G/L Account";
                        BankAccList: Page "Bank Account List";
                        CustomerList: Page "Customer List";
                        GLAccList: Page "G/L Account List";
                    begin
                        if _DifferenceAccountType = _DifferenceAccountType::"G/L Account" then begin
                            GLAccList.LookupMode := true;

                            if _DifferenceAccountNo <> '' then
                                if GLAcc.Get(_DifferenceAccountNo) then
                                    GLAccList.SetRecord(GLAcc);

                            if GLAccList.RunModal() = Action::LookupOK then begin
                                GLAccList.GetRecord(GLAcc);
                                _DifferenceAccountNo := GLAcc."No.";
                            end;
                        end;

                        if _DifferenceAccountType = _DifferenceAccountType::"Bank Account" then begin
                            BankAccList.LookupMode := true;

                            if _DifferenceAccountNo <> '' then
                                if BankAcc.Get(_DifferenceAccountNo) then
                                    BankAccList.SetRecord(BankAcc);

                            if BankAccList.RunModal() = Action::LookupOK then begin
                                BankAccList.GetRecord(BankAcc);
                                _DifferenceAccountNo := BankAcc."No.";
                            end;
                        end;

                        if _DifferenceAccountType = _DifferenceAccountType::Customer then begin
                            CustomerList.LookupMode := true;

                            if _DifferenceAccountNo <> '' then
                                if Customer.Get(_DifferenceAccountNo) then
                                    CustomerList.SetRecord(Customer);

                            if CustomerList.RunModal() = Action::LookupOK then begin
                                CustomerList.GetRecord(Customer);
                                _DifferenceAccountNo := Customer."No.";
                            end;
                        end;
                    end;
                }
            }
            group(DifferenceAccountNoNegGroup)
            {
                Caption = '';
                field(DifferenceAccountNoNegField; _DifferenceAccountNoNeg)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Difference Account No. (Neg)';
                    ToolTip = 'Specifies the value of the Difference Account No. (Neg) field';

                    trigger OnAssistEdit()
                    var
                        BankAcc: Record "Bank Account";
                        Customer: Record Customer;
                        GLAcc: Record "G/L Account";
                        BankAccList: Page "Bank Account List";
                        CustomerList: Page "Customer List";
                        GLAccList: Page "G/L Account List";
                    begin
                        if _DifferenceAccountType = _DifferenceAccountType::"G/L Account" then begin
                            GLAccList.LookupMode := true;

                            if _DifferenceAccountNoNeg <> '' then
                                if GLAcc.Get(_DifferenceAccountNoNeg) then
                                    GLAccList.SetRecord(GLAcc);

                            if GLAccList.RunModal() = Action::LookupOK then begin
                                GLAccList.GetRecord(GLAcc);
                                _DifferenceAccountNoNeg := GLAcc."No.";
                            end;
                        end;

                        if _DifferenceAccountType = _DifferenceAccountType::"Bank Account" then begin
                            BankAccList.LookupMode := true;

                            if _DifferenceAccountNoNeg <> '' then
                                if BankAcc.Get(_DifferenceAccountNoNeg) then
                                    BankAccList.SetRecord(BankAcc);

                            if BankAccList.RunModal() = Action::LookupOK then begin
                                BankAccList.GetRecord(BankAcc);
                                _DifferenceAccountNoNeg := BankAcc."No.";
                            end;
                        end;

                        if _DifferenceAccountType = _DifferenceAccountType::Customer then begin
                            CustomerList.LookupMode := true;

                            if _DifferenceAccountNoNeg <> '' then
                                if Customer.Get(_DifferenceAccountNoNeg) then
                                    CustomerList.SetRecord(Customer);

                            if CustomerList.RunModal() = Action::LookupOK then begin
                                CustomerList.GetRecord(Customer);
                                _DifferenceAccountNoNeg := Customer."No.";
                            end;
                        end;
                    end;
                }
            }
        }
    }

    var
        _AccountNo: Code[20];
        _DifferenceAccountNo: Code[20];
        _DifferenceAccountNoNeg: Code[20];
        _AccountType: Option " ","G/L Account","Bank Account",Customer;
        _DifferenceAccountType: Option " ","G/L Account","Bank Account",Customer;

    internal procedure POSPostingSetupToCreate(): Boolean
    begin
        exit(Rec.FindSet());
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

    internal procedure GetGlobals(var AccountType: Option " ","G/L Account","Bank Account",Customer; var AccountNo: Code[20]; var DiffAccountType: Option " ","G/L Account","Bank Account",Customer; var DiffAccountNo: Code[20]; var DiffAccountNoNeg: Code[20])
    begin
        AccountType := _AccountType;
        AccountNo := _AccountNo;
        DiffAccountType := _DifferenceAccountType;
        DiffAccountNo := _DifferenceAccountNo;
        DiffAccountNoNeg := _DifferenceAccountNoNeg;
    end;
}
