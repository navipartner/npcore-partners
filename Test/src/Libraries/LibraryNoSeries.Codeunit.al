codeunit 85045 "NPR Library - No. Series"
{
    //Generate an actually random no. series.

    procedure GenerateNoSeries(): Code[20]
    begin
        exit(GenerateNoSeries(''));
    end;

    procedure GenerateNoSeries(Prefix: Code[2]): Code[20]
    var
        NoSeries: Record "No. Series";
    begin
        GenerateNoSeries(Prefix, NoSeries);
        exit(NoSeries.Code);
    end;

    procedure GenerateNoSeries(Prefix: Code[2]; var NoSeries: Record "No. Series")
    var
        NoSeriesLine: Record "No. Series Line";
        LibraryRandom: Codeunit "Library - Random";
    begin
        NoSeries.Init();
        NoSeries.Code := LibraryRandom.RandText(20);
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := false;
        NoSeries."Date Order" := false;
        NoSeries.Insert();

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Starting No." := Prefix + GenerateRandomNumberString(18 - StrLen(Prefix));
        NoSeriesLine.Open := true;
        NoSeriesLine.Insert();
    end;

    procedure GenerateRandomNumberString(MaxLength: Integer): Text
    var
        StringBuilder: TextBuilder;
        i: Integer;
    begin
        if (MaxLength < 1) or (MaxLength > 18) then
            Error('Invalid input');

        for i := 1 to Random(MaxLength) do begin
            StringBuilder.Append(Format(Random(10) - 1));
        end;

        exit(StringBuilder.ToText());
    end;
}