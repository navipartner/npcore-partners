page 6014525 "NPR API V1 - Item Reference"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'itemReference';
    DelayedInsert = true;
    EntityName = 'itemReference';
    EntitySetName = 'itemReferences';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Item Reference";

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
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'itemNo', Locked = true;
                }
                field(referenceType; Rec."Reference Type")
                {
                    Caption = 'referenceType', Locked = true;
                }
                field(referenceTypeNo; Rec."Reference Type No.")
                {
                    Caption = 'referenceTypeNo', Locked = true;
                }
                field(referenceNo; Rec."Reference No.")
                {
                    Caption = 'referenceNo', Locked = true;
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'variantCode', Locked = true;
                }
                field(unitofMeasure; Rec."Unit of Measure")
                {
                    Caption = 'unitofMeasure', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'description', Locked = true;
                }
                field(description2; Rec."Description 2")
                {
                    Caption = 'description2', Locked = true;
                }
                field(discontinueBarCode; Rec."Discontinue Bar Code")
                {
                    Caption = 'discontinueBarCode', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
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
