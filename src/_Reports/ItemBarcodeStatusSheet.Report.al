report 6014455 "NPR Item Barcode Status Sheet"
{
    // NPR5.29/MMV /20161213 CASE 252307 Created report
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Barcode Status Sheet.rdlc';

    Caption = 'Item Barcode Status Sheet';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            CalcFields = "NPR Has Variants";
            column(CompanyName; CompanyName)
            {
            }
            column(ItemFilter; ItemFilter)
            {
            }
            column(ItemVariantFilter; ItemVariantFilter)
            {
            }
            column(ShowInventory; ShowInventory)
            {
            }
            dataitem(ItemVariant; "Item Variant")
            {
                DataItemLink = "Item No." = FIELD("No.");
                DataItemTableView = WHERE("NPR Blocked" = CONST(false));

                trigger OnAfterGetRecord()
                begin
                    ShowVariantInfo := 1;
                    AddToBuffer("Item No.", Code);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if not "NPR Has Variants" then
                    AddToBuffer("No.", '');
            end;
        }
        dataitem(TMPRetail_Journal_Line_Col1; "NPR Retail Journal Line")
        {
            DataItemTableView = SORTING("No.", "Line No.");
            UseTemporary = true;
            column(ItemNo_TMPRetailJournalLineCol1; TMPRetail_Journal_Line_Col1."Item No.")
            {
            }
            column(Description_TMPRetailJournalLineCol1; TMPRetail_Journal_Line_Col1.Description)
            {
            }
            column(Description2_TMPRetailJournalLineCol1; TMPRetail_Journal_Line_Col1."Description 2")
            {
            }
            column(Inventory_TMPRetailJournalLineCol1; TMPRetail_Journal_Line_Col1."Quantity to Print")
            {
            }
            column(VariantCode_TMPRetailJournalLineCol1; TMPRetail_Journal_Line_Col1."Variant Code")
            {
            }
            column(ShowVariantInfo_TMPRetailJournalLineCol1; ShowVariantInfo)
            {
            }
            column(BarCodeTempBlobCol1; BlobBuffer."Buffer 1")
            {
            }

            trigger OnAfterGetRecord()
            begin
                BarcodeLib.GenerateBarcode(Barcode, TempBlobCol1);
                BlobBuffer.GetFromTempBlob(TempBlobCol1, 1);
            end;
        }
        dataitem(TMPRetail_Journal_Line_Col2; "NPR Retail Journal Line")
        {
            DataItemTableView = SORTING("No.", "Line No.");
            UseTemporary = true;
            column(ItemNo_TMPRetailJournalLineCol2; TMPRetail_Journal_Line_Col2."Item No.")
            {
            }
            column(Description_TMPRetailJournalLineCol2; TMPRetail_Journal_Line_Col2.Description)
            {
            }
            column(Description2_TMPRetailJournalLineCol2; TMPRetail_Journal_Line_Col2."Description 2")
            {
            }
            column(Inventory_TMPRetailJournalLineCol2; TMPRetail_Journal_Line_Col2."Quantity to Print")
            {
            }
            column(VariantCode_TMPRetailJournalLineCol2; TMPRetail_Journal_Line_Col2."Variant Code")
            {
            }
            column(ShowVariantInfo_TMPRetailJournalLineCol2; ShowVariantInfo)
            {
            }
            column(BarCodeTempBlobCol2; BlobBuffer."Buffer 2")
            {
            }

            trigger OnAfterGetRecord()
            begin
                BarcodeLib.GenerateBarcode(Barcode, TempBlobCol2);
                BlobBuffer.GetFromTempBlob(TempBlobCol2, 2);
            end;
        }
        dataitem(TMPRetail_Journal_Line_Col3; "NPR Retail Journal Line")
        {
            DataItemTableView = SORTING("No.", "Line No.");
            UseTemporary = true;
            column(ItemNo_TMPRetailJournalLineCol3; TMPRetail_Journal_Line_Col3."Item No.")
            {
            }
            column(Description_TMPRetailJournalLineCol3; TMPRetail_Journal_Line_Col3.Description)
            {
            }
            column(Description2_TMPRetailJournalLineCol3; TMPRetail_Journal_Line_Col3."Description 2")
            {
            }
            column(Inventory_TMPRetailJournalLineCol3; TMPRetail_Journal_Line_Col3."Quantity to Print")
            {
            }
            column(VariantCode_TMPRetailJournalLineCol3; TMPRetail_Journal_Line_Col3."Variant Code")
            {
            }
            column(ShowVariantInfo_TMPRetailJournalLineCol3; ShowVariantInfo)
            {
            }
            column(BarCodeTempBlobCol3; BlobBuffer."Buffer 3")
            {
            }

            trigger OnAfterGetRecord()
            begin
                BarcodeLib.GenerateBarcode(Barcode, TempBlobCol3);
                BlobBuffer.GetFromTempBlob(TempBlobCol3, 3);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(ShowInventory; ShowInventory)
                {
                    Caption = 'Show Inventory';
                    ApplicationArea = All;
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        Inventory = 'Inv.:';
        PageNo = 'Page No.';
        ReportName = 'Item Barcode Status Sheet';
        Filters = 'Filters:';
        Variant = 'Variant:';
    }

    trigger OnPreReport()
    begin
        i := 1;
        LineNo := 1;
        BarcodeLib.SetBarcodeType('EAN13');
        BarcodeLib.SetAntiAliasing(false);
        BarcodeLib.SetShowText(true);

        ItemFilter := StrSubstNo('%1: %2', Item.TableCaption, Item.GetFilters());
        ItemVariantFilter := StrSubstNo('%1: %2', ItemVariant.TableCaption, ItemVariant.GetFilters());

        if ShowInventory then
            Item.SetAutoCalcFields(Inventory);
    end;

    var
        ShowInventory: Boolean;
        ShowVariantInfo: Integer;
        BarcodeLib: Codeunit "NPR Barcode Library";
        TempBlobCol1: Codeunit "Temp Blob";
        TempBlobCol2: Codeunit "Temp Blob";
        TempBlobCol3: Codeunit "Temp Blob";
        i: Integer;
        LineNo: Integer;
        ItemFilter: Text;
        ItemVariantFilter: Text;
        BlobBuffer: Record "NPR BLOB buffer" temporary;

    local procedure AddToBuffer(ItemNo: Code[20]; VariantCode: Code[10])
    begin
        //Quantity field in RJL is used to store the inventory value.

        case i of
            1:
                begin
                    TMPRetail_Journal_Line_Col1.Init;
                    TMPRetail_Journal_Line_Col1."No." := 'temp';
                    TMPRetail_Journal_Line_Col1."Line No." := LineNo;
                    TMPRetail_Journal_Line_Col1.Validate("Item No.", ItemNo);
                    if StrLen(VariantCode) > 0 then begin
                        TMPRetail_Journal_Line_Col1.Validate("Variant Code", VariantCode);
                        if ShowInventory then
                            TMPRetail_Journal_Line_Col1."Quantity to Print" := CalcVariantInventory(VariantCode);
                    end else
                        TMPRetail_Journal_Line_Col1."Quantity to Print" := Item.Inventory;

                    TMPRetail_Journal_Line_Col1.Insert;
                end;
            2:
                begin
                    TMPRetail_Journal_Line_Col2.Init;
                    TMPRetail_Journal_Line_Col2."No." := 'temp';
                    TMPRetail_Journal_Line_Col2."Line No." := LineNo;
                    TMPRetail_Journal_Line_Col2.Validate("Item No.", ItemNo);
                    if StrLen(VariantCode) > 0 then begin
                        TMPRetail_Journal_Line_Col2.Validate("Variant Code", VariantCode);
                        if ShowInventory then
                            TMPRetail_Journal_Line_Col2."Quantity to Print" := CalcVariantInventory(VariantCode);
                    end else
                        TMPRetail_Journal_Line_Col2."Quantity to Print" := Item.Inventory;

                    TMPRetail_Journal_Line_Col2.Insert;
                end;
            3:
                begin
                    TMPRetail_Journal_Line_Col3.Init;
                    TMPRetail_Journal_Line_Col3."No." := 'temp';
                    TMPRetail_Journal_Line_Col3."Line No." := LineNo;
                    TMPRetail_Journal_Line_Col3.Validate("Item No.", ItemNo);
                    if StrLen(VariantCode) > 0 then begin
                        TMPRetail_Journal_Line_Col3.Validate("Variant Code", VariantCode);
                        if ShowInventory then
                            TMPRetail_Journal_Line_Col3."Quantity to Print" := CalcVariantInventory(VariantCode);
                    end else
                        TMPRetail_Journal_Line_Col3."Quantity to Print" := Item.Inventory;

                    TMPRetail_Journal_Line_Col3.Insert;
                    i := 0;
                end;
        end;
        i += 1;
        LineNo += 1;
    end;

    local procedure CalcVariantInventory(VariantCode: Code[10]): Decimal
    var
        Item2: Record Item;
    begin
        Item2.Copy(Item);
        Item2.SetRange("Variant Filter", VariantCode);
        Item2.CalcFields(Inventory);
        exit(Item2.Inventory);
    end;
}

