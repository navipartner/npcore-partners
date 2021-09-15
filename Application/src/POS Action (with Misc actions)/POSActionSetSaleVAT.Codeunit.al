codeunit 6150842 "NPR POS Action - Set Sale VAT"
{

    var
        ActionDescription: Label 'Action for changing VAT Business Posting Group of active sale.';
        ConfirmTitle: Label 'Confirm VAT';
        ConfirmLead: Label 'Switch %1 on active sale?';
        ERROR_MINAMOUNT: Label 'Sale amount is below the minimum limit';
        ERROR_MAXAMOUNT: Label 'Sale amount is above the maximum limit';
        COMMENT_VATADDED: Label 'VAT added to sale';
        COMMENT_VATREMOVED: Label 'VAT removed from sale';

    local procedure ActionCode(): Code[20]
    begin
        exit('SET_SALE_VAT');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin

            Sender.RegisterWorkflowStep('changeVAT', 'if (param.ConfirmDialog) { confirm(labels.confirmTitle, labels.confirmLead).respond(); } else { respond(); }');
            Sender.RegisterWorkflow(false);

            Sender.RegisterBooleanParameter('MinimumSaleAmountLimit', false);
            Sender.RegisterDecimalParameter('MinimumSaleAmount', 0);
            Sender.RegisterBooleanParameter('MaximumSaleAmountLimit', false);
            Sender.RegisterDecimalParameter('MaximumSaleAmount', 0);
            Sender.RegisterBooleanParameter('AddCommentLine', false);
            Sender.RegisterBooleanParameter('ConfirmDialog', true);
            Sender.RegisterTextParameter('GenBusPostingGroup', '');
            Sender.RegisterTextParameter('VATBusPostingGroup', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
    begin
        Captions.AddActionCaption(ActionCode(), 'confirmTitle', ConfirmTitle);
        Captions.AddActionCaption(ActionCode(), 'confirmLead', StrSubstNo(ConfirmLead, VATBusinessPostingGroup.TableCaption));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        VATBusPostingGroup: Text;
        GenBusPostingGroup: Text;
        MinSaleAmountLimit: Boolean;
        MaxSaleAmountLimit: Boolean;
        MinSaleAmount: Decimal;
        MaxSaleAmount: Decimal;
        AddCommentLine: Boolean;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        MinSaleAmountLimit := JSON.GetBooleanParameterOrFail('MinimumSaleAmountLimit', ActionCode());
        MinSaleAmount := JSON.GetDecimalParameterOrFail('MinimumSaleAmount', ActionCode());
        MaxSaleAmountLimit := JSON.GetBooleanParameterOrFail('MaximumSaleAmountLimit', ActionCode());
        MaxSaleAmount := JSON.GetDecimalParameterOrFail('MaximumSaleAmount', ActionCode());
        AddCommentLine := JSON.GetBooleanParameterOrFail('AddCommentLine', ActionCode());
        GenBusPostingGroup := JSON.GetStringParameterOrFail('GenBusPostingGroup', ActionCode());
        VATBusPostingGroup := JSON.GetStringParameterOrFail('VATBusPostingGroup', ActionCode());

        CheckLimits(POSSession, MinSaleAmount, MinSaleAmountLimit, MaxSaleAmount, MaxSaleAmountLimit);
        ChangeSaleVATBusPostingGroup(POSSession, GenBusPostingGroup, VATBusPostingGroup, AddCommentLine);
    end;

    local procedure CheckLimits(POSSession: Codeunit "NPR POS Session"; MinSaleAmount: Decimal; MinSaleAmountLimit: Boolean; MaxSaleAmount: Decimal; MaxSaleAmountLimit: Boolean)
    var
        POSSale: Codeunit "NPR POS Sale";
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ChangeAmount: Decimal;
        RoundingAmount: Decimal;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetTotals(SalesAmount, PaidAmount, ChangeAmount, RoundingAmount);

        if MinSaleAmountLimit and (SalesAmount < MinSaleAmount) then
            Error('%1 (%2)', ERROR_MINAMOUNT, MinSaleAmount);

        if MaxSaleAmountLimit and (SalesAmount > MaxSaleAmount) then
            Error('%1 (%2)', ERROR_MAXAMOUNT, MaxSaleAmount);
    end;

    local procedure InsertComment(POSSaleLine: Codeunit "NPR POS Sale Line"; VATAmountDifference: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSDescLbl: Label '%1: %2', Locked = true;
    begin
        SaleLinePOS.Type := SaleLinePOS.Type::Comment;

        if VATAmountDifference = 0 then
            exit
        else
            if VATAmountDifference > 0 then
                SaleLinePOS.Description := StrSubstNo(SaleLinePOSDescLbl, COMMENT_VATREMOVED, VATAmountDifference)
            else
                SaleLinePOS.Description := StrSubstNo(SaleLinePOSDescLbl, COMMENT_VATADDED, VATAmountDifference);

        POSSaleLine.InsertLine(SaleLinePOS);
    end;

    local procedure ChangeSaleVATBusPostingGroup(POSSession: Codeunit "NPR POS Session"; NewGenBusPostingGroup: Text; NewVATBusPostingGroup: Text; AddCommentLine: Boolean)
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        OldVATTotal: Decimal;
        NewVATTotal: Decimal;
    begin
        if NewGenBusPostingGroup <> '' then
            GenBusinessPostingGroup.Get(NewGenBusPostingGroup);
        VATBusinessPostingGroup.Get(NewVATBusPostingGroup);

        POSSession.GetSaleLine(POSSaleLine);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
        if SaleLinePOS.FindSet() then
            repeat
                OldVATTotal += (SaleLinePOS."Amount Including VAT" - SaleLinePOS.Amount);
                if (NewGenBusPostingGroup <> '') and (SaleLinePOS."Gen. Bus. Posting Group" <> GenBusinessPostingGroup.Code) then
                    SaleLinePOS.Validate("Gen. Bus. Posting Group", NewGenBusPostingGroup);
                if (NewVATBusPostingGroup <> '') and (SaleLinePOS."VAT Bus. Posting Group" <> VATBusinessPostingGroup.Code) then
                    SaleLinePOS.Validate("VAT Bus. Posting Group", NewVATBusPostingGroup);
                SaleLinePOS.UpdateVATSetup();
                SaleLinePOS."Unit Price" := SaleLinePOS.FindItemSalesPrice();
                SaleLinePOS.UpdateAmounts(SaleLinePOS);
                SaleLinePOS.Modify();
                NewVATTotal += (SaleLinePOS."Amount Including VAT" - SaleLinePOS.Amount);
            until SaleLinePOS.Next() = 0;
        if (NewGenBusPostingGroup <> '') and (SalePOS."Gen. Bus. Posting Group" <> GenBusinessPostingGroup.Code) then
            SalePOS.Validate("Gen. Bus. Posting Group", NewGenBusPostingGroup);
        SalePOS.Validate("VAT Bus. Posting Group", VATBusinessPostingGroup.Code);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);

        if AddCommentLine then
            InsertComment(POSSaleLine, OldVATTotal - NewVATTotal);

        POSSaleLine.RefreshCurrent();
        POSSession.RequestRefreshData();
    end;
}

