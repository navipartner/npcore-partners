report 6014414 "NPR Item Sales Statistics"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Sales Statistics NPR.rdlc';
    Caption = 'Item Sales Statistics';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    dataset
    {
        dataitem(RunOnce; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            MaxIteration = 1;

            trigger OnAfterGetRecord()
            var
                Item: Record Item;
            begin
                if NoDefaultFilters then
                    CurrReport.Skip();

                if InventoryPostingGroupFilter <> '' then begin
                    Item.SetFilter("Inventory Posting Group", InventoryPostingGroupFilter);
                    InventoryPostingGroupFilterTxt := StrSubstNo(InventoryPostingGroupFilterCaption, InventoryPostingGroupFilter);
                end;

                if VendorItemNoFilter <> '' then begin
                    Item.SetFilter("Vendor Item No.", VendorItemNoFilter);
                    VendorItemNoFilterTxt := StrSubstNo(VendorItemNoFilterCaption, VendorItemNoFilter);
                end;

                if Item.FindSet() then
                    repeat
                        TempItem.Init();
                        TempItem."No." := Item."No.";
                        TempItem.Insert();
                    until Item.Next() = 0;
            end;

            trigger OnPreDataItem()
            begin
                Clear(NoDefaultFilters);
                Clear(VendorItemNoFilterTxt);
                Clear(InventoryPostingGroupFilterTxt);
                Clear(FiltersTxt);

                if (InventoryPostingGroupFilter = '') and (VendorItemNoFilter = '') then
                    NoDefaultFilters := true;

                if ItemLedgerEntry.GetFilters <> '' then
                    FiltersTxt := StrSubstNo(ItemLedgEntryFilterCaption, ItemLedgerEntry.GetFilters);
            end;
        }
        dataitem(ItemLedgerEntry; "Item Ledger Entry")
        {
            DataItemTableView = SORTING("Source Type", "Source No.", "Item No.", "Variant Code", "Posting Date");
            RequestFilterFields = "Document Type", "Posting Date", Quantity;
            column(GetFilters; FiltersTxt)
            {
            }
            column(InventoryPostingGroupFilter; InventoryPostingGroupFilterTxt)
            {
            }
            column(VendorItemNoFilter; VendorItemNoFilterTxt)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if not NoDefaultFilters then
                    if not TempItem.Get("Item No.") then
                        CurrReport.Skip();

                if TempLoopItem.Get("Item No.", 1) then begin
                    TempLoopItem."Decimal 1" += Quantity;
                    TempLoopItem.Modify();
                end else begin
                    TempLoopItem.Init();
                    TempLoopItem.Template := "Item No.";
                    TempLoopItem."Line No." := 1;
                    TempLoopItem."Decimal 1" := Quantity;
                    TempLoopItem.Insert();
                end;
            end;
        }
        dataitem(TempLoopItem; "NPR TEMP Buffer")
        {
            DataItemTableView = SORTING(Template, "Line No.");
            UseTemporary = true;
            column(ItemNo; Template)
            {
            }
            column(ItemQuantity; "Decimal 1")
            {
            }
            column(ItemDescription; Item2.Description)
            {
            }

            trigger OnAfterGetRecord()
            begin

                if not Item2.Get(Template) then
                    Clear(Item2);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("Inventory Posting Group Filter"; InventoryPostingGroupFilter)
                    {
                        Caption = 'Item Posting Group Filter:';

                        ToolTip = 'Specifies the value of the Item Posting Group Filter: field';
                        ApplicationArea = NPRRetail;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            InventoryPostingGroup: Record "Inventory Posting Group";
                        begin
                            if PAGE.RunModal(112, InventoryPostingGroup) = ACTION::LookupOK then
                                InventoryPostingGroupFilter := InventoryPostingGroup.Code;
                        end;
                    }
                    field("Vendor Item No Filter"; VendorItemNoFilter)
                    {
                        Caption = 'Vendor Item No. Filter:';

                        ToolTip = 'Specifies the value of the Vendor Item No. Filter: field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            ItemLedgerEntry.SetRange("Document Type", ItemLedgerEntry."Document Type"::"Sales Shipment");
            ItemLedgerEntry.SetFilter(Quantity, '<>%1', 0);
        end;
    }

    labels
    {
        PageLabel = 'Page %1 of %2';
        DescriptionLabel = 'Description';
        InventoryPostingGroupLabel = 'Inventory Posting Group';
        VendorItemNoLabel = 'Vendor Item No.';
        ReportLabel = 'Item Sales Statistics';
        ItemNoLabel = 'Item No.';
        QuantityLabel = 'Quantity';
    }

    var
        Item2: Record Item;
        TempItem: Record Item temporary;
        NoDefaultFilters: Boolean;
        InventoryPostingGroupFilterCaption: Label 'Inventory Posting Group Filter: %1';
        ItemLedgEntryFilterCaption: Label 'Item Ledger Entry Filter: %1';
        VendorItemNoFilterCaption: Label 'Vendor Item No Filter: %1';
        FiltersTxt: Text;
        InventoryPostingGroupFilter: Text;
        InventoryPostingGroupFilterTxt: Text;
        VendorItemNoFilter: Text;
        VendorItemNoFilterTxt: Text;
}

