codeunit 6150789 "POS Action - Print Item"
{
    // NPR5.34/TSA /20170710  CASE 282999 Added RegisterDataBinding to workflow
    // NPR5.37/MMV /20171009  CASE 289725 Unify print flow.
    // NPR5.37.01/MMV /20171113 CASE 296267 Use entered quantity in 'Selected Line' mode.
    // NPR5.46/MHA /20181005  CASE 330714 Changed Label Quantity to ABS to enable print of negative quantities in PrintAllLines()


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Print item-based prints.';
        Title: Label 'Item Print';
        PrintQuantity: Label 'Quantity To Print';

    local procedure ActionCode(): Text
    begin
        exit('PRINT_ITEM');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode,
            ActionDescription,
            ActionVersion,
            Type::Button,
            "Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep('1', 'if (param.LineSetting == param.LineSetting["Selected Line"]) { intpad({ title: labels.title, caption: labels.caption, value: 1, notBlank: true}, "value").respond() } else { respond() };');
            RegisterWorkflow(false);

            RegisterOptionParameter('LineSetting','All Lines,Selected Line','Selected Line');
            RegisterOptionParameter('PrintType','Price,Shelf,Sign','Price');

            //-NPR5.34 [282999]
            RegisterDataBinding();
            //+NPR5.34 [282999]

          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption (ActionCode, 'title', Title);
        Captions.AddActionCaption (ActionCode, 'caption', PrintQuantity);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        LineSetting: Option "All Lines","Selected Line";
        PrintType: Integer;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);

        JSON.SetScope('parameters',true);
        LineSetting := JSON.GetInteger('LineSetting', true);
        PrintType := JSON.GetInteger('PrintType', true);

        case LineSetting of
          LineSetting::"All Lines" : PrintAllLines(POSSession, FrontEnd, PrintType);
          LineSetting::"Selected Line" : PrintSelectedLine(Context, POSSession, FrontEnd, PrintType);
        end;

        Handled := true;
    end;

    local procedure PrintAllLines(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";PrintType: Integer)
    var
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOS2: Record "Sale Line POS";
        POSSaleLine: Codeunit "POS Sale Line";
        RetailJnlLine: Record "Retail Journal Line";
        GUID: Guid;
        LabelLibrary: Codeunit "Label Library";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        GUID := CreateGuid();

        with SaleLinePOS2 do begin
          SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
          SetRange(Type, SaleLinePOS2.Type::Item);

          if FindSet then repeat
            //-NPR5.37 [289725]
            //-NPR5.46 [330714]
            // LabelLibrary.ItemToRetailJnlLine("No.", "Variant Code", Quantity, GUID, RetailJnlLine);
            LabelLibrary.ItemToRetailJnlLine("No.","Variant Code",Abs(Quantity),GUID,RetailJnlLine);
            //+NPR5.46 [330714]
            //SaleLineToRJL(GUID, RetailJnlLine, SaleLinePOS2);
            //+NPR5.37 [289725]
          until Next = 0;
        end;

        RetailJnlLine.SetRange("No.", GUID);
        if not RetailJnlLine.FindSet then
          exit;

        PrintRJL(RetailJnlLine, PrintType);

        RetailJnlLine.DeleteAll;
    end;

    local procedure PrintSelectedLine(Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";PrintType: Integer)
    var
        GUID: Guid;
        JSON: Codeunit "POS JSON Management";
        SaleLinePOS: Record "Sale Line POS";
        QuantityInput: Integer;
        POSSaleLine: Codeunit "POS Sale Line";
        RetailJnlLine: Record "Retail Journal Line";
        LabelLibrary: Codeunit "Label Library";
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);

        QuantityInput := JSON.GetInteger('value', true);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        GUID := CreateGuid();

        //-NPR5.37 [289725]
        //SaleLineToRJL(GUID, RetailJnlLine, SaleLinePOS);
        //-NPR5.37.01 [296267]
        //LabelLibrary.ItemToRetailJnlLine(SaleLinePOS."No.", SaleLinePOS."Variant Code", SaleLinePOS.Quantity, GUID, RetailJnlLine);
        LabelLibrary.ItemToRetailJnlLine(SaleLinePOS."No.", SaleLinePOS."Variant Code", QuantityInput, GUID, RetailJnlLine);
        //+NPR5.37.01 [296267]
        //+NPR5.37 [289725]

        RetailJnlLine.SetRange("No.", GUID);
        if not RetailJnlLine.FindFirst then
          exit;

        //-NPR5.37 [289725]
        // RetailJnlLine.Quantity := QuantityInput;
        // RetailJnlLine.MODIFY;
        //+NPR5.37 [289725]

        PrintRJL(RetailJnlLine, PrintType);

        RetailJnlLine.DeleteAll;
    end;

    local procedure PrintRJL(var RetailJnlLine: Record "Retail Journal Line";PrintType: Option Price,Shelf,Sign)
    var
        ReportSelectionRetail: Record "Report Selection Retail";
        LabelLibrary: Codeunit "Label Library";
    begin
        case PrintType of
          PrintType::Price: ReportSelectionRetail."Report Type" := ReportSelectionRetail."Report Type"::"Price Label";
          PrintType::Shelf: ReportSelectionRetail."Report Type" := ReportSelectionRetail."Report Type"::"Shelf Label";
          PrintType::Sign:  ReportSelectionRetail."Report Type" := ReportSelectionRetail."Report Type"::Sign;
        end;

        Commit;

        LabelLibrary.PrintRetailJournal(RetailJnlLine, ReportSelectionRetail."Report Type");
    end;
}

