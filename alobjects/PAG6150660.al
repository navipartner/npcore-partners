page 6150660 "NPRE Waiter Pad"
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.34/ANEN/20170717 CASE 262628 Added support for status (fld "Status", "Status Description")
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.53/ALPO/20191210 CASE 380609 Store number of guests on waiter pad
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale

    Caption = 'Waiter Pad';
    InsertAllowed = false;
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Kitchen Print';
    SourceTable = "NPRE Waiter Pad";

    layout
    {
        area(content)
        {
            group(Control6014423)
            {
                ShowCaption = false;
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = All;
                    Caption = 'Opened';
                    Editable = false;
                }
                field("Current Seating FF"; "Current Seating FF")
                {
                    ApplicationArea = All;
                    Caption = 'Seating';
                    Editable = false;
                }
                field("Current Seating Description"; "Current Seating Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Number of Guests"; "Number of Guests")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Status Description FF"; "Status Description FF")
                {
                    ApplicationArea = All;
                    Caption = 'Waiter Pad Status';
                    DrillDown = false;

                    trigger OnAssistEdit()
                    var
                        FlowStatus: Record "NPRE Flow Status";
                        NewStatusCode: Code[10];
                    begin
                        //-NPR5.53 [360258]
                        NewStatusCode := Status;
                        if LookupFlowStatus(FlowStatus."Status Object"::WaiterPad, NewStatusCode) then begin
                            Validate(Status, NewStatusCode);
                            CalcFields("Status Description FF");
                        end;
                        //+NPR5.53 [360258]
                    end;
                }
                field("Serving Step Code"; "Serving Step Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Serving Step Description"; "Serving Step Description")
                {
                    ApplicationArea = All;
                    Caption = 'Serving Step';
                    DrillDown = false;

                    trigger OnAssistEdit()
                    var
                        FlowStatus: Record "NPRE Flow Status";
                        NewStatusCode: Code[10];
                    begin
                        //-NPR5.53 [360258]
                        NewStatusCode := "Serving Step Code";
                        if LookupFlowStatus(FlowStatus."Status Object"::WaiterPadLineMealFlow, NewStatusCode) then begin
                            Validate("Serving Step Code", NewStatusCode);
                            CalcFields("Serving Step Description");
                        end;
                        //+NPR5.53 [360258]
                    end;
                }
                field("Pre-receipt Printed"; "Pre-receipt Printed")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            part(WaiterPadLinesSubpage; "NPRE Waiter Pad Subform")
            {
                SubPageLink = "Waiter Pad No." = FIELD("No.");
                UpdatePropagation = Both;
            }
            group(ClosingStatus)
            {
                Caption = 'Closed';
                Editable = false;
                field(Closed; Closed)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Close Date"; "Close Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Close Time"; "Close Time")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
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
                        PromotedCategory = Category4;
                        PromotedIsBig = true;
                        ToolTip = 'Notify kitchen of all ordered items regardless of serving step and print categories';

                        trigger OnAction()
                        begin
                            //HospitalityPrint.PrintWaiterPadPreOrderToKitchenPressed(Rec);  //NPR5.55 [399170]-revoked
                            HospitalityPrint.PrintWaiterPadPreOrderToKitchenPressed(Rec, true);  //NPR5.55 [399170]
                        end;
                    }
                    action(RunNext)
                    {
                        Caption = 'Request Next Serving';
                        Image = SuggestLines;
                        Promoted = true;
                        PromotedCategory = Category4;
                        PromotedIsBig = true;
                        ToolTip = 'Ask kitchen to prepare next set of items based on current serving step and print categories';

                        trigger OnAction()
                        begin
                            HospitalityPrint.RequestRunServingStepToKitchen(Rec, true, '');  //NPR5.53 [360258]
                        end;
                    }
                    action(RunServingStep)
                    {
                        Caption = 'Request Serving Step';
                        Image = CalculateLines;
                        Promoted = true;
                        PromotedCategory = Category4;
                        PromotedIsBig = true;
                        ToolTip = 'Ask kitchen to prepare set of items belonging to a specific serving step';

                        trigger OnAction()
                        begin
                            HospitalityPrint.SelectAndRequestRunServingStepToKitchen(Rec);  //NPR5.53 [360258]
                        end;
                    }
                    action(RunSelectedLines)
                    {
                        Caption = 'Request Selected Lines';
                        Image = SelectLineToApply;
                        Promoted = true;
                        PromotedCategory = Category4;
                        PromotedIsBig = true;
                        ToolTip = 'Ask kitchen to prepare selected waiter pad lines regardless of serving step and print categories';

                        trigger OnAction()
                        var
                            WaiterPadLine: Record "NPRE Waiter Pad Line";
                            PrintTemplate: Record "NPRE Print Template";
                        begin
                            //-NPR5.53 [360258]
                            Clear(WaiterPadLine);
                            CurrPage.WaiterPadLinesSubpage.PAGE.GetSelection(WaiterPadLine);
                            WaiterPadLine.SetRange("Waiter Pad No.", "No.");
                            WaiterPadLine.MarkedOnly(true);
                            if not WaiterPadLine.IsEmpty then begin
                                //HospitalityPrint.PrintWaiterPadLinesToKitchen(Rec,WaiterPadLine,PrintTemplate."Print Type"::"Serving Request",'',FALSE);  //NPR5.55 [399170]-revoked
                                HospitalityPrint.PrintWaiterPadLinesToKitchen(Rec, WaiterPadLine, PrintTemplate."Print Type"::"Serving Request", '', false, true);  //NPR5.55 [399170]
                                CurrPage.WaiterPadLinesSubpage.PAGE.ClearMarkedLines();
                            end;
                            //+NPR5.53 [360258]
                        end;
                    }
                }
                action("Print Pre Receipt")
                {
                    Caption = 'Print Pre Receipt';
                    Image = PrintCheck;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

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
                    PromotedCategory = Process;
                    PromotedIsBig = true;

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
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        NPHWaiterPad: Page "NPRE Waiter Pad";
                    begin
                        if NPHWaiterPadPOSManagement.MergeWaiterPadUI(Rec) then begin
                            CurrPage.Close;
                        end;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateCurrentSeatingDescription;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //WaiterPadManagement.InsertWaiterPad(Rec, TRUE);  //NPR5.55 [399170]-revoked (inserts are not allowed here)
    end;

    trigger OnOpenPage()
    begin
        CurrPage.Editable := not Closed;  //NPR5.55 [399170]
    end;

    var
        WaiterPadManagement: Codeunit "NPRE Waiter Pad Management";
        HospitalityPrint: Codeunit "NPRE Restaurant Print";
        NPHWaiterPadPOSManagement: Codeunit "NPRE Waiter Pad POS Management";

    local procedure ActionViewLinkedSeating()
    var
        SeatingWaiterPadLinkPage: Page "NPRE Seating - Waiter Pad Link";
        SeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
    begin
        SeatingWaiterPadLink.Reset;
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", Rec."No.");

        Clear(SeatingWaiterPadLinkPage);
        SeatingWaiterPadLinkPage.SetTableView(SeatingWaiterPadLink);
        SeatingWaiterPadLinkPage.RunModal;
    end;

    local procedure ActionAddSeating()
    var
        SeatingList: Page "NPRE Seating List";
        Seating: Record "NPRE Seating";
        WaiterPadManagement: Codeunit "NPRE Waiter Pad Management";
    begin
        //Get a seating to add to waiter pad
        Clear(SeatingList);
        Seating.Reset;
        SeatingList.SetTableView(Seating);
        SeatingList.LookupMode(true);
        SeatingList.Editable(false);
        if SeatingList.RunModal = ACTION::LookupOK then begin
            SeatingList.GetRecord(Seating);
            WaiterPadManagement.LinkSeatingToWaiterPad(Rec."No.", Seating.Code);
        end;
    end;

    local procedure LookupFlowStatus(StatusObjectType: Integer; var StatusCode: Code[10]): Boolean
    var
        FlowStatus: Record "NPRE Flow Status";
    begin
        //-NPR5.53 [360258]
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
        //+NPR5.53 [360258]
    end;
}

