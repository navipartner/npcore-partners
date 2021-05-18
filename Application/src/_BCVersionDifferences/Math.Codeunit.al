codeunit 6014560 "NPR Math"
{
    var
#if BC17
        Math: DotNet NPRNetMath;
#else
        Math: Codeunit Math;
#endif
    procedure Sin(decimalValue: Decimal): Decimal
    begin
        exit(Math.Sin(decimalValue));
    end;

    procedure Cos(decimalValue: Decimal): Decimal
    begin
        exit(Math.Cos(decimalValue));
    end;

    procedure Acos(decimalValue: Decimal): Decimal
    begin
        exit(Math.Acos(decimalValue));
    end;

}
