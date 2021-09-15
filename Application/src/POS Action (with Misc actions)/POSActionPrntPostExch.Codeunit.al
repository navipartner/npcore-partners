codeunit 6151177 "NPR POS Action: Prnt Post.Exch"
{
    var
        ActionDescriptionCaption: Label 'This action is used to print an exchange label after a sale has been posted, either last sale or selectively.';
        ChooseDocumentCaption: Label 'Please choose sale';
        ChooseDetailsCaption: Label 'Please choose sale details';
        NoSaleLinesErr: Label 'The sale selected has no lines';

    local procedure ActionCode(): Code[20]
    begin
        exit('PRINT_TMPL_POSTED');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescriptionCaption,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('', 'respond();');
            Sender.RegisterWorkflow(false);
            Sender.RegisterTextParameter('Template', '');
            Sender.RegisterBooleanParameter('LastSale', false);
            Sender.RegisterBooleanParameter('SingleLine', false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        JSON: Codeunit "NPR POS JSON Management";
        TemplateMgt: Codeunit "NPR RP Template Mgt.";
        POSSetup: Codeunit "NPR POS Setup";
        RecordVar: Variant;
        LastSale: Boolean;
        SingleLine: Boolean;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());

        LastSale := JSON.GetBooleanParameterOrFail('LastSale', ActionCode());
        SingleLine := JSON.GetBooleanParameterOrFail('SingleLine', ActionCode());

        POSSession.GetSetup(POSSetup);

        POSEntry.FilterGroup(2);
        POSEntry.SetRange("POS Unit No.", POSSetup.GetPOSUnitNo());
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        POSEntry.FilterGroup(0);

        if LastSale then begin
            POSEntry.FindLast();
            POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        end else
            RunModalPage(POSEntry, POSSalesLine, SingleLine);

        if POSSalesLine.Count() = 0 then
            Error(NoSaleLinesErr);

        RecordVar := POSSalesLine;
        TemplateMgt.PrintTemplate(CopyStr(JSON.GetStringParameterOrFail('Template', ActionCode()), 1, 20), RecordVar, 0);

        Handled := true;
    end;

    local procedure RunModalPage(var POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line"; SingleLine: Boolean)
    var
        POSEntries: Page "NPR POS Entries";
        POSSalesLineList: Page "NPR POS Entry Sales Line List";
    begin
        POSEntries.LookupMode(true);
        POSEntries.Caption(ChooseDocumentCaption);
        POSEntries.SetTableView(POSEntry);
        if not (POSEntries.RunModal() = ACTION::LookupOK) then
            Error('');

        POSEntries.GetRecord(POSEntry);
        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");

        if not SingleLine then
            exit;

        POSSalesLineList.LookupMode(true);
        POSSalesLineList.Caption(ChooseDetailsCaption);
        POSSalesLineList.SetTableView(POSSalesLine);
        if not (POSSalesLineList.RunModal() = ACTION::LookupOK) then
            Error('');

        POSSalesLineList.GetRecord(POSSalesLine);
        POSSalesLine.SetRecFilter();
    end;
}

