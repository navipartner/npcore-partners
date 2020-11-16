page 6014571 "NPR Tax Free Consolidation"
{
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free Consolidation';
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
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
                }
                field("Sale Date"; "Sale Date")
                {
                    ApplicationArea = All;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    AuditRoll: Record "NPR Audit Roll";
                    AuditRollPage: Page "NPR Audit Roll";
                    TaxFreeMgt: Codeunit "NPR Tax Free Handler Mgt.";
                    TaxFreeVoucher: Record "NPR Tax Free Voucher";
                begin
                    AuditRoll.SetFilter(Type, '<>%1&<>%2', AuditRoll.Type::Cancelled, AuditRoll.Type::"Open/Close");
                    AuditRollPage.LookupMode(true);
                    AuditRollPage.SetTableView(AuditRoll);
                    if AuditRollPage.RunModal = ACTION::LookupOK then begin
                        AuditRollPage.GetRecord(AuditRoll);

                        SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");
                        if FindFirst then
                            Error(Error_AlreadySelected, AuditRoll."Sales Ticket No.");
                        SetRange("Sales Ticket No.");

                        if TaxFreeMgt.TryGetActiveVoucherFromReceiptNo(AuditRoll."Sales Ticket No.", TaxFreeVoucher) then begin
                            if not Confirm(Caption_VoidExisting) then
                                exit;

                            TaxFreeMgt.VoucherVoid(TaxFreeVoucher);

                            if not TaxFreeVoucher.Void then //Void attempt failed, don't add to consolidation list.
                                exit;
                        end;

                        "Entry No." := "Entry No." + 1;
                        "Sales Ticket No." := AuditRoll."Sales Ticket No.";
                        "Sale Date" := AuditRoll."Sale Date";
                        Insert;
                    end;
                end;
            }
            action("Remove Receipt")
            {
                Caption = 'Remove Receipt';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

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

