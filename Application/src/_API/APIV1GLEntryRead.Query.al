query 6014403 "NPR APIV1 - G/L Entry Read"
{
    Access = Internal;
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    EntityName = 'glEntry';
    EntitySetName = 'glEntries';
    OrderBy = ascending(replicationCounter);
    QueryType = API;
    ReadState = ReadShared;

    elements
    {
        dataitem(gLEntry; "G/L Entry")
        {
            column(systemId; SystemId)
            {
                Caption = 'SystemId', Locked = true;
            }
            column(entryNo; "Entry No.")
            {
                Caption = 'Entry No.', Locked = true;
            }
            column(transactionNo; "Transaction No.")
            {
                Caption = 'Transaction No.', Locked = true;
            }
            column(documentType; "Document Type")
            {
                Caption = 'Document Type', Locked = true;
            }
            column(documentNo; "Document No.")
            {
                Caption = 'Document No.', Locked = true;
            }
            column(documentDate; "Document Date")
            {
                Caption = 'Document Date', Locked = true;
            }
            column(postingDate; "Posting Date")
            {
                Caption = 'Posting Date', Locked = true;
            }
            column(description; Description)
            {
                Caption = 'Description', Locked = true;
            }
            column(amount; Amount)
            {
                Caption = 'Amount', Locked = true;
            }
            column(debitAmount; "Debit Amount")
            {
                Caption = 'Debit Amount', Locked = true;
            }
            column(creditAmount; "Credit Amount")
            {
                Caption = 'Credit Amount', Locked = true;
            }
            column(balAccountType; "Bal. Account Type")
            {
                Caption = 'Bal. Account Type', Locked = true;
            }
            column(balAccountNo; "Bal. Account No.")
            {
                Caption = 'Bal. Account No.', Locked = true;
            }
            column(gLAccountNo; "G/L Account No.")
            {
                Caption = 'G/L Account No.', Locked = true;
            }
            column(gLAccountName; "G/L Account Name")
            {
                Caption = 'G/L Account Name', Locked = true;
            }
            column(quantity; Quantity)
            {
                Caption = 'Quantity', Locked = true;
            }
            column(externalDocumentNo; "External Document No.")
            {
                Caption = 'External Document No.', Locked = true;
            }
            column(dimensionSetID; "Dimension Set ID")
            {
                Caption = 'Dimension Set ID', Locked = true;
            }
            column(globalDimension1Code; "Global Dimension 1 Code")
            {
                Caption = 'Global Dimension 1 Code', Locked = true;
            }
            column(globalDimension2Code; "Global Dimension 2 Code")
            {
                Caption = 'Global Dimension 2 Code', Locked = true;
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
            column(jobNo; "Job No.")
            {
                Caption = 'Job No.', Locked = true;
            }
            column(sourceCode; "Source Code")
            {
                Caption = 'Source Code', Locked = true;
            }
            column(sourceNo; "Source No.")
            {
                Caption = 'Source No.', Locked = true;
            }
            column(sourceType; "Source Type")
            {
                Caption = 'Source Type', Locked = true;
            }
            column(reasonCode; "Reason Code")
            {
                Caption = 'Reason Code', Locked = true;
            }
            column(noSeries; "No. Series")
            {
                Caption = 'No. Series', Locked = true;
            }
            column(journalBatchName; "Journal Batch Name")
            {
                Caption = 'Journal Batch Name', Locked = true;
            }
            column(vatBusPostingGroup; "VAT Bus. Posting Group")
            {
                Caption = 'VAT Bus. Posting Group', Locked = true;
            }
            column(vatProdPostingGroup; "VAT Prod. Posting Group")
            {
                Caption = 'VAT Prod. Posting Group', Locked = true;
            }
            column(vatAmount; "VAT Amount")
            {
                Caption = 'VAT Amount', Locked = true;
            }
            column(useTax; "Use Tax")
            {
                Caption = 'Use Tax', Locked = true;
            }
            column(taxGroupCode; "Tax Group Code")
            {
                Caption = 'Tax Group Code', Locked = true;
            }
            column(taxLiable; "Tax Liable")
            {
                Caption = 'Tax Liable', Locked = true;
            }
            column(taxAreaCode; "Tax Area Code")
            {
                Caption = 'Tax Area Code', Locked = true;
            }
            column(icPartnerCode; "IC Partner Code")
            {
                Caption = 'IC Partner Code', Locked = true;
            }
            column(faEntryNo; "FA Entry No.")
            {
                Caption = 'FA Entry No.', Locked = true;
            }
            column(faEntryType; "FA Entry Type")
            {
                Caption = 'FA Entry Type', Locked = true;
            }
            column(accountId; "Account Id")
            {
                Caption = 'Account Id', Locked = true;
            }
            column(addCurrencyCreditAmount; "Add.-Currency Credit Amount")
            {
                Caption = 'Add.-Currency Credit Amount', Locked = true;
            }
            column(addCurrencyDebitAmount; "Add.-Currency Debit Amount")
            {
                Caption = 'Add.-Currency Debit Amount', Locked = true;
            }
            column(additionalCurrencyAmount; "Additional-Currency Amount")
            {
                Caption = 'Additional-Currency Amount', Locked = true;
            }
            column(businessUnitCode; "Business Unit Code")
            {
                Caption = 'Business Unit Code', Locked = true;
            }
            column(closeIncomeStatementDimID; "Close Income Statement Dim. ID")
            {
                Caption = 'Close Income Statement Dim. ID', Locked = true;
            }
            column(prodOrderNo; "Prod. Order No.")
            {
                Caption = 'Prod. Order No.', Locked = true;
            }
            column(priorYearEntry; "Prior-Year Entry")
            {
                Caption = 'Prior-Year Entry', Locked = true;
            }
            column(reversed; Reversed)
            {
                Caption = 'Reversed', Locked = true;
            }
            column(reversedEntryNo; "Reversed Entry No.")
            {
                Caption = 'Reversed Entry No.', Locked = true;
            }
            column(reversedByEntryNo; "Reversed by Entry No.")
            {
                Caption = 'Reversed by Entry No.', Locked = true;
            }
            column("userID"; "User ID")
            {
                Caption = 'User ID', Locked = true;
            }
            column(systemModifiedAt; SystemModifiedAt)
            {
                Caption = 'SystemModifiedAt', Locked = true;
            }

            dataitem(auxGLEntry; "NPR Aux. G/L Entry")
            {
                DataItemLink = "Entry No." = gLEntry."Entry No.";
                SqlJoinType = InnerJoin;
                column(auxSystemId; SystemId)
                {
                    Caption = 'auxiliaryEntrySystemId', Locked = true;
                }
                column(replicationCounter; "Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}
