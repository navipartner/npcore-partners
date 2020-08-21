page 6150689 "NPRE Kitchen Requests"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200420 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale

    Caption = 'Kitchen Request List';
    DataCaptionExpression = GetPageCaption();
    Editable = false;
    PageType = Worksheet;
    PromotedActionCategories = 'New,Process,Report,Page';
    SourceTable = "NPRE Kitchen Request";
    SourceTableView = SORTING("Restaurant Code", "Line Status", Priority, "Order ID", "Created Date-Time");
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater("Order Lines")
            {
                Caption = 'Order Lines';
                IndentationColumn = 0;
                field("Request No."; "Request No.")
                {
                    ApplicationArea = All;
                }
                field("Order ID"; "Order ID")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Qty. Changed"; "Qty. Changed")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Serving Step"; "Serving Step")
                {
                    ApplicationArea = All;
                }
                field("Created Date-Time"; "Created Date-Time")
                {
                    ApplicationArea = All;
                }
                field("Serving Requested Date-Time"; "Serving Requested Date-Time")
                {
                    ApplicationArea = All;
                }
                field("Line Status"; "Line Status")
                {
                    ApplicationArea = All;
                }
                field("Production Status"; "Production Status")
                {
                    ApplicationArea = All;
                }
                field("No. of Kitchen Stations"; "No. of Kitchen Stations")
                {
                    ApplicationArea = All;
                    Visible = IsExpediteMode;
                }
                field("Restaurant Code"; "Restaurant Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("SeatingCode()"; SeatingCode())
                {
                    ApplicationArea = All;
                    Caption = 'Seating Code';
                }
            }
            part("Kitchen Stations"; "NPRE Kitchen Requests Subpage")
            {
                Caption = 'Kitchen Stations';
                SubPageLink = "Request No." = FIELD("Request No."),
                              "Production Restaurant Code" = FIELD("Production Restaurant Filter"),
                              "Kitchen Station" = FIELD("Kitchen Station Filter");
                Visible = IsExpediteMode;
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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = IsExpediteMode;

                    trigger OnAction()
                    var
                        KitchenRequest: Record "NPRE Kitchen Request";
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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = NOT IsExpediteMode;

                    trigger OnAction()
                    begin
                        RunKitchenStationRelatedAction(KitchenStationAction::"Start Production");  //NPR5.55 [382428]
                    end;
                }
                action(EndProduction)
                {
                    Caption = 'End Production';
                    Image = Stop;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = NOT IsExpediteMode;

                    trigger OnAction()
                    begin
                        RunKitchenStationRelatedAction(KitchenStationAction::"End Production");  //NPR5.55 [382428]
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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = NOT IsExpediteMode;

                    trigger OnAction()
                    begin
                        RunKitchenStationRelatedAction(KitchenStationAction::"Accept Qty. Change");  //NPR5.55 [382428]
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
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Visible = NOT IsExpediteMode;

                    trigger OnAction()
                    begin
                        //-NPR5.55 [382428]
                        if GetFilter("Production Status") <> '' then
                            if GetRangeMax("Production Status") = "Production Status"::Finished then begin
                                SetRange("Production Status", "Production Status"::"Not Started", "Production Status"::"On Hold");
                                exit;
                            end;
                        SetRange("Production Status", "Production Status"::"Not Started", "Production Status"::Finished);
                        //+NPR5.55 [382428]
                    end;
                }
                action(ToggleServed)
                {
                    Caption = 'Show/Hide Served';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Visible = IsExpediteMode;

                    trigger OnAction()
                    begin
                        //-NPR5.55 [382428]
                        if GetFilter("Line Status") <> '' then
                            if GetRangeMax("Line Status") = "Line Status"::Served then begin
                                SetRange("Line Status", "Line Status"::"Ready for Serving", "Line Status"::Planned);
                                exit;
                            end;
                        SetRange("Line Status", "Line Status"::"Ready for Serving", "Line Status"::Served);
                        //+NPR5.55 [382428]
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        Restaurant: Record "NPRE Restaurant";
    begin
        //-NPR5.55 [382428]
        IsExpediteMode := ViewMode = ViewMode::Expedite;
        if IsExpediteMode then begin
            if GetFilter("Restaurant Code") = '' then
                if not Restaurant.IsEmpty then begin
                    if PAGE.RunModal(0, Restaurant) <> ACTION::LookupOK then
                        Error('');
                    SetRange("Restaurant Code", Restaurant.Code);
                end;
            SetRange("Line Status", "Line Status"::"Ready for Serving", "Line Status"::Planned);
        end;
        CurrPage."Kitchen Stations".PAGE.SetViewMode(ViewMode);
        //+NPR5.55 [382428]
    end;

    var
        KitchenOrderMgt: Codeunit "NPRE Kitchen Order Mgt.";
        KitchenStationAction: Option "Accept Qty. Change","Start Production","End Production";
        ViewMode: Option Expedite,"Kitchen Station";
        StationNotFound: Label 'System was not able to identify kitchen station to apply the action to.';
        IsExpediteMode: Boolean;
        ViewModeListLbl: Label 'Expedite View,Kitchen Station View';

    local procedure GetPageCaption(): Text
    begin
        //-NPR5.55 [382428]
        exit(StrSubstNo('(%1)', SelectStr(ViewMode + 1, ViewModeListLbl)));
        //+NPR5.55 [382428]
    end;

    local procedure RunKitchenStationRelatedAction(ActionToRun: Option)
    var
        KitchenRequest: Record "NPRE Kitchen Request";
        KitchenRequestStation: Record "NPRE Kitchen Request Station";
    begin
        //-NPR5.55 [382428]
        CurrPage.SetSelectionFilter(KitchenRequest);
        if KitchenRequest.Count = 1 then begin  //Copy all auxiliary filters, if only one record is selected
            KitchenRequest.FindFirst;
            KitchenRequest.CopyFilters(Rec);
            KitchenRequest.SetRange("Request No.", KitchenRequest."Request No.");
        end;
        if KitchenRequest.FindSet then
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
                Commit;
            until KitchenRequest.Next = 0;
        //+NPR5.55 [382428]
    end;

    local procedure GetRequestStation(var KitchenRequest: Record "NPRE Kitchen Request"; var KitchenRequestStation: Record "NPRE Kitchen Request Station")
    begin
        //-NPR5.55 [382428]
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        KitchenRequest.CopyFilter("Production Restaurant Filter", KitchenRequestStation."Production Restaurant Code");
        KitchenRequest.CopyFilter("Kitchen Station Filter", KitchenRequestStation."Kitchen Station");
        if KitchenRequestStation.Count <> 1 then
            Error(StationNotFound);
        KitchenRequestStation.FindFirst;
        //+NPR5.55 [382428]
    end;

    procedure SetViewMode(NewViewMode: Option)
    begin
        //-NPR5.55 [382428]
        ViewMode := NewViewMode;
        //+NPR5.55 [382428]
    end;
}

