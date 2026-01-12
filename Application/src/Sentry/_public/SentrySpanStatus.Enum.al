enum 6248500 "NPR Sentry Span Status"
{
#if not BC17
    Access = Public;
#endif
    Extensible = false;

    value(0; Ok) { Caption = 'ok', Locked = true; }
    value(1; Cancelled) { Caption = 'cancelled', Locked = true; }
    value(2; Unknown) { Caption = 'unknown', Locked = true; }
    value(3; InvalidArgument) { Caption = 'invalid_argument', Locked = true; }
    value(4; DeadlineExceeded) { Caption = 'deadline_exceeded', Locked = true; }
    value(5; NotFound) { Caption = 'not_found', Locked = true; }
    value(6; AlreadyExists) { Caption = 'already_exists', Locked = true; }
    value(7; PermissionDenied) { Caption = 'permission_denied', Locked = true; }
    value(8; ResourceExhausted) { Caption = 'resource_exhausted', Locked = true; }
    value(9; Aborted) { Caption = 'aborted', Locked = true; }
    value(10; OutOfRange) { Caption = 'out_of_range', Locked = true; }
    value(11; Unimplemented) { Caption = 'unimplemented', Locked = true; }
    value(12; InternalError) { Caption = 'internal_error', Locked = true; }
    value(13; Unavailable) { Caption = 'unavailable', Locked = true; }
    value(14; DataLoss) { Caption = 'data_loss', Locked = true; }
    value(15; Unauthenticated) { Caption = 'unauthenticated', Locked = true; }
}
