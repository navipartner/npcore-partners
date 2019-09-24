report 6014404 "Return Reason Code Statistics"
{
    // NPR5.31/JLK /20170314  CASE 260767 Object created
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Return Reason Code Statistics.rdlc';

    Caption = 'Return Reason Code Statistics';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Return Reason";"Return Reason")
        {
            DataItemTableView = SORTING(Code);
            RequestFilterFields = "Code";
            column(ReturnReason_GetFilters;ReturnReasonFilters)
            {
            }
            column(ItemLedgerEntry_GetFilters;ItemLedgerEntryFilters)
            {
            }
            column(PostingDateCaption;PostingDateCaption)
            {
            }
            column(CustomerCaption;CustomerCaption)
            {
            }
            column(BaseUOMCaption;BaseUOMCaption)
            {
            }
            column(CostAmountCaption;CostAmountCaption)
            {
            }
            column(SalesAmountCaption;SalesAmountCaption)
            {
            }
            column(SalesTicketNumberCaption;SalesTicketNumberCaption)
            {
            }
            column(ReturnTypeCaption;ReturnTypeCaption)
            {
            }
            column(PageCaption;PageCaption)
            {
            }
            column(ReportCaption;ReportCaption)
            {
            }
            column(ItemDescriptionCaption;Item.FieldCaption(Description))
            {
            }
            column(Code_ReturnReason;Code)
            {
            }
            column(Description_ReturnReason;Description)
            {
            }
            column(ExistItemLedgEntry;ExistItemLedgEntry)
            {
            }
            dataitem("Item Ledger Entry";"Item Ledger Entry")
            {
                DataItemLink = "Return Reason Code"=FIELD(Code);
                DataItemTableView = SORTING("Entry No.");
                RequestFilterFields = "Posting Date","Register Number";
                column(EntryNo_ItemLedgerEntry;"Entry No.")
                {
                }
                column(ItemNo_ItemLedgerEntry;"Item No.")
                {
                    IncludeCaption = true;
                }
                column(ItemDescription;ItemDescription)
                {
                }
                column(PostingDate_ItemLedgerEntry;Format("Posting Date",0,1))
                {
                }
                column(ReturnType;ReturnType)
                {
                }
                column(CustomerNo;CustomerNo)
                {
                }
                column(ExternalDocumentNo_ItemLedgerEntry;"External Document No.")
                {
                    IncludeCaption = true;
                }
                column(LocationCode_ItemLedgerEntry;"Location Code")
                {
                    IncludeCaption = true;
                }
                column(DocumentNo_ItemLedgerEntry;"Document No.")
                {
                }
                column(RegisterNumber_ItemLedgerEntry;"Register Number")
                {
                    IncludeCaption = true;
                }
                column(SalespersonCode_ItemLedgerEntry;"Salesperson Code")
                {
                    IncludeCaption = true;
                }
                column(UnitofMeasureCode_ItemLedgerEntry;"Unit of Measure Code")
                {
                }
                column(Quantity_ItemLedgerEntry;Quantity)
                {
                    IncludeCaption = true;
                }
                column(CostAmount;CostAmount)
                {
                }
                column(SalesAmountActual_ItemLedgerEntry;"Sales Amount (Actual)")
                {
                }

                trigger OnAfterGetRecord()
                begin

                    CalcFields("Sales Amount (Actual)","Cost Amount (Expected)","Cost Amount (Actual)");

                    if Item.Get("Item No.") then
                      ItemDescription := Item.Description;

                    if ("Entry Type" = "Entry Type"::Sale) and (Quantity > 0) then
                      ReturnType := ReturnOrderCaption
                    else
                      ReturnType := Format("Entry Type"::Sale);

                    Clear(CustomerNo);
                    if "Source Type" = "Source Type"::Customer then
                      CustomerNo := "Source No.";

                    CostAmount := "Cost Amount (Expected)" + "Cost Amount (Actual)";
                end;
            }

            trigger OnAfterGetRecord()
            var
                ItemLedgerEntry: Record "Item Ledger Entry";
            begin

                ExistItemLedgEntry := false;
                ItemLedgerEntry.SetRange("Return Reason Code",Code);
                if ItemLedgerEntry.FindFirst then
                  ExistItemLedgEntry := true;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin

        if "Return Reason".GetFilters <> '' then
          ReturnReasonFilters := "Return Reason".TableCaption + ' ' + "Return Reason".GetFilters;

        if "Item Ledger Entry".GetFilters <> '' then
          ItemLedgerEntryFilters := "Item Ledger Entry".TableCaption + ' ' + "Item Ledger Entry".GetFilters;
    end;

    var
        ReturnType: Text;
        CustomerNo: Text;
        CostAmount: Decimal;
        ReturnOrderCaption: Label 'Return Order';
        ItemDescription: Text;
        Item: Record Item;
        ReturnTypeCaption: Label 'Type';
        SalesTicketNumberCaption: Label 'Sales Ticket No.';
        PostingDateCaption: Label 'Posting Date';
        CustomerCaption: Label 'Customer';
        BaseUOMCaption: Label 'Base UOM';
        CostAmountCaption: Label 'Cost Amount';
        SalesAmountCaption: Label 'Sales Amount';
        PageCaption: Label 'Page %1 of %2 ';
        ReportCaption: Label 'Return Reason Code Statistics';
        ReturnReasonFilters: Text;
        ItemLedgerEntryFilters: Text;
        ExistItemLedgEntry: Boolean;
}

