codeunit 6150697 "NPR POS Act:Prnt Post.Exch BL"
{
    Access = Internal;
    procedure OnActionPrintTmplPosted(Setup: codeunit "NPR POS Setup"; LastSale: Boolean; SingleLine: Boolean; TemplateCode: Code[20]; TransactionFilter: Option posunit,posstore,alltransactions)
    var
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        TemplateMgt: Codeunit "NPR RP Template Mgt.";
        RecordVar: Variant;
        NoSaleLinesErr: Label 'The sale selected has no lines';
        POSStore: Record "NPR POS Store";
    begin
        POSEntry.FilterGroup(2);
        Setup.Initialize();
        Case TransactionFilter of
            TransactionFilter::posunit:
                POSEntry.SetRange("POS Unit No.", Setup.GetPOSUnitNo());
            TransactionFilter::posstore:
                begin
                    Setup.GetPOSStore(POSStore);
                    POSEntry.SetRange("POS Store Code", POSStore.Code);
                end;
        End;
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
        TemplateMgt.PrintTemplate(TemplateCode, RecordVar, 0);
    end;

    local procedure RunModalPage(var POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line"; SingleLine: Boolean)
    var
        POSEntries: Page "NPR POS Entries";
        POSSalesLineList: Page "NPR POS Entry Sales Line List";
        ChooseDocumentCaption: Label 'Please choose sale';
        ChooseDetailsCaption: Label 'Please choose sale details';
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