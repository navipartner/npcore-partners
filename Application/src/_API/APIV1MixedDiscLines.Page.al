page 6014483 "NPR API V1 - Mixed Disc. Lines"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'aPIV1MixedDiscLine';
    DelayedInsert = true;
    EntityName = 'mixedDiscountLine';
    EntitySetName = 'mixedDiscountLines';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Mixed Discount Line";

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
                field("code"; Rec.Code)
                {
                    Caption = 'code', Locked = true;
                }
                field(no; Rec."No.")
                {
                    Caption = 'no', Locked = true;
                }
                field(crossReferenceNo; Rec."Cross-Reference No.")
                {
                    Caption = 'crossReferenceNo', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'description', Locked = true;
                }
                field(description2; Rec."Description 2")
                {
                    Caption = 'description2', Locked = true;
                }
                field(discGroupingType; Rec."Disc. Grouping Type")
                {
                    Caption = 'discGroupingType', Locked = true;
                }
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'startingDate', Locked = true;
                }
                field(startingTime; Rec."Starting Time")
                {
                    Caption = 'startingTime', Locked = true;
                }
                field(endingDate; Rec."Ending Date")
                {
                    Caption = 'endingDate', Locked = true;
                }
                field(endingTime; Rec."Ending Time")
                {
                    Caption = 'endingTime', Locked = true;
                }
                field(priority; Rec.Priority)
                {
                    Caption = 'priority', Locked = true;
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'quantity', Locked = true;
                }
                field(status; Rec.Status)
                {
                    Caption = 'status', Locked = true;
                }
                field(unitcost; Rec."Unit cost")
                {
                    Caption = 'unitcost', Locked = true;
                }
                field(unitprice; Rec."Unit price")
                {
                    Caption = 'unitprice', Locked = true;
                }
                field(unitpriceinclVAT; Rec."Unit price incl. VAT")
                {
                    Caption = 'unitpriceinclVAT', Locked = true;
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'variantCode', Locked = true;
                }
                field(vendorItemNo; Rec."Vendor Item No.")
                {
                    Caption = 'vendorItemNo', Locked = true;
                }
                field(vendorNo; Rec."Vendor No.")
                {
                    Caption = 'vendorNo', Locked = true;
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
