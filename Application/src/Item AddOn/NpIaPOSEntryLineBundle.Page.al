page 6185036 "NPR NpIa POSEntryLineBundle"
{
    Extensible = false;
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR NpIa POSEntryLineBundleId";
    Caption = 'Item AddOn POS Entry Sale Line Bundles';
    CardPageId = "NPR NpIa POSEntryLineBundleCrd";
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(ReferenceNumber; Rec.ReferenceNumber)
                {
                    ToolTip = 'Specifies the value of the Bundle Reference Number field.';
                    ApplicationArea = NPRRetail;
                }
                field(Bundle; Rec.Bundle)
                {
                    ToolTip = 'Specifies the value of the Bundle.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}