﻿report 6014424 "NPR Ret. Jnl. - Import Items"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    Caption = 'Import Items';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", "Vendor No.", "Item Category Code", "NPR Group sale", "Last Date Modified", Description, "Search Description";

            trigger OnAfterGetRecord()
            begin
                CalcFields("NPR Has Variants");
                if (Inventory <= 0) and OnlyInventory then
                    CurrReport.Skip();

                RetailJournalLine.Reset();
                RetailJournalLine.SetRange("No.", RetailJournalHeader."No.");
                if RetailJournalLine.FindLast() then
                    LastLineNo := RetailJournalLine."Line No."
                else
                    LastLineNo := 0;

                if not Item."NPR Has Variants" then begin
                    CalcFields(Inventory);
                    RetailJournalLine.Init();
                    RetailJournalLine.Validate("Line No.", LastLineNo + 10000);
                    RetailJournalLine.Validate("No.", RetailJournalHeader."No.");
                    RetailJournalLine.Validate("Item No.", Item."No.");
                    RetailJournalLine.Insert();
                    RetailJournalLine.Validate("Quantity to Print", 1);
                    RetailJournalLine.Validate(Description, Item.Description);
                    RetailJournalLine.Validate("Vendor No.", Item."Vendor No.");
                    RetailJournalLine.Validate("Vend Item No.", Item."Vendor Item No.");
                    RetailJournalLine.Validate("Discount Price Incl. Vat", Item."Unit Price");

                    case ImportUnitCost of
                        ImportUnitCost::"Standard Cost":
                            RetailJournalLine.Validate("Last Direct Cost", Item."Standard Cost");
                        ImportUnitCost::"Unit Cost":
                            RetailJournalLine.Validate("Last Direct Cost", Item."Unit Cost");
                        ImportUnitCost::"Last direct cost":
                            RetailJournalLine.Validate("Last Direct Cost", Item."Last Direct Cost");
                    end;
                    RetailJournalLine.Modify();
                end else begin
                    ItemVariants.SetRange("Item No.", Item."No.");
                    if ItemVariants.Find('-') then
                        repeat
                            RetailJournalLine.Init();
                            RetailJournalLine.Validate("Line No.", LastLineNo + 10000);
                            LastLineNo += 10000;
                            RetailJournalLine.Validate("No.", RetailJournalHeader."No.");
                            RetailJournalLine.Validate("Item No.", Item."No.");
                            RetailJournalLine.Validate("Variant Code", ItemVariants.Code);
                            RetailJournalLine.Insert();
                            Item.SetFilter("Variant Filter", '=%1', ItemVariants.Code);
                            RetailJournalLine.Validate("Quantity to Print", 1);
                            RetailJournalLine.Validate(Description, Item.Description);
                            RetailJournalLine.Validate("Vendor No.", Item."Vendor No.");
                            RetailJournalLine.Validate("Vend Item No.", Item."Vendor Item No.");
                            RetailJournalLine.Validate("Unit Price", Item."Unit Price");

                            case ImportUnitCost of
                                ImportUnitCost::"Standard Cost":
                                    RetailJournalLine.Validate("Last Direct Cost", Item."Standard Cost");
                                ImportUnitCost::"Unit Cost":
                                    RetailJournalLine.Validate("Last Direct Cost", Item."Unit Cost");
                                ImportUnitCost::"Last direct cost":
                                    RetailJournalLine.Validate("Last Direct Cost", Item."Last Direct Cost");
                            end;


                            ItemReference.Reset();
                            ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
                            ItemReference.SetRange("Item No.", Item."No.");
                            ItemReference.SetRange("Variant Code", ItemVariants.Code);
                            if ItemReference.FindFirst() then
                                RetailJournalLine.Validate(Barcode, ItemReference."Reference No.");

                            RetailJournalLine.Modify();
                            SetFilter(Item."Variant Filter", '');
                        until ItemVariants.Next() = 0;
                end;
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
                field("Only Inventory"; OnlyInventory)
                {

                    Caption = 'Only Inventory';
                    ToolTip = 'Specifies the value of the OnlyInventory field';
                    ApplicationArea = NPRRetail;
                }
            }
        }

    }

    var
        RetailJournalHeader: Record "NPR Retail Journal Header";
        RetailJournalLine: Record "NPR Retail Journal Line";
        OnlyInventory: Boolean;
        RetailJournalCode: Code[40];
        LastLineNo: Integer;
        ItemVariants: Record "Item Variant";
        ItemReference: Record "Item Reference";
        ImportUnitCost: Option "Standard Cost","Unit Cost","Last direct cost";

    internal procedure SetJournal(RetailJournalCodeIn: Code[40])
    begin
        RetailJournalCode := RetailJournalCodeIn;
        RetailJournalHeader.Get(RetailJournalCode);
    end;
}

