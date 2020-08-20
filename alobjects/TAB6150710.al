table 6150710 "POS View"
{
    // NPR5.36/VB /20170911  CASE 289188 Fixing issue with register/salesperson default selection not working.
    // NPR5.36/VB /20170912  CASE 289011 Implementing specific view layout during change view operation.

    Caption = 'POS View';
    DataClassification = CustomerContent;
    DrillDownPageID = "POS View List";
    LookupPageID = "POS View List";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; Markup; BLOB)
        {
            Caption = 'Markup';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        DefaultView: Record "POS Default View";
        DefaultViews: Page "POS Default Views";
    begin
        DefaultView.SetRange(DefaultView."POS View Code", Code);
        if not DefaultView.IsEmpty() then
            Error(Text001, TableCaption, Code, DefaultViews.Caption);
    end;

    var
        Text001: Label 'You cannot delete %1 %2 because it is currently being used as a default view. Run the %3 page to review the current configuration, then delete the view if you are still sure about it.';

    procedure GetMarkup() Text: Text
    var
        InStream: InStream;
        StreamReader: DotNet npNetStreamReader;
    begin
        if not Markup.HasValue then
            exit;

        CalcFields(Markup);
        Markup.CreateInStream(InStream);
        StreamReader := StreamReader.StreamReader(InStream);
        Text := StreamReader.ReadToEnd();
        StreamReader.Close();
    end;

    procedure SetMarkup(Text: Text)
    var
        OutStream: OutStream;
        StreamWriter: DotNet npNetStreamWriter;
    begin
        Clear(Markup);
        Markup.CreateOutStream(OutStream);
        StreamWriter := StreamWriter.StreamWriter(OutStream);
        StreamWriter.Write(Text);
        StreamWriter.Close();
    end;

    procedure FindViewByType(ViewType: Option; SalespersonCode: Code[10]; RegisterCode: Code[10]): Boolean
    var
        DefaultView: Record "POS Default View";
        DefaultUserView: Record "POS Default User View";
    begin
        //-NPR5.36 [289011]
        // User has an overridden default view
        if DefaultUserView.GetDefault(ViewType, RegisterCode) and (DefaultUserView."POS View Code" <> '') then begin
            if Get(DefaultUserView."POS View Code") then
                exit(true);
        end;
        //+NPR5.36 [289011]

        DefaultView.SetRange(Type, ViewType);
        DefaultView.SetFilter("Starting Date", '%1|<=%2', 0D, WorkDate);
        DefaultView.SetFilter("Ending Date", '%1|>=%2', 0D, WorkDate);
        case Date2DWY(WorkDate, 1) of
            1:
                DefaultView.SetRange(Monday, true);
            2:
                DefaultView.SetRange(Tuesday, true);
            3:
                DefaultView.SetRange(Wednesday, true);
            4:
                DefaultView.SetRange(Thursday, true);
            5:
                DefaultView.SetRange(Friday, true);
            6:
                DefaultView.SetRange(Saturday, true);
            7:
                DefaultView.SetRange(Sunday, true);
        end;
        if DefaultView.IsEmpty then
            exit(false);

        // Searching for the most specific view

        //-NPR5.36 [289188]
        //DefaultView.SETRANGE("Salesperson Filter",SalespersonCode);
        //DefaultView.SETRANGE("Register Filter",RegisterCode);
        //IF FindApplicableView(DefaultView) THEN
        //  EXIT(TRUE);
        //
        //DefaultView.SETFILTER("Register Filter",'<>%1','');
        //IF FilterApplicableView(DefaultView,SalespersonCode,RegisterCode) THEN
        //  EXIT(TRUE);
        //
        //DefaultView.SETFILTER("Salesperson Filter",'<>%1','');
        //IF FilterApplicableView(DefaultView,SalespersonCode,RegisterCode) THEN
        //  EXIT(TRUE);
        //
        //DefaultView.SETRANGE("Register Filter");
        //IF FilterApplicableView(DefaultView,SalespersonCode,RegisterCode) THEN
        //  EXIT(TRUE);
        //
        //DefaultView.SETRANGE("Salesperson Filter");
        //IF FilterApplicableView(DefaultView,SalespersonCode,RegisterCode) THEN
        //  EXIT(TRUE);
        //
        //EXIT(FALSE);

        // Both salesperson and register explicitly set to exact value
        if (SalespersonCode <> '') and (RegisterCode <> '') then begin
            DefaultView.SetRange("Salesperson Filter", SalespersonCode);
            DefaultView.SetRange("Register Filter", RegisterCode);
            if FindApplicableView(DefaultView) then
                exit(true);
        end;

        // Register explicitly set, salesperson not set
        if (RegisterCode <> '') then begin
            DefaultView.SetRange("Salesperson Filter", '');
            DefaultView.SetRange("Register Filter", RegisterCode);
            if FindApplicableView(DefaultView) then
                exit(true);
        end;

        // Salesperson explicitly set, register not set
        if (SalespersonCode <> '') then begin
            DefaultView.SetRange("Salesperson Filter", SalespersonCode);
            DefaultView.SetRange("Register Filter", '');
            if FindApplicableView(DefaultView) then
                exit(true);
        end;

        // Register set to a filter with salesperson explicitly set
        DefaultView.SetRange("Salesperson Filter", SalespersonCode);
        DefaultView.SetFilter("Register Filter", '<>%1', '');
        if FilterApplicableView(DefaultView, SalespersonCode, RegisterCode) then
            exit(true);

        // Salesperson set to a filter, with register explicitly set
        DefaultView.SetFilter("Salesperson Filter", '<>%1', '');
        DefaultView.SetRange("Register Filter", RegisterCode);
        if FilterApplicableView(DefaultView, SalespersonCode, RegisterCode) then
            exit(true);

        // Register set to a filter with salesperson not set
        DefaultView.SetRange("Salesperson Filter");
        DefaultView.SetFilter("Register Filter", '<>%1', '');
        if FilterApplicableView(DefaultView, SalespersonCode, RegisterCode) then
            exit(true);

        // Salesperson set to a filter, with register not set
        DefaultView.SetFilter("Salesperson Filter", '<>%1', '');
        DefaultView.SetRange("Register Filter");
        if FilterApplicableView(DefaultView, SalespersonCode, RegisterCode) then
            exit(true);

        // Any other combination
        DefaultView.SetRange("Register Filter");
        DefaultView.SetRange("Salesperson Filter");
        if FilterApplicableView(DefaultView, SalespersonCode, RegisterCode) then
            exit(true);

        exit(false);
        //+NPR5.36 [289188]
    end;

    local procedure FindApplicableView(var DefaultView: Record "POS Default View"): Boolean
    begin
        if not DefaultView.FindFirst() then
            exit(false);

        DefaultView.TestField("POS View Code");
        Get(DefaultView."POS View Code");
        exit(true);
    end;

    local procedure FilterApplicableView(var DefaultView: Record "POS Default View"; SalespersonCode: Code[10]; RegisterCode: Code[10]): Boolean
    var
        Register: Record Register;
        Salesperson: Record "Salesperson/Purchaser";
        RegisterTemp: Record Register temporary;
        SalespersonTemp: Record "Salesperson/Purchaser" temporary;
    begin
        //-NPR5.36 [289188]
        //IF RegisterCode <> '' THEN BEGIN
        //  Register.FILTERGROUP(2);
        //  Register.SETRANGE("Register No.",RegisterCode);
        //  Register.FILTERGROUP(0);
        //END;
        //
        //IF SalespersonCode <> '' THEN BEGIN
        //  Salesperson.FILTERGROUP(2);
        //  Salesperson.SETRANGE(Code,SalespersonCode);
        //  Salesperson.FILTERGROUP(0);
        //END;
        //
        //IF DefaultView.FINDSET THEN
        //  REPEAT
        //    Register.RESET();
        //    Salesperson.RESET();
        //
        //    IF DefaultView."Register Filter" <> '' THEN
        //      Register.SETFILTER("Register No.",DefaultView."Register Filter");
        //    IF DefaultView."Salesperson Filter" <> '' THEN
        //      Salesperson.SETFILTER(Code,DefaultView."Salesperson Filter");
        //
        //    IF (NOT Register.ISEMPTY) AND (NOT Salesperson.ISEMPTY) THEN BEGIN
        //      DefaultView.TESTFIELD("POS View Code");
        //      GET(DefaultView."POS View Code");
        //      EXIT(TRUE);
        //    END;
        //  UNTIL DefaultView.NEXT = 0;

        if RegisterCode <> '' then begin
            if Register.Get(RegisterCode) then begin
                RegisterTemp := Register;
                RegisterTemp.Insert;
            end;
        end;

        if SalespersonCode <> '' then begin
            if Salesperson.Get(SalespersonCode) then begin
                SalespersonTemp := Salesperson;
                SalespersonTemp.Insert;
            end;
        end;

        if DefaultView.FindSet then
            repeat
                if DefaultView."Register Filter" <> '' then
                    RegisterTemp.SetFilter("Register No.", DefaultView."Register Filter");
                if DefaultView."Salesperson Filter" <> '' then
                    SalespersonTemp.SetFilter(Code, DefaultView."Salesperson Filter");

                if ((not RegisterTemp.IsEmpty) or (RegisterCode = '')) and ((not SalespersonTemp.IsEmpty) or (SalespersonCode = '')) then begin
                    DefaultView.TestField("POS View Code");
                    Get(DefaultView."POS View Code");
                    exit(true);
                end;
            until DefaultView.Next = 0;
        //+NPR5.36 [289188]
    end;
}

