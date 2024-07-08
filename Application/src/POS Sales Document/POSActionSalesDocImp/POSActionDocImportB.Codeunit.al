codeunit 6059961 "NPR POS Action: Doc. Import B"
{
    Access = Internal;

    procedure ImportDocument(SelectCustomer: Boolean;
                             ConfirmInvDiscAmt: Boolean;
                             DocumentType: Integer;
                             LocationSource: Option "POS Store","Location Filter Parameter";
                             LocationFilter: Text;
                             SalesDocViewString: Text;
                             SalesPersonFromOrder: Boolean;
                             POSSale: Codeunit "NPR POS Sale")
    begin
        ImportDocument(SelectCustomer,
                       ConfirmInvDiscAmt,
                       DocumentType,
                       LocationSource,
                       LocationFilter,
                       SalesDocViewString,
                       SalesPersonFromOrder,
                       false,
                       '',
                       POSSale);
    end;

    procedure ImportDocument(SelectCustomer: Boolean;
                            ConfirmInvDiscAmt: Boolean;
                            DocumentType: Integer;
                            LocationSource: Option "POS Store","Location Filter Parameter";
                            LocationFilter: Text;
                            SalesDocViewString: Text;
                            SalesPersonFromOrder: Boolean;
                            GroupCodeFilterEnabled: Boolean;
                            GroupCodeFilter: Text;
                            POSSale: Codeunit "NPR POS Sale")
    var
        SalesHeader: Record "Sales Header";
        SalesDocImpMgt: codeunit "NPR Sales Doc. Imp. Mgt.";
        POSSession: Codeunit "NPR POS Session";
    begin
        if not CheckCustomer(POSSale, SelectCustomer) then
            exit;

        GetGroupCodeFilter(GroupCodeFilterEnabled,
                           GroupCodeFilter);
        if not
            SelectDocument(
              POSSale,
              SalesHeader,
              DocumentType,
              SalesDocViewString,
              LocationSource,
              LocationFilter,
              GroupCodeFilter)
        then
            exit;

        SalesHeader.TestField("Bill-to Customer No.");



        if ConfirmInvDiscAmt then
            ConfirmInvDiscAmount(SalesHeader);

        SetPosSaleCustomer(POSSale, SalesHeader."Bill-to Customer No.");

        SalesDocImpMgt.SalesDocumentToPOS(POSSession, SalesHeader);

        if SalesPersonFromOrder then
            UpdateSalesPerson(POSSale, SalesHeader);
    end;

    local procedure ConfirmInvDiscAmount(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        SalesDocImpMgt: codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("Inv. Discount Amount", '>%1', 0);
        SalesLine.CalcSums("Inv. Discount Amount");
        if SalesLine."Inv. Discount Amount" > 0 then begin
            if not Confirm(SalesDocImpMgt.GetImportInvDiscAmtQst()) then
                exit;
        end;
    end;

    local procedure CheckCustomer(POSSale: Codeunit "NPR POS Sale"; SelectCustomer: Boolean): Boolean
    var
        SalePOS: Record "NPR POS Sale";
        Customer: Record Customer;
    begin
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then
            exit(true);

        if not SelectCustomer then
            exit(true);

        if PAGE.RunModal(0, Customer) <> ACTION::LookupOK then
            exit(false);

        SetPosSaleCustomer(POSSale, Customer."No.");
        Commit();
        exit(true);
    end;

    local procedure SetPosSaleCustomer(POSSale: Codeunit "NPR POS Sale"; CustomerNo: Code[20])
    var
        SalePOS: Record "NPR POS Sale";
    begin
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then
            exit;
        SalePOS.Validate("Customer No.", CustomerNo);
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
    end;

    local procedure SelectDocument(POSSale: Codeunit "NPR POS Sale";
                                   var SalesHeader: Record "Sales Header";
                                   DocumentType: Integer;
                                   SalesDocViewString: Text;
                                   LocationSource: Option "POS Store","Location Filter Parameter";
                                   LocationFilter: Text;
                                   GroupCodeFilter: Text): Boolean
    var
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        POSStore: Record "NPR POS Store";
        SalePOS: Record "NPR POS Sale";
    begin
        POSSale.GetCurrentSale(SalePOS);

        if SalesDocViewString <> '' then
            SalesHeader.SetView(SalesDocViewString);
        SalesHeader.FilterGroup(2);
        if SalePOS."Customer No." <> '' then
            SalesHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
        SalesHeader.SetRange("Document Type", DocumentType);
        case LocationSource of
            LocationSource::"POS Store":
                begin
                    POSStore.Get(SalePOS."POS Store Code");
                    LocationFilter := POSStore."Location Code";
                end;
        end;
        if LocationFilter <> '' then
            SalesHeader.SetFilter("Location Code", LocationFilter);

        SalesHeader.SetFilter("NPR Group Code", GroupCodeFilter);
        SalesHeader.FilterGroup(0);
        if SalesHeader.FindFirst() then;
        exit(RetailSalesDocImpMgt.SelectSalesDocument('', SalesHeader));
    end;

    local procedure UpdateSalesPerson(POSSale: Codeunit "NPR POS Sale"; SalesHeader: Record "Sales Header")
    var
        SalePOS: Record "NPR POS Sale";
    begin
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Salesperson Code", SalesHeader."Salesperson Code");
        SalePOS.Modify();
        POSSale.RefreshCurrent();
    end;

    #region GetGroupCodeFilter
    local procedure GetGroupCodeFilter(GroupCodeFilterEnabled: Boolean; var GroupCodeFilter: Text)
    var
        NPRGroupCode: Record "NPR Group Code";
        NPRGroupCodes: Page "NPR Group Codes";
    begin

        if not GroupCodeFilterEnabled then begin
            GroupCodeFilter := '';
            exit;
        end;

        if GroupCodeFilter <> '' then
            exit;

        Clear(NPRGroupCodes);
        NPRGroupCodes.LookupMode(true);
        if NPRGroupCodes.RunModal() <> action::lookupOK then
            exit;

        Clear(NPRGroupCode);
        NPRGroupCodes.SetSelectionFilter(NPRGroupCode);

        NPRGroupCode.SetLoadFields(Code);
        if not NPRGroupCode.FindSet(false) then
            exit;
        repeat
            GroupCodeFilter += '|' + NPRGroupCode.Code;
        until NPRGroupCode.Next() = 0;

        GroupCodeFilter := CopyStr(GroupCodeFilter, 2, StrLen(GroupCodeFilter));

    end;
    #endregion GetGroupCodeFilter
}