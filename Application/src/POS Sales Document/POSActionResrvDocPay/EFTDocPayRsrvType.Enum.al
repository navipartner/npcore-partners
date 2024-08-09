enum 6059774 "NPR EFT Doc Pay Rsrv Type" implements "NPR EFT Doc Pay Reservation"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(6184607; "Adyen EFT Terminal")
    {
        Implementation = "NPR EFT Doc Pay Reservation" = "NPR Adyen EFT Doc Pay Rsrv";
    }
}