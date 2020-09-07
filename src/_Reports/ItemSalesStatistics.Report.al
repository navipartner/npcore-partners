report 6014414 "NPR Item Sales Statistics"
{
    // NPR5.43/JLK /20180503 CASE 310612 Object created
    // NPR5.44/JDH /20180726 CASE 323366 Renamed Report. This name is already used in a local NAV standard database
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Sales Statistics NPR.rdlc';

    Caption = 'Item Sales Statistics';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;

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
                    CurrReport.Skip;

                if InventoryPostingGroupFilter <> '' then begin
                    Item.SetFilter("Inventory Posting Group", InventoryPostingGroupFilter);
                    InventoryPostingGroupFilterTxt := StrSubstNo(InventoryPostingGroupFilterCaption, InventoryPostingGroupFilter);
                end;

                if VendorItemNoFilter <> '' then begin
                    Item.SetFilter("Vendor Item No.", VendorItemNoFilter);
                    VendorItemNoFilterTxt := StrSubstNo(VendorItemNoFilterCaption, VendorItemNoFilter);
                end;

                if Item.FindSet then
                    repeat
                        TempItem.Init;
                        TempItem."No." := Item."No.";
                        TempItem.Insert;
                    until Item.Next = 0;
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
                        CurrReport.Skip;

                with TempLoopItem do begin
                    if Get("Item No.", 1) then begin
                        "Decimal 1" += Quantity;
                        Modify;
                    end else begin
                        Init;
                        Template := "Item No.";
                        "Line No." := 1;
                        "Decimal 1" := Quantity;
                        Insert;
                    end;
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
                    field(InventoryPostingGroupFilter; InventoryPostingGroupFilter)
                    {
                        Caption = 'Item Posting Group Filter:';
                        ApplicationArea=All;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            InventoryPostingGroup: Record "Inventory Posting Group";
                        begin
                            if PAGE.RunModal(112, InventoryPostingGroup) = ACTION::LookupOK then
                                InventoryPostingGroupFilter := InventoryPostingGroup.Code;
                        end;
                    }
                    field(VendorItemNoFilter; VendorItemNoFilter)
                    {
                        Caption = 'Vendor Item No. Filter:';
                        ApplicationArea=All;
                    }
                }
            }
        }

        actions
        {
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
        InventoryPostingGroupFilter: Text;
        VendorItemNoFilter: Text;
        TempItem: Record Item temporary;
        NoDefaultFilters: Boolean;
        Item2: Record Item;
        InventoryPostingGroupFilterTxt: Text;
        VendorItemNoFilterTxt: Text;
        InventoryPostingGroupFilterCaption: Label 'Inventory Posting Group Filter: %1';
        VendorItemNoFilterCaption: Label 'Vendor Item No Filter: %1';
        FiltersTxt: Text;
        ItemLedgEntryFilterCaption: Label 'Item Ledger Entry Filter: %1';
}

