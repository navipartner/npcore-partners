report 6014424 "NPR Ret. Jnl. - Import Items"
{
    Caption = 'Import Items';
    ProcessingOnly = true; 
    UsageCategory = ReportsAndAnalysis; 
    ApplicationArea = All;
    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", "Vendor No.", "NPR Item Group", "NPR Group sale", "Last Date Modified", Description, "Search Description";

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
                    RetailJournalLine.Validate("Vendor Item No.", Item."Vendor Item No.");
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
                            CalcFields(Item.Inventory);
                            RetailJournalLine.Validate("Quantity to Print", 1);
                            RetailJournalLine.Validate(Description, Item.Description);
                            RetailJournalLine.Validate("Vendor No.", Item."Vendor No.");
                            RetailJournalLine.Validate("Vendor Item No.", Item."Vendor Item No.");
                            RetailJournalLine.Validate("Unit Price", Item."Unit Price");
                            RetailJournalLine.Validate(RetailJournalLine.Inventory, Item.Inventory);

                            case ImportUnitCost of
                                ImportUnitCost::"Standard Cost":
                                    RetailJournalLine.Validate("Last Direct Cost", Item."Standard Cost");
                                ImportUnitCost::"Unit Cost":
                                    RetailJournalLine.Validate("Last Direct Cost", Item."Unit Cost");
                                ImportUnitCost::"Last direct cost":
                                    RetailJournalLine.Validate("Last Direct Cost", Item."Last Direct Cost");
                            end;

                            CrossReference.Reset();
                            CrossReference.SetRange("Cross-Reference Type", CrossReference."Cross-Reference Type"::"Bar Code");
                            CrossReference.SetRange("Item No.", Item."No.");
                            CrossReference.SetRange("Variant Code", ItemVariants.Code);
                            if CrossReference.FindFirst then
                                RetailJournalLine.Validate(Barcode, CrossReference."Cross-Reference No.");

                            RetailJournalLine.Modify();
                            SetFilter(Item."Variant Filter", '');
                        until ItemVariants.Next() = 0;
                end;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field("Only Inventory"; OnlyInventory)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the OnlyInventory field';
                }
            }
        }

    }

    var
        CrossReference: Record "Item Cross Reference";
        ItemVariants: Record "Item Variant";
        RetailJournalHeader: Record "NPR Retail Journal Header";
        RetailJournalLine: Record "NPR Retail Journal Line";
        OnlyInventory: Boolean;
        RetailJournalCode: Code[20];
        LastLineNo: Integer;
        ImportUnitCost: Option "Standard Cost","Unit Cost","Last direct cost";

    procedure SetJournal(RetailJournalCodeIn: Code[20])
    begin
        RetailJournalCode := RetailJournalCodeIn;
        RetailJournalHeader.Get(RetailJournalCode);
    end;
}

