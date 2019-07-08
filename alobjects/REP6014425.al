report 6014425 "List of Status Phase"
{
    // NPR5.41/JLK /20180419  CASE 301928 Object created
    DefaultLayout = RDLC;
    RDLCLayout = './List of Status Phase.rdlc';

    Caption = 'List of Status Phase';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Stock-Take Worksheet";"Stock-Take Worksheet")
        {
            DataItemTableView = SORTING("Stock-Take Config Code",Name);
            RequestFilterFields = "Stock-Take Config Code",Name,"Global Dimension 1 Code Filter";
            column(StockTakeConfigCode_StockTakeWorksheet;"Stock-Take Config Code")
            {
                IncludeCaption = true;
            }
            column(Name_StockTakeWorksheet;Name)
            {
                IncludeCaption = true;
            }
            column(Description_StockTakeWorksheet;Description)
            {
                IncludeCaption = true;
            }
            column(Status_StockTakeWorksheet;Status)
            {
                IncludeCaption = true;
            }
            column(ItemGroupFilter_StockTakeWorksheet;"Item Group Filter")
            {
                IncludeCaption = true;
            }
            column(VendorCodeFilter_StockTakeWorksheet;"Vendor Code Filter")
            {
                IncludeCaption = true;
            }
            column(GlobalDimension1CodeFilter_StockTakeWorksheet;"Global Dimension 1 Code Filter")
            {
                IncludeCaption = true;
            }
            column(GlobalDimension2CodeFilter_StockTakeWorksheet;"Global Dimension 2 Code Filter")
            {
                IncludeCaption = true;
            }
            column(AllowUserModification_StockTakeWorksheet;"Allow User Modification")
            {
                IncludeCaption = true;
            }
            column(ConfCalcDate_StockTakeWorksheet;"Conf Calc. Date")
            {
                IncludeCaption = true;
            }
            column(ConfLocationCode_StockTakeWorksheet;"Conf Location Code")
            {
                IncludeCaption = true;
            }
            column(ConfItemGroupFilter_StockTakeWorksheet;"Conf Item Group Filter")
            {
                IncludeCaption = true;
            }
            column(ConfVendorCodeFilter_StockTakeWorksheet;"Conf Vendor Code Filter")
            {
                IncludeCaption = true;
            }
            column(ConfGlobalDim1CodeFilter_StockTakeWorksheet;"Conf Global Dim. 1 Code Filter")
            {
                IncludeCaption = true;
            }
            column(ConfGlobalDim2CodeFilter_StockTakeWorksheet;"Conf Global Dim. 2 Code Filter")
            {
                IncludeCaption = true;
            }
            column(ConfStockTakeMethod_StockTakeWorksheet;"Conf Stock Take Method")
            {
                IncludeCaption = true;
            }
            column(ConfAdjustmentMethod_StockTakeWorksheet;"Conf Adjustment Method")
            {
                IncludeCaption = true;
            }
            dataitem("Stock-Take Worksheet Line";"Stock-Take Worksheet Line")
            {
                DataItemLink = "Stock-Take Config Code"=FIELD("Stock-Take Config Code"),"Worksheet Name"=FIELD(Name);
                DataItemTableView = SORTING("Stock-Take Config Code","Worksheet Name","Line No.");
                column(StockTakeConfigCode_StockTakeWorksheetLine;"Stock-Take Config Code")
                {
                    IncludeCaption = true;
                }
                column(WorksheetName_StockTakeWorksheetLine;"Worksheet Name")
                {
                    IncludeCaption = true;
                }
                column(LineNo_StockTakeWorksheetLine;"Line No.")
                {
                    IncludeCaption = true;
                }
                column(Barcode_StockTakeWorksheetLine;Barcode)
                {
                    IncludeCaption = true;
                }
                column(ItemNo_StockTakeWorksheetLine;"Item No.")
                {
                    IncludeCaption = true;
                }
                column(VariantCode_StockTakeWorksheetLine;"Variant Code")
                {
                    IncludeCaption = true;
                }
                column(QtyCounted_StockTakeWorksheetLine;"Qty. (Counted)")
                {
                    IncludeCaption = true;
                }
                column(UnitCost_StockTakeWorksheetLine;"Unit Cost")
                {
                    IncludeCaption = true;
                }
                column(DateofInventory_StockTakeWorksheetLine;"Date of Inventory")
                {
                    IncludeCaption = true;
                }
                column(Blocked_StockTakeWorksheetLine;Blocked)
                {
                    IncludeCaption = true;
                }
                column(RequireVariantCode_StockTakeWorksheetLine;"Require Variant Code")
                {
                    IncludeCaption = true;
                }
                column(ShelfNo_StockTakeWorksheetLine;"Shelf  No.")
                {
                    IncludeCaption = true;
                }
                column(ShortcutDimension1Code_StockTakeWorksheetLine;"Shortcut Dimension 1 Code")
                {
                    IncludeCaption = true;
                }
                column(ShortcutDimension2Code_StockTakeWorksheetLine;"Shortcut Dimension 2 Code")
                {
                    IncludeCaption = true;
                }
                column(ItemTranslationSource_StockTakeWorksheetLine;"Item Translation Source")
                {
                    IncludeCaption = true;
                }
                column(SessionID_StockTakeWorksheetLine;"Session ID")
                {
                    IncludeCaption = true;
                }
                column(SessionName_StockTakeWorksheetLine;"Session Name")
                {
                    IncludeCaption = true;
                }
                column(SessionDateTime_StockTakeWorksheetLine;"Session DateTime")
                {
                    IncludeCaption = true;
                }
                column(TransferState_StockTakeWorksheetLine;"Transfer State")
                {
                    IncludeCaption = true;
                }
                column(ItemDescription_StockTakeWorksheetLine;"Item Description")
                {
                    IncludeCaption = true;
                }
                column(VariantDescription_StockTakeWorksheetLine;"Variant Description")
                {
                    IncludeCaption = true;
                }
                column(ItemTransSourceDesc_StockTakeWorksheetLine;"Item Trans. Source Desc.")
                {
                    IncludeCaption = true;
                }
                column(QtyTotalCounted_StockTakeWorksheetLine;"Qty. (Total Counted)")
                {
                    IncludeCaption = true;
                }
                column(PhysInvBatchNameFilter_StockTakeWorksheetLine;"Phys. Inv. Batch Name Filter")
                {
                    IncludeCaption = true;
                }
                column(DimensionSetID_StockTakeWorksheetLine;"Dimension Set ID")
                {
                    IncludeCaption = true;
                }
            }

            trigger OnAfterGetRecord()
            var
                StockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
            begin
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
        ReportTitleLabel = 'List of Status Phase';
        ControlLabel = 'Control';
    }
}

