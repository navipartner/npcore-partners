table 6014454 "Shoe Shelves"
{
    // NPR5.38/MHA /20180104  CASE 301054 Removed non-existing Page6060076 from LookupPageID and DrillDownPageID

    Caption = 'Shoe Shelves';

    fields
    {
        field(1;Location;Code[10])
        {
            Caption = 'Location';
            TableRelation = Location.Code;
        }
        field(2;"No.";Code[10])
        {
            Caption = 'No.';
        }
        field(3;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(4;shelve;Code[20])
        {
            Caption = 'Shelve';
            TableRelation = "No. Series";
        }
        field(5;ID;Code[10])
        {
            Caption = 'ID';
            TableRelation = "No. Series";
        }
        field(6;"Show Item No.";Boolean)
        {
            Caption = 'Show Item No.';
        }
    }

    keys
    {
        key(Key1;Location,"No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure NewPlacement(Item: Record Item) Placement: Code[10]
    var
        shelveRelation: Record "Shelves / Item Grp. Relation";
        Shelve: Record "Shoe Shelves";
        "item group": Record "Item Group";
        "No. series": Record "No. Series";
        MgtNoSeries: Codeunit NoSeriesManagement;
        newNumber: Code[20];
    begin
        if Item."Item Group" <> '' then begin
          shelveRelation.SetRange(shelveRelation.Type, shelveRelation.Type::"Item Group");
          shelveRelation.SetRange(shelveRelation."No.",Item."Item Group");
          if not shelveRelation.Find('-') then begin
            "item group".Get(Item."Item Group");
            shelveRelation.SetRange(shelveRelation."No.","item group"."Parent Item Group No.");
            if not shelveRelation.Find('-') then begin
              "item group".Get("item group"."Parent Item Group No.");
              shelveRelation.SetRange(shelveRelation."No.","item group"."Parent Item Group No.");
              if not shelveRelation.Find('-') then
                Error('Der findes ikke en reol til varegruppe %1',Item."Item Group");
            end;
          end;
          Shelve.SetRange("No.", shelveRelation.Shelve);
          Shelve.SetRange(Location, shelveRelation.Location);
          "No. series".SetRange("No. series".Code, Shelve.shelve);
          if Shelve.Find('-') then begin
            MgtNoSeries.InitSeries(Shelve.ID, '', Today,newNumber, Shelve.ID);
            Placement := Shelve."No."+'-'+padstr2(newNumber,4,'0');
            exit(Placement);
          end else
            Error('Fejl i opsætning af reoler!');
        end;
    end;

    procedure padstr2(str: Code[10];lenght: Integer;padString: Code[1]) outStr: Code[10]
    var
        i: Integer;
    begin
        outStr := str;
        for i := StrLen(Format(str)) to lenght-1 do
          outStr := padString+outStr;
    end;

    procedure CreateShelvesFromPlacement()
    var
        "shelf group": Code[3];
        currentMax: Integer;
        MgtNoSeries: Codeunit NoSeriesManagement;
        noSeries1: Record "No. Series";
        noSeriesLine1: Record "No. Series Line";
        noSeries2: Record "No. Series";
        noSeriesLine2: Record "No. Series Line";
        shelvesRelation: Record "Shelves / Item Grp. Relation";
        shelves: Record "Shoe Shelves";
        NoShelfNoCounter: Integer;
        ShelfCreatedCounter: Integer;
        Progress: Integer;
        TotalCount: Integer;
        CurrCount: Integer;
        UpdateGear: Integer;
        d: Dialog;
        OpenFormProgressText: Text[30];
        "filter": Code[10];
        pos: Integer;
        currentNo: Integer;
        item2: Record Item;
        item: Record Item;
    begin
        noSeries1.SetFilter(Code, 'SKO-*');
        if Confirm(StrSubstNo('Dette vil fjerne %1 nummerserier',noSeries1.Count),true) then
          noSeries1.DeleteAll(true)
        else exit;
        shelves.DeleteAll(true);
        shelvesRelation.DeleteAll(true);
        
        if item.Find('-') then repeat
          TotalCount := item.Count;
          CurrCount := 1;
          UpdateGear := 1;
        
          d.Open(OpenFormProgressText + '\' +
               '@1@@@@@@@@@@@@@@@@@@',Progress);
        
          pos := StrPos(item."Shelf No.", '-');
          if pos > 0 then
            "shelf group" := CopyStr(item."Shelf No.", 1, pos-1)
          else
            NoShelfNoCounter += 1;
        
          Progress := Round(( 9999 / TotalCount) * CurrCount, 1 ,'=');
          if UpdateGear > 10 then begin
            d.Update();
            UpdateGear := 1;
          end;
          CurrCount += 1;
          UpdateGear += 1;
        
          noSeries1.SetRange(Code,'SKO-'+"shelf group");
          if not noSeries1.Find('-') then begin
            filter := StrSubstNo('%1-*',"shelf group");
            item2.SetFilter(item2."Shelf No.", filter);
            currentMax := 0;
            if item2.Find('-') then repeat
              pos := StrPos(item."Shelf No.", '-');
              if not Evaluate(currentNo, CopyStr(item."Shelf No.", pos+1)) then Error('error: %1',item."Shelf No.");
              if (currentMax < currentNo) then currentMax := currentNo;
            until item2.Next = 0;
        
          /** Create no. series for this item group **/
            noSeries1.Init();
            noSeries1.Code := 'SKO-'+"shelf group";
            noSeries1.Description := 'Placeringsnummer til varegruppe '+"shelf group";
            noSeriesLine1.Init();
            noSeriesLine1."Series Code" := noSeries1.Code;
            noSeriesLine1."Starting Date" := Today;
            noSeriesLine1."Starting No." := '0';
            noSeriesLine1."Ending No." := '9999';
            noSeries1."Default Nos." := true;
            noSeriesLine1."Increment-by No." := 1;
            noSeriesLine1.Open := true;
        
             noSeries2.Init();
            noSeries2.Code := 'SKO-'+"shelf group"+'ID';
            noSeries2.Description := 'Placeringsnummer til varegruppe '+"shelf group";
            noSeriesLine2.Init();
            noSeriesLine2."Series Code" := noSeries2.Code;
            noSeriesLine2."Starting Date" := Today;
            noSeriesLine2."Starting No." := '0';
            noSeriesLine2."Ending No." := '9999';
            noSeries2."Default Nos." := true;
            noSeriesLine2."Increment-by No." := 1;
            noSeriesLine2.Open := true;
        
            if noSeries1.Insert(true) then
              if noSeriesLine1.Insert(true) then begin end
            else begin
              noSeries1.Modify(true);
              noSeriesLine1.Modify(true);
            end;
        
            if noSeries2.Insert(true) then
              if noSeriesLine2.Insert(true) then begin
              end
            else begin
              noSeries2.Modify(true);
              noSeriesLine2.Modify(true);
           end;
          /** A small hack to make sure the "last no. used" gets set **/
            noSeriesLine1."Last No. Used" := Format(currentMax);
            noSeriesLine1.Modify(true);
        
          /** Create relation to shelves **/
            shelvesRelation.Init();
            shelvesRelation.Location := '1';
            shelvesRelation.Shelve := "shelf group";
            shelvesRelation.Type := shelvesRelation.Type::"Item Group";
            shelvesRelation."No." := "shelf group";
            if not shelvesRelation.Insert(true) then
              shelvesRelation.Modify(true);
        
          /** Create Shelve **/
            shelves.Location := '1';
            shelves."No." := "shelf group";
            shelves.Description := 'Reol '+"shelf group";
            shelves.shelve := noSeries1.Code;
            shelves.ID := noSeries2.Code;
            if not shelves.Insert(true) then
               shelves.Modify(true);
        
          /** Status **/
            ShelfCreatedCounter += 1;
          end;
        until item.Next = 0;
        Message('K¢rsel afsluttet.\Der blev oprettet %1 nye hylder\Der er %2 varer uden placeringsnummer',
        ShelfCreatedCounter,NoShelfNoCounter);

    end;

    procedure CreateShelves()
    var
        itemGroup: Record "Item Group";
        MgtNoSeries: Codeunit NoSeriesManagement;
        noSeries1: Record "No. Series";
        noSeriesLine1: Record "No. Series Line";
        noSeries2: Record "No. Series";
        noSeriesLine2: Record "No. Series Line";
        shelvesRelation: Record "Shelves / Item Grp. Relation";
        shelves: Record "Shoe Shelves";
        NoShelfNoCounter: Integer;
        ShelfCreatedCounter: Integer;
        Progress: Integer;
        TotalCount: Integer;
        CurrCount: Integer;
        UpdateGear: Integer;
        d: Dialog;
        OpenFormProgressText: Text[30];
        item: Record Item;
        "filter": Code[10];
        currentMax: Integer;
        pos: Integer;
        currentNo: Integer;
    begin
        noSeries1.SetFilter(Code, 'SKO-*');
        if Confirm(StrSubstNo('Dette vil fjerne %1 nummerserier',noSeries1.Count),true) then
          noSeries1.DeleteAll(true)
        else exit;
        shelves.DeleteAll(true);
        shelvesRelation.DeleteAll(true);
        
        TotalCount := itemGroup.Count;
        CurrCount := 1;
        UpdateGear := 1;
        d.Open(OpenFormProgressText + '\' +
             '@1@@@@@@@@@@@@@@@@@@',Progress);
        
        if itemGroup.Find('-') then repeat
        
          Progress := Round(( 9999 / TotalCount) * CurrCount, 1 ,'=');
          if UpdateGear > 10 then begin
            d.Update();
            UpdateGear := 1;
          end;
          CurrCount += 1;
          UpdateGear += 1;
        
        /** We only want the item groups with 2 digits **/
          if StrLen(itemGroup."No.") = 2 then begin
          /** Find the highest number used in the number series **/
            item.SetRange("Item Group", itemGroup."No.");
            filter := StrSubstNo('%1-*',itemGroup."No.");
            item.SetFilter(item."Shelf No.", filter);
            currentMax := 0;
            if item.Find('-') then repeat
              pos := StrPos(item."Shelf No.", '-');
              if not Evaluate(currentNo, CopyStr(item."Shelf No.", pos+1)) then Error('error: %1',item."Shelf No.");
              if (currentMax < currentNo) then currentMax := currentNo;
            until item.Next = 0;
        
          /** Create no. series for this item group **/
            noSeries1.Init();
            noSeries1.Code := 'SKO-'+itemGroup."No.";
            noSeries1.Description := 'Placeringsnummer til varegruppe '+itemGroup."No.";
            noSeriesLine1.Init();
            noSeriesLine1."Series Code" := noSeries1.Code;
            noSeriesLine1."Starting Date" := Today;
            noSeriesLine1."Starting No." := '0';
            noSeriesLine1."Ending No." := '9999';
            noSeries1."Default Nos." := true;
            noSeriesLine1."Increment-by No." := 1;
            noSeriesLine1.Open := true;
        
            noSeries2.Init();
            noSeries2.Code := 'SKO-'+itemGroup."No."+'ID';
            noSeries2.Description := 'Placeringsnummer til varegruppe '+itemGroup."No.";
            noSeriesLine2.Init();
            noSeriesLine2."Series Code" := noSeries2.Code;
            noSeriesLine2."Starting Date" := Today;
            noSeriesLine2."Starting No." := '0';
            noSeriesLine2."Ending No." := '9999';
            noSeries2."Default Nos." := true;
            noSeriesLine2."Increment-by No." := 1;
            noSeriesLine2.Open := true;
        
            if noSeries1.Insert(true) then
              if noSeriesLine1.Insert(true) then begin end
            else begin
              noSeries1.Modify(true);
              noSeriesLine1.Modify(true);
            end;
        
            if noSeries2.Insert(true) then
              if noSeriesLine2.Insert(true) then begin
              end
            else begin
              noSeries2.Modify(true);
              noSeriesLine2.Modify(true);
           end;
          /** A small hack to make sure the "last no. used" gets set **/
            noSeriesLine1."Last No. Used" := Format(currentMax);
            noSeriesLine1.Modify(true);
        
          /** Create relation to shelves **/
            shelvesRelation.Init();
            shelvesRelation.Location := '1';
            shelvesRelation.Shelve := itemGroup."No.";
            shelvesRelation.Type := shelvesRelation.Type::"Item Group";
            shelvesRelation."No." := itemGroup."No.";
            if not shelvesRelation.Insert(true) then
              shelvesRelation.Modify(true);
        
          /** Create Shelve **/
            shelves.Location := '1';
            shelves."No." := itemGroup."No.";
            shelves.Description := 'Reol '+itemGroup."No.";
            shelves.shelve := noSeries1.Code;
            shelves.ID := noSeries2.Code;
            if not shelves.Insert(true) then
               shelves.Modify(true);
        
          /** Status **/
            ShelfCreatedCounter += 1;
          end;
        
        until itemGroup.Next = 0;
        Message('K¢rsel afsluttet.\Der blev oprettet %1 nye hylder',
        ShelfCreatedCounter);

    end;
}

