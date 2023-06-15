codeunit 85053 "NPR Library - Boarding Pass"
{
    procedure GenerateBoardingPass(NoOfLegs: text; PassengerName: Text; TravelLegs: Text) BoardingPass: Text;
    var
        PassengerNameLength: Integer;
        NoOfEmptySpaces: Integer;
        TB: TextBuilder;
    begin
        PassengerNameLength := StrLen(PassengerName);

        TB.Append('M'); //Format Code
        TB.Append(NoOfLegs);

        case true of
            (PassengerNameLength < 20):
                begin
                    NoOfEmptySpaces := 20 - PassengerNameLength;
                    AddEmptyString(NoOfEmptySpaces, PassengerName);
                end;

            (PassengerNameLength > 20):
                PassengerName := CopyStr(PassengerName, 1, 20);
        end;

        TB.Append(PassengerName);
        TB.Append('E'); //Electronic Ticket Indicator
        TB.Append(TravelLegs);

        BoardingPass := TB.ToText();
    end;

    local procedure AddEmptyString(NoOfSpaces: Integer; var NewString: Text)
    var
        i: Integer;
    begin
        for i := 1 to NoOfSpaces do
            NewString += ' ';
    end;

    local procedure DateToJulianDate(CalcDate: Date) JulianDate: Code[3]
    var
        DateFormulaLbl: Label '<-CY>', Locked = true;
    begin
        JulianDate := FORMAT(CalcDate - CALCDATE(DateFormulaLbl, CalcDate) + 1);
        JulianDate := PADSTR('', 3 - strlen(JulianDate), '0') + JulianDate;
    end;

    procedure GenerateTravelLeg(FromAirportCode: Code[3]; ToAirPortCode: Code[3]; OperatorFlightNo: Code[8]; FlightDate: Date) LegString: Text;
    var
        LibraryRandom: Codeunit "Library - Random";
        TB: TextBuilder;
    begin
        //one LegString length is 37
        //2nd LegString on 61th 

        TB.Append(LibraryRandom.RandText(7)); // Operating carrier PNR Code <=7
        TB.Append(FromAirportCode); // From City Airport Code [3]
        TB.Append(ToAirPortCode); // To City Airport Code [3]
        TB.Append(OperatorFlightNo); // Flight Number [8]
        TB.Append(DateToJulianDate(FlightDate)); // Flight Date [3]
        TB.Append(LibraryRandom.RandText(1)); //Compartment Code
        TB.Append(LibraryRandom.RandText(4)); //Seat Number
        TB.Append(LibraryRandom.RandText(5)); //CheckIn Sequence Number
        TB.Append(LibraryRandom.RandText(1)); //Passenger Status
        TB.Append('00'); //Field Size of variable size field (Conditional + Airline item 4)

        LegString := TB.ToText();

    end;

    procedure GenerateFlightInfoWorkDate(var FromAirportCode: Code[3]; var ToAirPortCode: Code[3]; var OperatorFlightNo: Code[8]; var FlightDate: Date)
    var
        LibraryRandom: Codeunit "Library - Random";
    begin
        FromAirportCode := LibraryRandom.RandText(3);
        ToAirPortCode := LibraryRandom.RandText(3);
        OperatorFlightNo := LibraryRandom.RandText(8);
        FlightDate := LibraryRandom.RandDate(0);
    end;

    procedure GenerateFlightInfoNOTWorkDate(var FromAirportCode: Code[3]; var ToAirPortCode: Code[3]; var OperatorFlightNo: Code[8]; var FlightDate: Date)
    var
        LibraryRandom: Codeunit "Library - Random";
    begin
        FromAirportCode := LibraryRandom.RandText(3);
        ToAirPortCode := LibraryRandom.RandText(3);
        OperatorFlightNo := LibraryRandom.RandText(8);
        FlightDate := LibraryRandom.RandDate(1);
    end;

    procedure GenerateRand20PassengerName() PassengerName: Text;
    var
        LibraryRandom: Codeunit "Library - Random";
    begin
        //generates random Passenger Name length 20 
        PassengerName := LibraryRandom.RandText(20);
    end;

}