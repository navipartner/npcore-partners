#pragma warning disable AL0432
page 6014524 "NPR APIV1 - Purchase Price"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'PurchasePrice';
    DelayedInsert = true;
    EntityName = 'purchasePrice';
    EntitySetName = 'purchasePrices';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Purchase Price";

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
                field(itemNumber; Rec."Item No.")
                {
                    Caption = 'itemNo', Locked = true;
                }
                field(vendorNumber; Rec."Vendor No.")
                {
                    Caption = 'vendorNo', Locked = true;
                }
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'startingDate', Locked = true;
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'currencyCode', Locked = true;
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'variantCode', Locked = true;
                }
                field(unitofMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'unitofMeasureCode', Locked = true;
                }
                field(minimumQuantity; Rec."Minimum Quantity")
                {
                    Caption = 'minimumQuantity', Locked = true;
                }
                field(directUnitCost; Rec."Direct Unit Cost")
                {
                    Caption = 'directUnitCost', Locked = true;
                }
                field(endingDate; Rec."Ending Date")
                {
                    Caption = 'endingDate', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'systemModifiedAt', Locked = true;
                }

                field(replicationCounter; Rec."NPR Replication Counter")
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

#pragma warning restore
