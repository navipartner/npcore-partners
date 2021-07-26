page 6014521 "NPR APIV1 - Item UOM"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'itemUnitOfMeasure';
    DelayedInsert = true;
    EntityName = 'itemUnitOfMeasure';
    EntitySetName = 'itemUnitsOfMeasure';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Item Unit of Measure";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }

                field(itemNumber; Rec."Item No.")
                {
                    Caption = 'Item No.';
                }

                field("code"; Rec.Code)
                {
                    Caption = 'Code';
                }

                field(qtyperUnitofMeasure; Rec."Qty. per Unit of Measure")
                {
                    Caption = 'Qty. per Unit of Measure';
                }

                field(length; Rec.Length)
                {
                    Caption = 'Length';
                }

                field(width; Rec.Width)
                {
                    Caption = 'Width';
                }

                field(height; Rec.Height)
                {
                    Caption = 'Height';
                }

                field(cubage; Rec.Cubage)
                {
                    Caption = 'Cubage';
                }

                field(weight; Rec.Weight)
                {
                    Caption = 'Weight';
                }

                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
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
