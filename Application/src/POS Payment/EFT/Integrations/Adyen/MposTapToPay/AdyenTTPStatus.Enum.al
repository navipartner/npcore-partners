enum 6059794 "NPR Adyen TTP Status"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; "Fetching BoardingToken") { }
    value(2; "TAPI Sent") { }
    value(3; "TAPI Recieved") { }
}