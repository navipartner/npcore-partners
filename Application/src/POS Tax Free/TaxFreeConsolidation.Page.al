page 6014571 "NPR Tax Free Consolidation"
{

    Caption = 'Tax Free Consolidation';
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Tax Free Consolidation";
    SourceTableTemporary = true;
    UsageCategory = None;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                InstructionalText = 'Use add/remove actions to specify which sales receipts should be consolidated.';
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {

                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sale Date"; Rec."Sale Date")
                {

                    ToolTip = 'Specifies the value of the Sale Date field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Add Receipt action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    PosEntry: Record "NPR POS Entry";
                    TaxFreeMgt: Codeunit "NPR Tax Free Handler Mgt.";
                    TaxFreeVoucher: Record "NPR Tax Free Voucher";
                begin
                    PosEntry.SetFilter("Entry Type", '<>%1', PosEntry."Entry Type"::"Cancelled Sale");
                    if Page.RunModal(0, PosEntry) <> ACTION::LookupOK then
                        exit;

                    Rec.SetRange("Sales Ticket No.", PosEntry."Document No.");
                    if Rec.FindFirst() then
                        Error(Error_AlreadySelected, PosEntry."Document No.");
                    Rec.SetRange("Sales Ticket No.");

                    if TaxFreeMgt.TryGetActiveVoucherFromReceiptNo(PosEntry."Document No.", TaxFreeVoucher) then begin
                        if not Confirm(Caption_VoidExisting) then
                            exit;

                        TaxFreeMgt.VoucherVoid(TaxFreeVoucher);

                        if not TaxFreeVoucher.Void then //Void attempt failed, don't add to consolidation list.
                            exit;
                    end;

                    Rec."Entry No." := Rec."Entry No." + 1;
                    Rec."Sales Ticket No." := PosEntry."Document No.";
                    Rec."Sale Date" := PosEntry."Entry Date";
                    Rec.Insert();

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

                ToolTip = 'Executes the Remove Receipt action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    if Confirm(Caption_DeleteSelected) then
                        Rec.Delete();
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

                ToolTip = 'Executes the Consolidate Receipts action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    TaxFreeMgt: Codeunit "NPR Tax Free Handler Mgt.";
                begin
                    if Rec.FindSet() then begin
                        TaxFreeMgt.VoucherConsolidate(TaxFreeUnit, Rec);
                        CurrPage.Close();
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
        TaxFreeUnit.SetRecFilter();
        TaxFreeUnit.FindFirst();
    end;
}

