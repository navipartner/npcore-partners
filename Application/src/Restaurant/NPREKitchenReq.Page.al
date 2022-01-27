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
                IndentationColumn = 0;
                field("Request No."; Rec."Request No.")
                {

                    ToolTip = 'Specifies the value of the Request No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Order ID"; Rec."Order ID")
                {

                    ToolTip = 'Specifies the value of the Order ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {

                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. Changed"; Rec."Qty. Changed")
                {

                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Qty. Changed field';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Step"; Rec."Serving Step")
                {

                    ToolTip = 'Specifies the value of the Serving Step field';
                    ApplicationArea = NPRRetail;
                }
                field("Created Date-Time"; Rec."Created Date-Time")
                {

                    ToolTip = 'Specifies the value of the Created Date-Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Requested Date-Time"; Rec."Serving Requested Date-Time")
                {

                    ToolTip = 'Specifies the value of the Serving Requested Date-Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Status"; Rec."Line Status")
                {

                    ToolTip = 'Specifies the value of the Line Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Production Status"; Rec."Production Status")
                {
                    Visible = IsExpediteMode;
                    ToolTip = 'Specifies the value of the Production Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Station Production Status"; Rec."Station Production Status")
                {
                    ApplicationArea = NPRRetail;
                    Visible = not IsExpediteMode;
                    ToolTip = 'Specifies the value of the Station Production Status field';
                    DrillDown = false;
                }
                field("No. of Kitchen Stations"; Rec."No. of Kitchen Stations")
                {

                    Visible = IsExpediteMode;
                    ToolTip = 'Specifies the value of the No. of Kitchen Stations field';
                    ApplicationArea = NPRRetail;
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Restaurant Code field';
                    ApplicationArea = NPRRetail;
                }
                field(SeatingCode; Rec.SeatingCode())
                {

                    Caption = 'Seating Code';
                    ToolTip = 'Specifies the value of the Seating Code field';
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
                    CurrPage.Update();
                    if IsExpediteMode then
                        CurrPage."Kitchen Stations".Page.Update();
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

                    ToolTip = 'Executes the Set Served action';
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

                    ToolTip = 'Executes the Start Production action';
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

                    ToolTip = 'Executes the End Production action';
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

                    ToolTip = 'Executes the Accept Qty. Change action';
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
                action(ToggleFinished)
                {
                    Caption = 'Show/Hide Finished';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Visible = NOT IsExpediteMode;

                    ToolTip = 'Executes the Show/Hide Finished action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        if Rec.GetFilter("Production Status") <> '' then
                            if Rec.GetRangeMax("Production Status") = Rec."Production Status"::Finished then begin
                                Rec.SetRange("Production Status", Rec."Production Status"::"Not Started", Rec."Production Status"::"On Hold");
                                Rec.SetRange("Station Production Status", Rec."Station Production Status"::"Not Started", Rec."Station Production Status"::Started);
                                exit;
                            end;
                        Rec.SetRange("Production Status", Rec."Production Status"::"Not Started", Rec."Production Status"::Finished);
                        Rec.SetRange("Station Production Status", Rec."Station Production Status"::"Not Started", Rec."Station Production Status"::Finished);
                    end;
                }
                action(ToggleServed)
                {
                    Caption = 'Show/Hide Served';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Visible = IsExpediteMode;

                    ToolTip = 'Executes the Show/Hide Served action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        if Rec.GetFilter("Line Status") <> '' then
                            if Rec.GetRangeMax("Line Status") = Rec."Line Status"::Served then begin
                                Rec.SetRange("Line Status", Rec."Line Status"::"Ready for Serving", Rec."Line Status"::Planned);
                                exit;
                            end;
                        Rec.SetRange("Line Status", Rec."Line Status"::"Ready for Serving", Rec."Line Status"::Served);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        Restaurant: Record "NPR NPRE Restaurant";
    begin
        IsExpediteMode := ViewMode = ViewMode::Expedite;
        if IsExpediteMode then begin
            if Rec.GetFilter("Restaurant Code") = '' then
                if not Restaurant.IsEmpty then begin
                    if Page.RunModal(0, Restaurant) <> Action::LookupOK then
                        Error('');
                    Rec.SetRange("Restaurant Code", Restaurant.Code);
                end;
            Rec.SetRange("Line Status", Rec."Line Status"::"Ready for Serving", Rec."Line Status"::Planned);
        end;
        CurrPage."Kitchen Stations".Page.SetViewMode(ViewMode);
    end;

    trigger OnClosePage()
    begin
        if TimerStarted then
            CurrPage.TimerControl.StopTimer();
    end;

    var
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        KitchenStationAction: Option "Accept Qty. Change","Start Production","End Production";
        ViewMode: Option Expedite,"Kitchen Station";
        StationNotFound: Label 'System was not able to identify kitchen station to apply the action to.';
        IsExpediteMode: Boolean;
        TimerStarted: Boolean;
        ViewModeListLbl: Label 'Expedite View,Kitchen Station View';

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
                        KitchenOrderMgt.StartProduction(KitchenRequestStation);
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

    procedure SetViewMode(NewViewMode: Option)
    begin
        ViewMode := NewViewMode;
    end;
}
