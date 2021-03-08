report 6014404 "NPR Return Reason Code Stat."
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Return Reason Code Statistics.rdlc';
    Caption = 'Return Reason Code Statistics';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem("Return Reason"; "Return Reason")
        {
            DataItemTableView = SORTING(Code);
            RequestFilterFields = "Code";
            column(ReturnReason_GetFilters; ReturnReasonFilters)
            {
            }
            column(ItemLedgerEntry_GetFilters; ItemLedgerEntryFilters)
            {
            }
            column(PostingDateCaption; PostingDateCaption)
            {
            }
            column(CustomerCaption; CustomerCaption)
            {
            }
            column(BaseUOMCaption; BaseUOMCaption)
            {
            }
            column(CostAmountCaption; CostAmountCaption)
            {
            }
            column(SalesAmountCaption; SalesAmountCaption)
            {
            }
            column(SalesTicketNumberCaption; SalesTicketNumberCaption)
            {
            }
            column(ReturnTypeCaption; ReturnTypeCaption)
            {
            }
            column(PageCaption; PageCaption)
            {
            }
            column(ReportCaption; ReportCaption)
            {
            }
            column(ItemDescriptionCaption; Item.FieldCaption(Description))
            {
            }
            column(Code_ReturnReason; Code)
            {
            }
            column(Description_ReturnReason; Description)
            {
            }
            column(ExistItemLedgEntry; ExistItemLedgEntry)
            {
            }
            dataitem(AuxItemLedgerEntry; "NPR Aux. Item Ledger Entry")
            {
                DataItemLink = "Return Reason Code" = FIELD(Code);
                DataItemTableView = SORTING("Entry No.");
                RequestFilterFields = "Posting Date", "POS Unit No.";

                column(EntryNo_ItemLedgerEntry; "Entry No.")
                {
                }
                column(ItemNo_ItemLedgerEntry; "Item No.")
                {
                    IncludeCaption = true;
                }
                column(ItemDescription; ItemDescription)
                {
                }
                column(PostingDate_ItemLedgerEntry; Format("Posting Date", 0, 1))
                {
                }
                column(ReturnType; ReturnType)
                {
                }
                column(CustomerNo; CustomerNo)
                {
                }
                column(ExternalDocumentNo_ItemLedgerEntry; GlobItemLedgerentry."External Document No.")
                {
                    IncludeCaption = true;
                }
                column(LocationCode_ItemLedgerEntry; "Location Code")
                {
                    IncludeCaption = true;
                }
                column(DocumentNo_ItemLedgerEntry; GlobItemLedgerentry."Document No.")
                {
                }
                column(RegisterNumber_ItemLedgerEntry; "POS Unit No.")
                {
                    IncludeCaption = true;
                }
                column(SalespersonCode_ItemLedgerEntry; "Salespers./Purch. Code")
                {
                    IncludeCaption = true;
                }
                column(UnitofMeasureCode_ItemLedgerEntry; GlobItemLedgerentry."Unit of Measure Code")
                {
                }
                column(Quantity_ItemLedgerEntry; Quantity)
                {
                    IncludeCaption = true;
                }
                column(CostAmount; CostAmount)
                {
                }
                column(SalesAmountActual_ItemLedgerEntry; GlobItemLedgerentry."Sales Amount (Actual)")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    GlobItemLedgerentry.get("Entry No.");
                    GlobItemLedgerentry.CalcFields("Sales Amount (Actual)", "Cost Amount (Expected)", "Cost Amount (Actual)");

                    if Item.Get("Item No.") then
                        ItemDescription := Item.Description;

                    if ("Entry Type" = "Entry Type"::Sale) and (Quantity > 0) then
                        ReturnType := ReturnOrderCaption
                    else
                        ReturnType := Format("Entry Type"::Sale);

                    Clear(CustomerNo);
                    if "Source Type" = "Source Type"::Customer then
                        CustomerNo := "Source No.";

                    CostAmount := GlobItemLedgerentry."Cost Amount (Expected)" + GlobItemLedgerentry."Cost Amount (Actual)";
                end;
            }

            trigger OnAfterGetRecord()
            var
                ItemLedgerEntry: Record "Item Ledger Entry";
            begin

                ExistItemLedgEntry := false;
                ItemLedgerEntry.SetRange("Return Reason Code", Code);
                if ItemLedgerEntry.FindFirst() then
                    ExistItemLedgEntry := true;
            end;
        }
    }

    trigger OnPreReport()
    begin
        if "Return Reason".GetFilters <> '' then
            ReturnReasonFilters := "Return Reason".TableCaption + ' ' + "Return Reason".GetFilters;

        if AuxItemLedgerEntry.GetFilters <> '' then
            ItemLedgerEntryFilters := AuxItemLedgerEntry.TableCaption + ' ' + AuxItemLedgerEntry.GetFilters;
    end;

    var
        Item: Record Item;
        GlobItemLedgerentry: Record "Item Ledger Entry";
        ExistItemLedgEntry: Boolean;
        CostAmount: Decimal;
        BaseUOMCaption: Label 'Base UOM';
        CostAmountCaption: Label 'Cost Amount';
        CustomerCaption: Label 'Customer';
        PageCaption: Label 'Page %1 of %2 ';
        PostingDateCaption: Label 'Posting Date';
        ReturnOrderCaption: Label 'Return Order';
        ReportCaption: Label 'Return Reason Code Statistics';
        SalesAmountCaption: Label 'Sales Amount';
        SalesTicketNumberCaption: Label 'Sales Ticket No.';
        ReturnTypeCaption: Label 'Type';
        CustomerNo: Text;
        ItemDescription: Text;
        ItemLedgerEntryFilters: Text;
        ReturnReasonFilters: Text;
        ReturnType: Text;
}

