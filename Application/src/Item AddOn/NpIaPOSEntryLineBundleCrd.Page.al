page 6185037 "NPR NpIa POSEntryLineBundleCrd"
{
    Extensible = false;
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR NpIa POSEntryLineBundleId";
    Caption = 'Item AddOn POS Entry Sale Line Bundle';
    DataCaptionExpression = '';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'Bundle Identifier';
                field(ReferenceNumber; Rec.ReferenceNumber)
                {
                    ToolTip = 'Specifies the value of the Bundle Reference Number field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(Bundle; Rec.Bundle)
                {
                    ToolTip = 'Specifies the value of the Bundle field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }

            }
            part(PartName; "NPR NpIa POSEntryLineBundlePrt")
            {
                Caption = 'Bundle Assets';
                ApplicationArea = NPRRetail;
                SubPageLink = AppliesToSaleLineId = field(POSEntrySaleLineId), Bundle = FIELD(Bundle);
            }
        }

    }


}