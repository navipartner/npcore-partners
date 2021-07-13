page 6150708 "NPR POS Data Sources"
{
    Caption = 'POS Data Sources';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Data Source Discovery";
    SourceTableTemporary = true;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
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

