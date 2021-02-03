codeunit 6014456 "NPR MathLib"
{
    trigger OnRun()
    begin
        Message(Format(evalStr2Dec('2+3')));
    end;

    procedure "!"(x: Decimal) Fakultet: Decimal
    begin
        Fakultet := x;
        while x > 1 do begin
            x -= 1;
            Fakultet := Fakultet * x
        end;
    end;

    procedure Sin(x: Decimal): Decimal
    begin
        exit(
          x - (Power(x, 3) / "!"(3)) + (Power(x, 5) / "!"(5))
          - (Power(x, 7) / "!"(7)) + (Power(x, 9) / "!"(9))
          - (Power(x, 12) / "!"(12)));
    end;

    procedure Cos(x: Decimal) Cos: Decimal
    begin
        exit(
          1 - (Power(x, 2) / "!"(2)) + (Power(x, 4) / "!"(4))
          - (Power(x, 6) / "!"(6)) + (Power(x, 8) / "!"(8))
          - (Power(x, 10) / "!"(10)));
    end;

    procedure Tan(x: Decimal): Decimal
    begin
        exit(Sin(x) / Cos(x));
    end;

    procedure ArcSin(x: Decimal): Decimal
    begin
        if x < 0 then
            exit(-ArcSin(-x))
        else
            if x = 1 then
                exit(Pi / 2)
            else
                exit(ArcTan(x / Sqrt(1 - x * x)));
    end;

    procedure ArcCos(x: Decimal): Decimal
    begin
        if x < 0 then
            exit(Pi - ArcCos(-x))
        else
            if x = 0 then
                exit(Pi / 2)
            else
                exit(ArcTan(Sqrt(1 - x * x) / x));
    end;

    procedure ArcTan(x: Decimal): Decimal
    var
        ArcTanErr: Label 'ArcTan (still) not Avaible)';
    begin
        Error(ArcTanErr);
    end;

    procedure Log(x: Decimal): Decimal
    begin
        exit(CalcLog(10, x));
    end;

    procedure Ln(x: Decimal): Decimal
    begin
        exit(CalcLog(E, x));

        //You could also calculate Ln with Taylorrows. It's (depending on the Acuracy) faster than the Root.
        //I preffer the Root-Algorythmus, because it is "smarter" and becomes allways maximal accurate.
        //Taylor becommes on very low (< 0,5) and high (> 100) Values more unaccurate.
        //IF (x <= 0) THEN
        //  ERROR('Ln out of Range (>0)');

        //CLEAR(Sum);
        //FOR i := 1 TO 40 DO BEGIN
        //  Sum := Sum + POWER(x-1,i) / (i * POWER(x+1,i));
        //  i += 1; //Step2
        //END;

        //For Ln (Base euler)->
        //EXIT(2*Sum);
        //For Log (Base 10)
        //exit(x/2.30258509299);
    end;

    procedure CalcLog(Base: Decimal; x: Decimal): Decimal
    var
        Down: Decimal;
        Step: Decimal;
        Up: Decimal;
        LeadingZeros: Integer;
        Steps: Integer;
        LeadingZeroString: Text[30];
    begin
        Clear(Steps);
        if x = 1 then //Log(1) = 1;
            exit(1);
        //first find upper and lower Range
        if x > 1 then begin
            Up := 1;
            Down := 0;
            while Power(Base, Up) < x do
                Up *= 2;
            Down := Up;
            while Power(Base, Down) > x do
                Down /= 10;
        end else begin
            //On Values 0..1 (except 0) the leading zeros are the offset in -Integer
            //i.e. 0,0027 leads to -2, because the LOG will be something between -2 and zero.
            Down := -StrLen(CopyStr(Format(x, 0, '<decimals,0>'), 2)) -
             StrLen(DelChr(CopyStr(Format(x, 0, '<decimals,0>'), 2), '<', '0'));
            Up := 0;
        end;

        //moving the Ranges step by step to the Result. Steps become smaler every loop.
        repeat
            Steps += 1;
            Step := (Up - Down) / 2;
            if Power(Base, Step + Down) > x then
                Up -= Step
            else
                Down += Step;
        until Steps = 53; //after this Navision doesnt get exacter. The first 12-14 decimals are allways acurate.
        exit(Round(Up, 0.000000000000001));
    end;

    procedure Adjust(x: Decimal): Decimal
    begin
        repeat
            if x <= -Pi then
                x := x + 2 * Pi;
            if x > Pi then
                x := x - 2 * Pi
        until (x > -Pi) and (x <= Pi);
    end;

    procedure "Grad>Rad"(Grad: Decimal) Rad: Decimal
    begin
        exit(Grad / 180 * Pi);
    end;

    procedure "Deg>Rad"(x: Decimal): Decimal
    begin
        exit(x * (Pi / 180));
    end;

    procedure "Rad>Deg"(x: Decimal): Decimal
    begin
        exit(x * (180 / Pi));
    end;

    procedure Sqrt(x: Decimal): Decimal
    begin
        exit(Power(x, 0.5));
    end;

    procedure gcd(x: Decimal; y: Decimal): Decimal
    var
        Puffer: Decimal;
    begin
        //größter gemeinsamer Teiler
        x := Abs(Int(x));
        y := Abs(Int(y));

        if (x = 0) and (y = 0) then
            exit(0);

        if (x = 0) or (x = y) then
            exit(y);

        if y = 0 then
            exit(x);

        repeat
            if x < y then begin
                Puffer := x;
                x := y;
                y := Puffer;
            end;
            Puffer := x mod y;
            x := y;
            y := Puffer;
        until Puffer = 0;

        exit(x);
    end;

    procedure lcm(x: Decimal; y: Decimal): Decimal
    begin
        //kleinstes gemeinsames Vielfaches
        x := Abs(Int(x));
        y := Abs(Int(y));
        exit(x * y div gcd(x, y));
    end;

    procedure Prime(x: Decimal): Boolean
    var
        i: Integer;
    begin
        //Primzahl?
        x := Abs(x);
        if x in [0, 1] then
            exit(false);
        if x in [2, 3] then
            exit(true);

        i := 2;
        while i <= Int(Sqrt(x)) do begin
            if (x mod i = 0) then
                exit(false);
            i += 1;
        end;
        exit(true);
    end;

    procedure CrossFoot(x: Decimal): Decimal
    begin
        //Quersumme
        x := Abs(Int(x));
        exit((x - 10) mod 9 + 1);
    end;

    procedure "(a+b)²"(a: Decimal; b: Decimal): Decimal
    begin
        //Binomic1
        exit(Power(a, 2) + 2 * a * b + Power(b, 2));
    end;

    procedure "(a-b)²"(a: Decimal; b: Decimal): Decimal
    begin
        //Binomic2
        exit(Power(a, 2) - 2 * a * b + Power(b, 2));
    end;

    procedure "(a+b)*(a-b)"(a: Decimal; b: Decimal): Decimal
    begin
        //Binomic3
        exit(Power(a, 2) - Power(b, 2));
    end;

    procedure Pi(): Decimal
    begin
        exit(3.14159265358979323);
    end;

    procedure E(): Decimal
    begin
        exit(2.71828182845904523);
    end;

    procedure Euler(): Decimal
    begin
        exit(0.57721566490153286);
    end;

    procedure Sign(x: Decimal): Integer
    begin
        if x < 0 then
            exit(-1);
        if x = 0 then
            exit(0);
        exit(1);
    end;

    procedure "Max"(Dec1: Decimal; Dec2: Decimal): Decimal
    begin
        if Dec1 > Dec2 then
            exit(Dec1)
        else
            exit(Dec2);
    end;

    procedure "Min"(Dec1: Decimal; Dec2: Decimal): Decimal
    begin
        if Dec1 > Dec2 then
            exit(Dec2)
        else
            exit(Dec1);
    end;

    procedure Int(x: Decimal): Decimal
    begin
        exit(Round(x, 1, '<'));
    end;

    procedure EuklDistance(x1: Decimal; y1: Decimal; x2: Decimal; y2: Decimal): Decimal
    begin
        exit(Sqrt(Power((x2 - x1), 2) + Power((y2 - y1), 2)));
    end;

    procedure ManhDistance(x1: Decimal; y1: Decimal; x2: Decimal; y2: Decimal): Decimal
    begin
        exit(Abs(x2 - x1) + Abs(y2 - y1));
    end;

    procedure StreetDistance(x1: Decimal; y1: Decimal; x2: Decimal; y2: Decimal): Decimal
    begin
        exit((Abs(x2 - x1) + Abs(y2 - y1)) * 1.111);
    end;

    procedure ConvLongtitute2Km(Latitude: Decimal; x: Decimal): Decimal
    var
        Multiplier: Decimal;
    begin
        //Längengrad zu Km
        exit(Cos("Grad>Rad"(Latitude)) * 111.32386667);
    end;

    procedure ConvLatitude2Km(x: Decimal): Decimal
    begin
        //Breitengrad zu km
        exit(x * 111.32386667);
    end;

    procedure evalStr2Dec(str: Text[1024]): Decimal
    var
        dec: Decimal;
        lastDec: Decimal;
        tmpDec: Decimal;
        i: Integer;
        N: Integer;
        lastMod: Text[1];
        t1: Text[1];
        tmp: Text[30];
    begin
        //evalStr2Dec
        N := StrLen(str);

        lastMod := '';

        for i := 1 to N do begin
            t1 := CopyStr(str, i, 1);
            if Evaluate(tmpDec, t1) then
                tmp += t1
            else begin
                case lastMod of
                    '+':
                        begin
                            Evaluate(dec, tmp);
                            lastDec += dec;
                            lastMod := '+';
                        end;
                    else begin
                            Evaluate(dec, tmp);
                            lastDec += dec;
                        end;
                end;
                tmp := '';
            end;
        end;

        exit(dec);
    end;
}

