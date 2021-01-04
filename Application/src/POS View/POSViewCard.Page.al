page 6150711 "NPR POS View Card"
{
    Caption = 'POS View Card';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR POS View";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
            usercontrol(Editor; "NPR JsonEditor")
            {
                ApplicationArea = All;
                trigger OnControlReady();
                begin
                    CurrPage.Editor.Invoke('setJson', GetMarkup());
                    Initialized := true;
                end;

                trigger OnEvent(Method: Text; EventContent: Text);
                begin
                    case Method of
                        'save':
                            begin
                                if (format(EventContent) = '{}') then
                                    eventContent := '';
                                SetMarkup(EventContent);
                                CurrPage.SaveRecord();
                            end;
                        'retrieve':
                            begin
                                RetrieveAutoCompleteOptions(EventContent);
                            end;
                    end;
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        if not Initialized then
            exit;

        CurrPage.Editor.Invoke('setJson', GetMarkup());
    end;

    trigger OnAfterGetRecord()
    begin
        if not Initialized then
            exit;

        CurrPage.Editor.Invoke('setJson', GetMarkup());
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if not Initialized then
            exit;

        CurrPage.Editor.Invoke('setJson', '');
    end;

    procedure RetrieveAutoCompleteOptions(OptionsType: Text);
    var
        Menu: record "NPR POS Menu";
        DataSourceTemp: Record "NPR POS Data Source Discovery" temporary;
        Options: JsonArray;
        OptionsText: Text;
    begin
        case OptionsType of
            'menu':
                begin
                    if Menu.FindSet() then
                        repeat
                            Options.Add(Menu.Code);
                        until Menu.Next() = 0;
                end;

            'dataSource':
                begin
                    DataSourceTemp.DiscoverDataSources();
                    if DataSourceTemp.FindSet() then
                        repeat
                            Options.Add(DataSourceTemp.Name);
                        until DataSourceTemp.Next() = 0;
                end;
        end;

        Options.AsToken().WriteTo(OptionsText);

        CurrPage.Editor.Invoke('autocomplete_' + OptionsType, OptionsText);
    end;

    var
        Initialized: Boolean;
}

