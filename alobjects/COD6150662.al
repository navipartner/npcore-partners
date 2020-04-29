codeunit 6150662 "NPRE Seating Management"
{
    // NPR5.34/ANEN  /2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.41/THRO /20180412 CASE 309869 Added filter parameters to UILookUpSeating
    // NPR5.50/TJ   /20190502 CASE 346384 Setting additional filters for seating


    trigger OnRun()
    begin
    end;

    var
        AdditionalFiltersSet: Boolean;
        SeatingFiltersGlobal: Record "NPRE Seating";

    procedure GetSeatingDescription(SeatingCode: Code[20]) SeatingDescription: Text
    var
        Seating: Record "NPRE Seating";
    begin
        SeatingDescription := '';
        Seating.Reset;
        Seating.SetRange(Code, SeatingCode);
        if not Seating.IsEmpty then begin
          Seating.FindFirst;
          SeatingDescription := Seating.Description;
        end;
    end;

    procedure UILookUpSeating(SeatingCodeFilter: Text;SeatingLocationFilter: Text) SeatingCode: Code[20]
    var
        Seating: Record "NPRE Seating";
        SeatingList: Page "NPRE Seating List";
    begin
        SeatingCode := '';

        Seating.Reset;
        //-NPR5.50 [346384]
        if AdditionalFiltersSet then
          Seating.CopyFilters(SeatingFiltersGlobal);
        //+NPR5.50 [346384]
        //-NPR5.41 [309869]
        if SeatingCodeFilter <> '' then
          Seating.SetFilter(Code,SeatingCodeFilter);
        if SeatingLocationFilter <> '' then
          Seating.SetFilter("Seating Location",SeatingLocationFilter);
        //+NPR5.41 [309869]
        SeatingList.SetTableView(Seating);
        SeatingList.LookupMode := true;
        if SeatingList.RunModal = ACTION::LookupOK then begin
          SeatingList.GetRecord(Seating);
          SeatingCode := Seating.Code;
        end;


        exit(SeatingCode);
    end;

    procedure SetAddSeatingFilters(var SeatingHere: Record "NPRE Seating")
    begin
        //-NPR5.50 [346384]
        SeatingFiltersGlobal.CopyFilters(SeatingHere);
        AdditionalFiltersSet := true;
        //+NPR5.50 [346384]
    end;
}

