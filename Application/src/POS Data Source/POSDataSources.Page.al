page 6150708 "NPR POS Data Sources"
{
    Extensible = False;
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

    trigger OnOpenPage()
    begin
        Rec.DiscoverDataSources();
        if DataSourceFilter <> '' then begin
            Rec.FilterGroup(2);
            Rec.SetFilter(Name, DataSourceFilter);
            Rec.FilterGroup(0);
        end;
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
        DataSourceFilter: Text;

    internal procedure SetSupportedDataSourceFilter(DataSourceFilterIn: Text)
    begin
        DataSourceFilter := DataSourceFilterIn;
    end;

    internal procedure SetCurrent(DataSourceIn: Code[50])
    begin
        DataSource := DataSourceIn;
    end;

    internal procedure GetCurrent(): Code[50]
    begin
        exit(Rec.Name);
    end;
}
