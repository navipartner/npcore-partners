page 6014488 "Credit Card Prefix"
{
    // NPR5.41/TS  /20180105 CASE 300893 Renamed Function Prefix to Show Prefix

    Caption = 'Credit Card Prefix';
    SourceTable = "Payment Type - Prefix";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Prefix;Prefix)
                {
                    Visible = Prefixvi;
                }
                field(Weight;Weight)
                {
                    Visible = weightvi;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Prefixvi:=show_prefix;
        Weightvi:=show_weight;
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

