page 6150689 "NPR NPRE Kitchen Req."
{
    Extensible = False;
    Caption = 'Kitchen Request List';
    DataCaptionExpression = GetPageCaption();
    Editable = false;
    PageType = Worksheet;
    PromotedActionCategories = 'New,Process,Report,Page';
    SourceTable = "NPR NPRE Kitchen Request";
    SourceTableView = SORTING("Restaurant Code", "Line Status", Priority, "Order ID", "Created Date-Time");
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater("Order Lines")
            {
                Caption = 'Order Lines';
                IndentationColumn = Rec.Indentation;
                IndentationControls = Description;
                field("Request No."; Rec."Request No.")
                {
                    ToolTip = 'Specifies the request unique Id, assigned by the system according to an automatically maintained number series.';
                    ApplicationArea = NPRRetail;
                }
                field("Order ID"; Rec."Order ID")
                {
                    ToolTip = 'Specifies the order Id this request belongs to.';
                    ApplicationArea = NPRRetail;
                }
                field("Line Type"; Rec."Line Type")
                {
                    ToolTip = 'Specifies the type of entity for this request line, such as Item, or Comment.';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the product you are preparing, if you have chosen "Item" in the Line Type field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the variant of the item on this line.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of what you are preparing. Based on your choices in the Line Type and No. fields, the field may show product description or a comment line.';
                    ApplicationArea = NPRRetail;
                }
                field("Modifications Exist"; Rec."Modifications Exist")
                {
                    ToolTip = 'Indicates if the customer has requested any changes to the ingredients or preparation of the product.';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies how many units of the product have been requested.';
                    ApplicationArea = NPRRetail;
                    Style = Unfavorable;
                    StyleExpr = Rec."Qty. Changed";
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies how each unit of the product is measured, such as in pieces or boxes.';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. Changed"; Rec."Qty. Changed")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies if there is at least one kitchen station yet to accept the quantity change.';
                    ApplicationArea = NPRRetail;
                    Style = Unfavorable;
                    StyleExpr = Rec."Qty. Changed";
                }
                field("Serving Step"; Rec."Serving Step")
                {
                    ToolTip = 'Specifies the meal flow serving step the product of this request is to be served at.';
                    ApplicationArea = NPRRetail;
                }
                field("Created Date-Time"; Rec."Created Date-Time")
                {
                    ToolTip = 'Specifies the date-time the request was created at.';
                    ApplicationArea = NPRRetail;
                }
                field("Expected Dine Date-Time"; Rec."Expected Dine Date-Time")
                {
                    ToolTip = 'Specifies the date-time the customer requested the order be ready at.';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Requested Date-Time"; Rec."Serving Requested Date-Time")
                {
                    ToolTip = 'Specifies the date-time waiter requested serving of the product on the line.';
                    ApplicationArea = NPRRetail;
                }
                field("Served Date-Time"; Rec."Served Date-Time")
                {
                    ToolTip = 'Specifies the date-time the request was served at.';
                    Visible = IsExpediteMode and FinishedIsShown;
                    ApplicationArea = NPRRetail;
                }
                field("Line Status"; Rec."Line Status")
                {
                    ToolTip = 'Specifies the status of this request.';
                    ApplicationArea = NPRRetail;
                    HideValue = HideLineStatusValue;
                }
                field("Production Status"; Rec."Production Status")
                {
                    Visible = IsExpediteMode;
                    ToolTip = 'Specifies overal production status of the request.';
                    ApplicationArea = NPRRetail;
                }
                field("Station Production Status"; Rec."Station Production Status")
                {
                    ApplicationArea = NPRRetail;
                    Visible = not IsExpediteMode;
                    ToolTip = 'Specifies the production status of the request at specific kitchen station.';
                    DrillDown = false;
                }
                field("No. of Kitchen Stations"; Rec."No. of Kitchen Stations")
                {
                    Visible = IsExpediteMode;
                    ToolTip = 'Specifies the number of kitchen stations involved in preparation of the product of this request.';
                    ApplicationArea = NPRRetail;
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the restaurant the ordered was created for.';
                    ApplicationArea = NPRRetail;
                }
                field(SeatingCodes; SeatingCodes)
                {
                    Caption = 'Seating Code';
                    ToolTip = 'Specifies the seating (table) code(s) the request was created for.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field(SeatingNos; SeatingNos)
                {
                    Caption = 'Seating No.';
                    ToolTip = 'Specifies the seating (table) number(s) the request was created for.';
                    ApplicationArea = NPRRetail;
                }
                field(AssignedWaiters; AssignedWaiters)
                {
                    Caption = 'Waiter Code';
                    ToolTip = 'Specifies the waiter (salesperson) code(s) the request was created for.';
                    ApplicationArea = NPRRetail;
                }
            }
            part("Kitchen Stations"; "NPR NPRE Kitchen Req. Subpage")
            {
                Caption = 'Kitchen Stations';
                SubPageLink = "Request No." = field("Request No."),
                              "Production Restaurant Code" = field("Production Restaurant Filter"),
                              "Kitchen Station" = field("Kitchen Station Filter");
                Visible = IsExpediteMode;
                ApplicationArea = NPRRetail;
            }
            usercontrol(TimerControl; "NPR TimerControl")
            {
                ApplicationArea = NPRRetail;

                trigger ControlAddInReady()
                begin
                    CurrPage.TimerControl.StartTimer(5000);
                    TimerStarted := true;
                end;

                trigger RefreshPage()
                begin
                    CurrPage.Update(false);
                    if IsExpediteMode then
                        CurrPage."Kitchen Stations".Page.Update(false);
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Flow)
            {
                Caption = 'Flow';
                action("Set Served")
                {
                    Caption = 'Set Served';
                    Image = Approve;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = IsExpediteMode;
                    ToolTip = 'Set selected requests as served.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        KitchenRequest: Record "NPR NPRE Kitchen Request";
                    begin
                        CurrPage.SetSelectionFilter(KitchenRequest);
                        KitchenOrderMgt.SetRequestLinesAsServed(KitchenRequest);
                        CurrPage.Update(false);
                    end;
                }
                action(StartProduction)
                {
                    Caption = 'Start Production';
                    Image = Start;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = NOT IsExpediteMode;
                    ToolTip = 'Start production of selected requests.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        RunKitchenStationRelatedAction(KitchenStationAction::"Start Production");
                    end;
                }
                action(EndProduction)
                {
                    Caption = 'End Production';
                    Image = Stop;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = NOT IsExpediteMode;
                    ToolTip = 'End production of selected requests.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        RunKitchenStationRelatedAction(KitchenStationAction::"End Production");
                    end;
                }
            }
            group(Changes)
            {
                Caption = 'Changes';
                action(AcceptQtyChange)
                {
                    Caption = 'Accept Qty. Change';
                    Image = Approve;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = NOT IsExpediteMode;
                    ToolTip = 'Accept requested quantity change.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        RunKitchenStationRelatedAction(KitchenStationAction::"Accept Qty. Change");
                    end;
                }
            }
            group(View)
            {
                Caption = 'View';
                action(ShowFinished)
                {
                    Caption = 'Show Finished';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Visible = not IsExpediteMode and not FinishedIsShown;
                    ToolTip = 'Show finished requests.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ToggleFinishedFilter();
                    end;
                }
                action(HideFinished)
                {
                    Caption = 'Hide Finished';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Visible = not IsExpediteMode and FinishedIsShown;
                    ToolTip = 'Hide finished requests.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ToggleFinishedFilter();
                    end;
                }
                action(ShowServed)
                {
                    Caption = 'Show Served';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Visible = IsExpediteMode and not ServedIsShown;
                    ToolTip = 'Show served requests.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ToggleServedFilter();
                    end;
                }
                action(HideServed)
                {
                    Caption = 'Hide Served';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Visible = IsExpediteMode and ServedIsShown;
                    ToolTip = 'Hide served requests.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ToggleServedFilter();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        UserSetup: Record "User Setup";
    begin
        IsExpediteMode := ViewMode = ViewMode::Expedite;
        if IsExpediteMode then begin
            if not Rec.IsFilteredByRestaurant() then
                if not Restaurant.IsEmpty() then begin
                    UserSetup.Get(UserId());
                    if not UserSetup."NPR Allow Restaurant Switch" then begin
                        UserSetup.TestField("NPR Backoffice Restaurant Code");
                        Restaurant.Code := UserSetup."NPR Backoffice Restaurant Code";
                    end else begin
                        if UserSetup."NPR Restaurant Switch Filter" <> '' then begin
                            Restaurant.FilterGroup(2);
                            Restaurant.SetFilter(Code, UserSetup."NPR Restaurant Switch Filter");
                            Restaurant.FilterGroup(0);
                        end;
                        if Restaurant.Count() = 1 then
                            Restaurant.FindFirst()
                        else
                            if Page.RunModal(0, Restaurant) <> Action::LookupOK then
                                Error('');
                    end;
                    Rec.FilterGroup(2);
                    Rec.SetRange("Restaurant Code", Restaurant.Code);
                    Rec.FilterGroup(0);
                end;
            Rec.SetRange("Line Status", Rec."Line Status"::"Ready for Serving", Rec."Line Status"::Planned);
        end;
        CurrPage."Kitchen Stations".Page.SetViewMode(ViewMode);

        if Rec.GetFilter("Production Status") <> '' then
            FinishedIsShown := Rec.GetRangeMax("Production Status") = Rec."Production Status"::Finished
        else
            FinishedIsShown := true;
        if Rec.GetFilter("Line Status") <> '' then
            ServedIsShown := Rec.GetRangeMax("Line Status") = Rec."Line Status"::Served
        else
            ServedIsShown := true;
    end;

    trigger OnClosePage()
    begin
        if TimerStarted then
            CurrPage.TimerControl.StopTimer();
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.GetSeatingAndWaiter(AssignedWaiters, SeatingCodes, SeatingNos);
        HideLineStatusValue := IsExpediteMode and (Rec."Parent Request No." <> 0);
    end;

    local procedure GetPageCaption(): Text
    var
        NewPageCaption: Text;
        PageCaptionLbl: Label '(%1)', Locked = true;
    begin
        NewPageCaption := StrSubstNo(PageCaptionLbl, SelectStr(ViewMode + 1, ViewModeListLbl));
        if ViewMode = ViewMode::"Kitchen Station" then
            NewPageCaption := NewPageCaption + ' - ' + Rec.GetFilter("Kitchen Station Filter");
        exit(NewPageCaption);
    end;

    local procedure RunKitchenStationRelatedAction(ActionToRun: Option)
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
    begin
        CurrPage.SetSelectionFilter(KitchenRequest);
        if KitchenRequest.Count() = 1 then begin  //Copy all auxiliary filters, if only one record is selected
            KitchenRequest.FindFirst();
            KitchenRequest.CopyFilters(Rec);
            KitchenRequest.SetRange("Request No.", KitchenRequest."Request No.");
        end;
        if KitchenRequest.FindSet() then
            repeat
                GetRequestStation(KitchenRequest, KitchenRequestStation);
                case ActionToRun of
                    KitchenStationAction::"Accept Qty. Change":
                        KitchenOrderMgt.AcceptQtyChange(KitchenRequestStation);
                    KitchenStationAction::"Start Production":
                        KitchenOrderMgt.StartProduction(KitchenRequest, KitchenRequestStation);
                    KitchenStationAction::"End Production":
                        KitchenOrderMgt.EndProduction(KitchenRequestStation);
                end;
                Commit();
            until KitchenRequest.Next() = 0;
    end;

    local procedure GetRequestStation(var KitchenRequest: Record "NPR NPRE Kitchen Request"; var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    begin
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        KitchenRequest.CopyFilter("Production Restaurant Filter", KitchenRequestStation."Production Restaurant Code");
        KitchenRequest.CopyFilter("Kitchen Station Filter", KitchenRequestStation."Kitchen Station");
        if KitchenRequestStation.Count() <> 1 then
            Error(StationNotFound);
        KitchenRequestStation.FindFirst();
    end;

    internal procedure SetViewMode(NewViewMode: Option)
    begin
        ViewMode := NewViewMode;
    end;

    local procedure ToggleFinishedFilter()
    begin
        if Rec.GetFilter("Production Status") <> '' then
            if Rec.GetRangeMax("Production Status") = Rec."Production Status"::Finished then begin
                Rec.SetRange("Production Status", Rec."Production Status"::"Not Started", Rec."Production Status"::"On Hold");
                Rec.SetRange("Station Production Status", Rec."Station Production Status"::"Not Started", Rec."Station Production Status"::Started);
                FinishedIsShown := false;
                exit;
            end;
        Rec.SetRange("Production Status", Rec."Production Status"::"Not Started", Rec."Production Status"::Finished);
        Rec.SetRange("Station Production Status", Rec."Station Production Status"::"Not Started", Rec."Station Production Status"::Finished);
        FinishedIsShown := true;
    end;

    local procedure ToggleServedFilter()
    begin
        if Rec.GetFilter("Line Status") <> '' then
            if Rec.GetRangeMax("Line Status") = Rec."Line Status"::Served then begin
                Rec.SetRange("Line Status", Rec."Line Status"::"Ready for Serving", Rec."Line Status"::Planned);
                ServedIsShown := false;
                exit;
            end;
        Rec.SetRange("Line Status", Rec."Line Status"::"Ready for Serving", Rec."Line Status"::Served);
        ServedIsShown := true;
    end;

    var
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        KitchenStationAction: Option "Accept Qty. Change","Start Production","End Production";
        ViewMode: Option Expedite,"Kitchen Station";
        AssignedWaiters: Text;
        SeatingCodes: Text;
        SeatingNos: Text;
        FinishedIsShown: Boolean;
        HideLineStatusValue: Boolean;
        IsExpediteMode: Boolean;
        ServedIsShown: Boolean;
        TimerStarted: Boolean;
        StationNotFound: Label 'System was not able to identify kitchen station to apply the action to.';
        ViewModeListLbl: Label 'Expedite View,Kitchen Station View';
}
