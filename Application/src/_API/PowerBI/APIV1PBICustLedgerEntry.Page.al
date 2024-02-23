page 6059913 "NPR APIV1 PBICustLedgerEntry"
{
    APIGroup = 'powerbi';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'customerLedgerEntry';
    EntitySetName = 'customerLedgerEntries';
    Caption = 'PowerBI Customer Ledger Entry';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "Cust. Ledger Entry";
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
                field(closedbyAmount; Rec."Closed by Amount")
                {
                    Caption = 'Closed by Amount', Locked = true;
                }
                field(customerno; Rec."Customer No.")
                {
                    Caption = 'Customer No.', Locked = true;
                }
                field(customername; Rec."Customer Name")
                {
                    Caption = 'Customer Name', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(globalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    Caption = 'Global Dimension 1 Code', Locked = true;
                }
                field(globalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    Caption = 'Global Dimension 2 Code', Locked = true;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date', Locked = true;
                }
                field(profitLCY; Rec."Profit (LCY)")
                {
                    Caption = 'Profit (LCY)', Locked = true;
                }
                field(salesLCY; Rec."Sales (LCY)")
                {
                    Caption = 'Sales (LCY)', Locked = true;
                }
                field(closedbyEntryNo; Rec."Closed by Entry No.")
                {
                    Caption = 'Closed by Entry No.', Locked = true;
                }
                field(selltoCustomerNo; Rec."Sell-to Customer No.")
                {
                    Caption = 'Sell-to Customer No.', Locked = true;
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

    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
}