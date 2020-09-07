pageextension 6014457 "NPR Purchase Order Subform" extends "Purchase Order Subform"
{
    // NPR4.13/MMV/20150708 CASE 214173 Changed "No." to variable to handle barcode scanning OnValidate trigger.
    // NPR4.14/???/20150804 CASE 219456 changed number assignment
    // NPR4.14/JDH/20150902 CASE 221915 Added field Label
    // NPR4.15.01/TS/20151021 CASE 214173 Removed Code related to release 4.13
    // NPR4.18/MMV/20160105 CASE 229221 Unify how label printing of lines are handled.
    // NPR5.22/TJ/20160411 CASE 238601 Setting standard captions on all of the actions and action groups
    //                                    Setting control ID of field No. back to standard value
    //                                    Reworked how to check for Retail Setup read permission
    // NPR5.22/MMV/20160420 CASE 237743 Updated references to label library CU.
    // NPR5.22/JLK/20160428 CASE 237825 Added Description 2
    // NPR5.24/JDH/20160720 CASE 241848 Moved code OnAfterGetRecord, OnNewRecord and OnDeleteRecord, so Powershell didnt triggered a mergeConflicts
    // NPR5.29/MMV /20161122 CASE 259110 Removed CurrPage.UPDATE() on Print Validate
    // NPR5.29/TJ  /20170117 CASE 262797 Removed unused functions and function separators
    // NPR5.29/TJ  /20170118 CASE 263761 Removed code from Vendor Item No. - OnLookup and unused variable
    // NPR5.30/TJ  /20170202 CASE 262533 Removed code, control, variables and functions used for label printing and moved to a subscriber
    // NPR5.39/BR  /20180219 CASE 295322 Added Action Nonstock Items
    // NPR5.49/LS  /20190329  CASE 347542 Added field 6014420 Exchange Label
    // NPR5.50/LS  /20190506  CASE 347542 Adding additional functionalities to field 6014420
    layout
    {
        addafter("No.")
        {
            field("NPR Vendor Item No."; "Vendor Item No.")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
        addafter(Description)
        {
            field("NPR Description 2"; "Description 2")
            {
                ApplicationArea = All;
            }
        }
        addafter("Line No.")
        {
            field("NPR Exchange Label"; "NPR Exchange Label")
            {
                ApplicationArea = All;
                Visible = false;

                trigger OnValidate()
                var
                    ExchangeLabel: Record "NPR Exchange Label";
                    ItemCheck: Record Item;
                    ExchangeLabelMultiple: Record "NPR Exchange Label";
                    PurchaseLineCheck: Record "Purchase Line";
                    PurchaseLineInsrt: Record "Purchase Line";
                begin
                    //-NPR5.50 [347542]
                    ExchangeLabel.Reset;
                    ExchangeLabel.SetRange(Barcode, "NPR Exchange Label");
                    if ExchangeLabel.FindFirst then begin
                        Validate(Type, Type::Item);
                        Validate("No.", ExchangeLabel."Item No.");
                        Validate("Variant Code", ExchangeLabel."Variant Code");
                        "NPR Exchange Label" := ExchangeLabel.Barcode;
                        Validate(Quantity, ExchangeLabel.Quantity);
                        ItemCheck.Reset;
                        if ItemCheck.Get("No.") then
                            Validate("Direct Unit Cost", ItemCheck."Unit Cost");

                        CurrPage.Update;

                        if ExchangeLabel."Sales Ticket No." <> '' then begin
                            ExchangeLabelMultiple.Reset;
                            ExchangeLabelMultiple.SetFilter(Barcode, '<>%1', "NPR Exchange Label");
                            ExchangeLabelMultiple.SetFilter("No.", '<>%1', ExchangeLabel."No.");
                            ExchangeLabelMultiple.SetRange("Store ID", ExchangeLabel."Store ID");
                            ExchangeLabelMultiple.SetRange("Sales Ticket No.", ExchangeLabel."Sales Ticket No.");
                            if ExchangeLabelMultiple.Count > 0 then begin
                                if ExchangeLabelMultiple.FindSet then
                                    repeat
                                        PurchaseLineCheck.Reset;
                                        PurchaseLineCheck.SetRange("Document Type", "Document Type");
                                        PurchaseLineCheck.SetRange("Document No.", "Document No.");
                                        if PurchaseLineCheck.FindLast then;

                                        PurchaseLineInsrt.Reset;
                                        PurchaseLineInsrt.Init;
                                        PurchaseLineInsrt.Validate("Document Type", "Document Type");
                                        PurchaseLineInsrt.Validate("Document No.", "Document No.");
                                        PurchaseLineInsrt."Line No." := PurchaseLineCheck."Line No." + 10000;
                                        PurchaseLineInsrt.Validate(Type, PurchaseLineInsrt.Type::Item);
                                        PurchaseLineInsrt.Validate("Buy-from Vendor No.", "Buy-from Vendor No.");
                                        PurchaseLineInsrt.Validate("No.", ExchangeLabelMultiple."Item No.");
                                        PurchaseLineInsrt.Validate("Variant Code", ExchangeLabelMultiple."Variant Code");
                                        PurchaseLineInsrt."NPR Exchange Label" := ExchangeLabelMultiple.Barcode;
                                        PurchaseLineInsrt.Validate(Quantity, ExchangeLabelMultiple.Quantity);
                                        ItemCheck.Reset;
                                        if ItemCheck.Get(ExchangeLabelMultiple."Item No.") then
                                            PurchaseLineInsrt.Validate("Direct Unit Cost", ItemCheck."Unit Cost");
                                        PurchaseLineInsrt.Insert;
                                        CurrPage.Update;

                                    until ExchangeLabelMultiple.Next = 0;
                            end;
                        end;
                    end;
                    //+NPR5.50 [347542]
                end;
            }
        }
    }
    actions
    {
        addafter(DocAttach)
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';
                ApplicationArea=All;
            }
        }
        addafter(OrderTracking)
        {
            action("NPR Nonstockitems")
            {
                AccessByPermission = TableData "Nonstock Item" = R;
                Caption = 'Nonstoc&k Items';
                Image = NonStockItem;
                ApplicationArea=All;
            }
        }
    }
}

