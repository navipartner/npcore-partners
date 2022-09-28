page 6060027 "NPR APIV1 - Item Substitutions"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'itemSubstitution';
    EntitySetName = 'itemSubstitutions';
    EntityCaption = 'Item Substitution';
    EntitySetCaption = 'Item Substitutions';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Item Substitution";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                    Editable = false;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No', Locked = true;
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant Code', Locked = true;
                }
                field(substituteNo; Rec."Substitute No.")
                {
                    Caption = 'Substitute No.', Locked = true;
                }
                field(substituteVariantCode; Rec."Substitute Variant Code")
                {
                    Caption = 'Substitute Variant Code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(inventory; Rec.Inventory)
                {
                    Caption = 'Inventory', Locked = true;
                }
                field(interchangeable; Rec.Interchangeable)
                {
                    Caption = 'Interchangeable', Locked = true;
                }
                field(condition; Rec.Condition)
                {
                    Caption = 'Condition', Locked = true;
                }
                field(locationFilter; Rec."Location Filter")
                {
                    Caption = 'Location Filter', Locked = true;
                }
                field(type; Rec.Type)
                {
                    Caption = 'Type', Locked = true;
                }
                field(substituteType; Rec."Substitute Type")
                {
                    Caption = 'Substitute Type', Locked = true;
                }
                field(subItemNo; Rec."Sub. Item No.")
                {
                    Caption = 'Sub. Item No.', Locked = true;
                }
                field(relationsLevel; Rec."Relations Level")
                {
                    Caption = 'Relations Level', Locked = true;
                }
                field(quantityAvailableOnShipmentDate; Rec."Quantity Avail. on Shpt. Date")
                {
                    Caption = 'Quantity Available on Shipment Date', Locked = true;
                }
                field(shipmentDate; Rec."Shipment Date")
                {
                    Caption = 'Shipment Date', Locked = true;
                }
                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

}