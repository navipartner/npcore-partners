codeunit 6150842 "NPR POS Action - Set Sale VAT"
{
    // NPR5.38/MMV /20180119 CASE 302307 Created
    // NPR5.45/MHA /20180803  CASE 323705 Signature changed on SaleLinePOS.FindItemSalesPrice()
    // NPR5.48/THRO/20181129  CASE 333938 Added option to set Gen. Bus. Posting Group


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Action for changing VAT Business Posting Group of active sale.';
        ConfirmTitle: Label 'Confirm VAT';
        ConfirmLead: Label 'Switch %1 on active sale?';
        ERROR_MINAMOUNT: Label 'Sale amount is below the minimum limit';
        ERROR_MAXAMOUNT: Label 'Sale amount is above the maximum limit';
        COMMENT_VATADDED: Label 'VAT added to sale';
        COMMENT_VATREMOVED: Label 'VAT removed from sale';

    local procedure ActionCode(): Text
    begin
        exit('SET_SALE_VAT');
    end;

    local procedure ActionVersion(): Text
    begin
        //-NPR5.48 [333938]
        exit('1.1');
        //+NPR5.48 [333938]
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
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
            //-NPR5.48 [333938]
            Sender.RegisterTextParameter('GenBusPostingGroup', '');
            //+NPR5.48 [333938]
            Sender.RegisterTextParameter('VATBusPostingGroup', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
    begin
        Captions.AddActionCaption(ActionCode, 'confirmTitle', ConfirmTitle);
        Captions.AddActionCaption(ActionCode, 'confirmLead', StrSubstNo(ConfirmLead, VATBusinessPostingGroup.TableCaption));
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
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
        //-NPR5.48 [333938]
        GenBusPostingGroup := JSON.GetStringParameterOrFail('GenBusPostingGroup', ActionCode());
        //+NPR5.48 [333938]
        VATBusPostingGroup := JSON.GetStringParameterOrFail('VATBusPostingGroup', ActionCode());

        CheckLimits(POSSession, MinSaleAmount, MinSaleAmountLimit, MaxSaleAmount, MaxSaleAmountLimit);
        //-NPR5.48 [333938]
        ChangeSaleVATBusPostingGroup(POSSession, GenBusPostingGroup, VATBusPostingGroup, AddCommentLine);
        //+NPR5.48 [333938]
    end;

    local procedure "--"()
    begin
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
            Error(StrSubstNo('%1 (%2)', ERROR_MINAMOUNT, MinSaleAmount));

        if MaxSaleAmountLimit and (SalesAmount > MaxSaleAmount) then
            Error(StrSubstNo('%1 (%2)', ERROR_MAXAMOUNT, MaxSaleAmount));
    end;

    local procedure InsertComment(POSSaleLine: Codeunit "NPR POS Sale Line"; VATAmountDifference: Decimal)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        SaleLinePOS.Type := SaleLinePOS.Type::Comment;

        if VATAmountDifference = 0 then
            exit
        else
            if VATAmountDifference > 0 then
                SaleLinePOS.Description := StrSubstNo('%1: %2', COMMENT_VATREMOVED, VATAmountDifference)
            else
                SaleLinePOS.Description := StrSubstNo('%1: %2', COMMENT_VATADDED, VATAmountDifference);

        POSSaleLine.InsertLine(SaleLinePOS);
    end;

    local procedure ChangeSaleVATBusPostingGroup(POSSession: Codeunit "NPR POS Session"; NewGenBusPostingGroup: Text; NewVATBusPostingGroup: Text; AddCommentLine: Boolean)
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR Sale Line POS";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        OldVATTotal: Decimal;
        NewVATTotal: Decimal;
    begin
        //-NPR5.48 [333938]
        if NewGenBusPostingGroup <> '' then
            GenBusinessPostingGroup.Get(NewGenBusPostingGroup);
        //+NPR5.48 [333938]
        VATBusinessPostingGroup.Get(NewVATBusPostingGroup);

        POSSession.GetSaleLine(POSSaleLine);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
        //-NPR5.48 [333938]
        //SaleLinePOS.SETFILTER("VAT Bus. Posting Group", '<>%1', VATBusinessPostingGroup.Code);
        //+NPR5.48 [333938]
        if SaleLinePOS.FindSet then
            repeat
                OldVATTotal += (SaleLinePOS."Amount Including VAT" - SaleLinePOS.Amount);
                //-NPR5.48 [333938]
                if (NewGenBusPostingGroup <> '') and (SaleLinePOS."Gen. Bus. Posting Group" <> GenBusinessPostingGroup.Code) then
                    SaleLinePOS.Validate("Gen. Bus. Posting Group", NewGenBusPostingGroup);
                if (NewVATBusPostingGroup <> '') and (SaleLinePOS."VAT Bus. Posting Group" <> VATBusinessPostingGroup.Code) then
                    SaleLinePOS.Validate("VAT Bus. Posting Group", NewVATBusPostingGroup);
                //+NPR5.48 [333938]
                SaleLinePOS.UpdateVATSetup();
                //-NPR5.45 [323705]
                //SaleLinePOS."Unit Price" := SaleLinePOS.FindItemSalesPrice(SaleLinePOS);
                SaleLinePOS."Unit Price" := SaleLinePOS.FindItemSalesPrice();
                //+NPR5.45 [323705]
                SaleLinePOS.UpdateAmounts(SaleLinePOS);
                SaleLinePOS.Modify;
                NewVATTotal += (SaleLinePOS."Amount Including VAT" - SaleLinePOS.Amount);
            until SaleLinePOS.Next = 0;
        //-NPR5.48 [333938]
        if (NewGenBusPostingGroup <> '') and (SalePOS."Gen. Bus. Posting Group" <> GenBusinessPostingGroup.Code) then
            SalePOS.Validate("Gen. Bus. Posting Group", NewGenBusPostingGroup);
        //+NPR5.48 [333938]
        SalePOS.Validate("VAT Bus. Posting Group", VATBusinessPostingGroup.Code);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);

        if AddCommentLine then
            InsertComment(POSSaleLine, OldVATTotal - NewVATTotal);

        POSSaleLine.RefreshCurrent();
        POSSession.RequestRefreshData();
    end;
}

