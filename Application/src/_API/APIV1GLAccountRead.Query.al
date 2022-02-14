query 6014406 "NPR APIV1 - G/L Account Read"
{
    Access = Internal;
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    EntityName = 'glAccountRead';
    EntitySetName = 'glAccountsRead';
    OrderBy = ascending(replicationCounter);
    QueryType = API;
    ReadState = ReadShared;

    elements
    {
        dataitem(glAccount; "G/L Account")
        {
            column(id; SystemId)
            {
                Caption = 'Id', Locked = true;
            }
            column(no; "No.")
            {
                Caption = 'No.', Locked = true;
            }
            column(no2; "No. 2")
            {
                Caption = 'No. 2', Locked = true;
            }
            column(displayName; Name)
            {
                Caption = 'Display Name', Locked = true;
            }
            column(accountCategory; "Account Category")
            {
                Caption = 'Account Category', Locked = true;
            }
            column(accountSubcategoryDescript; "Account Subcategory Descript.")
            {
                Caption = 'Account Subcategory Descript.', Locked = true;
            }
            column(accountSubcategoryEntryNo; "Account Subcategory Entry No.")
            {
                Caption = 'Account Subcategory Entry No.', Locked = true;
            }
            column(accountType; "Account Type")
            {
                Caption = 'Account Type', Locked = true;
            }
            column(apiAccountType; "API Account Type")
            {
                Caption = 'Account Type', Locked = true;
            }
            column(addCurrencyBalanceAtDate; "Add.-Currency Balance at Date")
            {
                Caption = 'Add.-Currency Balance at Date', Locked = true;
            }
            column(addCurrencyCreditAmount; "Add.-Currency Credit Amount")
            {
                Caption = 'Add.-Currency Credit Amount', Locked = true;
            }
            column(addCurrencyDebitAmount; "Add.-Currency Debit Amount")
            {
                Caption = 'Add.-Currency Debit Amount', Locked = true;
            }
            column(additionalCurrencyBalance; "Additional-Currency Balance")
            {
                Caption = 'Additional-Currency Balance', Locked = true;
            }
            column(additionalCurrencyNetChange; "Additional-Currency Net Change")
            {
                Caption = 'Additional-Currency Net Change', Locked = true;
            }
            column(automaticExtTexts; "Automatic Ext. Texts")
            {
                Caption = 'Automatic Ext. Texts', Locked = true;
            }
            column(balance; Balance)
            {
                Caption = 'Balance', Locked = true;
            }
            column(balanceAtDate; "Balance at Date")
            {
                Caption = 'Balance at Date', Locked = true;
            }
            column(blocked; Blocked)
            {
                Caption = 'Blocked', Locked = true;
            }
            column(budgetAtDate; "Budget at Date")
            {
                Caption = 'Budget at Date', Locked = true;
            }
            column(budgetedAmount; "Budgeted Amount")
            {
                Caption = 'Budgeted Amount', Locked = true;
            }
            column(budgetedCreditAmount; "Budgeted Credit Amount")
            {
                Caption = 'Budgeted Credit Amount', Locked = true;
            }
            column(budgetedDebitAmount; "Budgeted Debit Amount")
            {
                Caption = 'Budgeted Debit Amount', Locked = true;
            }

            column(consolCreditAcc; "Consol. Credit Acc.")
            {
                Caption = 'Consol. Credit Acc.', Locked = true;
            }
            column(consolDebitAcc; "Consol. Debit Acc.")
            {
                Caption = 'Consol. Debit Acc.', Locked = true;
            }
            column(consolTranslationMethod; "Consol. Translation Method")
            {
                Caption = 'Consol. Translation Method', Locked = true;
            }
            column(costTypeNo; "Cost Type No.")
            {
                Caption = 'Cost Type No.', Locked = true;
            }
            column(creditAmount; "Credit Amount")
            {
                Caption = 'Credit Amount', Locked = true;
            }

            column(debitAmount; "Debit Amount")
            {
                Caption = 'Debit Amount', Locked = true;
            }
            column(debitCredit; "Debit/Credit")
            {
                Caption = 'Debit/Credit', Locked = true;
            }
            column(defaultDeferralTemplateCode; "Default Deferral Template Code")
            {
                Caption = 'Default Deferral Template Code', Locked = true;
            }
            column(defaultIcPartnerGLAccNo; "Default IC Partner G/L Acc. No")
            {
                Caption = 'Default IC Partner G/L Acc. No', Locked = true;
            }
            column(directPosting; "Direct Posting")
            {
                Caption = 'Direct Posting', Locked = true;
            }
            column(exchangeRateAdjustment; "Exchange Rate Adjustment")
            {
                Caption = 'Exchange Rate Adjustment', Locked = true;
            }
            column(genBusPostingGroup; "Gen. Bus. Posting Group")
            {
                Caption = 'Gen. Bus. Posting Group', Locked = true;
            }
            column(genPostingType; "Gen. Posting Type")
            {
                Caption = 'Gen. Posting Type', Locked = true;
            }
            column(genProdPostingGroup; "Gen. Prod. Posting Group")
            {
                Caption = 'Gen. Prod. Posting Group', Locked = true;
            }
            column(globalDimension1Code; "Global Dimension 1 Code")
            {
                Caption = 'Global Dimension 1 Code', Locked = true;
            }
            column(globalDimension2Code; "Global Dimension 2 Code")
            {
                Caption = 'Global Dimension 2 Code', Locked = true;
            }
            column(incomeBalance; "Income/Balance")
            {
                Caption = 'Income/Balance', Locked = true;
            }
            column(indentation; Indentation)
            {
                Caption = 'Indentation', Locked = true;
            }
            column(lastDateModified; "Last Date Modified")
            {
                Caption = 'Last Date Modified', Locked = true;
            }
            column(lastModifiedDateTime2; "Last Modified Date Time")
            {
                Caption = 'Last Modified Date Time', Locked = true;
            }
            column(netChange; "Net Change")
            {
                Caption = 'Net Change', Locked = true;
            }
            column(newPage; "New Page")
            {
                Caption = 'New Page', Locked = true;
            }
            column(noOfBlankLines; "No. of Blank Lines")
            {
                Caption = 'No. of Blank Lines', Locked = true;
            }
            column(omitDefaultDescrInJnl; "Omit Default Descr. in Jnl.")
            {
                Caption = 'Omit Default Descr. in Jnl.', Locked = true;
            }
            column(picture; Picture)
            {
                Caption = 'Picture', Locked = true;
            }
            column(reconciliationAccount; "Reconciliation Account")
            {
                Caption = 'Reconciliation Account', Locked = true;
            }
            column(searchName; "Search Name")
            {
                Caption = 'Search Name', Locked = true;
            }
            column(taxAreaCode; "Tax Area Code")
            {
                Caption = 'Tax Area Code', Locked = true;
            }
            column(taxGroupCode; "Tax Group Code")
            {
                Caption = 'Tax Group Code', Locked = true;
            }
            column(taxLiable; "Tax Liable")
            {
                Caption = 'Tax Liable', Locked = true;
            }
            column(totaling; Totaling)
            {
                Caption = 'Totaling', Locked = true;
            }
            column(vatAmt; "VAT Amt.")
            {
                Caption = 'VAT Amt.', Locked = true;
            }
            column(vatBusPostingGroup; "VAT Bus. Posting Group")
            {
                Caption = 'VAT Bus. Posting Group', Locked = true;
            }
            column(vatProdPostingGroup; "VAT Prod. Posting Group")
            {
                Caption = 'VAT Prod. Posting Group', Locked = true;
            }
            column(lastModifiedDateTime; SystemModifiedAt)
            {
                Caption = 'Last Modified Date', Locked = true;
            }

            dataitem(auxGlAccount; "NPR Aux. G/L Account")
            {
                DataItemLink = "No." = glAccount."No.";
                SqlJoinType = InnerJoin;

                column(retailPayment; "Retail Payment")
                {
                    Caption = 'Retail Payment', Locked = true;
                }

                column(replicationCounter; "Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }
            }
        }
    }
}
