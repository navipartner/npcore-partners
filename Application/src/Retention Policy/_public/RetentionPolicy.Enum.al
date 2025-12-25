#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
enum 6059962 "NPR Retention Policy" implements "NPR IRetention Policy"
{
    Extensible = true;
    DefaultImplementation = "NPR IRetention Policy" = "NPR Ret.Pol.: Undefined";

    value(0; UNDEFINED)
    {
        Caption = '<Undefined>';
    }
    value(1; "NPR Retention Policy Log Entry")
    {
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: Log Entry RetPol";
    }
    value(2; "NPR Data Log Record")
    {
        // Also performs expired record deletion on DataLogField: Record "NPR Data Log Field";
        //                                          & DataLogProcessingEntry: Record "NPR Data Log Processing Entry";
        Implementation = "NPR IRetention Policy" = "NPR Ret.Pol.: Data Log Record";
    }
}
#endif