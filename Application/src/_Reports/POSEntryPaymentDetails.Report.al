report 6014423 "NPR POS Entry Payment Details"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/POS Entry Payment Details.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'POS Entry Payment Details';
    PreviewMode = PrintLayout;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(POS_Entry; "NPR POS Entry")
        {
            DataItemTableView = SORTING("Entry No.") where("Entry Type" = filter("Direct Sale" | "Credit Sale"));
            RequestFilterFields = "Entry No.", "POS Store Code", "POS Unit No.", "Document Date";
            column(EntryNo_POS_Entry; "Entry No.")
            {
            }
            column(POSStoreCode_POS_Entry; "POS Store Code")
            {
                IncludeCaption = true;
            }
            column(POSUnitNo_POS_Entry; "POS Unit No.")
            {
                IncludeCaption = true;
            }
            column(DocumentNo_POS_Entry; "Document No.")
            {
                IncludeCaption = true;
            }
            column(EntryDate_POS_Entry; format("Entry Date"))
            {
            }
            dataitem(NPRPOSEntryPaymentLine; "NPR POS Entry Payment Line")
            {
                DataItemLink = "POS Entry No." = FIELD("Entry No.");
                RequestFilterFields = "Document No.", "POS Payment Method Code";

                column(POSPaymentMethodCode_POS_EntryPaymentLine; "POS Payment Method Code")
                {
                    IncludeCaption = true;
                }
                column(CurrencyCode_POS_EntryPaymentLine; "Currency Code")
                {
                    IncludeCaption = true;
                }
                column(AmountSalesCurrency_POS_EntryPaymentLine; "Amount")
                {
                    IncludeCaption = true;
                }
                column(AmountLCY_POS_EntryPaymentLine; "Amount (LCY)")
                {
                    IncludeCaption = true;
                }
            }
            trigger OnPreDataItem()
            begin
                POS_Entry."System Entry" := false;
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
    labels
    {
        PageLabel = 'Page %1 of %2';
        TotalLabel = 'Total';
        EntryPaymentDetailsLabel = 'POS Entry Payment Details';
        EntryDateLabel = 'Entry Date';

    }
}
