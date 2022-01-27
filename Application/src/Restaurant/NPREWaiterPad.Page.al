page 6150660 "NPR NPRE Waiter Pad"
{
    Extensible = False;
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
            group(General)
            {
                Caption = 'General';
                field("Start Time"; Rec."Start Time")
                {
                    Caption = 'Opened';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Opened field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Number of Guests"; Rec."Number of Guests")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Number of Guests field';
                }
                field("Assigned Waiter Code"; Rec."Assigned Waiter Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the waiter assigned to the waiterpad';
                }
                field(Status; Rec.Status)
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Status Description FF"; Rec."Status Description FF")
                {
                    Caption = 'Waiter Pad Status';
                    DrillDown = false;
                    ToolTip = 'Specifies the value of the Waiter Pad Status field';
                    ApplicationArea = NPRRetail;

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
                    Visible = false;
                    ToolTip = 'Specifies the value of the Serving Step Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Step Description"; Rec."Serving Step Description")
                {
                    Caption = 'Serving Step';
                    DrillDown = false;
                    ToolTip = 'Specifies the value of the Serving Step field';
                    ApplicationArea = NPRRetail;

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
                    Editable = false;
                    ToolTip = 'Specifies the value of the Pre-receipt Printed field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Seating)
            {
                Caption = 'Seating';
                field("Current Seating Code"; Rec."Current Seating FF")
                {
                    Caption = 'Code';
                    Editable = false;
                    ToolTip = 'Specifies internal unique Id of the first seating currently assigned to the waiter pad';
                    ApplicationArea = NPRRetail;
                    Importance = Promoted;
                }
                field("Current Seating No."; Seating."Seating No.")
                {
                    Caption = 'No.';
                    Editable = false;
                    ToolTip = 'Specifies a user friendly id (table number) of the first seating currently assigned to the waiter pad';
                    ApplicationArea = NPRRetail;
                    Importance = Promoted;
                }
                field("Current Seating Description"; Seating.Description)
                {
                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies description of the first seating currently assigned to the waiter pad';
                    ApplicationArea = NPRRetail;
                    Importance = Promoted;
                }
                field("No. of Seatings Assigned"; Rec."Multiple Seating FF")
                {
                    Caption = 'Assigned Seatings';
                    Editable = false;
                    ToolTip = 'Specifies the total number of seatings currently assigned to the waiter pad';
                    ApplicationArea = NPRRetail;
                }
            }

            part(WaiterPadLinesSubpage; "NPR NPRE Waiter Pad Subform")
            {
                SubPageLink = "Waiter Pad No." = FIELD("No.");
                UpdatePropagation = Both;
                ApplicationArea = NPRRetail;
            }
            group(ClosingStatus)
            {
                Caption = 'Closed';
                Editable = false;
                field(Closed; Rec.Closed)
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Closed field';
                    ApplicationArea = NPRRetail;
                }
                field("Close Date"; Rec."Close Date")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Close Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Close Time"; Rec."Close Time")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Close Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Close Reason"; Rec."Close Reason")
                {
                    ToolTip = 'Specifies a reason or process context for the waiter pad was closure.';
                    ApplicationArea = NPRRetail;
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
                        ApplicationArea = NPRRetail;

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
                        ApplicationArea = NPRRetail;

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
                        ApplicationArea = NPRRetail;

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
                        ApplicationArea = NPRRetail;

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
                    ToolTip = 'Executes the Print Pre Receipt action';
                    ApplicationArea = NPRRetail;

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
                    ToolTip = 'Executes the Move seating action';
                    ApplicationArea = NPRRetail;

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
                    ToolTip = 'Executes the Merge waiter pad action';
                    ApplicationArea = NPRRetail;

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
                    ToolTip = 'Executes the Close waiter pad action';
                    ApplicationArea = NPRRetail;

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
        Rec.GetCurrentSeating(Seating);
    end;

    trigger OnOpenPage()
    begin
        CurrPage.Editable := not Rec.Closed;
    end;

    var
        Seating: Record "NPR NPRE Seating";
        HospitalityPrint: Codeunit "NPR NPRE Restaurant Print";
        NPHWaiterPadPOSManagement: Codeunit "NPR NPRE Waiter Pad POS Mgt.";

    local procedure LookupFlowStatus(StatusObjectType: Enum "NPR NPRE Status Object"; var StatusCode: Code[10]): Boolean
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
