page 6014666 "NPR APIV1 - POS Sale Line"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'POS Sale Lines';
    DelayedInsert = true;
    EntityName = 'posSaleLine';
    EntitySetName = 'posSaleLines';
    ODataKeyFields = "POS Sale Line System Id";
    PageType = API;
    SourceTable = "NPR POS Sales Line API Buffer"; //tableType = Temporary
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec."POS Sale Line System Id")
                {
                    Caption = 'Id';
                    Editable = false;
                }

                field(saleId; Rec."POS Sale System Id")
                {
                    Caption = 'POS Sale Id';
                }

                field(registerNo; Rec."Register No.")
                {
                    Caption = 'POS Unit No.';
                    Editable = false; //setup automatically
                }
                field(salesTicketNo; Rec."Sales Ticket No.")
                {
                    Caption = 'Sales Ticket No.';
                    Editable = false; //setup automatically
                }

                field("date"; Rec.Date)
                {
                    Caption = 'Date';
                    Editable = false; //setup automatically
                }

                field(saleType; Rec."Sale Type")
                {
                    Caption = 'Sale Type';
                }

                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.';
                    Editable = false; //setup automatically
                }

                field(type; Rec.Type)
                {
                    Caption = 'Type';
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                }

                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant Code';
                }

                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                    trigger OnValidate()
                    begin
                        IF NOT (Rec."Sale Type" IN [Rec."Sale Type"::Sale]) then
                            Error(CannotSetFieldForSalesTypeErr, Rec.FieldCaption(Quantity), Rec."Sale Type");

                        //IF Rec."Sale Type" IN [Rec."Sale Type"::Sale] then
                        //RegisterFieldSet(Rec.FieldNo(Quantity));
                    end;
                }

                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price';

                    trigger OnValidate()
                    begin
                        IF NOT (Rec."Sale Type" IN [Rec."Sale Type"::Sale]) then
                            Error(CannotSetFieldForSalesTypeErr, Rec.FieldCaption("Unit Price"), Rec."Sale Type");

                        //IF Rec."Sale Type" IN [Rec."Sale Type"::Sale] then
                        //RegisterFieldSet(Rec.FieldNo("Unit Price"));
                    end;
                }

                field(vatPercent; Rec."VAT %")
                {
                    Caption = 'VAT %';
                    Editable = false;
                }

                field(discountPercent; Rec."Discount %")
                {
                    Caption = 'Discount %';
                }

                field(discountAmount; Rec."Discount Amount")
                {
                    Caption = 'Discount Amount';
                }

                field(amount; Rec.Amount)
                {
                    Caption = 'Amount';

                    trigger OnValidate()
                    begin
                        IF NOT (Rec."Sale Type" IN [Rec."Sale Type"::Payment]) then
                            Error(CannotSetFieldForSalesTypeErr, Rec.FieldCaption(Amount), Rec."Sale Type");

                        //IF Rec."Sale Type" IN [Rec."Sale Type"::Payment] then
                        //RegisterFieldSet(Rec.FieldNo(Amount));
                    end;
                }

                field(amountIncludingVat; Rec."Amount Including VAT")
                {
                    Caption = 'Amount Including VAT';
                    Editable = false;
                }

                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                }

            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        APIPOSSaleMgmt: Codeunit "NPR APIV1 - POS Sale Mgmt.";
        POSSaleRec: Record "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        PaymentLine: Codeunit "NPR POS Payment Line";
    begin
        IF NOt Initialized then begin // when insert new sales line using posSaleLines endpoint, so this page is not initialized from the header page posSales
            Rec.TestField("POS Sale System Id"); // need to know in what Sale we insert a new line
            POSSaleRec.GetBySystemId(Rec."POS Sale System Id");
            Initialize(POSSaleRec);
        end;

        IF Rec."Sale Type" = Rec."Sale Type"::Sale then begin
            POSSession.GetSaleLine(SaleLine);
            APIPOSSaleMgmt.InsertPOSSaleLine(Rec, SaleLine, SaleBuffer, false);
        end;

        IF Rec."Sale Type" = Rec."Sale Type"::Payment then begin
            POSSession.GetPaymentLine(PaymentLine);
            APIPOSSaleMgmt.InsertPOSPaymentLine(Rec, PaymentLine, SaleBuffer, false);
        end;

    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        APIPOSSaleMgmt: Codeunit "NPR APIV1 - POS Sale Mgmt.";
        POSSaleIdFilter: Text;
        POSSaleLineIdFilter: Text;
        SysId: Guid;
        FilterView: Text;
    begin
        IF NOT LinesLoaded then begin
            FilterView := Rec.GetView();
            POSSaleLineIdFilter := Rec.GetFilter("POS Sale Line System Id");
            POSSaleIdFilter := Rec.GetFilter("POS Sale System Id");
            if (POSSaleLineIdFilter = '') and (POSSaleIdFilter = '') then
                Error(IDOrDocumentIdShouldBeSpecifiedForLinesErr);

            IF POSSaleLineIdFilter <> '' then begin
                Evaluate(SysId, POSSaleLineIdFilter);
                POSSaleIdFilter := APIPOSSaleMgmt.GetPOSSalesIdFilterFromPOSSalesLineSystemId(SysId);
            end else
                POSSaleIdFilter := Rec.GetFilter("POS Sale System Id");

            APIPOSSaleMgmt.LoadPOSSaleLines(Rec, POSSaleIdFilter);

            Rec.SetView(FilterView);
            if not Rec.FindFirst() then
                exit(false);

            LinesLoaded := true;

        end;

        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        SaleLine: Codeunit "NPR POS Sale Line";
        PaymentLine: Codeunit "NPR POS Payment Line";
        POSSalesLineRec: Record "NPR POS Sale Line";
        POSSaleRec: Record "NPR POS Sale";
    begin
        POSSalesLineRec.GetBySystemId(Rec."POS Sale Line System Id");
        IF not Initialized then begin
            POSSaleRec.Get(POSSalesLineRec."Register No.", POSSalesLineRec."Sales Ticket No.");
            Initialize(POSSaleRec);
        end;

        //delete line
        IF Rec."Sale Type" = Rec."Sale Type"::Sale then
            DeleteSalesLine(POSSalesLineRec, SaleLine);

        IF Rec."Sale Type" = Rec."Sale Type"::Payment then
            DeletePaymentLine(POSSalesLineRec, PaymentLine);

    end;

    trigger OnModifyRecord(): Boolean
    var
        APIPOSSaleMgmt: Codeunit "NPR APIV1 - POS Sale Mgmt.";
        SaleLine: Codeunit "NPR POS Sale Line";
        PaymentLine: Codeunit "NPR POS Payment Line";
        POSSalesLineRec: Record "NPR POS Sale Line";
        POSSaleRec: Record "NPR POS Sale";
    begin
        // to be able to modify some fields in case a mistake was made just for one line
        //APIPOSSaleMgmt.PropagateModifyPOSSaleLine(Rec, TempFieldBuffer);
        POSSalesLineRec.GetBySystemId(Rec."POS Sale Line System Id");
        IF not Initialized then begin
            POSSaleRec.Get(POSSalesLineRec."Register No.", POSSalesLineRec."Sales Ticket No.");
            Initialize(POSSaleRec);
        end;

        //delete line and recreate line (in order to use all existing logic as if line was recreated at POS)
        IF Rec."Sale Type" = Rec."Sale Type"::Sale then begin
            DeleteSalesLine(POSSalesLineRec, SaleLine);
            APIPOSSaleMgmt.InsertPOSSaleLine(Rec, SaleLine, SaleBuffer, true);
        end;

        IF Rec."Sale Type" = Rec."Sale Type"::Payment then begin
            DeletePaymentLine(POSSalesLineRec, PaymentLine);
            APIPOSSaleMgmt.InsertPOSPaymentLine(Rec, PaymentLine, SaleBuffer, true);
        end;
    end;

    procedure Initialize(POSSessionIn: Codeunit "NPR POS Session"; SaleBufferIn: Record "NPR POS Sales API Buffer")
    var
    begin
        //initialialize from a new pos sale: when we create a new pos sale together with one or more pos sale lines
        POSSession := POSSessionIn;

        POSSession.GetSetup(Setup);
        Setup.GetPOSUnit(POSUnit);
        SaleBuffer := SaleBufferIn;

        Initialized := true;
    end;

    procedure Initialize(POSSaleRec: Record "NPR POS Sale")
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        //initialize from an existing pos sale: when we modify/insert/delete a pos sale line of an existing pos sale.
        InitializePOSSale();
        IF SalespersonPurchaser.Get(POSSaleRec."Salesperson Code") then
            Setup.SetSalesperson(SalespersonPurchaser);
        POSSession.ResumeTransactionWS(POSSaleRec);
        SaleBuffer.Init();
        SaleBuffer.TransferFields(POSSaleRec);
        SaleBuffer."POS Sale System Id" := POSSaleRec.SystemId;

        Initialized := true;
    end;

    local procedure InitializePOSSale()
    begin
        POSSession.Constructor(Setup, POSSession);
        Setup.GetPOSUnit(POSUnit);
    end;

    /* local procedure RegisterFieldSet(FieldNo: Integer)
    var
        LastOrderNo: Integer;
    begin
        LastOrderNo := 1;
        if TempFieldBuffer.FindLast() then
            LastOrderNo := TempFieldBuffer.Order + 1;

        Clear(TempFieldBuffer);
        TempFieldBuffer.Order := LastOrderNo;
        TempFieldBuffer."Table ID" := Database::"NPR POS Sales Line API Buffer";
        TempFieldBuffer."Field ID" := FieldNo;
        TempFieldBuffer.Insert();
    end; */

    local procedure DeleteSalesLine(POSSalesLineRec: Record "NPR POS Sale Line"; VAR SalesLine: Codeunit "NPR POS Sale Line")
    begin
        POSSession.GetSaleLine(SalesLine);
        SalesLine.SetPosition(POSSalesLineRec.GetPosition());
        SalesLine.DeleteLine();
    end;

    local procedure DeletePaymentLine(POSSalesLineRec: Record "NPR POS Sale Line"; VAR PaymentLine: Codeunit "NPR POS Payment Line")
    begin
        POSSession.GetPaymentLine(PaymentLine);
        PaymentLine.SetPosition(POSSalesLineRec.GetPosition());
        PaymentLine.DeleteLine()
    end;

    var
        Setup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
        SaleBuffer: Record "NPR POS Sales API Buffer";
        POSSession: Codeunit "NPR POS Session";

        //TempFieldBuffer: Record "Field Buffer" temporary;
        LinesLoaded: Boolean;
        IDOrDocumentIdShouldBeSpecifiedForLinesErr: Label 'You must specify a POS Sales Id or a POS Sales Line Id to get the lines.';
        CannotSetFieldForSalesTypeErr: Label 'Cannot set field ''%1'' for Sales Type ''%2''';
        Initialized: Boolean;
}
