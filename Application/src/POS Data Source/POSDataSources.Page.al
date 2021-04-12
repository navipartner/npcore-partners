page 6150708 "NPR POS Data Sources"
{
    Caption = 'POS Data Sources';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Data Source Discovery";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Rec.DiscoverDataSources();
        if DataSource <> '' then begin
            Rec.Name := DataSource;
            if not Rec.Find() then
                DataSource := '';
        end;
        if DataSource = '' then
            if Rec.FindFirst() then;
    end;

    var
        DataSource: Code[50];

    procedure SetCurrent(DataSourceIn: Code[50])
    begin
        DataSource := DataSourceIn;
    end;

    procedure GetCurrent(): Code[50]
    begin
        exit(Rec.Name);
    end;
}

