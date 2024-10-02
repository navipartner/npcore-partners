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
                field(id; Rec.SystemId)
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
                    ObsoleteState = Pending;
                    ObsoleteTag = '2023-06-28';
                    ObsoleteReason = 'Replaced by SystemRowVersion';
                }
#IF NOT (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'systemRowVersion', Locked = true;
                }
#ENDIF
            }
        }
    }

    trigger OnInit()
    begin
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        CurrentTransactionType := TransactionType::Update;
#ELSE
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
    end;

}
