page 6150689 "NPR NPRE Kitchen Req."
{
    Caption = 'Kitchen Request List';
    DataCaptionExpression = GetPageCaption();
    Editable = false;
    PageType = Worksheet;
    PromotedActionCategories = 'New,Process,Report,Page';
    SourceTable = "NPR NPRE Kitchen Request";
    SourceTableView = SORTING("Restaurant Code", "Line Status", Priority, "Order ID", "Created Date-Time");
    UsageCategory = Lists;
    ApplicationArea = All;

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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request No. field';
                }
                field("Order ID"; Rec."Order ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order ID field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                }
                field("Qty. Changed"; Rec."Qty. Changed")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Qty. Changed field';
                }
                field("Serving Step"; Rec."Serving Step")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serving Step field';
                }
                field("Created Date-Time"; Rec."Created Date-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created Date-Time field';
                }
                field("Serving Requested Date-Time"; Rec."Serving Requested Date-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serving Requested Date-Time field';
                }
                field("Line Status"; Rec."Line Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Status field';
                }
                field("Production Status"; Rec."Production Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Production Status field';
                }
                field("No. of Kitchen Stations"; Rec."No. of Kitchen Stations")
                {
                    ApplicationArea = All;
                    Visible = IsExpediteMode;
                    ToolTip = 'Specifies the value of the No. of Kitchen Stations field';
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Restaurant Code field';
                }
                field("SeatingCode()"; Rec.SeatingCode())
                {
                    ApplicationArea = All;
                    Caption = 'Seating Code';
                    ToolTip = 'Specifies the value of the Seating Code field';
                }
            }
            part("Kitchen Stations"; "NPR NPRE Kitchen Req. Subpage")
            {
                Caption = 'Kitchen Stations';
                SubPageLink = "Request No." = FIELD("Request No."),
                              "Production Restaurant Code" = FIELD("Production Restaurant Filter"),
                              "Kitchen Station" = FIELD("Kitchen Station Filter");
                Visible = IsExpediteMode;
                ApplicationArea = All;
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Set Served action';

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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = NOT IsExpediteMode;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Start Production action';

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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = NOT IsExpediteMode;
                    ApplicationArea = All;
                    ToolTip = 'Executes the End Production action';

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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = NOT IsExpediteMode;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Accept Qty. Change action';

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
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Visible = NOT IsExpediteMode;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Show/Hide Finished action';

                    trigger OnAction()
                    begin
                        if Rec.GetFilter("Production Status") <> '' then
                            if Rec.GetRangeMax("Production Status") = Rec."Production Status"::Finished then begin
                                Rec.SetRange("Production Status", Rec."Production Status"::"Not Started", Rec."Production Status"::"On Hold");
                                exit;
                            end;
                        Rec.SetRange("Production Status", Rec."Production Status"::"Not Started", Rec."Production Status"::Finished);
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Show/Hide Served action';

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
                    if PAGE.RunModal(0, Restaurant) <> ACTION::LookupOK then
                        Error('');
                    Rec.SetRange("Restaurant Code", Restaurant.Code);
                end;
            Rec.SetRange("Line Status", Rec."Line Status"::"Ready for Serving", Rec."Line Status"::Planned);
        end;
        CurrPage."Kitchen Stations".PAGE.SetViewMode(ViewMode);
    end;

    var
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        KitchenStationAction: Option "Accept Qty. Change","Start Production","End Production";
        ViewMode: Option Expedite,"Kitchen Station";
        StationNotFound: Label 'System was not able to identify kitchen station to apply the action to.';
        IsExpediteMode: Boolean;
        ViewModeListLbl: Label 'Expedite View,Kitchen Station View';

    local procedure GetPageCaption(): Text
    begin
        exit(StrSubstNo('(%1)', SelectStr(ViewMode + 1, ViewModeListLbl)));
    end;

    local procedure RunKitchenStationRelatedAction(ActionToRun: Option)
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
    begin
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
    end;

    local procedure GetRequestStation(var KitchenRequest: Record "NPR NPRE Kitchen Request"; var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    begin
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        KitchenRequest.CopyFilter("Production Restaurant Filter", KitchenRequestStation."Production Restaurant Code");
        KitchenRequest.CopyFilter("Kitchen Station Filter", KitchenRequestStation."Kitchen Station");
        if KitchenRequestStation.Count <> 1 then
            Error(StationNotFound);
        KitchenRequestStation.FindFirst;
    end;

    procedure SetViewMode(NewViewMode: Option)
    begin
        ViewMode := NewViewMode;
    end;
}