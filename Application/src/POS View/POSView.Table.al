table 6150710 "NPR POS View"
{
    Access = Internal;
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
        if not Markup.HasValue() then
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

    [Obsolete('Replaced with same function without SalespersonCode. Salesperson is not used anymore on Default View filtering. Case 508848.')]
    procedure FindViewByType(ViewType: Option; SalespersonCode: Code[20]; RegisterCode: Code[10]): Boolean
    begin
        exit(FindViewByType(ViewType, RegisterCode));
    end;

    procedure FindViewByType(ViewType: Option; RegisterCode: Code[10]): Boolean
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
        if DefaultView.IsEmpty then
            exit(false);

        // Register explicitly set to exact value
        if (RegisterCode <> '') then begin
            DefaultView.SetRange("Register Filter", RegisterCode);
            if FindApplicableView(DefaultView) then
                exit(true);
        end;

        // Register set to a filter
        DefaultView.SetFilter("Register Filter", '<>%1', '');
        if FilterApplicableView(DefaultView, RegisterCode) then
            exit(GetApplicableView(DefaultView));

        // Any other combination
        DefaultView.SetRange("Register Filter", '');
        if DefaultView.FindFirst() then
            exit(GetApplicableView(DefaultView));

        exit(false);
    end;

    local procedure FindApplicableView(var DefaultView: Record "NPR POS Default View"): Boolean
    begin
        if not DefaultView.FindFirst() then
            exit(false);

        exit(GetApplicableView(DefaultView));
    end;

    local procedure FilterApplicableView(var DefaultView: Record "NPR POS Default View"; UnitCode: Code[10]): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        TempPOSUnit: Record "NPR POS Unit" temporary;
    begin
        if POSUnit.Get(UnitCode) then begin
            TempPOSUnit.TransferFields(POSUnit);
            TempPOSUnit.Insert();
        end;

        if DefaultView.FindSet() then
            repeat
                TempPOSUnit.SetFilter("No.", DefaultView."Register Filter");
                if not TempPOSUnit.IsEmpty() then
                    exit(true);
            until DefaultView.Next() = 0;

        exit(false);
    end;

    local procedure GetApplicableView(var DefaultView: Record "NPR POS Default View"): Boolean
    begin
        DefaultView.TestField("POS View Code");
        Get(DefaultView."POS View Code");
        exit(true);
    end;
}
