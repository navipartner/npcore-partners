query 6014402 "NPR APIV1 Item Ledg Entry Read"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    EntityName = 'itemLedgerEntry';
    EntitySetName = 'itemLedgerEntries';
    OrderBy = ascending(replicationCounter);
    QueryType = API;
    ReadState = ReadShared;

    elements
    {
        dataitem(itemLedgerEntry; "Item Ledger Entry")
        {
            column(systemId; SystemId)
            {
                Caption = 'systemId', Locked = true;
            }
            column(entryNo; "Entry No.")
            {
                Caption = 'entryNo', Locked = true;
            }
            column(entryType; "Entry Type")
            {
                Caption = 'entryType', Locked = true;
            }
            column(postingDate; "Posting Date")
            {
                Caption = 'postingDate', Locked = true;
            }

            column(documentDate; "Document Date")
            {
                Caption = 'documentDate', Locked = true;
            }
            column(documentType; "Document Type")
            {
                Caption = 'documentType', Locked = true;
            }
            column(documentNo; "Document No.")
            {
                Caption = 'documentNo', Locked = true;
            }
            column(documentLineNo; "Document Line No.")
            {
                Caption = 'documentLineNo', Locked = true;
            }
            column(externalDocumentNo; "External Document No.")
            {
                Caption = 'externalDocumentNo', Locked = true;
            }
            column(itemNo; "Item No.")
            {
                Caption = 'itemNo', Locked = true;
            }
            column(description; Description)
            {
                Caption = 'description', Locked = true;
            }
            column(locationCode; "Location Code")
            {
                Caption = 'locationCode', Locked = true;
            }

            column(countryRegionCode; "Country/Region Code")
            {
                Caption = 'Country/Region Code', Locked = true;
            }
            column(sourceType; "Source Type")
            {
                Caption = 'Source Type', Locked = true;
            }
            column(sourceNo; "Source No.")
            {
                Caption = 'Source No.', Locked = true;
            }
            column(quantity; Quantity)
            {
                Caption = 'quantity', Locked = true;
            }
            column(unitofMeasureCode; "Unit of Measure Code")
            {
                Caption = 'unitofMeasureCode', Locked = true;
            }
            column(qtyperUnitofMeasure; "Qty. per Unit of Measure")
            {
                Caption = 'qtyperUnitofMeasure', Locked = true;
            }
            column(invoicedQuantity; "Invoiced Quantity")
            {
                Caption = 'invoicedQuantity', Locked = true;
            }
            column(remainingQuantity; "Remaining Quantity")
            {
                Caption = 'remainingQuantity', Locked = true;
            }
            column(salesAmountActual; "Sales Amount (Actual)")
            {
                Caption = 'salesAmountActual', Locked = true;
            }
            column(costAmountActual; "Cost Amount (Actual)")
            {
                Caption = 'costAmountActual', Locked = true;
            }
            column(positive; Positive)
            {
                Caption = 'positive', Locked = true;
            }
            column(open; Open)
            {
                Caption = 'open', Locked = true;
            }
            column(orderType; "Order Type")
            {
                Caption = 'orderType', Locked = true;
            }
            column(variantCode; "Variant Code")
            {
                Caption = 'variantCode', Locked = true;
            }
            column(globalDimension1Code; "Global Dimension 1 Code")
            {
                Caption = 'globalDimension1Code', Locked = true;
            }
            column(globalDimension2Code; "Global Dimension 2 Code")
            {
                Caption = 'globalDimension2Code', Locked = true;
            }
            dataitem(auxItemLedgerEntry; "NPR Aux. Item Ledger Entry")
            {
                DataItemLink = "Entry No." = itemLedgerEntry."Entry No.";
                SqlJoinType = InnerJoin;

                column(posUnitNo; "POS Unit No.")
                {
                    Caption = 'POS Unit No.', Locked = true;
                }
                column(salesPersonCode; "Salespers./Purch. Code")
                {
                    Caption = 'Salesperson Code', Locked = true;
                }

                column(auxLastModifiedDateTime; SystemModifiedAt)
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }

                column(auxSystemId; SystemId)
                {
                    Caption = 'auxiliaryEntrySystemId', Locked = true;
                }

                column(replicationCounter; "Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }

            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}
