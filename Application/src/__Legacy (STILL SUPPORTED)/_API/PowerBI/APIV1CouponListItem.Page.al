page 6150844 "NPR APIV1 Coupon List Item"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'couponlistitem';
    EntitySetName = 'couponlistitems';
    Caption = 'PowerBI Coupon List Item';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    Extensible = false;
    Editable = false;
    SourceTable = "NPR NpDc Coupon List Item";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(applyDiscount; Rec."Apply Discount")
                {
                    Caption = 'Apply Discount';
                }
                field(couponType; Rec."Coupon Type")
                {
                    Caption = 'Coupon Type';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Item Description';
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.';
                }
                field(lotValidation; Rec."Lot Validation")
                {
                    Caption = 'Lot Validation';
                }
                field(maxDiscountAmount; Rec."Max. Discount Amount")
                {
                    Caption = 'Max. Discount Amount per Coupon';
                }
                field(maxQuantity; Rec."Max. Quantity")
                {
                    Caption = 'Max. Quantity per Coupon';
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(priority; Rec.Priority)
                {
                    Caption = 'Priority';
                }
                field(profit; Rec."Profit %")
                {
                    Caption = 'Profit %';
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'SystemCreatedAt';
                }
                field(systemCreatedBy; Rec.SystemCreatedBy)
                {
                    Caption = 'SystemCreatedBy';
                }
                field(systemId; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'SystemModifiedAt';
                }
                field(systemModifiedBy; Rec.SystemModifiedBy)
                {
                    Caption = 'SystemModifiedBy';
                }
                field(type; Rec."Type")
                {
                    Caption = 'Type';
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price';
                }
                field(validationQuantity; Rec."Validation Quantity")
                {
                    Caption = 'Validation Quantity';
                }
            }
        }
    }
}
