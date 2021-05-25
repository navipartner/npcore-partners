codeunit 6150789 "NPR POS Action: Print Item"
{
    var
        ActionDescription: Label 'Print item-based prints.';
        Title: Label 'Item Print';
        PrintQuantity: Label 'Quantity To Print';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Text
    begin
        exit('PRINT_ITEM');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
  ActionCode(),
  ActionDescription,
  ActionVersion(),
  Sender.Type::Button,
  Sender."Subscriber Instances Allowed"::Multiple)
then begin
            Sender.RegisterWorkflowStep('1', 'if (param.LineSetting == param.LineSetting["Selected Line"]) { intpad({ title: labels.title, caption: labels.caption, value: 1, notBlank: true}, "value").respond() } else { respond() };');
            Sender.RegisterWorkflow(false);

            Sender.RegisterOptionParameter('LineSetting', 'All Lines,Selected Line', 'Selected Line');
            Sender.RegisterOptionParameter('PrintType', 'Price,Shelf,Sign', 'Price');

            Sender.RegisterDataBinding();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'title', Title);
        Captions.AddActionCaption(ActionCode(), 'caption', PrintQuantity);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        LineSetting: Option "All Lines","Selected Line";
        PrintType: Integer;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        JSON.SetScopeParameters(ActionCode());
        LineSetting := JSON.GetIntegerOrFail('LineSetting', StrSubstNo(ReadingErr, ActionCode()));
        PrintType := JSON.GetIntegerOrFail('PrintType', StrSubstNo(ReadingErr, ActionCode()));

        case LineSetting of
            LineSetting::"All Lines":
                PrintAllLines(POSSession, PrintType);
            LineSetting::"Selected Line":
                PrintSelectedLine(Context, POSSession, FrontEnd, PrintType);
        end;

        Handled := true;
    end;

    local procedure PrintAllLines(POSSession: Codeunit "NPR POS Session"; PrintType: Integer)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOS2: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        RetailJnlLine: Record "NPR Retail Journal Line";
        GUID: Guid;
        LabelLibrary: Codeunit "NPR Label Library";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        GUID := CreateGuid();

        SaleLinePOS2.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOS2.SetRange(Type, SaleLinePOS2.Type::Item);

        if SaleLinePOS2.FindSet() then
            repeat
                LabelLibrary.ItemToRetailJnlLine(SaleLinePOS2."No.", SaleLinePOS2."Variant Code", Round(Abs(SaleLinePOS2.Quantity), 1, '>'), GUID, RetailJnlLine);
            until SaleLinePOS2.Next() = 0;

        RetailJnlLine.SetRange("No.", GUID);
        if not RetailJnlLine.FindSet() then
            exit;

        PrintRJL(RetailJnlLine, PrintType);

        RetailJnlLine.DeleteAll();
    end;

    local procedure PrintSelectedLine(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; PrintType: Integer)
    var
        GUID: Guid;
        JSON: Codeunit "NPR POS JSON Management";
        SaleLinePOS: Record "NPR POS Sale Line";
        QuantityInput: Integer;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        RetailJnlLine: Record "NPR Retail Journal Line";
        LabelLibrary: Codeunit "NPR Label Library";
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        QuantityInput := JSON.GetIntegerOrFail('value', StrSubstNo(ReadingErr, ActionCode()));

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        GUID := CreateGuid();

        LabelLibrary.ItemToRetailJnlLine(SaleLinePOS."No.", SaleLinePOS."Variant Code", QuantityInput, GUID, RetailJnlLine);

        RetailJnlLine.SetRange("No.", GUID);
        if not RetailJnlLine.FindFirst() then
            exit;

        PrintRJL(RetailJnlLine, PrintType);

        RetailJnlLine.DeleteAll();
    end;

    local procedure PrintRJL(var RetailJnlLine: Record "NPR Retail Journal Line"; PrintType: Option Price,Shelf,Sign)
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        LabelLibrary: Codeunit "NPR Label Library";
    begin
        case PrintType of
            PrintType::Price:
                ReportSelectionRetail."Report Type" := ReportSelectionRetail."Report Type"::"Price Label";
            PrintType::Shelf:
                ReportSelectionRetail."Report Type" := ReportSelectionRetail."Report Type"::"Shelf Label";
            PrintType::Sign:
                ReportSelectionRetail."Report Type" := ReportSelectionRetail."Report Type"::Sign;
        end;

        Commit();

        LabelLibrary.PrintRetailJournal(RetailJnlLine, ReportSelectionRetail."Report Type");
    end;
}
