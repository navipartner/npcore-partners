﻿report 6014514 "NPR Retail Journal List"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Retail Journal List.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Retail Journal List';
    PreviewMode = PrintLayout;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Retail Journal Line"; "NPR Retail Journal Line")
        {
            DataItemTableView = SORTING("No.", "Line No.");
            column(ItemNo_RetailJournalLine; "Retail Journal Line"."Item No.")
            {
                IncludeCaption = true;
            }
            column(Description_RetailJournalLine; "Retail Journal Line".Description)
            {
                IncludeCaption = true;
            }
            column(Inventory_RetailJournalLine; "Retail Journal Line".Inventory)
            {
                IncludeCaption = true;
            }
            column(LastDirectCost_RetailJournalLine; "Retail Journal Line"."Last Direct Cost")
            {
                IncludeCaption = true;
            }
            column(UnitPrice_RetailJournalLine; "Retail Journal Line"."Unit Price")
            {
                IncludeCaption = true;
            }
            column(VendorItemNo_RetailJournalLine; "Retail Journal Line"."Vend Item No.")
            {
                IncludeCaption = true;
            }
            column(VendorName_RetailJournalLine; "Retail Journal Line"."Vend Name")
            {
                IncludeCaption = true;
            }
            column(UnitPrice_Item; Item."Unit Price")
            {
            }
            column(QtyOnSalesOrder_Item; Item."Qty. on Sales Order")
            {
            }
            column(QtyOnPurchOrder_Item; Item."Qty. on Purch. Order")
            {
            }
            column(CompanyName; CompanyName)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if not Item.Get("Retail Journal Line"."Item No.") then
                    Clear(Item);
                Item.CalcFields("Qty. on Sales Order", "Qty. on Purch. Order");
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
    }
    labels
    {
        LabelPrintingLine = 'Label Printing Line';
        UnitPriceItemCard = 'Unit Price (Item Card)';
        ReportPageCaption = 'Page';
        QtyOnSalesOrder = 'Qty. on Sales Order';
        QtyOnPurchOrder = 'Qty. on Purch. Order';
    }

    var
        Item: Record Item;
}

