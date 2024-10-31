page 6059925 "NPR APIV1 PBIGLEntry"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'gLEntry';
    EntitySetName = 'gLEntries';
    Caption = 'PowerBI G/L Entry';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "G/L Entry";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount', Locked = true;
                }
                field(balAccountNo; Rec."Bal. Account No.")
                {
                    Caption = 'Bal. Account No.', Locked = true;
                }
                field(balAccountType; Rec."Bal. Account Type")
                {
                    Caption = 'Bal. Account Type', Locked = true;
                }
                field(creditAmount; Rec."Credit Amount")
                {
                    Caption = 'Credit Amount', Locked = true;
                }
                field(debitAmount; Rec."Debit Amount")
                {
                    Caption = 'Debit Amount', Locked = true;
                }
                field(gLAccountNo; Rec."G/L Account No.")
                {
                    Caption = 'G/L Account No.', Locked = true;
                }
                field(gLAccountName; Rec."G/L Account Name")
                {
                    Caption = 'G/L Account Name', Locked = true;
                }
                field(globalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    Caption = 'Global Dimension 1 Code', Locked = true;
                }
                field(globalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    Caption = 'Global Dimension 2 Code', Locked = true;
                }
                field(shortcutDimension3Code; ShortcutDimCode[3])
                {
                    Caption = 'Shortcut Dimension 3 Code', Locked = true;
                }
                field(shortcutDimension4Code; ShortcutDimCode[4])
                {
                    Caption = 'Shortcut Dimension 4 Code', Locked = true;
                }
                field(shortcutDimension5Code; ShortcutDimCode[5])
                {
                    Caption = 'Shortcut Dimension 5 Code', Locked = true;
                }
                field(shortcutDimension6Code; ShortcutDimCode[6])
                {
                    Caption = 'Shortcut Dimension 6 Code', Locked = true;
                }
                field(shortcutDimension7Code; ShortcutDimCode[7])
                {
                    Caption = 'Shortcut Dimension 7 Code', Locked = true;
                }
                field(shortcutDimension8Code; ShortcutDimCode[8])
                {
                    Caption = 'Shortcut Dimension 8 Code', Locked = true;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date', Locked = true;
                }
                field(sourceNo; Rec."Source No.")
                {
                    Caption = 'Source No.', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(vatAmount; Rec."VAT Amount")
                {
                    Caption = 'VAT Amount', Locked = true;
                }
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'Document No.', Locked = true;
                }
                field(taxGroupCode; Rec."Tax Group Code")
                {
                    Caption = 'Tax Group Code', Locked = true;
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type', Locked = true;
                }
                field(dimensionSetID; Rec."Dimension Set ID")
                {
                    Caption = 'Dimension Set ID', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(lastModifiedDateTime; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt))
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(transactionNo; Rec."Transaction No.")
                {
                    Caption = 'Transaction No.', Locked = true;
                }
                field(sourceCode; Rec."Source Code")
                {
                    Caption = 'Source Code', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
                }
                field(priorYearEntry; Rec."Prior-Year Entry")
                {
                    Caption = 'Prior-Year Entry', Locked = true;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DimMgt.GetShortcutDimensions(Rec."Dimension Set ID", ShortcutDimCode);
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
        ShortcutDimCode: array[8] of Code[20];
}