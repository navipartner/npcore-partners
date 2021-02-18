table 6150710 "NPR POS View"
{
    Caption = 'POS View';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS View List";
    LookupPageID = "NPR POS View List";

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

    trigger OnDelete()
    var
        DefaultView: Record "NPR POS Default View";
        DefaultViews: Page "NPR POS Default Views";
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
    begin
        if not Markup.HasValue then
            exit;

        CalcFields(Markup);
        Markup.CreateInStream(InStream);
        InStream.Read(Text);
    end;

    procedure SetMarkup(Text: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Markup);
        Markup.CreateOutStream(OutStream);
        OutStream.Write(Text);
    end;

    procedure FindViewByType(ViewType: Option; SalespersonCode: Code[20]; RegisterCode: Code[10]): Boolean
    var
        DefaultView: Record "NPR POS Default View";
        DefaultUserView: Record "NPR POS Default User View";
    begin
        // User has an overridden default view
        if DefaultUserView.GetDefault(ViewType, RegisterCode) and (DefaultUserView."POS View Code" <> '') then begin
            if Get(DefaultUserView."POS View Code") then
                exit(true);
        end;

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
    end;

    local procedure FindApplicableView(var DefaultView: Record "NPR POS Default View"): Boolean
    begin
        if not DefaultView.FindFirst() then
            exit(false);

        DefaultView.TestField("POS View Code");
        Get(DefaultView."POS View Code");
        exit(true);
    end;

    local procedure FilterApplicableView(var DefaultView: Record "NPR POS Default View"; SalespersonCode: Code[20]; RegisterCode: Code[10]): Boolean
    var
        Register: Record "NPR Register";
        Salesperson: Record "Salesperson/Purchaser";
        RegisterTemp: Record "NPR Register" temporary;
        SalespersonTemp: Record "Salesperson/Purchaser" temporary;
    begin
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
    end;
}