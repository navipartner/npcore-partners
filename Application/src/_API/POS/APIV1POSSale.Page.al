page 6014665 "NPR APIV1 - POS Sale"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'POS Sale';
    DelayedInsert = true;
    EntityName = 'posSale';
    EntitySetName = 'posSales';
    ODataKeyFields = "POS Sale System Id";
    PageType = API;
    SourceTable = "NPR POS Sales API Buffer"; //tableType = Temporary

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec."POS Sale System Id")
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(password; Rec.Password)
                {
                    Caption = 'Password';
                }
                field(registerNo; Rec."Register No.")
                {
                    Caption = 'POS Unit No.';
                    Editable = false;
                }
                field(salesTicketNo; Rec."Sales Ticket No.")
                {
                    Caption = 'Sales Ticket No.';
                    Editable = false; //setup automatically
                }
                field(saletype; Rec."Sale type")
                {
                    Caption = 'Sale type';
                    Editable = false; //setup automatically
                }
                field(posStoreCode; Rec."POS Store Code")
                {
                    Caption = 'POS Store Code';
                }
                field(salespersonCode; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson Code';
                }
                field("date"; Rec.Date)
                {
                    Caption = 'Date';
                    Editable = false; //setup automatically
                }
                field(startTime; Rec."Start Time")
                {
                    Caption = 'Start Time';
                    Editable = false; //setup automatically
                }

                field(customerType; Rec."Customer Type")
                {
                    Caption = 'Customer Type';
                }
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.';
                }

                field(contactNo; Rec."Contact No.")
                {
                    Caption = 'Contact No.';
                }
                field(reference; Rec.Reference)
                {
                    Caption = 'Reference';
                }

                field(pricesIncludingVAT; Rec."Prices Including VAT")
                {
                    Caption = 'Prices Including VAT';
                }

                field(externalDocumentNo; Rec."External Document No.")
                {
                    Caption = 'External Document No.';
                }
                //add Sales Line subform
                part(posSaleLines; "NPR APIV1 - POS Sale Line")
                {
                    Caption = 'POS Sale Lines';
                    EntityName = 'posSaleLine';
                    EntitySetName = 'posSaleLines';
                    SubPageLink = "POS Sale System Id" = field("POS Sale System Id");
                }

            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        InsertNewPOSSale();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        IdFilter: Text;
        APIPOSSaleMgmt: Codeunit "NPR APIV1 - POS Sale Mgmt.";
    begin
        IF NOT HeaderLoaded then begin
            IdFilter := Rec.GetFilter("POS Sale System Id");
            APIPOSSaleMgmt.LoadPOSSale(Rec, IdFilter);

            HeaderLoaded := true;
        end;

        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        POSSaleRec: Record "NPR POS Sale";
    begin
        POSSaleRec.GetBySystemId(Rec."POS Sale System Id");
        POSSaleRec.Delete(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Error(ModifyNotAllowedErr);
    end;

    var
        Setup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
        Sale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        HeaderLoaded: Boolean;
        ModifyNotAllowedErr: Label 'It is not allowed to modify an existing POS Sale. Please Delete existing record and Recreate it if a correction is needed.';

    local procedure InitializePOSSale()
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        POSSession.Constructor(Setup, POSSession);
        Setup.GetPOSUnit(POSUnit);

        IF Rec."Salesperson Code" <> '' then begin
            SalespersonPurchaser.Get(Rec."Salesperson Code");
            Setup.SetSalesperson(SalespersonPurchaser);
        end else begin
            SalespersonPurchaser.SetRange("NPR Register Password", Rec.Password);
            if ((SalespersonPurchaser.FindFirst() and (Rec.Password <> ''))) then
                Setup.SetSalesperson(SalespersonPurchaser)
            else
                Error('Illegal password.');
        end;
    end;

    local procedure InsertNewPOSSale()
    var
        APIPOSSaleMgmt: Codeunit "NPR APIV1 - POS Sale Mgmt.";
    begin
        InitializePOSSale();

        POSSession.StartPOSSessionWS();
        POSSession.StartTransactionWS();
        POSSession.GetSale(Sale);
        APIPOSSaleMgmt.UpdatePOSSale(Rec, Sale);

        CurrPage.posSaleLines.Page.Initialize(POSSession, Rec);
    end;

    [ServiceEnabled]
    procedure TryEndDirectSale() InfoText: Text
    var
        POSSaleRec: Record "NPR POS Sale";
        POSSaleCodeunit: Codeunit "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        APIPOSSaleMgmt: Codeunit "NPR APIV1 - POS Sale Mgmt.";
        POSEntryCreatedTxt: Label 'POS Entry created.';
        InfoTxtJson: JsonObject;
    begin
        POSSaleRec.GetBySystemId(Rec."POS Sale System Id");

        APIPOSSaleMgmt.ValidateBalance(POSSaleRec);
        POSSaleCodeunit.ValidateSaleBeforeEnd(POSSaleRec);
        APIPOSSaleMgmt.EndSaleTransaction(POSSaleRec, POSEntry);

        InfoTxtJson.Add('Action', POSEntryCreatedTxt);
        InfoTxtJson.Add('Entry No.', POSEntry."Entry No.");
        InfoTxtJson.WriteTo(InfoText);
    end;

    [ServiceEnabled]
    procedure GetSaleBalance(): Decimal
    var
        POSSaleRec: Record "NPR POS Sale";
        SaleAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        Subtotal: Decimal;
        APIPOSSaleMgmt: Codeunit "NPR APIV1 - POS Sale Mgmt.";
    begin
        POSSaleRec.GetBySystemId(Rec."POS Sale System Id");
        APIPOSSaleMgmt.CalculateBalance(POSSaleRec, SaleAmount, PaidAmount, ReturnAmount, Subtotal);
        Exit(ReturnAmount);
    end;

    [ServiceEnabled]
    procedure ExportToDocument(inputJsonTxt: Text) InfoText: Text
    var
        POSSaleRec: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        APIPOSSaleMgmt: Codeunit "NPR APIV1 - POS Sale Mgmt.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        JsonObj: JsonObject;
        InfoTxtJson: JsonObject;
        SalesHeaderCreatedTxt: Label 'Sales Header created.';
    begin
        POSSaleRec.GetBySystemId(Rec."POS Sale System Id");
        InitializePOSSale();
        POSSession.ResumeTransactionWS(POSSaleRec);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(POSSaleRec);
        POSSession.GetSaleLine(POSSaleLine);

        JsonObj.ReadFrom(inputJsonTxt);

        IF NOT APIPOSSaleMgmt.SetCustomer(JsonObj, POSSaleRec) then
            POSSaleRec.TestField("Customer No.");

        APIPOSSaleMgmt.SetDocExportReference(JsonObj, POSSaleRec);
        APIPOSSaleMgmt.SetPricesInclVAT(JsonObj, POSSaleRec);
        APIPOSSaleMgmt.SetDocExportParameters(JsonObj, POSSaleLine, RetailSalesDocMgt);
        APIPOSSaleMgmt.ValidateSale(POSSaleRec, RetailSalesDocMgt);

        RetailSalesDocMgt.ProcessPOSSale(POSSaleRec);

        RetailSalesDocMgt.GetCreatedSalesHeader(SalesHeader);
        InfoTxtJson.Add('Action', SalesHeaderCreatedTxt);
        InfoTxtJson.Add('Document Type', Format(SalesHeader."Document Type"));
        InfoTxtJson.Add('Document No.', SalesHeader."No.");
        InfoTxtJson.WriteTo(InfoText);
    end;

}
