page 6059846 "NPR APIV1 - GL Accounts"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'GLAccounts';
    DelayedInsert = true;
    EntityName = 'glAccount';
    EntitySetName = 'glAccounts';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "G/L Account";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                    Editable = false;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                }
                field(no2; Rec."No. 2")
                {
                    Caption = 'No. 2', Locked = true;
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'Display Name', Locked = true;
                }
                field(accountCategory; Rec."Account Category")
                {
                    Caption = 'Account Category', Locked = true;
                }
                field(accountSubcategoryDescript; Rec."Account Subcategory Descript.")
                {
                    Caption = 'Account Subcategory Descript.', Locked = true;
                }
                field(accountSubcategoryEntryNo; Rec."Account Subcategory Entry No.")
                {
                    Caption = 'Account Subcategory Entry No.', Locked = true;
                }
                field(accountType; Rec."Account Type")
                {
                    Caption = 'Account Type', Locked = true;
                }
                field(apiAccountType; Rec."API Account Type")
                {
                    Caption = 'Account Type', Locked = true;
                }
                field(addCurrencyBalanceAtDate; Rec."Add.-Currency Balance at Date")
                {
                    Caption = 'Add.-Currency Balance at Date', Locked = true;
                }
                field(addCurrencyCreditAmount; Rec."Add.-Currency Credit Amount")
                {
                    Caption = 'Add.-Currency Credit Amount', Locked = true;
                }
                field(addCurrencyDebitAmount; Rec."Add.-Currency Debit Amount")
                {
                    Caption = 'Add.-Currency Debit Amount', Locked = true;
                }
                field(additionalCurrencyBalance; Rec."Additional-Currency Balance")
                {
                    Caption = 'Additional-Currency Balance', Locked = true;
                }
                field(additionalCurrencyNetChange; Rec."Additional-Currency Net Change")
                {
                    Caption = 'Additional-Currency Net Change', Locked = true;
                }
                field(automaticExtTexts; Rec."Automatic Ext. Texts")
                {
                    Caption = 'Automatic Ext. Texts', Locked = true;
                }
                field(balance; Rec.Balance)
                {
                    Caption = 'Balance', Locked = true;
                }
                field(balanceAtDate; Rec."Balance at Date")
                {
                    Caption = 'Balance at Date', Locked = true;
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked', Locked = true;
                }
                field(budgetAtDate; Rec."Budget at Date")
                {
                    Caption = 'Budget at Date', Locked = true;
                }
                field(budgetedAmount; Rec."Budgeted Amount")
                {
                    Caption = 'Budgeted Amount', Locked = true;
                }
                field(budgetedCreditAmount; Rec."Budgeted Credit Amount")
                {
                    Caption = 'Budgeted Credit Amount', Locked = true;
                }
                field(budgetedDebitAmount; Rec."Budgeted Debit Amount")
                {
                    Caption = 'Budgeted Debit Amount', Locked = true;
                }
                field(consolCreditAcc; Rec."Consol. Credit Acc.")
                {
                    Caption = 'Consol. Credit Acc.', Locked = true;
                }
                field(consolDebitAcc; Rec."Consol. Debit Acc.")
                {
                    Caption = 'Consol. Debit Acc.', Locked = true;
                }
                field(consolTranslationMethod; Rec."Consol. Translation Method")
                {
                    Caption = 'Consol. Translation Method', Locked = true;
                }
                field(costTypeNo; Rec."Cost Type No.")
                {
                    Caption = 'Cost Type No.', Locked = true;
                }
                field(creditAmount; Rec."Credit Amount")
                {
                    Caption = 'Credit Amount', Locked = true;
                }
                field(debitAmount; Rec."Debit Amount")
                {
                    Caption = 'Debit Amount', Locked = true;
                }
                field(debitCredit; Rec."Debit/Credit")
                {
                    Caption = 'Debit/Credit', Locked = true;
                }
                field(defaultDeferralTemplateCode; Rec."Default Deferral Template Code")
                {
                    Caption = 'Default Deferral Template Code', Locked = true;
                }
                field(defaultIcPartnerGLAccNo; Rec."Default IC Partner G/L Acc. No")
                {
                    Caption = 'Default IC Partner G/L Acc. No', Locked = true;
                }
                field(directPosting; Rec."Direct Posting")
                {
                    Caption = 'Direct Posting', Locked = true;
                }
                field(exchangeRateAdjustment; Rec."Exchange Rate Adjustment")
                {
                    Caption = 'Exchange Rate Adjustment', Locked = true;
                }
                field(genBusPostingGroup; Rec."Gen. Bus. Posting Group")
                {
                    Caption = 'Gen. Bus. Posting Group', Locked = true;
                }
                field(genPostingType; Rec."Gen. Posting Type")
                {
                    Caption = 'Gen. Posting Type', Locked = true;
                }
                field(genProdPostingGroup; Rec."Gen. Prod. Posting Group")
                {
                    Caption = 'Gen. Prod. Posting Group', Locked = true;
                }
                field(globalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    Caption = 'Global Dimension 1 Code', Locked = true;
                }
                field(globalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    Caption = 'Global Dimension 2 Code', Locked = true;
                }
                field(incomeBalance; Rec."Income/Balance")
                {
                    Caption = 'Income/Balance', Locked = true;
                }
                field(indentation; Rec.Indentation)
                {
                    Caption = 'Indentation', Locked = true;
                }
                field(lastDateModified; Rec."Last Date Modified")
                {
                    Caption = 'Last Date Modified', Locked = true;
                }
                field(lastModifiedDateTime2; Rec."Last Modified Date Time")
                {
                    Caption = 'Last Modified Date Time', Locked = true;
                }
                field(nprIsRetailPayment; IsRetailPayment)
                {
                    Caption = 'Retail Payment', Locked = true;
                }
                field(netChange; Rec."Net Change")
                {
                    Caption = 'Net Change', Locked = true;
                }
                field(newPage; Rec."New Page")
                {
                    Caption = 'New Page', Locked = true;
                }
                field(noOfBlankLines; Rec."No. of Blank Lines")
                {
                    Caption = 'No. of Blank Lines', Locked = true;
                }
                field(omitDefaultDescrInJnl; Rec."Omit Default Descr. in Jnl.")
                {
                    Caption = 'Omit Default Descr. in Jnl.', Locked = true;
                }
                field(picture; Rec.Picture)
                {
                    Caption = 'Picture', Locked = true;
                }
                field(reconciliationAccount; Rec."Reconciliation Account")
                {
                    Caption = 'Reconciliation Account', Locked = true;
                }
                field(searchName; Rec."Search Name")
                {
                    Caption = 'Search Name', Locked = true;
                }
                field(taxAreaCode; Rec."Tax Area Code")
                {
                    Caption = 'Tax Area Code', Locked = true;
                }
                field(taxGroupCode; Rec."Tax Group Code")
                {
                    Caption = 'Tax Group Code', Locked = true;
                }
                field(taxLiable; Rec."Tax Liable")
                {
                    Caption = 'Tax Liable', Locked = true;
                }
                field(totaling; Rec.Totaling)
                {
                    Caption = 'Totaling', Locked = true;
                }
                field(vatAmt; Rec."VAT Amt.")
                {
                    Caption = 'VAT Amt.', Locked = true;
                }
                field(vatBusPostingGroup; Rec."VAT Bus. Posting Group")
                {
                    Caption = 'VAT Bus. Posting Group', Locked = true;
                }
                field(vatProdPostingGroup; Rec."VAT Prod. Posting Group")
                {
                    Caption = 'VAT Prod. Posting Group', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
            }
        }
    }
    Var
        IsRetailPayment: Boolean;

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        SetAuxGLAccount();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        SetAuxGLAccount();
    end;

    local procedure SetAuxGLAccount()
    var
        AuxGLAccount: Record "NPR Aux. G/L Account";
    begin
        if not AuxGLAccount.Get(Rec."No.") then begin
            AuxGLAccount."No." := Rec."No.";
            AuxGLAccount.Insert();
        end;
        if AuxGLAccount."Retail Payment" <> IsRetailPayment then begin
            AuxGLAccount."Retail Payment" := IsRetailPayment;
            AuxGLAccount.Modify();
        end;
    end;

}
