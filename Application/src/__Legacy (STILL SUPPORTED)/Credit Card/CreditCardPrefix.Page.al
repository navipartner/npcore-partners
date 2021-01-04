page 6014488 "NPR Credit Card Prefix"
{
    // NPR5.41/TS  /20180105 CASE 300893 Renamed Function Prefix to Show Prefix

    Caption = 'Credit Card Prefix';
    SourceTable = "NPR Payment Type - Prefix";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Prefix; Prefix)
                {
                    ApplicationArea = All;
                    Visible = Prefixvi;
                    ToolTip = 'Specifies the value of the Prefix field';
                }
                field(Weight; Weight)
                {
                    ApplicationArea = All;
                    Visible = weightvi;
                    ToolTip = 'Specifies the value of the Weight field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Prefixvi := show_prefix;
        Weightvi := show_weight;
    end;

    var
        show_prefix: Boolean;
        show_weight: Boolean;
        [InDataSet]
        Prefixvi: Boolean;
        [InDataSet]
        Weightvi: Boolean;

    procedure ShowPrefix()
    begin
        show_prefix := true;
        show_weight := false;
    end;

    procedure weights()
    begin
        show_weight := true;
        show_prefix := false;
    end;
}

