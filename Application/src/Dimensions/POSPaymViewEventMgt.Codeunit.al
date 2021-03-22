codeunit 6151053 "NPR POS Paym. View Event Mgt."
{
    var
        Text000: Label 'Enter Dimension on POS Sale';

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        case Rec."Subscriber Function" of
            'PopupDimension':
                begin
                    Rec.Description := CopyStr(Text000, 1, MaxStrLen(Rec.Description));
                    Rec."Sequence No." := CurrCodeunitId();
                    Rec.Enabled := false;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS View Change WF Mgt.", 'OnPaymentView', '', true, true)]
    local procedure PopupDimension(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; var POSSession: Codeunit "NPR POS Session")
    var
        POSPaymentViewEventSetup: Record "NPR POS Paym. View Event Setup";
        POSPaymentViewLogEntry: Record "NPR POS Paym. View Log Entry";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        DimensionValue: Code[20];
        POSSalesNo: Integer;
        POSAction: Record "NPR POS Action";
        POSFrontEndMgt: Codeunit "NPR POS Front End Management";
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'PopupDimension' then
            exit;

        POSSession.GetFrontEnd(POSFrontEndMgt, false);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if SkipPopup(SalePOS, POSPaymentViewEventSetup) then
            exit;

        POSPaymentViewLogEntry.SetCurrentKey("POS Unit", "Sales Ticket No.");
        POSPaymentViewLogEntry.SetRange("POS Unit", SalePOS."Register No.");
        POSPaymentViewLogEntry.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if not POSPaymentViewLogEntry.FindFirst then begin
            Clear(POSPaymentViewLogEntry);
            case POSPaymentViewEventSetup."Popup per" of
                POSPaymentViewEventSetup."Popup per"::All:
                    begin
                        POSPaymentViewLogEntry.SetCurrentKey("POS Sales No.");
                        if POSPaymentViewLogEntry.FindLast then;
                        POSSalesNo := POSPaymentViewLogEntry."POS Sales No." + 1;
                    end;
                POSPaymentViewEventSetup."Popup per"::"POS Store":
                    begin
                        POSPaymentViewLogEntry.SetCurrentKey("POS Store", "POS Sales No.");
                        POSPaymentViewLogEntry.SetRange("POS Store", SalePOS."POS Store Code");
                        if POSPaymentViewLogEntry.FindLast then;
                        POSSalesNo := POSPaymentViewLogEntry."POS Sales No." + 1;
                    end;
                POSPaymentViewEventSetup."Popup per"::"POS Unit":
                    begin
                        POSPaymentViewLogEntry.SetCurrentKey("POS Unit", "POS Sales No.");
                        POSPaymentViewLogEntry.SetRange("POS Unit", SalePOS."Register No.");
                        if POSPaymentViewLogEntry.FindLast then;
                        POSSalesNo := POSPaymentViewLogEntry."POS Sales No." + 1;
                    end;
            end;

            Clear(POSPaymentViewLogEntry);
            POSPaymentViewLogEntry.Init;
            POSPaymentViewLogEntry."Entry No." := 0;
            POSPaymentViewLogEntry."POS Store" := SalePOS."POS Store Code";
            POSPaymentViewLogEntry."POS Unit" := SalePOS."Register No.";
            POSPaymentViewLogEntry."Sales Ticket No." := SalePOS."Sales Ticket No.";
            POSPaymentViewLogEntry."POS Sales No." := POSSalesNo;
            if POSPaymentViewEventSetup."Popup every" > 0 then
                POSPaymentViewLogEntry."Post Code Popup" := (POSPaymentViewLogEntry."POS Sales No." mod POSPaymentViewEventSetup."Popup every" = 0);
            POSPaymentViewLogEntry."Log Date" := CurrentDateTime;
            POSPaymentViewLogEntry.Insert;
        end;

        if not POSPaymentViewLogEntry."Post Code Popup" then
            exit;

        POSAction.Get('SALE_DIMENSION');
        case POSPaymentViewEventSetup."Popup Mode" of
            POSPaymentViewEventSetup."Popup Mode"::List:
                begin
                    POSAction.SetWorkflowInvocationParameter('ValueSelection', '0', POSFrontEndMgt);
                end;
            POSPaymentViewEventSetup."Popup Mode"::Numpad:
                begin
                    POSAction.SetWorkflowInvocationParameter('ValueSelection', '2', POSFrontEndMgt);
                end;
            POSPaymentViewEventSetup."Popup Mode"::Input:
                begin
                    POSAction.SetWorkflowInvocationParameter('ValueSelection', '3', POSFrontEndMgt);
                end;
        end;
        POSAction.SetWorkflowInvocationParameter('StatisticsFrequency', 1, POSFrontEndMgt);
        POSAction.SetWorkflowInvocationParameter('ShowConfirmMessage', false, POSFrontEndMgt);
        POSAction.SetWorkflowInvocationParameter('DimensionSource', '2', POSFrontEndMgt);
        POSAction.SetWorkflowInvocationParameter('DimensionCode', POSPaymentViewEventSetup."Dimension Code", POSFrontEndMgt);
        POSAction.SetWorkflowInvocationParameter('CreateDimValue', POSPaymentViewEventSetup."Create New Dimension Values", POSFrontEndMgt);
        POSFrontEndMgt.InvokeWorkflow(POSAction);

        POSSale.RefreshCurrent();
        POSSession.RequestRefreshData();
    end;

    local procedure SkipPopup(SalePOS: Record "NPR Sale POS"; var POSPaymentViewEventSetup: Record "NPR POS Paym. View Event Setup"): Boolean
    begin

        if not POSPaymentViewEventSetup.Get then
            exit(true);

        if not POSPaymentViewEventSetup."Dimension Popup Enabled" then
            exit(true);

        if not ValidTime(Time, POSPaymentViewEventSetup."Popup Start Time", POSPaymentViewEventSetup."Popup End Time") then
            exit(true);

        if POSPaymentViewEventSetup."Dimension Code" = '' then
            exit(true);

        if POSPaymentViewEventSetup."Skip Popup on Dimension Value" then begin
            if HasDimValue(SalePOS, POSPaymentViewEventSetup."Dimension Code") then
                exit(true);
        end;

        if SkipOnItemFilter(SalePOS) then
            exit(true);

        exit(false);
    end;

    local procedure SkipOnItemFilter(SalePOS: Record "NPR Sale POS"): Boolean;
    var
        SalePOSLine: Record "NPR Sale Line POS";
        PopupDimFilter: Record "NPR Popup Dim. Filter";
    begin
        if PopupDimFilter.IsEmpty() then
            exit(false);
        SalePOSLine.SetRange(Type, SalePOSLine.Type::Item);
        if not SalePOSLine.FindSet() then
            exit(true);
        repeat
            if PopupDimFilter.Get(PopupDimFilter.Type::Item, SalePOSLine."No.") or PopupDimFilter.Get(PopupDimFilter.Type::"Item Category", SalePOSLine."Item Category Code") then
                exit(false);
        until SalePOSLine.Next() = 0;

        exit(true);
    end;

    local procedure ValidTime(CheckTime: Time; StartTime: Time; EndTime: Time): Boolean
    begin
        if EndTime = 0T then
            exit(CheckTime >= StartTime);

        if StartTime = 0T then
            exit(CheckTime <= EndTime);

        if StartTime <= EndTime then
            exit((CheckTime >= StartTime) and (CheckTime <= EndTime));

        exit((CheckTime >= StartTime) or (CheckTime <= EndTime));
    end;

    local procedure HasDimValue(SalePOS: Record "NPR Sale POS"; DimensionCode: Code[20]): Boolean
    var
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        if SalePOS."Dimension Set ID" = 0 then
            exit(false);
        DimensionSetEntry.SetRange("Dimension Set ID", SalePOS."Dimension Set ID");
        DimensionSetEntry.SetRange("Dimension Code", DimensionCode);
        if not DimensionSetEntry.FindFirst then
            exit(false);

        exit(DimensionSetEntry."Dimension Value Code" <> '');
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Paym. View Event Mgt.");
    end;
}

