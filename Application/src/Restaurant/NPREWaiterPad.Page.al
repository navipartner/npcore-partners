page 6150660 "NPR NPRE Waiter Pad"
{
    Caption = 'Waiter Pad';
    InsertAllowed = false;
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Kitchen Print';
    SourceTable = "NPR NPRE Waiter Pad";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(Control6014423)
            {
                ShowCaption = false;
                field("Start Time"; Rec."Start Time")
                {
                    ApplicationArea = All;
                    Caption = 'Opened';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Opened field';
                }
                field("Current Seating FF"; Rec."Current Seating FF")
                {
                    ApplicationArea = All;
                    Caption = 'Seating';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Seating field';
                }
                field("Current Seating Description"; Rec."Current Seating Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Seating Description field';
                }
                field("Number of Guests"; Rec."Number of Guests")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Number of Guests field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Status Description FF"; Rec."Status Description FF")
                {
                    ApplicationArea = All;
                    Caption = 'Waiter Pad Status';
                    DrillDown = false;
                    ToolTip = 'Specifies the value of the Waiter Pad Status field';

                    trigger OnAssistEdit()
                    var
                        FlowStatus: Record "NPR NPRE Flow Status";
                        NewStatusCode: Code[10];
                    begin
                        NewStatusCode := Rec.Status;
                        if LookupFlowStatus(FlowStatus."Status Object"::WaiterPad, NewStatusCode) then begin
                            Rec.Validate(Status, NewStatusCode);
                            Rec.CalcFields("Status Description FF");
                        end;
                    end;
                }
                field("Serving Step Code"; Rec."Serving Step Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Serving Step Code field';
                }
                field("Serving Step Description"; Rec."Serving Step Description")
                {
                    ApplicationArea = All;
                    Caption = 'Serving Step';
                    DrillDown = false;
                    ToolTip = 'Specifies the value of the Serving Step field';

                    trigger OnAssistEdit()
                    var
                        FlowStatus: Record "NPR NPRE Flow Status";
                        NewStatusCode: Code[10];
                    begin
                        NewStatusCode := Rec."Serving Step Code";
                        if LookupFlowStatus(FlowStatus."Status Object"::WaiterPadLineMealFlow, NewStatusCode) then begin
                            Rec.Validate("Serving Step Code", NewStatusCode);
                            Rec.CalcFields("Serving Step Description", "Status Description FF");
                        end;
                    end;
                }
                field("Pre-receipt Printed"; Rec."Pre-receipt Printed")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Pre-receipt Printed field';
                }
            }
            part(WaiterPadLinesSubpage; "NPR NPRE Waiter Pad Subform")
            {
                SubPageLink = "Waiter Pad No." = FIELD("No.");
                UpdatePropagation = Both;
                ApplicationArea = All;
            }
            group(ClosingStatus)
            {
                Caption = 'Closed';
                Editable = false;
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Closed field';
                }
                field("Close Date"; Rec."Close Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Close Date field';
                }
                field("Close Time"; Rec."Close Time")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Close Time field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Print)
            {
                group("Kitchen Print")
                {
                    Caption = 'Kitchen Print';
                    Image = SendToMultiple;
                    action(SendOrder)
                    {
                        Caption = 'Send Full Order';
                        Image = AllLines;
                        Promoted = true;
                        PromotedOnly = true;
                        PromotedCategory = Category4;
                        PromotedIsBig = true;
                        ToolTip = 'Notify kitchen of all ordered items regardless of serving step and print categories';
                        ApplicationArea = All;

                        trigger OnAction()
                        begin
                            HospitalityPrint.PrintWaiterPadPreOrderToKitchenPressed(Rec, true);
                        end;
                    }
                    action(RunNext)
                    {
                        Caption = 'Request Next Serving';
                        Image = SuggestLines;
                        Promoted = true;
                        PromotedOnly = true;
                        PromotedCategory = Category4;
                        PromotedIsBig = true;
                        ToolTip = 'Ask kitchen to prepare next set of items based on current serving step and print categories';
                        ApplicationArea = All;

                        trigger OnAction()
                        begin
                            HospitalityPrint.RequestRunServingStepToKitchen(Rec, true, '');
                        end;
                    }
                    action(RunServingStep)
                    {
                        Caption = 'Request Serving Step';
                        Image = CalculateLines;
                        Promoted = true;
                        PromotedOnly = true;
                        PromotedCategory = Category4;
                        PromotedIsBig = true;
                        ToolTip = 'Ask kitchen to prepare set of items belonging to a specific serving step';
                        ApplicationArea = All;

                        trigger OnAction()
                        begin
                            HospitalityPrint.SelectAndRequestRunServingStepToKitchen(Rec);
                        end;
                    }
                    action(RunSelectedLines)
                    {
                        Caption = 'Request Selected Lines';
                        Image = SelectLineToApply;
                        Promoted = true;
                        PromotedOnly = true;
                        PromotedCategory = Category4;
                        PromotedIsBig = true;
                        ToolTip = 'Ask kitchen to prepare selected waiter pad lines regardless of serving step and print categories';
                        ApplicationArea = All;

                        trigger OnAction()
                        var
                            WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
                            PrintTemplate: Record "NPR NPRE Print Templ.";
                        begin
                            Clear(WaiterPadLine);
                            CurrPage.WaiterPadLinesSubpage.PAGE.GetSelection(WaiterPadLine);
                            WaiterPadLine.SetRange("Waiter Pad No.", Rec."No.");
                            WaiterPadLine.MarkedOnly(true);
                            if not WaiterPadLine.IsEmpty then begin
                                HospitalityPrint.PrintWaiterPadLinesToKitchen(Rec, WaiterPadLine, PrintTemplate."Print Type"::"Serving Request", '', false, true);
                                CurrPage.WaiterPadLinesSubpage.PAGE.ClearMarkedLines();
                            end;
                        end;
                    }
                }
                action("Print Pre Receipt")
                {
                    Caption = 'Print Pre Receipt';
                    Image = PrintCheck;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Print Pre Receipt action';

                    trigger OnAction()
                    begin
                        HospitalityPrint.PrintWaiterPadPreReceiptPressed(Rec);
                    end;
                }
                separator(Separator6014410)
                {
                }
            }
            group("Waiter pad")
            {
                Caption = 'Waiter pad';
                action("Move seating")
                {
                    Caption = 'Move seating';
                    Image = Change;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Move seating action';

                    trigger OnAction()
                    begin
                        NPHWaiterPadPOSManagement.MoveWaiterPadToNewSeatingUI(Rec);
                    end;
                }
                action("Merge waiter pad")
                {
                    Caption = 'Merge waiter pad';
                    Image = ChangeBatch;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Merge waiter pad action';

                    trigger OnAction()
                    begin
                        if NPHWaiterPadPOSManagement.MergeWaiterPadUI(Rec) then begin
                            CurrPage.Close();
                        end;
                    end;
                }
                action(CloseWaiterPad)
                {
                    Caption = 'Close waiter pad';
                    Image = CloseDocument;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Close waiter pad action';

                    trigger OnAction()
                    begin
                        Rec.CloseWaiterPad();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Rec.UpdateCurrentSeatingDescription;
    end;

    trigger OnOpenPage()
    begin
        CurrPage.Editable := not Rec.Closed;
    end;

    var
        HospitalityPrint: Codeunit "NPR NPRE Restaurant Print";
        NPHWaiterPadPOSManagement: Codeunit "NPR NPRE Waiter Pad POS Mgt.";

    local procedure ActionViewLinkedSeating()
    var
        SeatingWaiterPadLinkPage: Page "NPR NPRE Seat.: WaiterPadLink";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        SeatingWaiterPadLink.Reset();
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", Rec."No.");

        Clear(SeatingWaiterPadLinkPage);
        SeatingWaiterPadLinkPage.SetTableView(SeatingWaiterPadLink);
        SeatingWaiterPadLinkPage.RunModal();
    end;

    local procedure ActionAddSeating()
    var
        SeatingList: Page "NPR NPRE Seating List";
        Seating: Record "NPR NPRE Seating";
        WaiterPadManagement: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        //Get a seating to add to waiter pad
        Clear(SeatingList);
        Seating.Reset();
        SeatingList.SetTableView(Seating);
        SeatingList.LookupMode(true);
        SeatingList.Editable(false);
        if SeatingList.RunModal() = ACTION::LookupOK then begin
            SeatingList.GetRecord(Seating);
            WaiterPadManagement.LinkSeatingToWaiterPad(Rec."No.", Seating.Code);
        end;
    end;

    local procedure LookupFlowStatus(StatusObjectType: Integer; var StatusCode: Code[10]): Boolean
    var
        FlowStatus: Record "NPR NPRE Flow Status";
    begin
        FlowStatus.SetRange("Status Object", StatusObjectType);
        if StatusCode <> '' then begin
            FlowStatus."Status Object" := StatusObjectType;
            FlowStatus.Code := StatusCode;
            if FlowStatus.Find('=><') then;
        end;
        if PAGE.RunModal(0, FlowStatus) = ACTION::LookupOK then begin
            StatusCode := FlowStatus.Code;
            exit(true);
        end;
        exit(false);
    end;
}
