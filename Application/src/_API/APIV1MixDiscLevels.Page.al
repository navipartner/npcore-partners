page 6014482 "NPR API V1 - Mix. Disc. Levels"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Mixed Discount Levels';
    DelayedInsert = true;
    EntityName = 'mixedDiscountLevel';
    EntitySetName = 'mixedDiscountLevels';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Mixed Discount Level";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'systemId', Locked = true;
                }
                field(mixedDiscountCode; Rec."Mixed Discount Code")
                {
                    Caption = 'mixedDiscountCode', Locked = true;
                }
                field(discount; Rec."Discount %")
                {
                    Caption = 'discount', Locked = true;
                }
                field(discountAmount; Rec."Discount Amount")
                {
                    Caption = 'discountAmount', Locked = true;
                }
                field(multipleOf; Rec."Multiple Of")
                {
                    Caption = 'multipleOf', Locked = true;
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'quantity', Locked = true;
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'systemModifiedAt', Locked = true;
                }

                field(replicationCounter; Rec."Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }
            }
        }
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

}
