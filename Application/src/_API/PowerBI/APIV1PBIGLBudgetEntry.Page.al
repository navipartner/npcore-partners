page 6060035 "NPR APIV1 PBIG/L Budget Entry"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'glBudgetEntry';
    EntitySetName = 'glBudgetEntries';
    Caption = 'PowerBI GL Budget Entry';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "G/L Budget Entry";
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
                field(budgetName; Rec."Budget Name")
                {
                    Caption = 'Budget Name', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(glAccountNo; Rec."G/L Account No.")
                {
                    Caption = 'G/L Account No.', Locked = true;
                }
                field("date"; Rec."date")
                {
                    Caption = 'Date', Locked = true;
                }
                field(description; Rec."Description")
                {
                    Caption = 'Description', Locked = true;
                }
                field(amount; Rec."Amount")
                {
                    Caption = 'Amount', Locked = true;
                }
                field(businessUnitCode; Rec."Business Unit Code")
                {
                    Caption = 'Business Unit Code', Locked = true;
                }
                field("userId"; Rec."User Id")
                {
                    Caption = 'User Id', Locked = true;
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
                field(budgetDimension1Code; Rec."Budget Dimension 1 Code")
                {
                    Caption = 'Budget Dimension 1 Code', Locked = true;
                }
                field(budgetDimension2Code; Rec."Budget Dimension 2 Code")
                {
                    Caption = 'Budget Dimension 2 Code', Locked = true;
                }
                field(budgetDimension3Code; Rec."Budget Dimension 3 Code")
                {
                    Caption = 'Budget Dimension 3 Code', Locked = true;
                }
                field(dimensionSetId; Rec."Dimension Set Id")
                {
                    Caption = 'Dimension Set Id', Locked = true;
                }
                field(lastModifiedDateTime; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt))
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        CurrRecordRef: RecordRef;
    begin
        CurrRecordRef.GetTable(Rec);
        PowerBIUtils.UpdateSystemModifiedAtfilter(CurrRecordRef);
    end;

    trigger OnAfterGetRecord()
    begin
        DimMgt.GetShortcutDimensions(Rec."Dimension Set ID", ShortcutDimCode);
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
        ShortcutDimCode: array[8] of Code[20];
}