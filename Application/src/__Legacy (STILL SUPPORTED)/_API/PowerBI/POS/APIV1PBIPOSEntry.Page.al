page 6059935 "NPR APIV1 PBIPOSEntry"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'posEntry';
    EntitySetName = 'posEntries';
    Caption = 'PowerBI POS Entry';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR POS Entry";
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
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(entryType; Rec."Entry Type")
                {
                    Caption = 'Entry Type', Locked = true;
                }
                field(eventNo; Rec."Event No.")
                {
                    Caption = 'Event No.', Locked = true;
                }
                field(startingTime; Rec."Starting Time")
                {
                    Caption = 'Starting Time', Locked = true;
                }
                field(endingTime; Rec."Ending Time")
                {
                    Caption = 'Ending Time', Locked = true;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date', Locked = true;
                }
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'Document No.', Locked = true;
                }
                field(posStoreCode; Rec."POS Store Code")
                {
                    Caption = 'POS Store Code', Locked = true;
                }
                field(posUnitNo; Rec."POS Unit No.")
                {
                    Caption = 'POS Unit No.', Locked = true;
                }
                field(fiscalNo; Rec."Fiscal No.")
                {
                    Caption = 'Fiscal No.', Locked = true;
                }
                field(posPeriodRegisterNo; Rec."POS Period Register No.")
                {
                    Caption = 'POS Period Register No.', Locked = true;
                }
                field(shortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                    Caption = 'Shortcut Dimension 1 Code', Locked = true;
                }
                field(shortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {
                    Caption = 'Shortcut Dimension 2 Code', Locked = true;
                }
                field(salespersonCode; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson Code', Locked = true;
                }
                field(amountExclTax; Rec."Amount Excl. Tax")
                {
                    Caption = 'Amount Excl. Tax', Locked = true;
                }
                field(amountInclTax; Rec."Amount Incl. Tax")
                {
                    Caption = 'Amount Incl. Tax', Locked = true;
                }
                field(salesDocumentType; Rec."Sales Document Type")
                {
                    Caption = 'Sales Document Type', Locked = true;
                }
                field(salesDocumentNo; Rec."Sales Document No.")
                {
                    Caption = 'Sales Document No.', Locked = true;
                }
                field(lastModifiedDateTime; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt))
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
                }
#if not (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'System Row Version', Locked = true;
                }
#endif
            }
        }
    }
    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
}