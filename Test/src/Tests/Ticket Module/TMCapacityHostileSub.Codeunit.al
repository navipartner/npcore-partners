/// <summary>
/// A subscriber that misbehaves the two ways a third party can: throwing, and committing. Used to prove the
/// containment on "NPR TM Ticket Webhooks" holds, since neither is observable from the publisher otherwise.
/// </summary>
codeunit 85480 "NPR TM Capacity Hostile Sub"
{
    EventSubscriberInstance = Manual;

    var
        _Behavior: Option Throw,Commit;
        _RanPastCommit: Boolean;
        _CallCount: Integer;

    procedure SetThrow()
    begin
        _Behavior := _Behavior::Throw;
        _CallCount := 0;
    end;

    procedure SetCommit()
    begin
        _Behavior := _Behavior::Commit;
        _CallCount := 0;
        _RanPastCommit := false;
    end;

    /// <summary>
    /// False once the event has refused the commit, since the refusal aborts the subscriber where it stands.
    /// </summary>
    procedure RanPastCommit(): Boolean
    begin
        exit(_RanPastCommit);
    end;

    procedure CallCount(): Integer
    begin
        exit(_CallCount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR TM Ticket Webhooks", OnAfterCapacityChanged, '', false, false)]
    local procedure OnAfterCapacityChanged(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; RemainingCapacity: Integer; CapacityAsOf: DateTime)
    begin
        _CallCount += 1;

        case _Behavior of
            _Behavior::Throw:
                Error('Hostile subscriber refuses to cooperate.');
            _Behavior::Commit:
                begin
                    Commit();
                    _RanPastCommit := true;
                end;
        end;
    end;
}
