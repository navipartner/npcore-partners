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
                    Caption = 'Id', Locked = true;
                    Editable = false;
                }

                field(itemNumber; Rec."Item No.")
                {
                    Caption = 'Item No.', Locked = true;
                }

                field("code"; Rec.Code)
                {
                    Caption = 'Code', Locked = true;
                }

                field(qtyperUnitofMeasure; Rec."Qty. per Unit of Measure")
                {
                    Caption = 'Qty. per Unit of Measure', Locked = true;
                }

                field(length; Rec.Length)
                {
                    Caption = 'Length', Locked = true;
                }

                field(width; Rec.Width)
                {
                    Caption = 'Width', Locked = true;
                }

                field(height; Rec.Height)
                {
                    Caption = 'Height', Locked = true;
                }

                field(cubage; Rec.Cubage)
                {
                    Caption = 'Cubage', Locked = true;
                }

                field(weight; Rec.Weight)
                {
                    Caption = 'Weight', Locked = true;
                }

                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date', Locked = true;
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
