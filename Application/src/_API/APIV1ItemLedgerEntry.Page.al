page 6014517 "NPR APIV1 - Item Ledger Entry"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'itemLedgerEntry';
    DelayedInsert = true;
    EntityName = 'itemLedgerEntry';
    EntitySetName = 'itemLedgerEntries';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Item Ledger Entry";

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
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'entryNo', Locked = true;
                }
                field(entryType; Rec."Entry Type")
                {
                    Caption = 'entryType', Locked = true;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'postingDate', Locked = true;
                }
                field(documentDate; Rec."Document Date")
                {
                    Caption = 'documentDate', Locked = true;
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'documentType', Locked = true;
                }
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'documentNo', Locked = true;
                }
                field(documentLineNo; Rec."Document Line No.")
                {
                    Caption = 'documentLineNo', Locked = true;
                }
                field(externalDocumentNo; Rec."External Document No.")
                {
                    Caption = 'externalDocumentNo', Locked = true;
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'itemNo', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'description', Locked = true;
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'locationCode', Locked = true;
                }

                field(countryRegionCode; Rec."Country/Region Code")
                {
                    Caption = 'Country/Region Code', Locked = true;
                }
                field(sourceType; Rec."Source Type")
                {
                    Caption = 'Source Type', Locked = true;
                }
                field(sourceNo; Rec."Source No.")
                {
                    Caption = 'Source No.', Locked = true;
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'quantity', Locked = true;
                }
                field(unitofMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'unitofMeasureCode', Locked = true;
                }
                field(qtyperUnitofMeasure; Rec."Qty. per Unit of Measure")
                {
                    Caption = 'qtyperUnitofMeasure', Locked = true;
                }
                field(invoicedQuantity; Rec."Invoiced Quantity")
                {
                    Caption = 'invoicedQuantity', Locked = true;
                }
                field(remainingQuantity; Rec."Remaining Quantity")
                {
                    Caption = 'remainingQuantity', Locked = true;
                }
                field(salesAmountActual; Rec."Sales Amount (Actual)")
                {
                    Caption = 'salesAmountActual', Locked = true;
                }
                field(costAmountActual; Rec."Cost Amount (Actual)")
                {
                    Caption = 'costAmountActual', Locked = true;
                }
                field(positive; Rec.Positive)
                {
                    Caption = 'positive', Locked = true;
                }
                field(open; Rec.Open)
                {
                    Caption = 'open', Locked = true;
                }
                field(orderType; Rec."Order Type")
                {
                    Caption = 'orderType', Locked = true;
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'variantCode', Locked = true;
                }
                field(globalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    Caption = 'globalDimension1Code', Locked = true;
                }
                field(globalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    Caption = 'globalDimension2Code', Locked = true;
                }

                field(posUnitNo; NPRAuxILE."POS Unit No.")
                {
                    Caption = 'POS Unit No.', Locked = true;
                }

                field(salesPersonCode; NPRAuxILE."Salespers./Purch. Code")
                {
                    Caption = 'Salesperson Code', Locked = true;
                }

                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }

                field(replicationCounter; NPRAuxILE."Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }

            }
        }

    }

    var
        NPRAuxILE: Record "NPR Aux. Item Ledger Entry";

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

    trigger OnAfterGetRecord()
    var
    begin
        IF NPRAuxILE.Get(REc."Entry No.") then;

    end;

}
