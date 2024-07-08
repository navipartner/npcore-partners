page 6151377 "NPR TM Replan Schedule"
{
    Extensible = False;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR TM Det. Ticket AccessEntry";
    Caption = 'Replan Ticket Reservation';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(destination)
            {
                Caption = 'Replan to';
                Editable = true;
                field(_TargetAdmissionCode; _TargetAdmissionCode)
                {
                    Caption = 'Admission Code';
                    ToolTip = 'Select destination admission code';
                    ApplicationArea = NPRMembershipAdvanced;
                    TableRelation = "NPR TM Admission";
                    ShowMandatory = true;
                    Editable = _TargetAdmissionIsEditable;

                    trigger OnValidate()
                    begin
                        _TargetExternalEntryNo := 0;
                        _TargetScheduledTime := '';
                        CurrPage.Update(false);
                    end;
                }
                field(_TargetScheduleCode; _TargetScheduleCode)
                {
                    Caption = 'Schedule Code';
                    ToolTip = 'Select destination schedule code';
                    ApplicationArea = NPRMembershipAdvanced;
                    TableRelation = "NPR TM Admis. Schedule";

                    trigger OnValidate()
                    begin
                        _TargetExternalEntryNo := 0;
                        _TargetScheduledTime := '';
                        CurrPage.Update(false);
                    end;
                }
                field(_TargetDate; _TargetDate)
                {
                    Caption = 'Date';
                    ToolTip = 'Select destination date';
                    ApplicationArea = NPRMembershipAdvanced;
                    trigger OnValidate()
                    begin
                        if (_TargetDate < Today()) then
                            Error('You can only replan to a future date.');
                        _TargetExternalEntryNo := 0;
                        _TargetScheduledTime := '';
                        CurrPage.Update(false);
                    end;
                }
                group(SelectTime)
                {
                    Caption = 'Select New Time';
                    field(_TargetScheduledTime; _TargetScheduledTime)
                    {
                        Caption = 'Time';
                        ToolTip = 'Select destination time slot';
                        ApplicationArea = NPRMembershipAdvanced;
                        ShowMandatory = true;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            SelectSchedule: Page "NPR TM Ticket Select Schedule";
                            ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                        begin
                            _TargetExternalEntryNo := 0;
                            _TargetScheduledTime := '';
                            CurrPage.Update(false);

                            if (_TargetAdmissionCode = '') then
                                Error('Please select Admission Code first');

                            if (_TargetAdmissionCode <> '') then
                                ScheduleEntry.SetFilter("Admission Code", '=%1', _TargetAdmissionCode);

                            if (_TargetScheduleCode <> '') then
                                ScheduleEntry.SetFilter("Schedule Code", '=%1', _TargetScheduleCode);

                            if (_TargetDate <> 0D) then
                                ScheduleEntry.SetFilter("Admission Start Date", '=%1', _TargetDate);

                            if (_TargetDate = 0D) then
                                ScheduleEntry.SetFilter("Admission Start Date", '>=%1', Today());

                            ScheduleEntry.SetFilter(Cancelled, '=%1', false);
                            SelectSchedule.FillPage(ScheduleEntry, 1, '', '');
                            SelectSchedule.LookupMode(true);
                            if (SelectSchedule.RunModal() <> Action::LookupOK) then
                                exit;

                            SelectSchedule.GetRecord(ScheduleEntry);
                            ScheduleEntry.Find();
                            _TargetExternalEntryNo := ScheduleEntry."External Schedule Entry No.";
                            _TargetScheduledTime := StrSubstNo('%1 - %2', ScheduleEntry."Admission Start Date", ScheduleEntry."Admission Start Time");
                            CurrPage.Update(false);
                        end;

                        trigger OnValidate()
                        var
                            ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                        begin
                            if (_TargetExternalEntryNo <> 0) then begin
                                ScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', _TargetExternalEntryNo);
                                ScheduleEntry.SetFilter(Cancelled, '=%1', false);
                                if (not ScheduleEntry.FindFirst()) then begin
                                    _TargetExternalEntryNo := 0;
                                end else begin
                                    _TargetScheduleCode := ScheduleEntry."Schedule Code";
                                    _TargetScheduledTime := StrSubstNo('%1 - %2', ScheduleEntry."Admission Start Date", ScheduleEntry."Admission Start Time");
                                end;
                            end;

                            if (_TargetExternalEntryNo = 0) then
                                _TargetScheduledTime := '';

                            CurrPage.Update(false);
                        end;
                    }
                    field(_TargetIncludeInitialEntry; _TargetIncludeInitialEntry)
                    {
                        Caption = 'Include Initial Entry';
                        ToolTip = 'With this option checked, the initial entry is also replanned';
                        ApplicationArea = NPRMembershipAdvanced;
                    }
                }
            }
            group(source)
            {
                Caption = 'Reservations to replan';
                Editable = false;
                repeater(GroupName)
                {
                    field("Ticket No."; Rec."Ticket No.")
                    {
                        ApplicationArea = NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Ticket No. field';
                    }
                    field("Ticket Access Entry No."; Rec."Ticket Access Entry No.")
                    {
                        ApplicationArea = NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Ticket Access Entry No. field';
                    }
                    field(Type; Rec.Type)
                    {
                        ApplicationArea = NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Type field';
                    }
                    field("External Adm. Sch. Entry No."; Rec."External Adm. Sch. Entry No.")
                    {
                        ApplicationArea = NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the External Adm. Sch. Entry No. field';
                    }
                    field("Scheduled Time"; _ScheduledTime)
                    {
                        ApplicationArea = NPRTicketAdvanced;
                        Caption = 'Scheduled Time';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Scheduled Time field';
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Replan)
            {
                Caption = 'Replan Reservations';
                ToolTip = 'This actions the Replan page for this this time slot, allowing reservations to be moved.';
                ApplicationArea = NPRTicketAdvanced;
                Image = Replan;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction();
                var
                    DetTicketEntry: Record "NPR TM Det. Ticket AccessEntry";
                    TicketManagement: Codeunit "NPR TM Ticket Management";
                begin
                    if (_TargetExternalEntryNo = 0) then
                        Error('Selected target time slot is not valid.');

                    CurrPage.SetSelectionFilter(DetTicketEntry);
                    if (not Confirm('%1 selected entries will be replanned to time slot %2.', true, DetTicketEntry.Count(), _TargetExternalEntryNo)) then
                        exit;

                    DetTicketEntry.FindSet();
                    repeat
                        TicketManagement.ReplanReservation(DetTicketEntry."Entry No.", _TargetExternalEntryNo, _TargetIncludeInitialEntry);
                    until (DetTicketEntry.Next() = 0);

                end;
            }
        }
    }

    var
        _TargetAdmissionCode, _TargetScheduleCode : Code[20];
        _TargetDate: Date;
        _TargetExternalEntryNo: Integer;
        _TargetIncludeInitialEntry, _TargetAdmissionIsEditable : Boolean;
        _ScheduledTime, _TargetScheduledTime : Text[30];
        _ScheduledTimeLbl: Label '%1 %2', Locked = true;

    trigger OnInit()
    begin
        _TargetAdmissionIsEditable := true;
        _TargetIncludeInitialEntry := true;
    end;

    trigger OnAfterGetRecord()
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        _ScheduledTime := '';
        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', Rec."External Adm. Sch. Entry No.");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (AdmissionScheduleEntry.FindFirst()) then
            _ScheduledTime := StrSubstNo(_ScheduledTimeLbl, AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");
    end;

    internal procedure SetAdmissionCode(AdmissionCode: Code[20])
    begin
        _TargetAdmissionCode := AdmissionCode;
        _TargetAdmissionIsEditable := false;
    end;

}