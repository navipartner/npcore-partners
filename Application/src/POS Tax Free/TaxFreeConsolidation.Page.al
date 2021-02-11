page 6014571 "NPR Tax Free Consolidation"
{
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free Consolidation';
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Tax Free Consolidation";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                InstructionalText = 'Use add/remove actions to specify which sales receipts should be consolidated.';
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Sale Date"; "Sale Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sale Date field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Add Receipt")
            {
                Caption = 'Add Receipt';
                Image = Add;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Add Receipt action';

                trigger OnAction()
                var
                    POSEntry: Record "NPR POS Entry";
                    POSEntryPage: Page "NPR POS Entry List";
                    TaxFreeMgt: Codeunit "NPR Tax Free Handler Mgt.";
                    TaxFreeVoucher: Record "NPR Tax Free Voucher";
                begin
                    POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
                    if Page.RunModal(0, POSEntry) = Action::LookupOK then begin
                        Rec.SetRange("Sales Ticket No.", POSEntry."Document No.");
                        if Rec.FindFirst then
                            Error(Error_AlreadySelected, POSEntry."Document No.");
                        Rec.SetRange("Sales Ticket No.");

                        if TaxFreeMgt.TryGetActiveVoucherFromReceiptNo(POSEntry."Document No.", TaxFreeVoucher) then begin
                            if not Confirm(Caption_VoidExisting) then
                                exit;

                            TaxFreeMgt.VoucherVoid(TaxFreeVoucher);

                            if not TaxFreeVoucher.Void then //Void attempt failed, don't add to consolidation list.
                                exit;
                        end;

                        Rec."Entry No." += 1;
                        Rec."Sales Ticket No." := POSEntry."Document No.";
                        Rec."Sale Date" := POSEntry."Document Date";
                        Rec.Insert;
                    end;
                end;
            }
            action("Remove Receipt")
            {
                Caption = 'Remove Receipt';
                Image = Delete;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Remove Receipt action';

                trigger OnAction()
                begin
                    if Confirm(Caption_DeleteSelected) then
                        Delete;
                end;
            }
            action("Consolidate Receipts")
            {
                Caption = 'Consolidate Receipts';
                Image = Approve;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Consolidate Receipts action';

                trigger OnAction()
                var
                    TaxFreeMgt: Codeunit "NPR Tax Free Handler Mgt.";
                begin
                    if FindSet then begin
                        TaxFreeMgt.VoucherConsolidate(TaxFreeUnit, Rec);
                        CurrPage.Close;
                    end;
                end;
            }
        }
    }

    var
        Caption_VoidExisting: Label 'The selected receipt already has another tax free voucher attached. Continue with void of the existing voucher?';
        Caption_DeleteSelected: Label 'Delete selected receipt from consolidation list?';
        Error_AlreadySelected: Label 'You have already added receipt %1 to the consolidation list';
        TaxFreeUnit: Record "NPR Tax Free POS Unit";

    procedure SetRec(var tmpTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary)
    begin
        if not tmpTaxFreeConsolidation.IsTemporary then
            exit;

        Rec.Copy(tmpTaxFreeConsolidation, true);
    end;

    procedure GetRec(var tmpTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary)
    begin
        if not tmpTaxFreeConsolidation.IsTemporary then
            exit;

        tmpTaxFreeConsolidation.Copy(Rec, true);
    end;

    procedure SetTaxFreeUnit(TaxFreeUnitIn: Record "NPR Tax Free POS Unit")
    begin
        TaxFreeUnit := TaxFreeUnitIn;
        TaxFreeUnit.SetRecFilter;
        TaxFreeUnit.FindFirst;
    end;
}

