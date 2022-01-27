page 6150711 "NPR POS View Card"
{
    Extensible = False;
    Caption = 'POS View Card';
    PageType = Card;
    SourceTable = "NPR POS View";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
            usercontrol(Editor; "NPR JsonEditor")
            {
                ApplicationArea = NPRRetail;

                trigger OnControlReady();
                begin
                    CurrPage.Editor.Invoke('setJson', Rec.GetMarkup());
                    Initialized := true;
                end;

                trigger OnEvent(Method: Text; EventContent: Text);
                begin
                    case Method of
                        'save':
                            begin
                                if (format(EventContent) = '{}') then
                                    eventContent := '';
                                Rec.SetMarkup(EventContent);
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

    trigger OnAfterGetCurrRecord()
    begin
        if not Initialized then
            exit;

        CurrPage.Editor.Invoke('setJson', Rec.GetMarkup());
    end;

    trigger OnAfterGetRecord()
    begin
        if not Initialized then
            exit;

        CurrPage.Editor.Invoke('setJson', Rec.GetMarkup());
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
        TempDataSource: Record "NPR POS Data Source Discovery" temporary;
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
                    TempDataSource.DiscoverDataSources();
                    if TempDataSource.FindSet() then
                        repeat
                            Options.Add(TempDataSource.Name);
                        until TempDataSource.Next() = 0;
                end;
        end;

        Options.AsToken().WriteTo(OptionsText);

        CurrPage.Editor.Invoke('autocomplete_' + OptionsType, OptionsText);
    end;

    var
        Initialized: Boolean;
}
