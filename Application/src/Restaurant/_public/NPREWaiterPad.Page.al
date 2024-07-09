page 6150660 "NPR NPRE Waiter Pad"
{
    Caption = 'Waiter Pad';
    InsertAllowed = false;
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Kitchen';
    SourceTable = "NPR NPRE Waiter Pad";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(openedDateTime; Rec.SystemCreatedAt)
                {
                    Caption = 'Opened Date-Time';
                    Editable = false;
                    ToolTip = 'Specifies the date-time the waiter pad was opened at.';
                    ApplicationArea = NPRRetail;
                }
                field("Start Time"; Rec."Start Time")
                {
                    Caption = 'Opened';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Opened field';
                    ApplicationArea = NPRRetail;
                    ObsoleteState = Pending;
                    ObsoleteTag = '2023-08-28';
                    ObsoleteReason = 'Replaced by SystemCreatedAt field.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies additional optional description of the waiter pad. You can use it to specify main guest name or other information, which can help you distinguish this waiter pad from other ones created for the same seating.';
                    ApplicationArea = NPRRetail;
                }
                field(CustomerDetails; GetCustomerDetails())
                {
                    Caption = 'Customer';
                    ToolTip = 'Specifies the name of the customer assigned to the waiter pad.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("Customer Phone No."; Rec."Customer Phone No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the phone number of the customer who is to be notified about the order.';
                }
                field("Customer E-Mail"; Rec."Customer E-Mail")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the email address of the customer who is to be notified about the order.';
                }
                field("Number of Guests"; Rec."Number of Guests")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the party size (number of guests) the waiter pad was opened for.';
                }
                field("Assigned Waiter Code"; Rec."Assigned Waiter Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the waiter assigned to the waiter pad.';
                }
                field(Status; Rec.Status)
                {
                    Visible = false;
                    ToolTip = 'Specifies current waiter pad status code.';
                    ApplicationArea = NPRRetail;
                }
                field("Status Description FF"; Rec."Status Description FF")
                {
                    Caption = 'Waiter Pad Status';
                    DrillDown = false;
                    ToolTip = 'Specifies current waiter pad status.';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    var
                        FlowStatus: Record "NPR NPRE Flow Status";
                        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
                        NewStatusCode: Code[10];
                    begin
                        NewStatusCode := Rec.Status;
                        if LookupFlowStatus(FlowStatus."Status Object"::WaiterPad, NewStatusCode) then begin
                            if Rec.Status <> NewStatusCode then begin
                                WaiterPadMgt.SetWaiterPadStatus(Rec, NewStatusCode);
                                Rec.CalcFields("Status Description FF");
                            end;
                        end;
                    end;
                }
                field("Serving Step Code"; Rec."Serving Step Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the serving step code the waiter is currently on.';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Step Description"; Rec."Serving Step Description")
                {
                    Caption = 'Serving Step';
                    DrillDown = false;
                    ToolTip = 'Specifies the serving step the waiter is currently on.';
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
                    ToolTip = 'Specifies if pre-receipt has already been printed for the waiter pad.';
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
                    ToolTip = 'Specifies the internal unique Id of the primary seating currently assigned to the waiter pad.';
                    ApplicationArea = NPRRetail;
                    Importance = Promoted;
                }
                field("Current Seating No."; Seating."Seating No.")
                {
                    Caption = 'No.';
                    Editable = false;
                    ToolTip = 'Specifies the user friendly id (table number) of the primary seating currently assigned to the waiter pad.';
                    ApplicationArea = NPRRetail;
                    Importance = Promoted;
                }
                field("Current Seating Description"; Seating.Description)
                {
                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies description of the primary seating currently assigned to the waiter pad.';
                    ApplicationArea = NPRRetail;
                    Importance = Promoted;
                }
                field("No. of Seatings Assigned"; Rec."Multiple Seating FF")
                {
                    Caption = 'Assigned Seatings';
                    Editable = false;
                    ToolTip = 'Specifies the total number of seatings currently assigned to the waiter pad.';
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
                    ToolTip = 'Specifies if the waiter pad has been already finished and closed.';
                    ApplicationArea = NPRRetail;
                }
                field("Close Date"; Rec."Close Date")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies the date when the waiter pad was closed on.';
                    ApplicationArea = NPRRetail;
                }
                field("Close Time"; Rec."Close Time")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies the time when the waiter pad was closed at.';
                    ApplicationArea = NPRRetail;
                }
                field("Close Reason"; Rec."Close Reason")
                {
                    ToolTip = 'Specifies a reason or process context for the waiter pad closure.';
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
                    Caption = 'Kitchen';
                    Image = SendToMultiple;
                    action(ShowKitchenRequests)
                    {
                        Caption = 'Kitchen Requests';
                        Image = BlanketOrder;
                        Promoted = true;
                        PromotedOnly = true;
                        PromotedCategory = Category4;
                        PromotedIsBig = true;
                        ToolTip = 'View outstaning kitchen requests (expedite view) for the waiter pad.';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            KitchenRequest: Record "NPR NPRE Kitchen Request";
                            KitchenReqSourceParam: Record "NPR NPRE Kitchen Req.Src. Link";
                            Seating: Record "NPR NPRE Seating";
                            WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
                            KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
                            KitchenRequests: Page "NPR NPRE Kitchen Req.";
                            RestaurantCode: Code[20];
                        begin
                            Rec.CalcFields("Current Seating FF");
                            Rec.TestField("Current Seating FF");
                            Seating.Get(Rec."Current Seating FF");
                            RestaurantCode := Seating.GetSeatingRestaurant();
                            WaiterPadLine."Waiter Pad No." := Rec."No.";
                            WaiterPadLine."Line No." := 0;
                            KitchenOrderMgt.InitKitchenReqSourceFromWaiterPadLine(KitchenReqSourceParam, WaiterPadLine, RestaurantCode, '', '', '', 0DT);
                            KitchenOrderMgt.FindKitchenRequestsForSourceDoc(KitchenRequest, KitchenReqSourceParam);
                            KitchenRequest.SetRange("Restaurant Code", RestaurantCode);

                            Clear(KitchenRequests);
                            KitchenRequests.SetViewMode(0);
                            KitchenRequests.SetTableView(KitchenRequest);
                            KitchenRequests.Run();
                        end;
                    }
                    action(SendOrder)
                    {
                        Caption = 'Send Full Order';
                        Image = AllLines;
                        Promoted = true;
                        PromotedOnly = true;
                        PromotedCategory = Category4;
                        PromotedIsBig = true;
                        ToolTip = 'Notify kitchen of all ordered items regardless of serving step and print categories.';
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
                        ToolTip = 'Ask kitchen to prepare next set of items based on current serving step and print categories.';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            HospitalityPrint.RequestRunServingStepToKitchenWithMessage(Rec, true, '');
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
                        ToolTip = 'Ask kitchen to prepare set of items belonging to a specific serving step.';
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
                        ToolTip = 'Ask kitchen to prepare selected waiter pad lines regardless of serving step and print categories.';
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
                    ToolTip = 'Print pre-receipt for the waiter pad.';
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
                    ToolTip = 'Move the waiter pad to another seating (table).';
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
                    ToolTip = 'Merge current waiter pad with another one.';
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
                    ToolTip = 'Close the waiter pad. Please note that once closed, you won''t be able to reopen the waiter pad again.';
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

    local procedure GetCustomerDetails(): Text
    var
        Customer: Record Customer;
        ExitPlaceholderLbl: Label '%1 %2 "%3"', Comment = '%1 - Customer or Contact table caption, %2 - Customer/Contact No., %3 - Customer/Contact Name';
    begin
        if Rec."Customer No." = '' then
            exit('');
        if not Customer.Get(Rec."Customer No.") then
            Clear(Customer);
        exit(StrSubstNo(ExitPlaceholderLbl, Customer.TableCaption(), Customer."No.", Customer.Name));
    end;
}
